module Main exposing (..)

import Browser
import Html exposing (..)
import Loader exposing (fetchData)
import Messages exposing (..)
import Model exposing (Model, emptyModel)
import Plot exposing (plotData)
import Set



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
    ( emptyModel
    , Loading
    )



-- VIEW


view : Model -> Html Msg
view model =
    case model.error of
        Nothing ->
            plotData model

        Just errorMessage ->
            div []
                [ h2 []
                    [ text ("Error: " ++ errorMessage) ]
                ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loading ->
            ( model, fetchData )

        DataReceived (Ok contigs) ->
            let
                genomes =
                    Set.insert .genome_name contigs
            in
            ( { model
                | contigs = contigs
                , genomes = genomes
              }
            , plotData
            )

        DataReceived (Err httpError) ->
            ( { model
                | error = Just (Debug.toString httpError)
              }
            , Cmd.none
            )

        Drawing ->
            ( model, Cmd.none )
