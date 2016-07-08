module Webdriver.Step
    exposing
        ( Step(..)
        , UnitStep(..)
        , MaybeStep(..)
        , StringStep(..)
        , BoolStep(..)
        , Expectation(..)
        , getCookie
        , cookieExists
        , cookieNotExists
        , getUrl
        , getAttribute
        , getCssProperty
        )


type alias Selector =
    String


type Expectation
    = Pass
    | Fail String


{-| The valid actions that can be executed in the browser
-}
type Step
    = ReturningUnit UnitStep
    | BranchMaybe MaybeStep (Maybe String -> List Step)
    | BranchString StringStep (String -> List Step)
    | BranchBool BoolStep (Bool -> List Step)
    | Assertion StringStep (String -> Expectation)


type UnitStep
    = Visit String
    | Click Selector
    | AppendValue String String
    | ClearValue String
    | SetValue Selector String
    | SelectByValue Selector String
    | SelectByIndex Selector Int
    | SelectByText Selector String
    | Submit Selector
    | WaitForExist Selector Int
    | WaitForNotExist Selector Int
    | WaitForVisible Selector Int
    | WaitForNotVisible Selector Int
    | WaitForValue Selector Int
    | WaitForNoValue Selector Int
    | WaitForSelected Selector Int
    | WaitForNotSelected Selector Int
    | WaitForText Selector Int
    | WaitForNoText Selector Int
    | WaitForEnabled Selector Int
    | WaitForNotEnabled Selector Int
    | WaitForDebug
    | Pause Int
    | ScrollTo Selector Int Int
    | Scroll Int Int
    | SavePagecreenshot String
    | SwitchFrame Int
    | TriggerClick Selector
    | Close
    | End


type StringStep
    = Url


type MaybeStep
    = GetAttribute Selector String
    | GetCookie String
    | GetCss Selector String


type BoolStep
    = CookieExists String
    | CookieNotExists String


{-| Returns the value of a cookie by name
-}
getCookie : String -> MaybeStep
getCookie name =
    GetCookie name


{-| Returns true if a cookie exists
-}
cookieExists : String -> BoolStep
cookieExists name =
    CookieExists name


{-| Returns false if a cookie exists
-}
cookieNotExists : String -> BoolStep
cookieNotExists name =
    CookieNotExists name


{-| Returns the current window URL
-}
getUrl : StringStep
getUrl =
    Url


{-| Returns a specific attribute form the element
-}
getAttribute : Selector -> String -> MaybeStep
getAttribute selector name =
    GetAttribute selector name


{-| Returns a specific attribute form the element
-}
getCssProperty : Selector -> String -> MaybeStep
getCssProperty selector name =
    GetCss selector name
