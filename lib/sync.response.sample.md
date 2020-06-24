%{
   "account_data" => %{
     "events" => [
       %{
         "content" => %{
           "voronchuk@gmail.com" => ["!bmmqZJwhoYmswCBbEO:ExMatrixApi.greet.local"]
         },
         "type" => "m.direct"
       },
       %{
         "content" => %{
           "recent_rooms" => ["!PbgnPTKjEORkYGBqtm:ExMatrixApi.greet.local",
            "!bmmqZJwhoYmswCBbEO:ExMatrixApi.greet.local"]
         },
         "type" => "im.vector.setting.breadcrumbs"
       },
       %{
         "content" => %{
           "device" => %{},
           "global" => %{
             "content" => [
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "default"},
                   %{"set_tweak" => "highlight"}
                 ],
                 "default" => true,
                 "enabled" => true,
                 "pattern" => "admin",
                 "rule_id" => ".m.rule.contains_user_name"
               }
             ],
             "override" => [
               %{
                 "actions" => ["dont_notify"],
                 "conditions" => [],
                 "default" => true,
                 "enabled" => false,
                 "rule_id" => ".m.rule.master"
               },
               %{
                 "actions" => ["dont_notify"],
                 "conditions" => [
                   %{
                     "key" => "content.msgtype",
                     "kind" => "event_match",
                     "pattern" => "m.notice"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.suppress_notices"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "default"},
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.member"
                   },
                   %{
                     "key" => "content.membership",
                     "kind" => "event_match",
                     "pattern" => "invite"
                   },
                   %{
                     "key" => "state_key",
                     "kind" => "event_match",
                     "pattern" => "@admin:ExMatrixApi.greet.local"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.invite_for_me"
               },
               %{
                 "actions" => ["dont_notify"],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.member"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.member_event"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "default"},
                   %{"set_tweak" => "highlight"}
                 ],
                 "conditions" => [%{"kind" => "contains_display_name"}],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.contains_display_name"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "highlight", "value" => true}
                 ],
                 "conditions" => [
                   %{
                     "key" => "content.body",
                     "kind" => "event_match",
                     "pattern" => "@room"
                   },
                   %{
                     "key" => "room",
                     "kind" => "sender_notification_permission"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.roomnotif"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "highlight", "value" => true}
                 ],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.tombstone"
                   },
                   %{
                     "key" => "state_key",
                     "kind" => "event_match",
                     "pattern" => ""
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.tombstone"
               },
               %{
                 "actions" => ["dont_notify"],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.reaction"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.reaction"
               }
             ],
             "room" => [],
             "sender" => [],
             "underride" => [
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "ring"},
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.call.invite"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.call"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "default"},
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{"is" => "2", "kind" => "room_member_count"},
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.message"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.room_one_to_one"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "sound", "value" => "default"},
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{"is" => "2", "kind" => "room_member_count"},
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.encrypted"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.encrypted_room_one_to_one"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.message"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.message"
               },
               %{
                 "actions" => [
                   "notify",
                   %{"set_tweak" => "highlight", "value" => false}
                 ],
                 "conditions" => [
                   %{
                     "key" => "type",
                     "kind" => "event_match",
                     "pattern" => "m.room.encrypted"
                   }
                 ],
                 "default" => true,
                 "enabled" => true,
                 "rule_id" => ".m.rule.encrypted"
               }
             ]
           }
         },
         "type" => "m.push_rules"
       }
     ]
   },
   "device_lists" => %{"changed" => [], "left" => []},
   "device_one_time_keys_count" => %{},
   "groups" => %{"invite" => %{}, "join" => %{}, "leave" => %{}},
   "next_batch" => "s18_709_0_1_1_1_1_7_1",
   "presence" => %{
     "events" => [
       %{
         "content" => %{
           "currently_active" => true,
           "last_active_ago" => 242,
           "presence" => "online"
         },
         "sender" => "@admin:ExMatrixApi.greet.local",
         "type" => "m.presence"
       }
     ]
   },
   "rooms" => %{
     "invite" => %{},
     "join" => %{
       "!PbgnPTKjEORkYGBqtm:ExMatrixApi.greet.local" => %{
         "account_data" => %{
           "events" => [
             %{
               "content" => %{
                 "event_id" => "$pz1nQDdJqP3yoCwHvZrqvp4e74HY3hZ50LKqSxXb5V8"
               },
               "type" => "m.fully_read"
             }
           ]
         },
         "ephemeral" => %{"events" => []},
         "state" => %{"events" => []},
         "summary" => %{},
         "timeline" => %{
           "events" => [
             %{
               "content" => %{
                 "creator" => "@admin:ExMatrixApi.greet.local",
                 "room_version" => "5"
               },
               "event_id" => "$D4rs5K5icI0M0z0fuDg0JCxdqHRnogv15abHtymmtNE",
               "origin_server_ts" => 1581614118198,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.create",
               "unsigned" => %{"age" => 20592285}
             },
             %{
               "content" => %{
                 "avatar_url" => nil,
                 "displayname" => "admin",
                 "membership" => "join"
               },
               "event_id" => "$tA5lVDSQROxJZXyu1_bExzCjiUUoa89rSEWXC7akjYk",
               "origin_server_ts" => 1581614118507,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "@admin:ExMatrixApi.greet.local",
               "type" => "m.room.member",
               "unsigned" => %{"age" => 20591976}
             },
             %{
               "content" => %{
                 "ban" => 50,
                 "events" => %{
                   "m.room.avatar" => 50,
                   "m.room.canonical_alias" => 50,
                   "m.room.history_visibility" => 100,
                   "m.room.name" => 50,
                   "m.room.power_levels" => 100
                 },
                 "events_default" => 0,
                 "invite" => 0,
                 "kick" => 50,
                 "redact" => 50,
                 "state_default" => 50,
                 "users" => %{"@admin:ExMatrixApi.greet.local" => 100},
                 "users_default" => 0
               },
               "event_id" => "$9w_MQPZB2ugIfiTObo4E4tOTw_pMJp3a02IIE6aYlmk",
               "origin_server_ts" => 1581614118814,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.power_levels",
               "unsigned" => %{"age" => 20591669}
             },
             %{
               "content" => %{"alias" => "#test:ExMatrixApi.greet.local"},
               "event_id" => "$QiSwiwLteu2z8EqU2Igcye3jn2ljDQ0GAZT255pDMaE",
               "origin_server_ts" => 1581614119065,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.canonical_alias",
               "unsigned" => %{"age" => 20591418}
             },
             %{
               "content" => %{"join_rule" => "public"},
               "event_id" => "$DdRV9ne4KpiaIF9HNf23aHwJegPJrY-IX36vySJWvE4",
               "origin_server_ts" => 1581614119271,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.join_rules",
               "unsigned" => %{"age" => 20591212}
             },
             %{
               "content" => %{"history_visibility" => "shared"},
               "event_id" => "$MAsjV30QsTYfPtbhEX77w4nP7kjgzqEnddpWHFtEz60",
               "origin_server_ts" => 1581614119475,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.history_visibility",
               "unsigned" => %{"age" => 20591008}
             },
             %{
               "content" => %{"name" => "test"},
               "event_id" => "$BzPKlQceDhhk_tGStY2A-wujJ_8-S1OGtIC6Ep4E47s",
               "origin_server_ts" => 1581614119627,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.name",
               "unsigned" => %{"age" => 20590856}
             },
             %{
               "content" => %{"aliases" => ["#test:ExMatrixApi.greet.local"]},
               "event_id" => "$aK6qxODricWdIDODcB16IWHfsRreknRBSPJJpaXYowI",
               "origin_server_ts" => 1581614119792,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "ExMatrixApi.greet.local",
               "type" => "m.room.aliases",
               "unsigned" => %{"age" => 20590691}
             },
             %{
               "content" => %{"body" => "Hi", "msgtype" => "m.text"},
               "event_id" => "$HTznxoeiuOJ46hVQQcHkfobIlbxLjRVh2AkIgo_2DtI",
               "origin_server_ts" => 1581614126582,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "type" => "m.room.message",
               "unsigned" => %{"age" => 20583901}
             },
             %{
               "content" => %{
                 "body" => "I'm just testing messages",
                 "msgtype" => "m.text"
               },
               "event_id" => "$pz1nQDdJqP3yoCwHvZrqvp4e74HY3hZ50LKqSxXb5V8",
               "origin_server_ts" => 1581614132990,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "type" => "m.room.message",
               "unsigned" => %{"age" => 20577493}
             }
           ],
           "limited" => false,
           "prev_batch" => "s18_709_0_1_1_1_1_7_1"
         },
         "unread_notifications" => %{}
       },
       "!bmmqZJwhoYmswCBbEO:ExMatrixApi.greet.local" => %{
         "account_data" => %{
           "events" => [
             %{
               "content" => %{
                 "event_id" => "$CuXY_MVRNr_PoH8cy9nXj58MLJ45C0wNRNnk8AkUGVg"
               },
               "type" => "m.fully_read"
             }
           ]
         },
         "ephemeral" => %{"events" => []},
         "state" => %{"events" => []},
         "summary" => %{},
         "timeline" => %{
           "events" => [
             %{
               "content" => %{
                 "creator" => "@admin:ExMatrixApi.greet.local",
                 "room_version" => "5"
               },
               "event_id" => "$MItCyB4TWErfccW4nnyMNJDzCW0RqY3_RHl_LEo4wb8", 
               "origin_server_ts" => 1581542727455,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.create",
               "unsigned" => %{"age" => 91983028}
             },
             %{
               "content" => %{
                 "avatar_url" => nil,
                 "displayname" => "admin",
                 "membership" => "join"
               },
               "event_id" => "$3MZtVkdZw96DEJ7YDiq9qmKS-03p9nkpwcyN3bM9O1g",
               "origin_server_ts" => 1581542727722,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "@admin:ExMatrixApi.greet.local",
               "type" => "m.room.member",
               "unsigned" => %{"age" => 91982761}
             },
             %{
               "content" => %{
                 "ban" => 50,
                 "events" => %{
                   "m.room.avatar" => 50,
                   "m.room.canonical_alias" => 50,
                   "m.room.history_visibility" => 100,
                   "m.room.name" => 50,
                   "m.room.power_levels" => 100
                 },
                 "events_default" => 0,
                 "invite" => 0,
                 "kick" => 50,
                 "redact" => 50,
                 "state_default" => 50,
                 "users" => %{"@admin:ExMatrixApi.greet.local" => 100},
                 "users_default" => 0
               },
               "event_id" => "$wI6YchYZMXOD3lRpWCdbDMcYCQomt6vGXLLm5EJdQPY",
               "origin_server_ts" => 1581542727969,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.power_levels",
               "unsigned" => %{"age" => 91982514}
             },
             %{
               "content" => %{"join_rule" => "invite"},
               "event_id" => "$qU_iJmbDVVj-bWpSsP8J9HXpheJCqErfHms2NFYVVgM",
               "origin_server_ts" => 1581542728071,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.join_rules",
               "unsigned" => %{"age" => 91982412}
             },
             %{
               "content" => %{"history_visibility" => "shared"},
               "event_id" => "$U4w3QNZTyXUd7uz8-Y_UzDYivHwil7dq8WMofWOhG1U",
               "origin_server_ts" => 1581542728246,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.history_visibility",
               "unsigned" => %{"age" => 91982237}
             },
             %{
               "content" => %{"guest_access" => "can_join"},
               "event_id" => "$G4wFhou5WXP_lAVPkRJBhD8n21Z_u6FSbTqX6YoJL4s",
               "origin_server_ts" => 1581542728446,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "",
               "type" => "m.room.guest_access",
               "unsigned" => %{"age" => 91982037}
             },
             %{
               "content" => %{
                 "display_name" => "vor...@gma...",
                 "key_validity_url" => "https://vector.im/_matrix/identity/api/v1/pubkey/isvalid",
                 "public_key" => "ta8IQ0u1sp44HVpxYi7dFOdS/bfwDjcy4xLFlfY5KOA",
                 "public_keys" => [
                   %{
                     "key_validity_url" => "https://vector.im/_matrix/identity/api/v1/pubkey/isvalid",
                     "public_key" => "ta8IQ0u1sp44HVpxYi7dFOdS/bfwDjcy4xLFlfY5KOA"
                   },
                   %{
                     "key_validity_url" => "https://vector.im/_matrix/identity/api/v1/pubkey/ephemeral/isvalid",
                     "public_key" => "fI5n89mMZPxi3E7zXnDOPHZK22Q9o_FuQAw3Sdfu4rc"
                   }
                 ]
               },
               "event_id" => "$CuXY_MVRNr_PoH8cy9nXj58MLJ45C0wNRNnk8AkUGVg",
               "origin_server_ts" => 1581542729309,
               "sender" => "@admin:ExMatrixApi.greet.local",
               "state_key" => "NqxSzVhSXhAALWASOAhAEsmmlgOWoaRyebprYGVYydLRzjOnCoBLrBFVjAHsfuJNZogRtAxENwdqexpWxRjPWcstOHPxdiKCRmIoqgirjrIJWxQsJWTnaeDFwgZjSnev",
               "type" => "m.room.third_party_invite",
               "unsigned" => %{"age" => 91981174}
             }
           ],
           "limited" => false,
           "prev_batch" => "s18_709_0_1_1_1_1_7_1"
         },
         "unread_notifications" => %{}
       }
     },
     "leave" => %{}
   },
   "to_device" => %{"events" => []}
 }}