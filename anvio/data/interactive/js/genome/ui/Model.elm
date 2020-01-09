module Model exposing (Model, emptyModel)

import SharedTypes exposing (Contig)


type alias Model =
    { contigs : List Contig
    , genomes : List String
    , error : Maybe String
    , basesPerPixel : Float
    }


emptyModel =
    { contigs = []
    , genomes = []
    , error = Nothing
    , basesPerPixel = 1000.0
    }
