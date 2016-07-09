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
        , getElementHTML
        , getPageHTML
        , getText
        , getTitle
        , getValue
        , elementExists
        , elementEnabled
        , elementVisible
        , elementVisibleWithinViewport
        , optionIsSelected
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
    = GetUrl
    | GetHtml String
    | GetSource
    | GetTitle
    | GetText String
    | GetValue String


type MaybeStep
    = GetAttribute Selector String
    | GetCookie String
    | GetCss Selector String


type BoolStep
    = CookieExists String
    | CookieNotExists String
    | ElementExists String
    | ElementEnabled String
    | ElementVisible String
    | ElementViewportVisible String
    | OptionSelected String


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
    GetUrl


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


{-| Returns the HTML for an element
-}
getElementHTML : Selector -> StringStep
getElementHTML selector =
    GetHtml selector


{-| Returns the page HTML
-}
getPageHTML : StringStep
getPageHTML =
    GetSource


{-| Returns the page title
-}
getTitle : StringStep
getTitle =
    GetTitle


{-| Returns the concatenation of all text nodes for the element
-}
getText : String -> StringStep
getText selector =
    GetText selector


{-| Returns the value for the given input
-}
getValue : String -> StringStep
getValue selector =
    GetValue selector


{-| Returns whether or not an element exists in the page
-}
elementExists : String -> BoolStep
elementExists selector =
    ElementExists selector


{-| Returns whether or not an input is enabled
-}
elementEnabled : String -> BoolStep
elementEnabled selector =
    ElementEnabled selector


{-| Returns whether or not an element is visible
-}
elementVisible : String -> BoolStep
elementVisible selector =
    ElementVisible selector


{-| Returns whether or not an element is visible within
the viewport
-}
elementVisibleWithinViewport : String -> BoolStep
elementVisibleWithinViewport selector =
    ElementViewportVisible selector


{-| Returns whether or not an select option is currently selected
-}
optionIsSelected : String -> BoolStep
optionIsSelected selector =
    OptionSelected selector
