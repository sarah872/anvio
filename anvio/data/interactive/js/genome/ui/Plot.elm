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

        genePath =
            newPath
                [ { x = 0, y = 0 }
                , { x = 10, y = 10 }
                , { x = 10, y = 15 }
                ]
    in
    case gene.direction of
        Forward ->
            genePath

        Reverse ->
            flipPathX genePath



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
