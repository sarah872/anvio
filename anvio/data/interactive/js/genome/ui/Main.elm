module Main exposing (..)

import Browser
import Http
import Loader exposing (fetchData)
import Messages exposing (..)
import Model exposing (Model, emptyModel)
import Plot exposing (plotData)



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
    div []
        [ text model.error
        , ul
            []
            (List.map (\x -> text x.name) model.contigs)
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loading ->
            ( model, fetchData )

        DataReceived (Ok contigs) ->
            ( { model
                | contigs = contigs
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