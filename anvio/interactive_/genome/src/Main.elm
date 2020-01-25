module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border exposing (shadow)
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Model exposing (Model, defaultModel)
import Plot exposing (plotData)
import Set exposing (..)
import Types exposing (Contig, Gene)



-- Flags


type alias Flags =
    { data :
        { contigs : List Contig
        , genes : List Gene
        }
    }



-- Msg


type Msg
    = NoOp
    | UpdateParam String String



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { defaultModel
        | contigs = flags.data.contigs
        , genes = flags.data.genes
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Browser.Document msg
view model =
    { title = "Anvi'o Genome Viewer"
    , body =
        [ layout [] <|
            column [ height fill, width fill ]
                [ row
                    [ height <| px 80
                    , width fill
                    , Background.color <| rgb255 89 92 102
                    , Font.color <| rgb255 255 255 255
                    ]
                    [ text "channels" ]
                , row [ width fill, height fill ]
                    [ el
                        [ width fill
                        , height fill
                        , Background.color <| rgb255 235 241 245
                        , inFront <|
                            el
                                [ alignRight
                                , width <| px 300
                                , height fill
                                , alpha 0.98
                                , Background.color <| rgb255 62 65 75
                                ]
                            <|
                                text "placebolder"
                        ]
                      <|
                        html (plotData model)
                    ]
                ]
        ]
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )
