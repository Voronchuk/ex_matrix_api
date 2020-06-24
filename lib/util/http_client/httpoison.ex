defmodule ExMatrixApi.Util.HttpClient.HTTPoison do
  @moduledoc """
  Behaviour wrapper for HTTPoison HTTP client.
  """

  alias ExMatrixApi.Behaviour.HttpClient
  alias HttpClient.HttpError
  alias HTTPoison.{Response, Error}

  @successful_http_codes [200, 201, 202, 204]
  @json_headers ["application/json", "application/json; charset=utf-8"]

  @type http_header :: {String.t(), String.t()}

  @behaviour HttpClient

  @impl HttpClient
  @spec get(String.t(), [http_header], Keyword.t()) :: HttpClient.response()
  def get(url, headers \\ [], opts \\ []) do
    headers = default_headers(headers)

    HTTPoison.get(url, headers, opts)
    |> process_response()
  end

  @impl HttpClient
  @spec put(String.t(), HttpClient.payload(), [http_header], Keyword.t()) :: HttpClient.response()
  def put(url, payload, headers \\ [], opts \\ []) when is_map(payload) or is_binary(payload) do
    headers = default_headers(headers)

    case prepare_payload(payload) do
      {:ok, body} ->
        HTTPoison.put(url, body, headers, opts)
        |> process_response()

      _ ->
        {:error, HttpError.new("invalid payload")}
    end
  end

  @impl HttpClient
  @spec post(String.t(), HttpClient.payload(), [http_header], Keyword.t()) ::
          HttpClient.response()
  def post(url, payload, headers \\ [], opts \\ []) when is_map(payload) or is_binary(payload) do
    headers = default_headers(headers)

    case prepare_payload(payload) do
      {:ok, body} ->
        HTTPoison.post(url, body, headers, opts)
        |> process_response()

      _ ->
        {:error, HttpError.new("invalid payload")}
    end
  end

  @impl HttpClient
  @spec delete(String.t(), [http_header], Keyword.t()) :: HttpClient.response()
  def delete(url, headers \\ [], opts \\ []) do
    headers = default_headers(headers)

    HTTPoison.delete(url, headers, opts)
    |> process_response()
  end

  @spec process_response({:ok, Response.t()} | {:error, Error.t()}) :: HttpClient.response()
  defp process_response({:ok, %Response{status_code: code, body: ""}})
       when code in @successful_http_codes do
    {:ok, nil}
  end

  defp process_response({:ok, %Response{status_code: code, body: body, headers: headers}})
       when code in @successful_http_codes do
    if is_json_response?(headers) do
      with {:error, _} <- Jason.decode(body) do
        {:error, HttpError.new("invalid response data")}
      end
    else
      {:ok, body}
    end
  end

  defp process_response({:ok, %Response{status_code: code, body: ""}}) do
    {:error, HttpError.new("unexpected empty response", code)}
  end

  defp process_response({:ok, %Response{status_code: code, body: body, headers: headers}}) do
    if is_json_response?(headers) do
      case Jason.decode(body) do
        {:ok, errors} ->
          {:error, HttpError.new(body, code, errors)}

        _ ->
          {:error, HttpError.new("invalid error response", code)}
      end
    else
      {:error, HttpError.new(body, code)}
    end
  end

  defp process_response({:error, %Error{reason: reason}}) do
    {:error, HttpError.new(reason)}
  end

  defp process_response(_) do
    {:error, HttpError.new("invalid HTTP response")}
  end

  @spec is_json_response?([http_header]) :: boolean()
  defp is_json_response?(headers) do
    Enum.any?(headers, fn {_header, value} -> value in @json_headers end)
  end

  @spec default_headers([http_header]) :: [http_header]
  defp default_headers(headers) when length(headers) == 0 do
    [{"Content-type", "application/json; charset=utf-8"}]
  end

  defp default_headers(headers), do: headers

  @spec prepare_payload(HttpClient.payload()) :: {:ok, binary()} | {:error, any()}
  defp prepare_payload(payload) when is_binary(payload), do: {:ok, payload}
  defp prepare_payload(payload), do: Jason.encode(payload)
end
