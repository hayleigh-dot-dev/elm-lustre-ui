module Chapters.Tabs exposing (chapter_)

import ElmBook.Chapter exposing (Chapter, chapter, renderComponentList)
import Html exposing (Html)
import Html.Attributes
import Lustre.Ui.Tabs


chapter_ : Chapter x
chapter_ =
    chapter "Tabs"
        |> renderComponentList
            [ ( "Basic", basic ) ]



-- STYLES ----------------------------------------------------------------------


tabs : String
tabs =
    "rounded-md border border-gray-200"


tabsList : String
tabsList =
    "relative z-0 flex items-center gap-1 p-1 shadow-[inset_0_-1px] shadow-gray-200"


tabsTrigger : String
tabsTrigger =
    "flex h-6 items-center justify-center px-2 text-sm text-gray-400 transition-colors duration-300 outline-none hover:text-gray-900 [:state(active)]:text-blue-700"


tabsIndicator : String
tabsIndicator =
    "absolute -z-10 left-0 top-0 h-(--indicator-height) w-(--indicator-width) translate-x-(--indicator-x) translate-y-(--indicator-y) rounded-sm bg-blue-50 transition-[width_height_transform] duration-300 ease-in-out border-b border-transparent has-[~lustre-tabs-trigger:focus]:border-blue-800 has-[~lustre-tabs-trigger:focus]:rounded-b-none"


tabsContent : String
tabsContent =
    "h-32"


tabsPanel : String
tabsPanel =
    "relative flex h-full items-center justify-center -outline-offset-1 outline-blue-800 focus-visible:rounded-b-md focus-visible:outline focus-visible:outline-2"



-- STORIES ---------------------------------------------------------------------


basic : Html msg
basic =
    Lustre.Ui.Tabs.view
        [ Html.Attributes.class tabs ]
        (Lustre.Ui.Tabs.list [ Html.Attributes.class tabsList ]
            [ Lustre.Ui.Tabs.indicator [ Html.Attributes.class tabsIndicator ] []
            , Lustre.Ui.Tabs.trigger "wibble" [ Html.Attributes.class tabsTrigger ] [ Html.text "Wibble" ]
            , Lustre.Ui.Tabs.trigger "wobble" [ Html.Attributes.class tabsTrigger ] [ Html.text "Woooooooobble" ]
            ]
        )
        (Lustre.Ui.Tabs.content [ Html.Attributes.class tabsContent ]
            [ Lustre.Ui.Tabs.panel "wibble" [ Html.Attributes.class tabsPanel ] [ Html.text "wibble." ]
            , Lustre.Ui.Tabs.panel "wobble" [ Html.Attributes.class tabsPanel ] [ Html.text "wobble." ]
            ]
        )
