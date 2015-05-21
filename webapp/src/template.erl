-module(template).
-compile(export_all).
-include("yaws_api.hrl").

%% Front page
front(Path) ->
    layout:create_frontpage(
      Path,
      [
       {'div', [{id, "connect-modal"}],
	      [
	       {'div', [{class, "right-align"}],
	        [{a, [{href, "register"}], ["Sign up"]}]},
         {form, [],
	        [
	         {input,
	          [
	           {type, "text"},
             {name, "nickname"},
             {placeholder, "your nickname"}
            ]},
           {input,
	          [
	           {type, "password"},
             {name, "password"},
             {placeholder, "your password"}
            ]},
           {input,
	          [
	           {type, "submit"},
             {name, "validation"},
             {value, "Connection"}
            ]}
           ]}
          ]
        }
      ]
    ).


%% Front page
register() ->
  layout:create_frontpage(
    ["register"],
    [

    ]).
