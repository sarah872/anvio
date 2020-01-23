module Types exposing (..)


type alias Contig =
    { name : String
    , length : Int
    , gc_content : Float
    , num_splits : Int
    , genome_name : String
    }


type alias Gene =
    { gene_callers_id : Int
    , contig : String
    , start : Float
    , stop : Float
    , direction : String
    , partial : Int
    , source : String
    , version : String
    , genome_name : String
    }
