module Plot exposing (plotData)

import Html exposing (Html)
import Model exposing (Model)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Keyed as Keyed exposing (..)
import Svg.Lazy exposing (lazy3)
import Types exposing (Contig, Gene)


plotData : Model -> Html msg
plotData model =
    svg
        [ width "100%"
        , height "100%"
        , Svg.Attributes.style "position: relative"
        ]
        (List.indexedMap
            (\index contig ->
                let
                    startY =
                        toFloat
                            index
                            * toFloat (model.contigBarHeight + model.gap)
                in
                g []
                    [ rect
                        [ x "0"
                        , y (toStr startY)
                        , width (toStr (toFloat contig.length / model.scaleX))
                        , height (String.fromInt model.contigBarHeight)
                        , fill "lightgray"
                        , strokeWidth "0"
                        ]
                        []
                    , g []
                        (genGeneArrows
                            model
                            contig
                            startY
                        )

                    --
                    -- [ lazy3 genGeneArrows
                    --     model
                    --     contig
                    --     startY
                    -- ]
                    ]
            )
            model.contigs
        )


toStr : Float -> String
toStr a =
    String.fromFloat a


genGeneArrows : Model -> Contig -> Float -> List (Svg msg)
genGeneArrows model contig startY =
    let
        sX =
            \n -> toStr (n / model.scaleX)

        sY =
            {- TO DO: There is no scaleY yet -}
            \n -> toStr (n / model.scaleX)
    in
    List.map
        (\gene ->
            Keyed.node "path"
                [ d
                    (String.join
                        " "
                        [ "M" ++ sX gene.start ++ "," ++ sY startY
                        , "L" ++ sX gene.stop ++ "," ++ sY startY
                        , "L" ++ sX gene.stop ++ "," ++ sY (startY + toFloat model.contigBarHeight)
                        , "L" ++ sX gene.start ++ "," ++ sY (startY + toFloat model.contigBarHeight)
                        , "Z"
                        ]
                    )
                , strokeWidth "1"
                , stroke "#00000"
                ]
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
