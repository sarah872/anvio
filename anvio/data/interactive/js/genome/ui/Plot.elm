module Plot exposing (plotData)

import Html exposing (Html)
import Model exposing (Model)
import SharedTypes exposing (Contig, Direction(..), Gene, Path, Point)
import Svg exposing (..)
import Svg.Attributes exposing (..)


plotData : Model -> Svg msg
plotData model =
    svg []
        [ g
            []
            (List.map genContigBackground model.contigs)
        ]


genContigBackground : Contig -> Svg msg
genContigBackground contig =
    rect
        [ x "0"
        , y "0"
        , width (String.fromInt contig.length)
        , height "40"
        , fill "green"
        , stroke "black"
        , strokeWidth "2"
        ]
        []



--
-- genGenePath : Gene -> Path
-- genGenePath gene =
--     let
--         genePath =
--             newPath
--                 [ { x = toFloat gene.start, y = 0 }
--                 , { x = toFloat gene.start, y = 20 }
--                 , { x = toFloat gene.stop, y = 20 }
--                 , { x = toFloat gene.stop, y = 0 }
--                 ]
--     in
--     case gene.direction of
--         Forward ->
--             genePath
--
--         Reverse ->
--             flipPathX genePath
-- flipPathX : Path -> Path
-- flipPathX path =
--     let
--         allX =
--             List.map .x path.points
--
--         center =
--             (List.maximum .x + List.minimum .x) / 2
--
--         flipped =
--             List.map (\x -> x) path.points
--     in
--     { path | points = flipped }
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
