module Model exposing (Model, defaultModel)

import Set exposing (..)
import Types exposing (Contig, Gene)


type alias Model =
    { contigs : List Contig
    , genes : List Gene
    , genomes : Set String
    , error : Maybe String
    , scaleX : Float
    , screenCenterAsBasePos : Float
    , contigBarHeight : Int
    , gap : Int
    , leftPanel : String
    , globalClock : Float
    , panelTriggerClock : Float
    }


defaultModel =
    { contigs = []
    , genes = []
    , leftPanel = ""
    , genomes = Set.empty
    , error = Nothing
    , scaleX = 100.0
    , screenCenterAsBasePos = 0.0
    , contigBarHeight = 20
    , gap = 5
    , globalClock = 0
    , panelTriggerClock = 0
    }
