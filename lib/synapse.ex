defmodule ExMatrixApi.Synapse do
  @moduledoc """
  API level to make requests to Matrix Synapse.
  """

  alias ExMatrixApi.Synapse.Rooms.{Timeline, Event, InviteState, Member}
  alias ExMatrixApi.Synapse.RegisteredUser
  alias ExMatrixApi.Util
  alias ExMatrixApi.Util.{Request, UUID}
  alias UtilsHttp.Behaviour.HttpClient.HttpError

  @doc """
  Get authorization token by login / password.
  """
  @spec get_token(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def get_token(user, password) do
    login_url = api_url!("/login")

    with {:ok, %{"flows" => [%{"type" => type}]}} <- Request.get(login_url),
         payload = %{type: type, user: user, password: password},
         {:ok, %{"access_token" => access_token}} <- Request.post(login_url, payload) do
      {:ok, access_token}
    end
  end

  @doc """
  Check if synapse allowing to register specific username.
  """
  @spec is_username_available?(String.t()) :: {:ok, boolean()} | {:error, any()}
  def is_username_available?(username) do
    username_check_url = api_url!("/register/available?username=#{username}")

    with {:ok, %{"available" => available}} <- Request.get(username_check_url) do
      {:ok, available}
    end
  end

  @doc """
  Register new user on Matrix synapse.
  """
  @spec register(String.t(), String.t(), map()) :: {:ok, RegisteredUser.t()} | {:error, any()}
  def register(username, password, params \\ %{}) do
    # api_url!("/register")
    register_url = api_url!("/admin/register")
    payload = Map.merge(params, %{username: username, password: password})
    key = config!(:registration_secret)

    with {:ok, %{"nonce" => nonce}} <- Request.get(register_url),
         token = "#{nonce}\x00#{username}\x00#{password}\x00notadmin",
         mac = :crypto.hmac(:sha, key, token) |> Base.encode16(case: :lower),
         payload = Map.merge(payload, %{nonce: nonce, mac: mac}),
         {:ok, response} <- Request.post(register_url, payload) do
      {:ok, Util.to_struct(RegisteredUser, response)}
    end
  end

  @doc """
  Update specific field of user's data, currently supported
  only for display name and avatar.
  """
  @spec update_user(String.t(), String.t(), :name | :avatar, String.t()) :: :ok | {:error, any()}
  def update_user(token, user_id, :name, new_name) do
    update_user_url = api_url!("/profile/#{user_id}/displayname")
    headers = auth_headers(token)
    payload = %{"displayname" => new_name}

    with {:ok, _} <- Request.put(update_user_url, payload, headers) do
      :ok
    end
  end

  def update_user(token, user_id, :avatar, avatar_url) do
    update_user_url = api_url!("/profile/#{user_id}/avatar_url")
    headers = auth_headers(token)
    payload = %{"avatar_url" => avatar_url}

    with {:ok, _} <- Request.put(update_user_url, payload, headers) do
      :ok
    end
  end

  @doc """
  Update display name, avatar or password.
  """
  @spec update_user(String.t(), :password, String.t(), String.t(), String.t()) ::
          :ok | {:error, any()}
  def update_user(token, :password, user_id, old_password, new_password) do
    update_user_url = api_url!("/account/password")
    headers = auth_headers(token)
    payload = %{"new_password" => new_password}

    with {:error, %{data: %{"session" => session, "flows" => [%{"stages" => [type]}]}}} <-
           Request.post(update_user_url, payload, headers),
         payload =
           Map.put(payload, "auth", %{
             session: session,
             type: type,
             user: user_id,
             password: old_password
           }),
         {:ok, _} <- Request.post(update_user_url, payload, headers) do
      :ok
    end
  end

  @doc """
  Upload file and return mxc:// URI of the uploaded asset.
  """
  @spec upload_media(String.t(), String.t(), binary(), String.t() | nil) ::
          {:ok, String.t()} | {:error, any()}
  def upload_media(token, content_type, bin, filename \\ nil) do
    upload_url =
      if is_nil(filename),
        do: media_api_url!("/upload"),
        else: media_api_url!("/upload?" <> URI.encode_query(%{filename: filename}))

    headers = [{"Content-Type", content_type} | auth_headers(token)]

    with {:ok, %{"content_uri" => content_uri}} <- Request.post(upload_url, bin, headers) do
      {:ok, content_uri}
    end
  end

  @doc """
  Convert mxc URI into http URL for display.
  """
  @spec thumbnail(String.t(), integer(), integer()) :: String.t()
  def thumbnail("mxc://" <> path, width, height) do
    media_id = String.split(path, "/") |> List.last()
    query = URI.encode_query(%{width: width, height: height})
    media_api_url!("/thumbnail/#{config!(:host)}/#{media_id}?#{query}")
  end

  @doc """
  Convert mxc URI into http URL for download
  """
  @spec download(String.t()) :: String.t()
  def download("mxc://" <> path) do
    media_id = String.split(path, "/") |> List.last()
    media_api_url!("/download/#{config!(:host)}/#{media_id}")
  end

  @type timelines :: %{String.t() => Timeline.t()}
  @type invites :: %{String.t() => InviteState.t()}

  @doc """
  Get major user data in scope synapse.
  """
  @spec sync(String.t(), map()) :: {:ok, timelines, invites} | {:error, any()}
  def sync(token, params \\ %{}) do
    rooms_url = api_url!("/sync?#{URI.encode_query(params)}")
    headers = auth_headers(token)

    with {:ok,
          %{
            "next_batch" => next_batch,
            "rooms" => %{"join" => joined_rooms, "invite" => invited_rooms}
          }} <- Request.get(rooms_url, headers) do
      room_event_batch =
        for {key,
             %{
               "state" => %{
                 "events" => raw_state_events
               },
               "timeline" => %{
                 "events" => raw_events,
                 "prev_batch" => batch_ref,
                 "limited" => limited
               }
             }} <- joined_rooms do
          relevant_state_events =
            Enum.filter(raw_state_events, &Event.is_state_event?(Map.get(&1, "type")))

          relevant_raw_events =
            Enum.filter(raw_events, &Event.is_supported_type?(Map.get(&1, "type")))

          events = Enum.map(relevant_raw_events, &Util.to_struct(Event, &1))
          state_events = Enum.map(relevant_state_events, &Util.to_struct(Event, &1))

          timeline = %Timeline{
            uid: key,
            events: events,
            state_events: state_events,
            limited: limited,
            prev_batch: batch_ref,
            next_batch: next_batch
          }

          {key, timeline}
        end

      invite_event_batch =
        for {key, %{"invite_state" => %{"events" => raw_events}}} <- invited_rooms do
          relevant_raw_events =
            Enum.filter(raw_events, &Event.is_supported_type?(Map.get(&1, "type")))

          events = Enum.map(relevant_raw_events, &Util.to_struct(Event, &1))

          invite_state = %InviteState{
            uid: key,
            events: events
          }

          {key, invite_state}
        end

      {:ok, Enum.into(room_event_batch, %{}), Enum.into(invite_event_batch, %{})}
    end
  end

  @doc """
  Create new room for user's conversation.
  """
  @spec create_room(String.t(), map()) :: {:ok, String.t()} | {:error, any()}
  def create_room(token, payload) do
    room_creation_url = api_url!("/createRoom")
    headers = auth_headers(token)

    with {:ok, %{"room_id" => room_id}} <- Request.post(room_creation_url, payload, headers) do
      {:ok, room_id}
    end
  end

  @doc """
  Change room state, by executing state event.
  """
  @spec update_room_state(String.t(), String.t(), String.t(), map(), String.t()) ::
          {:ok, String.t()} | {:error, any()}
  def update_room_state(token, room_id, event_type, payload \\ %{}, state_key \\ "") do
    room_update_url = api_url!("/rooms/#{room_id}/state/#{event_type}/#{state_key}")
    headers = auth_headers(token)

    with {:ok, %{"event_id" => event_id}} <- Request.put(room_update_url, payload, headers) do
      {:ok, event_id}
    end
  end

  @doc """
  Join room by accepting invite.
  """
  @spec join_invited_room(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def join_invited_room(token, room_uid) do
    room_join_url = api_url!("/join/#{room_uid}")
    headers = auth_headers(token)

    with {:ok, %{"room_id" => room_id}} <- Request.post(room_join_url, %{}, headers) do
      {:ok, room_id}
    end
  end

  @doc """
  Decline invite to join room.
  """
  @spec forget_invited_room(String.t(), String.t()) :: :ok | {:error, any()}
  def forget_invited_room(token, room_uid) do
    decline_invite_url = api_url!("/rooms/#{room_uid}/forget")
    headers = auth_headers(token)

    with {:ok, _} <- Request.post(decline_invite_url, %{}, headers) do
      :ok
    end
  end

  @doc """
  Leave room.
  """
  @spec leave_room(String.t(), String.t()) :: :ok | {:error, any()}
  def leave_room(token, room_uid) do
    leave_room_url = api_url!("/rooms/#{room_uid}/leave")
    headers = auth_headers(token)

    with {:ok, _} <- Request.post(leave_room_url, %{}, headers) do
      :ok
    end
  end

  @doc """
  Get secure room id from it's alias.
  """
  @spec room_id_by_alias(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def room_id_by_alias(token, room_alias) do
    room_url = api_url!("/directory/room/#{room_alias}")
    headers = auth_headers(token)

    with {:ok, %{"room_id" => room_id}} <- Request.get(room_url, headers) do
      {:ok, room_id}
    end
  end

  @doc """
  Get list of room names.
  """
  @spec rooms(String.t()) :: {:ok, [String.t()]} | {:error, any()}
  def rooms(token) do
    rooms_url = api_url!("/joined_rooms")
    headers = auth_headers(token)

    with {:ok, %{"joined_rooms" => rooms}} <- Request.get(rooms_url, headers) do
      {:ok, rooms}
    end
  end

  @doc """
  Get list of messages in a specific room.
  """
  @spec room_messages(Sring.t(), String.t(), String.t(), integer(), String.t()) ::
          {:ok, {[map()], String.t(), String.t()}} | {:error, any()}
  def room_messages(token, room_id, from, limit \\ 20, dir \\ "b") do
    messages_url = api_url!("/rooms/#{room_id}/messages?from=#{from}&dir=#{dir}&limit=#{limit}")
    headers = auth_headers(token)

    with {:ok, %{"chunk" => events, "start" => sb, "end" => eb}} <-
           Request.get(messages_url, headers) do
      raw_events = Enum.filter(events, &Event.is_supported_type?(Map.get(&1, "type")))
      events = Enum.map(raw_events, &Util.to_struct(Event, &1))
      {:ok, {events, sb, eb}}
    end
  end

  @doc """
  Get full room state.
  """
  @spec room_state(String.t(), String.t()) :: {:ok, [Event.t()]} | {:error, any()}
  def room_state(token, room_id) do
    room_state_url = api_url!("/rooms/#{room_id}/state")
    headers = auth_headers(token)

    with {:ok, raw_events} when is_list(raw_events) <- Request.get(room_state_url, headers) do
      relevant_raw_events =
        Enum.filter(raw_events, &Event.is_supported_type?(Map.get(&1, "type")))

      events = Enum.map(relevant_raw_events, &Util.to_struct(Event, &1))
      {:ok, events}
    end
  end

  @doc """
  Send new text message in a specific room.
  """
  @spec send_text_message(String.t(), String.t(), String.t(), String.t() | nil) ::
          {:ok, Event.t()} | {:error, any()}
  def send_text_message(token, room, text, formatted_body \\ nil) do
    payload = %{
      "msgtype" => "m.text",
      "body" => text
    }

    payload =
      unless is_nil(formatted_body) do
        payload
        |> Map.put("formatted_body", formatted_body)
      else
        payload
      end

    send_message(token, room, payload)
  end

  @doc """
  Send new file message in a specific room.
  """
  @spec send_file_message(String.t(), String.t(), String.t(), %{
          content_type: String.t(),
          description: String.t(),
          filename: nil | String.t()
        }) :: {:ok, Event.t()} | {:error, HttpError.t()}
  def send_file_message(token, room, file_content, %{
        filename: filename,
        content_type: content_type,
        description: description
      }) do
    with {:ok, media_url} <- upload_media(token, content_type, file_content, filename),
         payload <- %{
           "msgtype" => "m.file",
           "body" =>
             if(bit_size(description) > 0) do
               description
             else
               filename
             end,
           "filename" => filename,
           "url" => media_url,
           "info" => %{
             "mimetype" => content_type,
             "size" => byte_size(file_content)
           }
         } do
      send_message(token, room, payload)
    end
  end

  @doc """
  Send new notice message in a specific room.
  """
  @spec send_notice_message(String.t(), String.t(), String.t(), String.t() | nil) ::
          {:ok, Event.t()} | {:error, any()}
  def send_notice_message(token, room, text, formatted_body \\ nil) do
    payload = %{
      "msgtype" => "m.notice",
      "body" => text
    }

    payload =
      unless is_nil(formatted_body) do
        payload
        |> Map.put("formatted_body", formatted_body)
      else
        payload
      end

    send_message(token, room, payload)
  end

  @doc """
  Mark room events as read.
  """
  @spec set_read_marker(String.t(), String.t(), String.t()) :: :ok | {:error, any()}
  def set_read_marker(token, room, to_event_id) do
    headers = auth_headers(token)
    read_message_url = api_url!("/rooms/#{room}/read_markers")
    payload = %{"m.fully_read" => to_event_id, "m.read" => to_event_id}

    with {:ok, _} <- Request.post(read_message_url, payload, headers) do
      :ok
    end
  end

  @doc """
  Gets list of room members
  """
  @spec joined_members(String.t(), String.t()) ::
          {:ok, list(Member.t())} | {:error, any()}
  def joined_members(token, room) do
    headers = auth_headers(token)
    joined_members_url = api_url!("/rooms/#{room}/joined_members")

    with {:ok, %{"joined" => room_members}} <- Request.get(joined_members_url, headers) do
      members =
        for {key, %{"display_name" => display_name, "avatar_url" => avatar_url}} <- room_members do
          %Member{
            user_id: key,
            display_name: display_name,
            avatar_url: avatar_url
          }
        end

      {:ok, members}
    end
  end

  @doc """
  Redacts event
  """
  @spec redact_event(String.t(), String.t(), String.t(), String.t()) ::
          {:ok, Event.t()} | {:error, HttpError.t()}
  def redact_event(token, room, event_id, reason \\ "delete") do
    headers = auth_headers(token)
    txn_id = generate_uuid()
    api_url = api_url!("/rooms/#{room}/redact/#{event_id}/#{txn_id}")

    payload = %{
      "reason" => reason
    }

    with {:ok, %{"event_id" => _event_id} = response} <-
           Request.put(api_url, payload, headers) do
      {:ok, Util.to_struct(Event, response)}
    end
  end

  @doc """
  Gets event by id
  """
  @spec get_event(String.t(), String.t(), String.t()) ::
          {:ok, Event.t()} | {:error, HttpError.t()}
  def get_event(token, room, event_id) do
    headers = auth_headers(token)
    api_url = api_url!("/rooms/#{room}/event/#{event_id}")

    with {:ok, %{"event_id" => _event_id} = response} <-
           Request.get(api_url, headers) do
      {:ok, Util.to_struct(Event, response)}
    end
  end

  @doc """
  Read config settings.
  """
  @spec config!(atom()) :: any()
  def config!(key) do
    Application.get_env(:ex_matrix_api, __MODULE__)
    |> Keyword.fetch!(key)
  end

  defp api_url!(suffix), do: config!(:api_url) <> suffix

  defp media_api_url!(suffix), do: config!(:media_api_url) <> suffix

  defp auth_headers(token), do: [{"Authorization", "Bearer #{token}"}]

  defp send_message(token, room, message_payload) do
    headers = auth_headers(token)
    uuid = generate_uuid()
    message_url = api_url!("/rooms/#{room}/send/m.room.message/#{uuid}")

    message_payload =
      if Map.has_key?(message_payload, "formatted_body") do
        message_payload
        |> Map.put("format", "org.matrix.custom.html")
      else
        message_payload
      end

    with {:ok, %{"event_id" => _event_id} = response} <-
           Request.put(message_url, message_payload, headers) do
      {:ok, Util.to_struct(Event, response)}
    end
  end

  defp generate_uuid() do
    UUID.generate()
  end
end
