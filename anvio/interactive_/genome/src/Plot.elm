module Plot exposing (plotData)

-- import Svg.Keyed as Keyed exposing (..)
-- import Svg.Lazy as Lazy exposing (..)

import Html exposing (Html)
import Model exposing (Model)
import Svg exposing (..)
import Svg.Attributes exposing (..)
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
            let
                startY =
                    toFloat index * toFloat (model.contigBarHeight + model.gap)
            in
            g []
                (genGeneArrows model contig startY)
         -- rect
         --     [ x "0"
         --     , y (toStr startY)
         --     , width (String.fromInt contig.length)
         --     , height (String.fromInt model.contigBarHeight)
         --     , fill "lightgray"
         --     , strokeWidth "0"
         --     ]
         --     []
        )
        model.contigs


toStr : Float -> String
toStr a =
    String.fromFloat a


genGeneArrows : Model -> Contig -> Float -> List (Svg msg)
genGeneArrows model contig startY =
    List.map
        (\gene ->
            Svg.path
                [ d
                    (String.join
                        " "
                        [ "M" ++ toStr gene.start ++ "," ++ toStr startY
                        , "L" ++ toStr gene.stop ++ "," ++ toStr startY
                        , "L" ++ toStr gene.stop ++ "," ++ toStr (startY + toFloat model.contigBarHeight)
                        , "L" ++ toStr gene.start ++ "," ++ toStr (startY + toFloat model.contigBarHeight)
                        , "Z"
                        ]
                    )
                , strokeWidth "1"
                , stroke "#00000"
                ]
                []
        )
        (List.reverse
            (filterGenes model.genes contig)
        )


filterGenes : List Gene -> Contig -> List Gene
filterGenes allGenes contig =
    List.filter
        (\gene ->
            gene.contig
                == contig.name
                && gene.genome_name
                == contig.genome_name
        )
        allGenes
