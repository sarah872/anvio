module Main exposing (..)

import Browser
import Html exposing (..)
import Model exposing (Model, defaultModel)
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
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text "hello world" ]



-- plotData
-- model
-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )
