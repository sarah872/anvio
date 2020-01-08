module Main exposing (Contig, Gene)


type alias Contig =
    { name : String
    , length : Int
    , gc_content : Float
    , num_splits : Int
    , genome_name : String
    , genes : List Gene
    }


type alias Gene =
    { gene_callers_id : Int
    , start : Int
    , stop : Int
    , direction : Direction
    , partial : Int
    }


type Direction
    = Forward
    | Reverse


type alias Point =
    { x : Float
    , y : Float
    }
