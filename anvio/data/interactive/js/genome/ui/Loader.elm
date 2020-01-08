module Main exposing (fetchData)

import Json.Decode as JD exposing (Decoder, field, float, int, list, string)
import SharedTypes exposing (Contig, Direction, Gene)


fetchData : Cmd Msg
fetchData =
    Http.get
        { url = host ++ "/data/get_contigs"
        , expect = Http.expectJson DataReceived contigListDecoder
        }


contigListDecoder : Decoder (List Contig)
contigListDecoder =
    list contigDecoder


contigDecoder : Decoder Contig
contigDecoder =
    JD.map5 Contig
        (field "name" string)
        (field "length" int)
        (field "gc_content" float)
        (field "num_splits" int)
        (field "genome_name" string)


geneListDecoder : Decoder (List Gene)
geneListDecoder =
    list geneDecoder


geneDecoder : Decoder Gene
geneDecoder =
    JD.map5 Contig
        (field "gene_callers_id" int)
        (field "start" int)
        (field "stop" int)
        (field "patial" int)
        (field "direction" decodeDirection)


directionDecoder : Decoder Direction
directionDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "f" ->
                        Decode.succeed Forward

                    "r" ->
                        Decode.succeed Reverse

                    somethingElse ->
                        Decode.fail <| "Unknown direction: " ++ somethingElse
            )
