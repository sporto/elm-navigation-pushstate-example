module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Navigation
import UrlParser


-- MESSAGES


type Msg
    = ChangeLocation String
    | OnLocationChange Navigation.Location



-- MODELS


type alias Model =
    { route : Route
    , changes : Int
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , changes = 0
    }



-- ROUTING


type Route
    = HomeRoute
    | AboutRoute
    | NotFoundRoute


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map HomeRoute UrlParser.top
        , UrlParser.map AboutRoute (UrlParser.s "about")
        ]


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


{-|
When clicking a link we want to prevent the default browser behaviour which is to load a new page.
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
        onWithOptions "click" options (Decode.succeed message)


{-|
We want our links to show a proper href e.g. "/about", so we include an href attribute.
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
