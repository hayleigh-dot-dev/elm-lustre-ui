module Chapters.Toggle exposing (chapter_)

import ElmBook.Chapter exposing (Chapter, chapter, renderComponentList)
import Html exposing (Html)
import Html.Attributes
import Lustre.Ui.Toggle


chapter_ : Chapter x
chapter_ =
    chapter "Toggle"
        |> renderComponentList
            [ ( "Basic", basic )
            , ( "Group", group )
            ]



-- STYLES ----------------------------------------------------------------------


toggle : String
toggle =
    "inline-flex justify-center items-center rounded size-8 hover:bg-gray-100 [:state(pressed)]:bg-blue-50 [:state(pressed)]:text-blue-500 [:state(disabled)]:opacity-50 [:state(disabled)]:cursor-not-allowed focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-500"


groupStyle : String
groupStyle =
    "flex border border-gray-300 rounded *:rounded-none *:first:rounded-l *:last:rounded-r *:focus:z-10"



-- DATA ------------------------------------------------------------------------


type alias ToggleItem =
    { label : String
    , value : String
    , pressed : Bool
    , disabled : Bool
    }


items : List ToggleItem
items =
    [ { label = "B", value = "bold", pressed = False, disabled = False }
    , { label = "I", value = "italic", pressed = True, disabled = False }
    , { label = "U", value = "underline", pressed = False, disabled = True }
    ]



-- STORIES ---------------------------------------------------------------------


basic : Html msg
basic =
    Html.div [ Html.Attributes.class "flex gap-2 items-center" ] <|
        List.map
            (\item_ ->
                Lustre.Ui.Toggle.view
                    [ Html.Attributes.class toggle
                    , Lustre.Ui.Toggle.default_pressed item_.pressed
                    , Lustre.Ui.Toggle.disabled item_.disabled
                    ]
                    [ Html.text item_.label ]
            )
            items


group : Html msg
group =
    Html.div [ Html.Attributes.class "flex gap-4" ]
        [ Lustre.Ui.Toggle.group [ Html.Attributes.class groupStyle, Lustre.Ui.Toggle.loop True ] <|
            List.map
                (\item_ ->
                    Lustre.Ui.Toggle.item item_.value [ Html.Attributes.class toggle ] [ Html.text item_.label ]
                )
                items
        ]