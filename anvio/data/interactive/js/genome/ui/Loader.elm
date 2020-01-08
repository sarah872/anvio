module Loader exposing (fetchData)

{- Note: Msg(..) imports all Message variant types -}

import Http
import Json.Decode as JD exposing (Decoder, andThen, fail, field, float, int, list, string, succeed)
import Messages exposing (Msg(..))
import SharedTypes exposing (..)


host =
    "http://localhost:8080"


fetchData : Cmd Msg
fetchData =
    Http.get
        { url = host ++ "/data/get_contigs"
        , expect = Http.expectJson DataReceived contigListDecoder
        }



{- Parse contig data -}


contigDecoder : Decoder Contig
contigDecoder =
    JD.map5 Contig
        (field "name" string)
        (field "length" int)
        (field "gc_content" float)
        (field "num_splits" int)
        (field "genome_name" string)


contigListDecoder : Decoder (List Contig)
contigListDecoder =
    list contigDecoder



{- Parse gene data -}


geneListDecoder : Decoder (List Gene)
geneListDecoder =
    list geneDecoder


geneDecoder : Decoder Gene
geneDecoder =
    JD.map5 Gene
        (field "gene_callers_id" int)
        (field "start" int)
        (field "stop" int)
        (field "patial" int)
        (field "direction" directionDecoder)


directionDecoder : Decoder Direction
directionDecoder =
    string
        |> andThen
            (\str ->
                case str of
                    "f" ->
                        succeed Forward

                    "r" ->
                        succeed Reverse

                    somethingElse ->
                        fail <| "Unknown direction: " ++ somethingElse
            )
