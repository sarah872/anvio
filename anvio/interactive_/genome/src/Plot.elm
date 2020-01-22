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
                (genGeneArrows model contig index)
        )
        model.contigs


genGeneArrows : Model -> Contig -> Int -> List (Svg msg)
genGeneArrows model contig index =
    let
        start =
            String.fromInt (index * (model.contigBarHeight + model.gap))
    in
    List.map
        (\gene ->
            polyline [ points (start ++ ",10 10,10 20,20 30,30") ]
                []
        )
        (filterGenes model.genes contig)


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
