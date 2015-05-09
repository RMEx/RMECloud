-module(crypter).
-include("yaws_api.hrl").
-include("rmecloud.hrl").
-export([md5/1,sha1/1]).
 
%% Cryptokit

encrypt(Str, F) ->
    Digest = 
        [
         io_lib:format("~2.16.0b",[N]) 
         || <<N>> <= F(Str)
        ],
    lists:flatten(Digest).
    

%% Cryptokit for MD5 Digest
md5(Str)  -> encrypt(Str, fun erlang:md5/1).
sha1(Str) -> encrypt(Str, fun(X) -> crypto:hash(sha, X) end).
