module Model exposing (Model, emptyModel)

import Http exposing (..)
import Set exposing (..)
import SharedTypes exposing (Contig)


type alias Model =
    { contigs : List Contig
    , genomes : Set String
    , error : Maybe String
    , basesPerPixel : Float
    }


emptyModel =
    { contigs = []
    , genomes = Set.empty
    , error = Nothing
    , basesPerPixel = 1000.0
    }
