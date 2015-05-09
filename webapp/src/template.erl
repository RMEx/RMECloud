-module(template).
-compile(export_all).
-include("yaws_api.hrl").

%% Front page
front() ->
    layout:content(
      ["front"], "RMECloud: connect RPGMaker VXAce around the World!", 
      [
       {'div', [{id, "front-content"}], 
        [
         {'div', [], 
          [
           {h1, [{id, "title-h"}], ["RMECloud"]}, 
           {h2, [{id, "subtitle-h"}], 
            ["Connect RPGMaker VXAce around the World !"]}, 
           {'div', [{id, "connect-modal"}],
            [
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
            ]}
          ]}
        ]}
      ]
     ).
