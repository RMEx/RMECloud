-module(util).
-compile(export_all).
-include("yaws_api.hrl").
-include("rmecloud.hrl").

%% Make a date 
create_date() ->
    {{Year,Month,Day},{Hour,Min,Sec}} = erlang:localtime(),
    create_date(Year, Month, Day, Hour, Min, Sec).

create_date(Y, M, D, Hour, Min, Sec) ->
    #date{
       year    = Y, 
       month   = M, 
       day     = D, 
       hour    = Hour, 
       min     = Min, 
       sec     = Sec
      }.

