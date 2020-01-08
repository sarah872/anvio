module SharedTypes exposing (..)


type alias Contig =
    { name : String
    , length : Int
    , gc_content : Float
    , num_splits : Int
    , genome_name : String
    }


type alias Gene =
    { gene_callers_id : Int
    , start : Int
    , stop : Int
    , partial : Int
    , direction : Direction
    }


type Direction
    = Forward
    | Reverse


type alias Point =
    { x : Float
    , y : Float
    }


type alias Path =
    { points : List Point
    , color : Maybe String
    , fill : Bool
    }
