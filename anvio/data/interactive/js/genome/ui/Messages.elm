module Messages exposing (..)

import Http
import SharedTypes exposing (Contig)


type Msg
    = Loading
    | DataReceived (Result Http.Error (List Contig))
    | Drawing
    | Done
