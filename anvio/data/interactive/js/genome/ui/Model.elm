module Model exposing (Model, emptyModel)

import Set
import SharedTypes exposing (Contig)


type alias Model =
    { contigs : List Contig
    , genomes : Set String
    , error : Maybe String
    , basesPerPixel : Float
    }


emptyModel =
    { contigs = []
    , genomes = []
    , error = Nothing
    , basesPerPixel = 1000.0
    }
