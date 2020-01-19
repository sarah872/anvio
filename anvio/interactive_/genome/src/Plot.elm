module Plot exposing (plotData)

import Html exposing (Html)
import Model exposing (Model)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Keyed as Keyed exposing (..)
import Types exposing (Contig, Gene)


plotData : Model -> Svg msg
plotData model =
    svg
        [ width "100%"
        , height "100%"
        , Svg.Attributes.style "position: fixed"
        ]
        (genContigBackgrounds
            model
        )


genContigBackgrounds : Model -> List (Svg msg)
genContigBackgrounds model =
    List.indexedMap
        (\index contig ->
            rect
                [ x "0"
                , y
                    (String.fromInt
                        (index * (model.contigBarHeight + model.gap))
                    )
                , width (String.fromInt contig.length)
                , height (String.fromInt model.contigBarHeight)
                , fill "lightgray"
                , strokeWidth "0"
                ]
                []
        )
        model.contigs



-- genGeneArrows : Model -> Contig -> Int -> Svg msg
-- genGeneArrows model contig index =
--     List.map
--         (\_ ->
--             polyline []
--                 []
--         )
--         (List.filter
--             (\_ ->
--                 False
--             )
--             model.genes
--         )
-- genContigBackground : Contig -> Svg msg
-- genContigBackground contig index model =
--
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
