module Main exposing (..)

import Browser
import Html exposing (..)
import Loader exposing (fetchData)
import Messages exposing (Msg(..))
import Model exposing (Model, defaultModel)
import Plot exposing (plotData)
import Set exposing (..)



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
    , fetchData
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
        DataReceived (Ok contigs) ->
            ( { model
                | contigs = contigs
                , genomes = Set.fromList (List.map .genome_name contigs)
              }
            , Cmd.none
            )

        DataReceived (Err httpError) ->
            ( { model
                | error = Just (Debug.toString httpError)
              }
            , Cmd.none
            )
