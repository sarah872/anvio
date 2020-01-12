module Model exposing (Model, defaultModel)

import Http exposing (..)
import Set exposing (..)
import Types exposing (Contig)


type alias Model =
    { contigs : List Contig
    , genomes : Set String
    , error : Maybe String
    , scaleX : Float
    , screenCenterAsBasePos : Float
    , contigBarHeight : Int
    , gap : Int
    }


defaultModel =
    { contigs = []
    , genomes = Set.empty
    , error = Nothing
    , scaleX = 10000.0
    , screenCenterAsBasePos = 0.0
    , contigBarHeight = 20
    , gap = 5
    }
