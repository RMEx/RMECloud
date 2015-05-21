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


%% Register page
register(Path) -> register(Path, "", "", "").
register(Path, Login, Mail, Password) ->
  layout:create_frontpage(
    Path,
    [
      {'div', [{id, "connect-modal"}],
      [
        {'div', [{class, "right-align"}],
          [{a, [{href, uri:root(Path, "front")}], ["Sign in"]}]},
        {form, [{method, "post"}, {action, "register/process"}],
        [
          {input,
          [
            {type, "text"},
            {name, "nickname"},
            {value, Login},
            {placeholder, "your nickname"}
          ]},
          {input,
          [
            {type, "password"},
            {name, "password"},
            {value, Password},
            {placeholder, "your password"}
          ]},
          {input,
          [
            {type, "password"},
            {name, "password-rep"},
            {placeholder, "Retype your password"}
          ]},
          {input,
          [
            {type, "email"},
            {name, "email"},
            {value, Mail},
            {placeholder, "your mail address"}
          ]},
          {input,
          [
            {type, "submit"},
            {name, "validation"},
            {value, "Request Account"}
          ]}
        ]}
       ]
     }
    ]).
