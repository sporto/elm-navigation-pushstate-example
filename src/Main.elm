module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Navigation
import UrlParser


-- MESSAGES


{-|

  - ChangeLocation will be used for initiating a url change
  - OnLocationChange will be triggered after a location change
-}
type Msg
    = ChangeLocation String
    | OnLocationChange Navigation.Location



-- MODELS


{-|

  - `route` will hold the current matched route
  - `changes` is just here to prove that we are not reloading the page and wiping out the app state
-}
type alias Model =
    { route : Route
    , changes : Int
    }


{-| initialModel will be called with the current matched route.
We store this in the model so we can display the corrent view.
-}
initialModel : Route -> Model
initialModel route =
    { route = route
    , changes = 0
    }



-- ROUTING


{-| This are our available routes
NotFoundRoute will be used when we cannot match a route.
-}
type Route
    = HomeRoute
    | AboutRoute
    | NotFoundRoute


{-| Define how to match urls
-}
matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map HomeRoute UrlParser.top
        , UrlParser.map AboutRoute (UrlParser.s "about")
        ]


{-| Match a location given by the Navigation package and return the matched route.
-}
parseLocation : Navigation.Location -> Route
parseLocation location =
    case (UrlParser.parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


homePath =
    "/"


aboutPath =
    "/about"



-- UPDATE


{-| On `ChangeLocation` call `Navigation.newUrl` to create a command that will change the browser location.

`OnLocationChange` will be called each time the browser location changes.
In this case we store the new route in the Model.

-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeLocation path ->
            ( { model | changes = model.changes + 1 }, Navigation.newUrl path )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )



-- VIEWS


view : Model -> Html Msg
view model =
    div []
        [ nav model
        , page model
        ]


{-| When clicking a link we want to prevent the default browser behaviour which is to load a new page.
Unless the ctrl or command key is pressed.
So we use `onWithOptions` instead of `onClick`.
-}
onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
        onWithOptions
            "click"
            options
            (preventDefaultUnlessKeyPressed
                |> Decode.andThen (maybePreventDefault message)
            )


preventDefaultUnlessKeyPressed : Decode.Decoder Bool
preventDefaultUnlessKeyPressed =
    Decode.map2
        nor
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "metaKey" Decode.bool)


nor : Bool -> Bool -> Bool
nor x y =
    not (x || y)


maybePreventDefault : msg -> Bool -> Decode.Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Decode.succeed msg

        False ->
            Decode.fail "Delegated to browser default"


{-| We want our links to show a proper href e.g. "/about", so we include an href attribute.
onLinkClick will prevent the browser reloading the page.
-}
nav : Model -> Html Msg
nav model =
    div []
        [ a [ href homePath, onLinkClick (ChangeLocation homePath) ] [ text "Home" ]
        , text " "
        , a [ href aboutPath, onLinkClick (ChangeLocation aboutPath) ] [ text "About" ]
        , text (" " ++ toString model.changes)
        ]


{-| Decide what to show based on the current `model.route`
-}
page : Model -> Html Msg
page model =
    case model.route of
        HomeRoute ->
            text "Home"

        AboutRoute ->
            text "About"

        NotFoundRoute ->
            text "Not Found"



-- PROGRAM


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
