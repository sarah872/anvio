module Model exposing (Model, emptyModel)

import SharedTypes exposing (Contig)


type alias Model =
    { contigs : List Contig
    , error : Maybe String
    , basesPerPixel : Float
    }


emptyModel =
    { contigs = []
    , error = Nothing
    , basesPerPixel = 1000.0
    }
