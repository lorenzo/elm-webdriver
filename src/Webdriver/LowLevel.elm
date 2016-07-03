module Webdriver.LowLevel
    exposing
        ( Browser
        , Options
        , Capabilities
        , Error(..)
        , open
        , url
        , click
        , close
        , setValue
        , selectByIndex
        , selectByValue
        , selectByText
        , submitForm
        )

{-| Offers access to the webdriver.io js library

# API
@docs open, url, click, close
@docs selectByIndex, selectByValue, selectByText, setValue, submitForm
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


{-| Selects the option in the dropdown using the option index
-}
selectByIndex : String -> Int -> Browser -> Task Error ()
selectByIndex =
    Native.Webdriver.selectByIndex


{-| Selects the option in the dropdown using the option value
-}
selectByValue : String -> String -> Browser -> Task Error ()
selectByValue =
    Native.Webdriver.selectByValue


{-| Selects the option in the dropdown using the option visible text
-}
selectByText : String -> String -> Browser -> Task Error ()
selectByText =
    Native.Webdriver.selectByText


{-| Submits the form with the given selector
-}
submitForm : String -> Browser -> Task Error ()
submitForm =
    Native.Webdriver.submitForm
