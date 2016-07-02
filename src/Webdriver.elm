module Webdriver
    exposing
        ( open
        , visit
        , click
        )

{-| A library to interface with Webdriver.io and produce commands

@docs open, visit, click
-}

import Webdriver.LowLevel as Wd exposing (Error, Browser, Options)
import Task exposing (Task, perform)


{-| Opens a new Browser window. The provided tagger
will receive the browser as parameter.
-}
open : Options -> (Error -> msg) -> (Browser -> msg) -> Cmd msg
open options onError onSuccess =
    perform onError onSuccess (Wd.open options |> Task.map (\( _, b ) -> b))


{-| Visit a url
The provided tagger will receive the resulting url.
-}
visit : String -> (Error -> msg) -> (String -> msg) -> Browser -> Cmd msg
visit url onError onSuccess browser =
    perform onError onSuccess (Wd.url url browser)


{-| Click on an element using a selector
-}
click : String -> (Error -> msg) -> (() -> msg) -> Browser -> Cmd msg
click selector onError onSuccess browser =
    perform onError onSuccess (Wd.click selector browser)
