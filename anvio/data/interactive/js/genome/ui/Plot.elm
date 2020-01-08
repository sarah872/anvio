module Plot exposing (plotData)

import Html exposing (Attribute, Html, div, input, text)
import SharedTypes exposing (Contig, Gene, Point)
import Svg exposing (..)
import Svg.Attributes exposing (..)


plotData : Model -> List Gene -> Html Msg
plotData genes =
    div []
        []


genGenePath : Gene -> List Point
genGenePath gene =
    let
        startPos =
            gene.start
    in
    case gene.direction of
        Forward ->
            "M0,0 L0,6 L9,3 z"

        Reverse ->
            "M0,0 L0,6 L9,3 z"



--
-- view : Model -> Html Msg
-- view model =
--     let
--         gene =
--             { start = 100
--             , end = 200
--             , direction = Forward
--             }
--     in
--     div []
--         [ svg
--             [ width "400"
--             , height "200"
--             ]
--             repeat
--             3
--             [ Svg.path [ d (genGenePath gene) ] []
--             ]
--         ]
