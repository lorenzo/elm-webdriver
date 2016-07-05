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
        , end
        , setValue
        , appendValue
        , clearValue
        , selectByIndex
        , selectByValue
        , selectByText
        , submitForm
        , waitForExist
        , waitForNotExist
        , waitForVisible
        , waitForNotVisible
        , waitForValue
        , waitForNoValue
        , waitForSelected
        , waitForNotSelected
        , waitForText
        , waitForNoText
        , waitForEnabled
        , waitForNotEnabled
        , pause
        , scrollToElement
        , scrollToElementOffset
        , scrollWindow
        , pageScreenshot
        , savePageScreenshot
        , viewportScreenshot
        , switchToFrame
        , triggerClick
        , debug
        )

{-| Offers access to the webdriver.io js library

# API
@docs open, url, click, close, end, switchToFrame
@docs selectByIndex, selectByValue, selectByText, setValue, appendValue, clearValue, submitForm
@docs Error, Browser, Options, Capabilities

## Waiting
@docs waitForExist, waitForNotExist, waitForVisible, waitForNotVisible, waitForValue, waitForNoValue
@docs waitForSelected, waitForNotSelected, waitForText, waitForNoText, waitForEnabled, waitForNotEnabled, pause

## Scrolling

@docs scrollToElement
    , scrollToElementOffset
    , scrollWindow

## Screenshots

@docs pageScreenshot
    , savePageScreenshot
    , viewportScreenshot

## Custom

@docs triggerClick

## Debugging

@docs debug

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
    | FailedElementPrecondition (ErrorDetails (WithSelector {}))
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


{-| Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.
-}
debug : Browser -> Task Error ()
debug =
    Native.Webdriver.debug


{-| Fills in the specified input with a value
-}
setValue : String -> String -> Browser -> Task Error ()
setValue =
    Native.Webdriver.setValue


{-| Appends to an input's value
-}
appendValue : String -> String -> Browser -> Task Error ()
appendValue =
    Native.Webdriver.addValue


{-| Clears the value of the given input
-}
clearValue : String -> Browser -> Task Error ()
clearValue =
    Native.Webdriver.clearElement


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


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM
-}
waitForExist : String -> Int -> Browser -> Task Error ()
waitForExist selector ms browser =
    Native.Webdriver.waitForExist selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM
-}
waitForNotExist : String -> Int -> Browser -> Task Error ()
waitForNotExist selector ms browser =
    Native.Webdriver.waitForExist selector ms True browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.
-}
waitForVisible : String -> Int -> Browser -> Task Error ()
waitForVisible selector ms browser =
    Native.Webdriver.waitForVisible selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.
-}
waitForNotVisible : String -> Int -> Browser -> Task Error ()
waitForNotVisible selector ms browser =
    Native.Webdriver.waitForVisible selector ms True browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.
-}
waitForValue : String -> Int -> Browser -> Task Error ()
waitForValue selector ms browser =
    Native.Webdriver.waitForValue selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.
-}
waitForNoValue : String -> Int -> Browser -> Task Error ()
waitForNoValue selector ms browser =
    Native.Webdriver.waitForValue selector ms True browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.
-}
waitForSelected : String -> Int -> Browser -> Task Error ()
waitForSelected selector ms browser =
    Native.Webdriver.waitForSelected selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.
-}
waitForNotSelected : String -> Int -> Browser -> Task Error ()
waitForNotSelected selector ms browser =
    Native.Webdriver.waitForSelected selector ms True browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.
-}
waitForText : String -> Int -> Browser -> Task Error ()
waitForText selector ms browser =
    Native.Webdriver.waitForText selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.
-}
waitForNoText : String -> Int -> Browser -> Task Error ()
waitForNoText selector ms browser =
    Native.Webdriver.waitForText selector ms True browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.
-}
waitForEnabled : String -> Int -> Browser -> Task Error ()
waitForEnabled selector ms browser =
    Native.Webdriver.waitForEnabled selector ms False browser


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.
-}
waitForNotEnabled : String -> Int -> Browser -> Task Error ()
waitForNotEnabled selector ms browser =
    Native.Webdriver.waitForEnabled selector ms True browser


{-| Ends the browser session
-}
end : Browser -> Task Error ()
end =
    Native.Webdriver.end


{-| Pauses the browser session for the given milliseconds
-}
pause : Int -> Browser -> Task Error ()
pause =
    Native.Webdriver.pause


{-| Scrolls the window to the element specified in the selector
-}
scrollToElement : String -> Browser -> Task Error ()
scrollToElement selector browser =
    scrollToElementOffset selector 0 0 browser


{-| Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element
-}
scrollToElementOffset : String -> Int -> Int -> Browser -> Task Error ()
scrollToElementOffset =
    Native.Webdriver.scrollToElement


{-| Scrolls the window to the absolute coordinate (x, y) position provided in pixels
-}
scrollWindow : Int -> Int -> Browser -> Task Error ()
scrollWindow =
    Native.Webdriver.scrollWindow


{-| Takes a screenshot of the whole page and returns a base64 encoded png
-}
pageScreenshot : Browser -> Task Error String
pageScreenshot =
    Native.Webdriver.pageScreenshot


{-| Takes a screenshot of the whole page and saves it to a file
-}
savePageScreenshot : String -> Browser -> Task Error ()
savePageScreenshot =
    Native.Webdriver.savePageScreenshot


{-| Takes a screenshot of the current viewport and returns a base64 encoded png
-}
viewportScreenshot : Browser -> Task Error String
viewportScreenshot =
    Native.Webdriver.viewportScreenshot


{-| Makes any future actions happen inside the frame specified by its index
-}
switchToFrame : Int -> Browser -> Task Error String
switchToFrame =
    Native.Webdriver.frame


{-| Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.
-}
triggerClick : String -> Browser -> Task Error String
triggerClick =
    Native.Webdriver.triggerClick
