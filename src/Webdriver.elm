effect module Webdriver
    where { command = MyCmd }
    exposing
        ( open
        , visit
        , click
        )

{-| Effect Manager for Webdriver.io

@docs open, visit, click
-}

import Webdriver.LowLevel as Wd
import Task exposing (Task, andThen, onError, succeed, fail)
import Dict exposing (Dict)
import Platform exposing (Router, sendToSelf, sendToApp)


-- COMMANDS


type alias Id =
    String


type MyCmd msg
    = Open Wd.Options (String -> msg)
    | Visit Id String (String -> msg)
    | Click Id String (String -> msg)


{-| Opens a new Browser window. The provided tagger
will receive the session id string as parameter.
-}
open : Wd.Options -> (Id -> msg) -> Cmd msg
open options onSuccess =
    command (Open options onSuccess)


{-| Using the given browser session, visit a url
The provided tagger will receive the resulting url.
-}
visit : Id -> String -> (String -> msg) -> Cmd msg
visit session url onSuccess =
    command (Visit session url onSuccess)


{-| Using the given browser session, visit a url
The provided tagger will receive the resulting url.
-}
click : Id -> String -> (String -> msg) -> Cmd msg
click session selector onSuccess =
    command (Click session selector onSuccess)


cmdMap : (a -> b) -> MyCmd a -> MyCmd a
cmdMap _ command =
    command



-- MANAGER


init : Task Never State
init =
    Task.succeed (State Dict.empty)


type alias State =
    { clients : BrowsersDict
    }


type alias BrowsersDict =
    Dict Id Wd.Browser


type alias Commands msg =
    List (MyCmd msg)


type Msg
    = SessionStarted String


onEffects : Router msg Msg -> Commands msg -> State -> Task Never (State)
onEffects router commands state =
    let
        tasks =
            executeCommands router commands state.clients

        cleanup newClients =
            succeed (State newClients)
    in
        tasks `andThen` cleanup


executeCommands : Router msg Msg -> Commands msg -> BrowsersDict -> Task never BrowsersDict
executeCommands router commands clients =
    case commands of
        [] ->
            succeed clients

        (Open options onSuccess) :: rest ->
            let
                thisTask =
                    Wd.open options
                        `andThen` (\( id, browser ) -> sendToApp router (onSuccess id) |> Task.map (always ( id, browser )))
                        `andThen` (\( id, browser ) -> succeed (Dict.insert id browser clients))
                        `onError` (\_ -> succeed clients)

                otherTasks =
                    executeCommands router rest
            in
                thisTask `andThen` otherTasks

        (Visit id url onSuccess) :: rest ->
            Wd.url url
                |> executeCommandHelp router id clients rest onSuccess

        (Click id selector onSuccess) :: rest ->
            Wd.click selector
                |> executeCommandHelp router id clients rest onSuccess


executeCommandHelp :
    Router msg Msg
    -> Id
    -> BrowsersDict
    -> Commands msg
    -> (a -> msg)
    -> (Wd.Browser -> Task x a)
    -> Task never BrowsersDict
executeCommandHelp router id clients rest onSuccess commander =
    case Dict.get id clients of
        Just browser ->
            commander browser
                `andThen` (\result -> sendToApp router (onSuccess result))
                `andThen` (\_ -> succeed clients)
                `onError` (\_ -> succeed clients)
                `andThen` (executeCommands router rest)

        _ ->
            executeCommands router rest clients


onSelfMsg : Router msg Msg -> Msg -> State -> Task Never (State)
onSelfMsg router msg state =
    Task.succeed state
