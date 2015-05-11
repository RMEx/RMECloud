-module(state).
-include("yaws_api.hrl").
-include("rmecloud.hrl").
-compile(export_all).

eval(Cookie) -> yaws_api:cookieval_to_opaque(Cookie).
init(Struct) -> yaws_api:new_cookie_session(Struct).

retreive(Arg, Name) ->
  Header = Arg#arg.headers,
  yaws_api:find_cookie_val(Name, H#headers.cookie).

return(Arg, Name) ->
  case retreive(Name, Arg) of
    [] -> {error, unexistant};
    Cookie -> eval(Cookie)
  end.
