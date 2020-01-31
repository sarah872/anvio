module Main exposing (Node, Tree)

import Parser exposing (..)


type alias Tree =
    { root : Node }


type alias Node =
    { label : Maybe String
    , children : List Node
    }


isLeaf : Node -> Bool
isLeaf node =
    List.isEmpty node.children


newickParser : Parser Tree
newickParser =
    succeed Tree
        oneOf [
        ,
        ]


tree1 =
    parseNewick "(A:0.1,B:0.2,(C:0.3,D:0.4):0.5);"
