module Webdriver.Branch exposing (..)

{-| Enables you to conditionally execute a list of steps depending on the current
state of the browser.

@docs whenCookie, whenCookieExists, whenCookieNotExists, whenUrl, whenAttribute, whenCss
-}

import Webdriver.Step exposing (..)


{-| Executes the list of steps the passed function returns depending
on the value of the specified cookie
-}
whenCookie : String -> (Maybe String -> List Step) -> Step
whenCookie name f =
    BranchMaybe (getCookie name) f


{-| Executes the provided list of steps if the specified cookie exists
-}
whenCookieExists : String -> List Step -> Step
whenCookieExists name list =
    BranchBool (cookieExists name)
        (\res ->
            if Debug.log "exists" res then
                list
            else
                []
        )


{-| Executes the provided list of steps if the specified cookie does not exist
-}
whenCookieNotExists : String -> List Step -> Step
whenCookieNotExists name list =
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
whenUrl : (String -> List Step) -> Step
whenUrl f =
    BranchString getUrl f


{-| Executes the list of steps the passed function returns depending
on the value of the specified attribute in the given element
-}
whenAttribute : String -> String -> (Maybe String -> List Step) -> Step
whenAttribute selector name f =
    BranchMaybe (getAttribute selector name) f


{-| Executes the list of steps the passed function returns depending
on the value of the specified css attribute in the given element
-}
whenCss : String -> String -> (Maybe String -> List Step) -> Step
whenCss selector name f =
    BranchMaybe (getCssProperty selector name) f
