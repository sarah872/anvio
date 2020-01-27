module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border exposing (shadow)
import Element.Events exposing (onClick)
import Element.Font as Font
import Html exposing (Html, button, i, span)
import Html.Attributes exposing (class, style)
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
    | TogglePanel String



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
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


view : Model -> Html Msg
view model =
    layout [] <|
        column [ height fill, width fill ]
            [ navigationPanel model
            , row [ width fill, height fill ]
                [ el
                    [ width fill
                    , height fill
                    , inFront <| settingsPanel model
                    ]
                  <|
                    html (plotData model)
                ]
            ]


navigationPanel : Model -> Element Msg
navigationPanel model =
    row
        [ height <| px 80
        , width fill
        , Background.color <| rgb255 235 241 245
        ]
        [ row
            [ padding 10
            , spacing 7
            , centerX
            ]
            [ el [ onClick <| TogglePanel "settings" ] <| navigationButton "settings"
            , el [ onClick <| TogglePanel "settings" ] <| navigationButton "settings"
            , el [ onClick <| TogglePanel "settings" ] <| navigationButton "settings"
            ]
        ]


navigationButton : String -> Element msg
navigationButton name =
    column []
        [ el [] <|
            html <|
                i
                    [ style "font-size" "40px"
                    , class "material-icons"
                    ]
                    [ Html.text name ]
        , el [] <|
            Element.text name
        ]


settingsPanel : Model -> Element msg
settingsPanel model =
    el
        [ htmlAttribute <| style "display" "visible"
        , alignRight
        , width <| px 300
        , height fill
        , alpha 0.98
        , Background.color <| rgb255 235 241 245
        ]
    <|
        text "placebolder"



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TogglePanel panel ->
            ( { model
                | leftPanel = Just panel
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )
