module Model exposing (Model, defaultModel)

import Animation exposing (Clock)
import Http exposing (..)
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
    , clock : Clock
    , lastClickTime : Clock
    }


defaultModel =
    { contigs = []
    , genes = []
    , leftPanel = ""
    , genomes = Set.empty
    , error = Nothing
    , scaleX = 2000.0
    , screenCenterAsBasePos = 0.0
    , contigBarHeight = 20
    , gap = 5
    , clock = 0
    , lastClickTime = 0
    }
