module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Navigation
import UrlParser


-- MESSAGES


type Msg
    = OnLocationChange Navigation.Location



-- MODELS


type alias Model =
    { route : Route
    }


initialModel : Route -> Model
initialModel route =
    { route = route
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
    "/home"


aboutPath =
    "/about"



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
        [ nav
        , page model
        ]


nav : Html Msg
nav =
    div [] [ a [ href homePath ] [ text "Home" ], text " ", a [ href aboutPath ] [ text "About" ] ]


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
