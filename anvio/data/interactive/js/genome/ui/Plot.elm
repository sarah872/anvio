module Plot exposing (plotData)

import Messages exposing (Msg)
import Model exposing (Model)
import SharedTypes exposing (Contig, Direction(..), Gene, Path)


plotData : Model -> List Path
plotData model =
    []


genGenePath : Gene -> Path
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
