module Messages exposing (Msg(..))

import Http exposing (..)
import SharedTypes exposing (Contig)


type Msg
    = DataReceived (Result Http.Error (List Contig))
