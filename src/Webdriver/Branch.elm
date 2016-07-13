module Webdriver.Branch exposing (..)

{-| Enables you to conditionally execute a list of steps depending on the current
state of the browser.

## Cookies

@docs ifCookie, ifCookieExists, ifCookieNotExists

## Page properties

@docs ifUrl, ifPageHTML, ifTitle, ifElementCount

## Element properties

@docs ifAttribute, ifCss, ifElementHTML, ifText, ifValue, ifExists
@docs ifEnabled, ifVisible, ifVisibleWithinViewport, ifOptionIsSelected
@docs ifElementSize, ifElementPosition, ifElementViewPosition

-}

import Webdriver.Step exposing (..)


{-| Executes the list of steps the passed function returns depending
on the value of the specified cookie
-}
ifCookie : String -> (Maybe String -> List Step) -> Step
ifCookie name f =
    BranchMaybe (getCookie name) f


{-| Executes the provided list of steps if the specified cookie exists
-}
ifCookieExists : String -> List Step -> Step
ifCookieExists name list =
    BranchBool (cookieExists name)
        (\res ->
            if res then
                list
            else
                []
        )


{-| Executes the provided list of steps if the specified cookie does not exist
-}
ifCookieNotExists : String -> List Step -> Step
ifCookieNotExists name list =
    BranchBool (cookieNotExists name)
        (\res ->
            if res then
                list
            else
                []
        )


{-| Executes the list of steps the passed function returns depending
on the current url
-}
ifUrl : (String -> List Step) -> Step
ifUrl f =
    BranchString getUrl f


{-| Executes the list of steps the passed function returns depending
on the current page title
-}
ifTitle : (String -> List Step) -> Step
ifTitle f =
    BranchString getTitle f


{-| Executes the list of steps the passed function returns depending
on the current page source
-}
ifPageHTML : (String -> List Step) -> Step
ifPageHTML f =
    BranchString getPageHTML f


{-| Executes the list of steps the passed function returns depending
on the value of the specified attribute in the given element
-}
ifAttribute : String -> String -> (Maybe String -> List Step) -> Step
ifAttribute selector name f =
    BranchMaybe (getAttribute selector name) f


{-| Executes the list of steps the passed function returns depending
on the value of the specified css attribute in the given element
-}
ifCss : String -> String -> (Maybe String -> List Step) -> Step
ifCss selector name f =
    BranchMaybe (getCssProperty selector name) f


{-| Executes the list of steps the passed function returns depending
on the value of the HTMl for the given element
-}
ifElementHTML : String -> (String -> List Step) -> Step
ifElementHTML selector f =
    BranchString (getElementHTML selector) f


{-| Executes the list of steps the passed function returns depending
on the value of the text node of the given element
-}
ifText : String -> (String -> List Step) -> Step
ifText selector f =
    BranchString (getText selector) f


{-| Executes the list of steps the passed function returns depending
on the value of the specified input field
-}
ifValue : String -> (String -> List Step) -> Step
ifValue selector f =
    BranchString (getValue selector) f


{-| Executes the list of steps the passed function returns depending
on whether or not the input field is enabled
-}
ifExists : String -> (Bool -> List Step) -> Step
ifExists selector f =
    BranchBool (elementExists selector) f


{-| Executes the list of steps the passed function returns depending
on whether or not the element exists
-}
ifEnabled : String -> (Bool -> List Step) -> Step
ifEnabled selector f =
    BranchBool (elementEnabled selector) f


{-| Executes the list of steps the passed function returns depending
on whether or not the element is visible
-}
ifVisible : String -> (Bool -> List Step) -> Step
ifVisible selector f =
    BranchBool (elementVisible selector) f


{-| Executes the list of steps the passed function returns depending
on whether or not the element is visible within the viewport
-}
ifVisibleWithinViewport : String -> (Bool -> List Step) -> Step
ifVisibleWithinViewport selector f =
    BranchBool (elementVisibleWithinViewport selector) f


{-| Executes the list of steps the passed function returns depending
on whether or not the options in the select box is selected
-}
ifOptionIsSelected : String -> (Bool -> List Step) -> Step
ifOptionIsSelected selector f =
    BranchBool (optionIsSelected selector) f


{-| Executes the list of steps the passed function returns depending
on the size (width, height) of the element
-}
ifElementSize : String -> (( Int, Int ) -> List Step) -> Step
ifElementSize selector f =
    BranchGeometry (getElementSize selector) f


{-| Executes the list of steps the passed function returns depending
on the location (x, y) of the element
-}
ifElementPosition : String -> (( Int, Int ) -> List Step) -> Step
ifElementPosition selector f =
    BranchGeometry (getElementPosition selector) f


{-| Executes the list of steps the passed function returns depending
on the location (x, y) of the element relative to the current viewport
-}
ifElementViewPosition : String -> (( Int, Int ) -> List Step) -> Step
ifElementViewPosition selector f =
    BranchGeometry (getElementViewPosition selector) f


{-| Executes the list of steps the passed function returns depending
on the number of elements returned by the selector
-}
ifElementCount : String -> (Int -> List Step) -> Step
ifElementCount selector f =
    BranchInt (countElements selector) f
