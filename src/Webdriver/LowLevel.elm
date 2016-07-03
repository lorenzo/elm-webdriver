module Webdriver.LowLevel
    exposing
        ( Browser
        , Options
        , Capabilities
        , Error(..)
        , basicOptions
        , open
        , url
        , click
        , close
        , setValue
        )

{-| Offers access to the webdriver.io js library

# API
@docs basicOptions, open, url, click, close, setValue
@docs Error, Browser, Options, Capabilities
-}

import Native.Webdriver
import Task exposing (Task)


{-| Represents a Browser Window
-}
type Browser
    = Browser


{-| Options for selenium
-}
type alias Options =
    { desiredCapabilities : Capabilities
    }


{-| Browser capabilities
-}
type alias Capabilities =
    { browserName : String
    }


{-| Possible errors
-}
type Error
    = ConnectionError (ErrorDetails (WithScreenshot {}))
    | MissingElement (ErrorDetails (WithSelector {}))
    | UnreachableElement (ErrorDetails (WithScreenshot (WithSelector {})))
    | UnknownError (ErrorDetails (WithScreenshot {}))


type alias WithScreenshot a =
    { a | screeshot : String }


type alias WithSelector a =
    { a | selector : String }


type alias ErrorDetails a =
    { a
        | errorType : String
        , message : String
    }


{-| Bare minimum options for running selenium
-}
basicOptions : Options
basicOptions =
    { desiredCapabilities =
        { browserName = "firefox"
        }
    }


{-| Opens a new browser window
-}
open : Options -> Task Error ( String, Browser )
open =
    Native.Webdriver.open


{-| Visits the given url.
The result of the task is the resulting URL address, after any
possible redirects.
-}
url : String -> Browser -> Task Error String
url =
    Native.Webdriver.url


{-| Clicks the element after finding it with the given selector.
-}
click : String -> Browser -> Task Error ()
click =
    Native.Webdriver.click


{-| Closes the current browser window
-}
close : Browser -> Task Error ()
close =
    Native.Webdriver.close


{-| Fills in the specified input with a value
-}
setValue : String -> String -> Browser -> Task Error ()
setValue =
    Native.Webdriver.setValue
