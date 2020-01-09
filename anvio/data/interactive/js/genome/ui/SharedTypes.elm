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
    , fill : Maybe Bool
    }


newPath : List Point -> Path
newPath points color fill =
    { points = points
    , color = Maybe.withDefault color "#000000"
    , fill = Maybe.withDefault fill True
    }


flipPathX : Path -> Path
flipPathX path =
    let
        allX =
            List.map .x path.points

        max =
            maximum allX

        min =
            minimum allX
    in
    {- TO DO: Actually flip it -}
    path
