-module(app).
-compile(export_all).
-include("yaws_api.hrl").

%% Application entry point
out(Arg) ->
    Path   = uri:make_path(Arg),
    Method = (Arg#arg.req)#http_request.method,
    rest_controller(Arg, Method, Path).

%% Front page
rest_controller(_, _, ["front"]) -> template:front();
%% Controller of application
rest_controller(Arg, Method, Path) ->
    layout:content(
      Path, "title",
      [
       {h1, [], ["Page test"]}, 
       {h2, [], ["Test routing"]}
      ]
     ).
