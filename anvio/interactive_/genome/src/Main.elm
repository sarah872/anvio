module Main exposing (..)

import Animation exposing (..)
import Browser
import Browser.Events exposing (onAnimationFrameDelta, onResize)
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
    column [ pointer ]
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


slideIn : Animation
slideIn =
    animation -300
        |> from -300
        |> to 0
        |> duration 10000


settingsPanel : Model -> Element msg
settingsPanel model =
    el
        [ if model.leftPanel == "settings" then
            htmlAttribute <|
                style "display" "block"

          else
            htmlAttribute <|
                style "display" "none"
        , alignRight
        , width <| px 300
        , htmlAttribute <|
            style "right" <|
                String.fromFloat <|
                    animate (model.clock - model.lastClickTime) slideIn
        , height fill
        , alpha 0.98
        , Background.color <| rgb255 235 241 245
        ]
    <|
        text <|
            String.fromFloat <|
                ((model.clock - model.lastClickTime) / 1000)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( { model | clock = model.clock + dt }, Cmd.none )

        TogglePanel panel ->
            ( { model
                | lastClickTime = model.clock
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
