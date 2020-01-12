module Messages exposing (Msg(..))

import Http exposing (..)
import Types exposing (Contig)


type Msg
    = DataReceived (Result Http.Error (List Contig))
