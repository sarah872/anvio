module Main exposing (..)

import Browser
import Html exposing (..)
import Model exposing (defaultModel)
import Plot exposing (plotData)
import Set exposing (..)



-- Msg


type Msg
    = NoOp
    | UpdateParam String String



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( defaultModel
    , NoOp
    )



-- VIEW


view : Model -> Html Msg
view model =
    plotData model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            Nothing
