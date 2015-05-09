-module(uri).
-compile(export_all).
-include("yaws_api.hrl").

% make a path from an Appmod data set
make_path(Arg) ->
    case Arg#arg.appmoddata of 
        []  -> [];
        Str -> string:tokens(Str, "/")
    end.

% Return to the real root
root(Path, Target) ->
    Flashback = lists:map(fun(_) -> ".." end, Path),
    NewTarget = lists:append(Flashback, [Target]),
    filename:join(NewTarget).
