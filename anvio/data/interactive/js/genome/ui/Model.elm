module Model exposing (Model, defaultModel)

import Http exposing (..)
import Set exposing (..)
import SharedTypes exposing (Contig)


type alias Model =
    { contigs : List Contig
    , genomes : Set String
    , error : Maybe String
    , basesPerPixel : Float
    }


defaultModel =
    { contigs = []
    , genomes = Set.empty
    , error = Nothing
    , basesPerPixel = 1000.0
    }
