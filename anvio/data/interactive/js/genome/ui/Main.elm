module Main exposing (..)

import Browser
import Html exposing (Html)
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


init : ( Model, Cmd Msg )
init =
    ( emptyModel
    , Loading
    )



-- VIEW


view : Model -> Html Msg
view model =
    plotData model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loading ->
            ( model, fetchData )

        DataReceived (Ok contigs) ->
            let
                genomes =
                    Set.fromList (List.map .genome_name contigs)
            in
            ( { model
                | contigs = contigs
                , genomes = genomes
              }
            , plotData
            )

        DataReceived (Err httpError) ->
            ( { model
                | error = Debug.toString httpError
              }
            , Cmd.none
            )

        Drawing ->
            ( model, Cmd.none )
