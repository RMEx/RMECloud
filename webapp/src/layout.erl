-module(layout).
-compile(export_all).
-include("yaws_api.hrl").


%% Simple page description
page(Path, Body) -> 
    page(Path, [], Body).
page(Path, Head, Body) -> page(Path, Head, [], Body).
page(Path, Head, BArgs, Body) ->
    {ehtml, 
     [
      <<"<!DOCTYPE html><html>">>,
      {head, [], Head}, 
      {body, BArgs, Body},
      <<"</html>">>
     ]
    }.

%% Container description
content(Path, Title, Body) ->
    page(
      Path, 
      [
       {title, [], [Title]},
       {meta, [{charset, "utf-8"}]}, 
       link_css(
         "http://fonts.googleapis.com/css?"
         ++ "family=Lato:400,700,900,400italic,700italic,900italic"
         ++ "&subset=latin,latin-ext"
        ),
       link_css(uri:root(Path, "asset/css/style.css"))
      ], 
      Body).


%% Helpers
link_css(Url) ->
    {link, 
     [{rel, "stylesheet"}, {type, "text/css"}, {href, Url}]}.
