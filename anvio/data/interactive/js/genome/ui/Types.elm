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
    , direction : Maybe String
    }
