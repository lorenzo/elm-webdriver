module Webdriver.Assert exposing (..)

{-| Enables you to conditionally execute a list of steps depending on the current
state of the browser.

## Types

@docs Expectation

## Cookies

@docs cookie, cookieExists, cookieNotExists

## Page properties

@docs url, pageHTML, title, elementCount

## Element properties

@docs attribute, css, elementHTML, elementText, inputValue, exists
@docs inputEnabled, visible, visibleWithinViewport, optionSelected
@docs elementSize, elementPosition, elementViewPosition

-}

import Webdriver.Step exposing (..)
import Expect


{-| Alias for the test Expectation type
-}
type alias Expectation =
    Expect.Expectation


{-| Asserts the value of a cookie. If the cookie does not exists the assertion
will automatically fail.

    cookie "user" <| Expect.equal "jon snow"
-}
cookie : String -> (String -> Expectation) -> Step
cookie name f =
    AssertionMaybe (getCookie name)
        (\res ->
            case res of
                Just value ->
                    f value

                _ ->
                    Expect.fail <| "The cookie " ++ name ++ " does not exist"
        )


{-| Asserts that a cookie exists.

    cookieExists "user"
-}
cookieExists : String -> Step
cookieExists name =
    AssertionBool
        (Webdriver.Step.cookieExists name)
        (Expect.true <| "The cookie " ++ name ++ " was expected to exist.")


{-| Asserts that a cookie has not been set.

    cookieNotExists "user"
-}
cookieNotExists : String -> Step
cookieNotExists name =
    AssertionBool
        (Webdriver.Step.cookieNotExists name)
        (Expect.true <| "The cookie " ++ name ++ " was not expected to be present.")


{-| Asserts the value of the current url.

    url <| Expect.equal "https://google.com"
-}
url : (String -> Expectation) -> Step
url f =
    AssertionString getUrl f


{-| Asserts the title tag of the current page.

    tile <| Expect.equal "This is the page title"
-}
title : (String -> Expectation) -> Step
title f =
    AssertionString getTitle f


{-| Asserts the html source of the current page.

    pageHTML <|
        String.contains "Saved successfully" >> Expect.true "Expected a success message"
-}
pageHTML : (String -> Expectation) -> Step
pageHTML f =
    AssertionString getPageHTML f


{-| Assets the number of elements matching a selector

    elementCount "#loginForm input" <| Expect.atLeast 2
-}
elementCount : String -> (Int -> Expectation) -> Step
elementCount selector f =
    AssertionInt (countElements selector) f


{-| Asserts the value of an attribute for a given element. Only one element may be matched by the selector.
If the attribute is not present in the element, the assertion will automatically fail.

    attribute "input.username" "autocomplete" <| Expect.equal "off"
-}
attribute : String -> String -> (String -> Expectation) -> Step
attribute selector name f =
    AssertionMaybe
        (getAttribute selector name)
        (\res ->
            case res of
                Just attr ->
                    f attr

                _ ->
                    Expect.fail <| "The attribute '" ++ name ++ "' for  '" ++ selector ++ "' is not present"
        )


{-| Asserts the value of a css property for a given element. Only one element may be matched by the selector.
If the attribute is not present in the element, the assertion will automatically fail.

    css "input.username" "color" <| Expect.equal "#000000"
-}
css : String -> String -> (String -> Expectation) -> Step
css selector name f =
    AssertionMaybe
        (getCssProperty selector name)
        (\res ->
            case res of
                Just attr ->
                    f attr

                _ ->
                    Expect.fail <| "The css property '" ++ name ++ "' for  '" ++ selector ++ "' is not present"
        )


{-| Asserts the HTML of an element. Only one element may be matched by the selector.

    elementHTML "#username" <| Expect.equal "<input id='username' value='jon' />"
-}
elementHTML : String -> (String -> Expectation) -> Step
elementHTML selector f =
    AssertionString (getElementHTML selector) f


{-| Asserts the text node of an element. Only one element may be matched by the selector.

    elementText "p.intro" <| Expect.equal "Welcome to the site!"
-}
elementText : String -> (String -> Expectation) -> Step
elementText selector f =
    AssertionString (getText selector) f


{-| Asserts the value of an input element. Only one element may be matched by the selector.

    inputValue "#username" <| Expect.equal "jon_snow"
-}
inputValue : String -> (String -> Expectation) -> Step
inputValue selector f =
    AssertionString (getValue selector) f


{-| Asserts that an element exists in the page. Only one element may be matched by the selector.

    exists "h1.logo"
-}
exists : String -> Step
exists selector =
    AssertionBool (elementExists selector)
        (\res ->
            if res then
                Expect.pass
            else
                Expect.fail <| "The element '" ++ selector ++ "' was expected to be present"
        )


{-| Asserts that an element exists in the page.  Only one element may be matched by the selector.

    enabled "#username"
-}
inputEnabled : String -> Step
inputEnabled selector =
    AssertionBool (elementEnabled selector)
        (\res ->
            if res then
                Expect.pass
            else
                Expect.fail <| "The input element '" ++ selector ++ "' was expected to be enabled"
        )


{-| Asserts that an element to be visible anywhere in the page. Only one element may be matched by the selector.

    enabled "#username"
-}
visible : String -> Step
visible selector =
    AssertionBool (elementVisible selector)
        (\res ->
            if res then
                Expect.pass
            else
                Expect.fail <| "The input element '" ++ selector ++ "' was expected to be visible"
        )


{-| Asserts that an element to be visible within the viewport. Only one element may be matched by the selector.

    enabled "#username"
-}
visibleWithinViewport : String -> Step
visibleWithinViewport selector =
    AssertionBool (elementVisibleWithinViewport selector)
        (\res ->
            if res then
                Expect.pass
            else
                Expect.fail <| "The input element '" ++ selector ++ "' was expected to be visible within the viewport"
        )


{-| Asserts that a select option is selected. Only one element may be matched by the selector.

    optionSelected "[value=\"foo\"]"
-}
optionSelected : String -> Step
optionSelected selector =
    AssertionBool (optionIsSelected selector)
        (\res ->
            if res then
                Expect.pass
            else
                Expect.fail <| "The option '" ++ selector ++ "' was expected to be selected"
        )


{-| Asserts the size (width, height) of an element. Only one element may be matched by the selector.

    elementSize ".logo" <| (fst >> Expect.equal 100)
-}
elementSize : String -> (( Int, Int ) -> Expectation) -> Step
elementSize selector f =
    AssertionGeometry (getElementSize selector) f


{-| Asserts the position (x, y) of an element. Only one element may be matched by the selector.

    elementPosition ".logo" <| (snd >> Expect.atLeast 330)
-}
elementPosition : String -> (( Int, Int ) -> Expectation) -> Step
elementPosition selector f =
    AssertionGeometry (getElementPosition selector) f


{-| Asserts the position (x, y) of an element relative to the viewport.
Only one element may be matched by the selector.

    elementViewPosition ".logo" <| (snd >> Expect.atLeast 330)
-}
elementViewPosition : String -> (( Int, Int ) -> Expectation) -> Step
elementViewPosition selector f =
    AssertionGeometry (getElementViewPosition selector) f
