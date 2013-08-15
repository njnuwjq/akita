%%%----------------------------------------------------------------------
%%% File      : akita.erl
%%% Author    : ryan.ruan@ericsson.com
%%% Purpose   : Bootstrap module.
%%% Created   : Apr 3, 2013
%%%----------------------------------------------------------------------

%%%----------------------------------------------------------------------
%%% Copyright Ericsson AB 1996-2013. All Rights Reserved.
%%%
%%% The contents of this file are subject to the Erlang Public License,
%%% Version 1.1, (the "License"); you may not use this file except in
%%% compliance with the License. You should have received a copy of the
%%% Erlang Public License along with this software. If not, it can be
%%% retrieved online at http://www.erlang.org/.
%%%
%%% Software distributed under the License is distributed on an "AS IS"
%%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%%% the License for the specific language governing rights and limitations
%%% under the License.
%%%----------------------------------------------------------------------

-module(akita).            

%% API Functions
-export([start/0, stop/0, start_collect/0, stop_collect/0, status/0]).

-define(HUB, akita_cluster_info).

%% ===================================================================
%% API Functions
%% ===================================================================
start() ->
    ensure_started(crypto),
    ensure_started(sasl),
    ensure_started(westminster),
    application:start(akita).

stop() ->
    application:stop(akita).

start_collect() -> 
    ?HUB ! start_collect.

stop_collect() -> 
    ?HUB ! stop_collect.

status() ->
    Pid = whereis(?HUB),
    if
        is_pid(Pid) ->
            IsProcAlive = is_process_alive(Pid),
            if
                not IsProcAlive ->
                    error_logger:error_msg("akita crashes unexpectedly~n", []);
                true ->
                    ?HUB ! status
            end;
        true ->
            error_logger:info_msg("akita does not start yet~n", [])
    end,
    ok.



%% ===================================================================
%% Inner Functions
%% ===================================================================
ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.
