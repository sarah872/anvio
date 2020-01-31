module Main exposing (..)

import Browser
import Browser.Events exposing (onAnimationFrameDelta, onResize)
import Ease
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
import Time
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
    | Tick Float
    | Resize Int Int



-- MAIN


subs : Sub Msg
subs =
    Sub.batch
        [ onResize Resize
        , onAnimationFrameDelta Tick
        ]


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always subs
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
        , Background.color <| rgb255 240 240 240
        ]
        [ row
            [ padding 10
            , spacing 10
            , centerX
            ]
            [ el [ onClick <| TogglePanel "settings" ] <| navigationButton "settings" "Settings"
            , el [ onClick <| TogglePanel "settings" ] <| navigationButton "clear_all" "Alignment"
            , el [ onClick <| TogglePanel "settings" ] <| navigationButton "color_lens" "Colors"
            , el [ onClick <| TogglePanel "settings" ] <| navigationButton "search" "Search"
            ]
        ]


navigationButton : String -> String -> Element msg
navigationButton name title =
    column [ pointer ]
        [ el
            [ centerX
            ]
          <|
            html <|
                i
                    [ style "font-size" "40px"
                    , class "material-icons"
                    ]
                    [ Html.text name ]
        , el
            [ centerX
            , padding 6
            , Font.size 12
            , htmlAttribute <|
                style "text-transform" "capitalize"
            ]
          <|
            Element.text title
        ]


settingsPanel : Model -> Element msg
settingsPanel model =
    let
        widthPx =
            300

        timeSincePanelTriggered =
            model.globalClock - model.panelTriggerClock
    in
    el
        [ htmlAttribute <|
            style "right" <|
                String.fromFloat
                    (min 0
                        ((-1 * widthPx)
                            + (widthPx
                                * Ease.inQuad (timeSincePanelTriggered * 4)
                              )
                        )
                    )
                    ++ "px"
        , if model.leftPanel == "settings" then
            htmlAttribute <|
                style "display" "block"

          else
            htmlAttribute <|
                style "display" "none"
        , height fill
        , alpha 0.98
        , width <| px widthPx
        , alignRight
        , Background.color <| rgb255 235 241 245
        ]
    <|
        text "Hai"



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( { model | globalClock = model.globalClock + (dt / 1000) }, Cmd.none )

        TogglePanel panel ->
            ( { model
                | panelTriggerClock = model.globalClock
                , leftPanel =
                    if panel == model.leftPanel then
                        {- Hide the panel -}
                        ""

                    else
                        panel
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )
