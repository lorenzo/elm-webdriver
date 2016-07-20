module Webdriver.LowLevel
    exposing
        ( Browser
        , Options
        , Capabilities
        , Error(..)
        , open
        , url
        , click
        , moveTo
        , moveToWithOffset
        , close
        , end
        , back
        , forward
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
        , getUrl
        , getCookie
        , getAttribute
        , getCssProperty
        , getElementSize
        , getElementHTML
        , getElementPosition
        , getElementViewPosition
        , getPageHTML
        , getText
        , getTitle
        , getValue
        , elementExists
        , elementEnabled
        , elementVisible
        , elementVisibleWithinViewport
        , optionIsSelected
        , cookieExists
        , countElements
        , customCommand
        )

{-| Offers access to the webdriver.io js library

## Types

@docs Error, Browser, Options, Capabilities

## Navigation

@docs open, url, click, moveTo, moveToWithOffset, close, end, switchToFrame

# Forms

@docs selectByIndex, selectByValue, selectByText, setValue, appendValue
    ,clearValue, submitForm

## History

@docs back, forward

## Waiting

@docs waitForExist, waitForNotExist, waitForVisible, waitForNotVisible
    , waitForValue, waitForNoValue, waitForSelected, waitForNotSelected
    , waitForText, waitForNoText, waitForEnabled, waitForNotEnabled, pause

## Scrolling

@docs scrollToElement, scrollToElementOffset, scrollWindow

## Screenshots

@docs pageScreenshot, savePageScreenshot, viewportScreenshot

## Utilities

@docs countElements, triggerClick

## Debugging

@docs debug

## Page properties

@docs getUrl, getPageHTML, getTitle

## Element properties

@docs getAttribute, getCssProperty, getElementSize, getElementHTML
    , getElementPosition, getElementViewPosition, getText, getValue
    , elementExists, elementVisible, elementVisibleWithinViewport
    , elementEnabled, optionIsSelected

## Cokies

@docs getCookie, cookieExists

## Custom

@docs customCommand

-}

import Native.Webdriver
import Task exposing (Task)
import Json.Encode exposing (Value)


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
    | TooManyElements (ErrorDetails (WithSelector {}))
    | FailedElementPrecondition (ErrorDetails (WithSelector {}))
    | UnknownError (ErrorDetails (WithScreenshot {}))
    | InvalidCommand (ErrorDetails {})


type alias WithScreenshot a =
    { a | screenshot : String }


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
-}
url : String -> Browser -> Task Error ()
url =
    Native.Webdriver.url


{-| Clicks the element after finding it with the given selector.
-}
click : String -> Browser -> Task Error ()
click =
    Native.Webdriver.click


{-| Moves the mouse to the middle of the specified element
-}
moveTo : String -> Browser -> Task Error ()
moveTo selector =
    moveToWithOffset selector Nothing Nothing


{-| Moves the mouse to the middle of the specified element. This function
takes two integers (offsetX and offsetY).

If offsetX has a value, move relative to the top-left corner of the element on the X axis
If offsetY has a value, move relative to the top-left corner of the element on the Y axis
-}
moveToWithOffset : String -> Maybe Int -> Maybe Int -> Browser -> Task Error ()
moveToWithOffset =
    Native.Webdriver.moveToObjectWithOffset


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
switchToFrame : Int -> Browser -> Task Error ()
switchToFrame =
    Native.Webdriver.frame


{-| Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.
-}
triggerClick : String -> Browser -> Task Error ()
triggerClick =
    Native.Webdriver.triggerClick


{-| Goes back in the browser history
-}
back : Browser -> Task Error ()
back =
    Native.Webdriver.back


{-| Goes forward in the browser history
-}
forward : Browser -> Task Error ()
forward =
    Native.Webdriver.forward


{-| Returns the url for the current browser window
-}
getUrl : Browser -> Task Error String
getUrl =
    Native.Webdriver.getUrl


{-| Returns the cookie value for the given cookie name
-}
getCookie : String -> Browser -> Task Error (Maybe String)
getCookie =
    Native.Webdriver.getCookie


{-| Returns the value for the given attribute in the specified element by selector
-}
getAttribute : String -> String -> Browser -> Task Error (Maybe String)
getAttribute =
    Native.Webdriver.getAttribute


{-| Returns the value for the given attribute in the specified element by selector
-}
getCssProperty : String -> String -> Browser -> Task Error (Maybe String)
getCssProperty =
    Native.Webdriver.getCssProperty


{-| Returns the size of the give element
-}
getElementSize : String -> Browser -> Task Error { width : Int, height : Int }
getElementSize =
    Native.Webdriver.getElementSize


{-| Returns the HTML for the given element
-}
getElementHTML : String -> Browser -> Task Error String
getElementHTML =
    Native.Webdriver.getHTML


{-| Returns the element's location on a page
-}
getElementPosition : String -> Browser -> Task Error { x : Int, y : Int }
getElementPosition =
    Native.Webdriver.getLocation


{-| Determine an element’s location on the screen once it has been scrolled into view.
-}
getElementViewPosition : String -> Browser -> Task Error { x : Int, y : Int }
getElementViewPosition =
    Native.Webdriver.getLocationInView


{-| Returns the page HTML
-}
getPageHTML : Browser -> Task Error String
getPageHTML =
    Native.Webdriver.getSource


{-| Returns the text node for the given element
-}
getText : String -> Browser -> Task Error String
getText =
    Native.Webdriver.getText


{-| Returns the current window title
-}
getTitle : Browser -> Task Error String
getTitle =
    Native.Webdriver.getTitle


{-| Returns the input element's current value
-}
getValue : String -> Browser -> Task Error String
getValue =
    Native.Webdriver.getValue


{-| Returns true if the element exists in the DOM
-}
elementExists : String -> Browser -> Task Error Bool
elementExists =
    Native.Webdriver.isExisting


{-| Returns true if the input element is enabled
-}
elementEnabled : String -> Browser -> Task Error Bool
elementEnabled =
    Native.Webdriver.isEnabled


{-| Returns true if the input element is visible
-}
elementVisible : String -> Browser -> Task Error Bool
elementVisible =
    Native.Webdriver.isVisible


{-| Returns true if the input element is visible
-}
elementVisibleWithinViewport : String -> Browser -> Task Error Bool
elementVisibleWithinViewport =
    Native.Webdriver.isVisibleWithinViewport


{-| Returns true if the select option specified in the element selector is selected
-}
optionIsSelected : String -> Browser -> Task Error Bool
optionIsSelected =
    Native.Webdriver.isSelected


{-| Returns true if the specified cookie is present
-}
cookieExists : String -> Browser -> Task Error Bool
cookieExists name browser =
    getCookie name browser
        |> Task.map
            (\res ->
                if res == Nothing then
                    False
                else
                    True
            )


{-| Returns the count of elements matching the provided selector
-}
countElements : String -> Browser -> Task Error Int
countElements =
    Native.Webdriver.countElements


{-| Allows you to execute an arbitrary command in the client by a name. The return value
of the comand coms as a Json.Encode.Value.

    customCommand "windowHandleSize" [JE.string "dc30381e-e2f3-9444-8bf3-12cc44e8372a"] browser
-}
customCommand : String -> List Value -> Browser -> Task Error Value
customCommand =
    Native.Webdriver.customCommand
