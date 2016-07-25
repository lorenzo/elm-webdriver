module Webdriver.Branch exposing (..)

{-| Enables you to conditionally execute a list of steps depending on the current
state of the browser.

## Cookies

@docs ifCookie, ifCookieExists, ifCookieNotExists

## Page properties

@docs ifUrl, ifPageHTML, ifTitle, ifElementCount

## Element properties

@docs ifAttribute, ifCss, ifElementHTML, ifText, ifValue, ifExists, ifNotExist
@docs ifEnabled, ifNotEnabled, ifVisible, ifNotVisible, ifVisibleWithinViewport, ifNotVisibleWithinViewport, ifOptionIsSelected, ifNotOptionIsSelected
@docs ifElementSize, ifElementPosition, ifElementViewPosition
@docs ifTask, ifDriverCommand

-}

import Webdriver.Step exposing (..)
import Webdriver.LowLevel as Wd
import Task exposing (Task)


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


{-| Executes the list of steps if the specified element exists in the DOM
-}
ifExists : String -> List Step -> Step
ifExists selector list =
    BranchBool (elementExists selector)
        (\ex ->
            if ex then
                list
            else
                []
        )


{-| Executes the list of steps if the specified element does not exist in the DOM
-}
ifNotExist : String -> List Step -> Step
ifNotExist selector list =
    BranchBool (elementExists selector)
        (\ex ->
            if ex then
                []
            else
                list
        )


{-| Executes the list of steps if the input element is enabled
-}
ifEnabled : String -> List Step -> Step
ifEnabled selector list =
    BranchBool (elementEnabled selector)
        (\en ->
            if en then
                list
            else
                []
        )


{-| Executes the list of steps if the input element is not enabled
-}
ifNotEnabled : String -> List Step -> Step
ifNotEnabled selector list =
    BranchBool (elementEnabled selector)
        (\en ->
            if en then
                []
            else
                list
        )


{-| Executes the list of steps if element is visible
-}
ifVisible : String -> List Step -> Step
ifVisible selector list =
    BranchBool (elementVisible selector)
        (\res ->
            if res then
                list
            else
                []
        )


{-| Executes the list of steps if element is not visible
-}
ifNotVisible : String -> List Step -> Step
ifNotVisible selector list =
    BranchBool (elementVisible selector)
        (\res ->
            if res then
                []
            else
                list
        )


{-| Executes the list of steps if the element is visible within the viewport
-}
ifVisibleWithinViewport : String -> List Step -> Step
ifVisibleWithinViewport selector list =
    BranchBool (elementVisibleWithinViewport selector)
        (\res ->
            if res then
                list
            else
                []
        )


{-| Executes the list of steps if the element is not visible within the viewport
-}
ifNotVisibleWithinViewport : String -> List Step -> Step
ifNotVisibleWithinViewport selector list =
    BranchBool (elementVisibleWithinViewport selector)
        (\res ->
            if res then
                []
            else
                list
        )


{-| Executes the list of steps if the option in the select box is selected
-}
ifOptionIsSelected : String -> List Step -> Step
ifOptionIsSelected selector list =
    BranchBool (optionIsSelected selector)
        (\res ->
            if res then
                list
            else
                []
        )


{-| Executes the list of steps if the option in the select box is not selected
-}
ifNotOptionIsSelected : String -> List Step -> Step
ifNotOptionIsSelected selector list =
    BranchBool (optionIsSelected selector)
        (\res ->
            if res then
                []
            else
                list
        )


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


{-| Executes the list of steps returned as the result of performing a Task
-}
ifTask : Task Never (List Step) -> Step
ifTask theTask =
    BranchTask theTask


{-| Executes the list of steps resulting of executing a LowLevel Webdriver task. This allows you to create
custom sequences of tasks to be executed directly in the webdriver, maybe after getting
values from other tasks.
-}
ifDriverCommand : (Wd.Browser -> Task Wd.Error a) -> (a -> List Step) -> Step
ifDriverCommand partiallyAppliedTask f =
    let
        task browser =
            partiallyAppliedTask browser
                |> Task.map f
    in
        BranchWebdriver task
