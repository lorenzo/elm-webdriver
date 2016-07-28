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
    BranchMaybe (initMeta <| "Check cookie '" ++ name ++ "' value and execute branch")
        (getCookie name)
        f


{-| Executes the provided list of steps if the specified cookie exists
-}
ifCookieExists : String -> List Step -> Step
ifCookieExists name list =
    BranchBool (initMeta <| "Check if the cookie '" ++ name ++ "' exists and execute branch")
        (cookieExists name)
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
    BranchBool (initMeta <| "Check if the cookie '" ++ name ++ "' does not exist and execute branch")
        (cookieNotExists name)
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
    BranchString (initMeta "Check current url and execute branch") getUrl f


{-| Executes the list of steps the passed function returns depending
on the current page title
-}
ifTitle : (String -> List Step) -> Step
ifTitle f =
    BranchString (initMeta "Check current title and execute branch") getTitle f


{-| Executes the list of steps the passed function returns depending
on the current page source
-}
ifPageHTML : (String -> List Step) -> Step
ifPageHTML f =
    BranchString (initMeta "Check HTML and execute branch") getPageHTML f


{-| Executes the list of steps the passed function returns depending
on the value of the specified attribute in the given element
-}
ifAttribute : String -> String -> (Maybe String -> List Step) -> Step
ifAttribute selector name f =
    BranchMaybe (initMeta <| "Check the '" ++ name ++ "' attribute for <" ++ selector ++ "> and execute branch")
        (getAttribute selector name)
        f


{-| Executes the list of steps the passed function returns depending
on the value of the specified css attribute in the given element
-}
ifCss : String -> String -> (Maybe String -> List Step) -> Step
ifCss selector name f =
    BranchMaybe (initMeta <| "Check the '" ++ name ++ "' css attribute for <" ++ selector ++ "> and execute branch")
        (getCssProperty selector name)
        f


{-| Executes the list of steps the passed function returns depending
on the value of the HTMl for the given element
-}
ifElementHTML : String -> (String -> List Step) -> Step
ifElementHTML selector f =
    BranchString (initMeta <| "Check the HTML for <" ++ selector ++ "> and execute branch")
        (getElementHTML selector)
        f


{-| Executes the list of steps the passed function returns depending
on the value of the text node of the given element
-}
ifText : String -> (String -> List Step) -> Step
ifText selector f =
    BranchString (initMeta <| "Check the text for <" ++ selector ++ "> and execute branch")
        (getText selector)
        f


{-| Executes the list of steps the passed function returns depending
on the value of the specified input field
-}
ifValue : String -> (String -> List Step) -> Step
ifValue selector f =
    BranchString (initMeta <| "Check the value for the <" ++ selector ++ "> input and execute branch")
        (getValue selector)
        f


{-| Executes the list of steps if the specified element exists in the DOM
-}
ifExists : String -> List Step -> Step
ifExists selector list =
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is present and execute branch")
        (elementExists selector)
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
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is not present and execute branch")
        (elementExists selector)
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
    BranchBool (initMeta <| "Check if the <" ++ selector ++ "> input is enabled and execute branch")
        (elementEnabled selector)
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
    BranchBool (initMeta <| "Check if the <" ++ selector ++ "> input is not present and execute branch")
        (elementEnabled selector)
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
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is visible and execute branch")
        (elementVisible selector)
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
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is not visible and execute branch")
        (elementVisible selector)
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
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is visible within the viewport and execute branch")
        (elementVisibleWithinViewport selector)
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
    BranchBool (initMeta <| "Check if <" ++ selector ++ "> is not visible within the viewport and execute branch")
        (elementVisibleWithinViewport selector)
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
    BranchBool (initMeta <| "Check if the option <" ++ selector ++ "> is selected and execute branch")
        (optionIsSelected selector)
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
    BranchBool (initMeta <| "Check if the option <" ++ selector ++ "> is not selected and execute branch")
        (optionIsSelected selector)
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
    BranchGeometry (initMeta <| "Check the size of <" ++ selector ++ "> and execute branch")
        (getElementSize selector)
        f


{-| Executes the list of steps the passed function returns depending
on the location (x, y) of the element
-}
ifElementPosition : String -> (( Int, Int ) -> List Step) -> Step
ifElementPosition selector f =
    BranchGeometry (initMeta <| "Check the position of <" ++ selector ++ "> and execute branch")
        (getElementPosition selector)
        f


{-| Executes the list of steps the passed function returns depending
on the location (x, y) of the element relative to the current viewport
-}
ifElementViewPosition : String -> (( Int, Int ) -> List Step) -> Step
ifElementViewPosition selector f =
    BranchGeometry (initMeta <| "Check the position of <" ++ selector ++ "> in the viewport and execute branch")
        (getElementViewPosition selector)
        f


{-| Executes the list of steps the passed function returns depending
on the number of elements returned by the selector
-}
ifElementCount : String -> (Int -> List Step) -> Step
ifElementCount selector f =
    BranchInt (initMeta <| "Check the amout of elements for <" ++ selector ++ "> and execute branch")
        (countElements selector)
        f


{-| Executes the list of steps returned as the result of performing a Task
-}
ifTask : Task Never (List Step) -> Step
ifTask theTask =
    BranchTask (initMeta "Perform a custom task and execute branch") theTask


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
        BranchWebdriver (initMeta "Preform a custom webdriver command and execute task") task
