%% This module is for dataset initialisation
%% Each function of this module must be create ONCE

-module(initialize).
-include("yaws_api.hrl").
-include("rmecloud.hrl").
-compile(export_all).

%% Create Data Schema
create_mnesia_schema() ->
    mnesia:create_schema([node()]).

%% Create User Table
create_user_table() ->
    mnesia:start(),
    mnesia:create_table(
      user, 
      [
       {attributes, record_info(fields, user)},
       {type, ordered_set}, 
       {disc_copies, [node()]}
      ]
     ),
    mnesia:stop().
