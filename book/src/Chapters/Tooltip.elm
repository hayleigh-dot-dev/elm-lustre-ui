module Chapters.Tooltip exposing (chapter_)

import ElmBook.Chapter exposing (Chapter, chapter, renderComponentList)
import Html exposing (Html)
import Html.Attributes
import Lustre.Ui.Tooltip


chapter_ : Chapter x
chapter_ =
    chapter "Tooltip"
        |> renderComponentList
            [ ( "Top", basicTop )
            , ( "Right", basicRight )
            , ( "Bottom", basicBottom )
            , ( "Left", basicLeft )
            , ( "Controlled (open)", controlled )
            ]



-- STYLES ----------------------------------------------------------------------


buttonStyle : String
buttonStyle =
    "inline-flex justify-center items-center rounded size-8 hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-500"


popoverStyle : String
popoverStyle =
    "flex flex-col px-2 py-1 rounded-md bg-black text-white text-xs shadow opacity-0 scale-99 [:state(open)]:opacity-100 [:state(open)]:scale-100 [:state(top)]:left-(--tooltip-popover-x) [:state(top)]:top-[calc(var(--tooltip-popover-y)+10px)] [:state(top)]:transition-[top_opacity_transform] [:state(top):state(open)]:top-(--tooltip-popover-y) [:state(bottom)]:left-(--tooltip-popover-x) [:state(bottom)]:top-[calc(var(--tooltip-popover-y)-10px)] [:state(bottom)]:transition-[top_opacity_transform] [:state(bottom):state(open)]:top-(--tooltip-popover-y) [:state(left)]:top-(--tooltip-popover-y) [:state(left)]:left-[calc(var(--tooltip-popover-x)+10px)] [:state(left)]:transition-[left_opacity_transform] [:state(left):state(open)]:left-(--tooltip-popover-x) [:state(right)]:top-(--tooltip-popover-y) [:state(right)]:left-[calc(var(--tooltip-popover-x)-10px)] [:state(right)]:transition-[left_opacity_transform] [:state(right):state(open)]:left-(--tooltip-popover-x)"



-- STORIES ---------------------------------------------------------------------


basicTop : Html msg
basicTop =
    Lustre.Ui.Tooltip.view
        [ Lustre.Ui.Tooltip.delay 50 ]
        (Lustre.Ui.Tooltip.popover
            [ Html.Attributes.class popoverStyle
            , Lustre.Ui.Tooltip.side Lustre.Ui.Tooltip.Top
            , Lustre.Ui.Tooltip.offset 10
            ]
            [ Html.text "Bold" ]
        )
        (Lustre.Ui.Tooltip.trigger []
            [ Html.button [ Html.Attributes.class buttonStyle ] [ Html.text "B" ] ]
        )


basicRight : Html msg
basicRight =
    Lustre.Ui.Tooltip.view
        [ Lustre.Ui.Tooltip.delay 50 ]
        (Lustre.Ui.Tooltip.popover
            [ Html.Attributes.class popoverStyle
            , Lustre.Ui.Tooltip.side Lustre.Ui.Tooltip.Right
            , Lustre.Ui.Tooltip.offset 10
            ]
            [ Html.text "Bold" ]
        )
        (Lustre.Ui.Tooltip.trigger []
            [ Html.button [ Html.Attributes.class buttonStyle ] [ Html.text "B" ] ]
        )


basicBottom : Html msg
basicBottom =
    Lustre.Ui.Tooltip.view
        [ Lustre.Ui.Tooltip.delay 50 ]
        (Lustre.Ui.Tooltip.popover
            [ Html.Attributes.class popoverStyle
            , Lustre.Ui.Tooltip.side Lustre.Ui.Tooltip.Bottom
            , Lustre.Ui.Tooltip.offset 10
            ]
            [ Html.text "Bold" ]
        )
        (Lustre.Ui.Tooltip.trigger []
            [ Html.button [ Html.Attributes.class buttonStyle ] [ Html.text "B" ] ]
        )


basicLeft : Html msg
basicLeft =
    Lustre.Ui.Tooltip.view
        [ Lustre.Ui.Tooltip.delay 50 ]
        (Lustre.Ui.Tooltip.popover
            [ Html.Attributes.class popoverStyle
            , Lustre.Ui.Tooltip.side Lustre.Ui.Tooltip.Left
            , Lustre.Ui.Tooltip.offset 10
            ]
            [ Html.text "Bold" ]
        )
        (Lustre.Ui.Tooltip.trigger []
            [ Html.button [ Html.Attributes.class buttonStyle ] [ Html.text "B" ] ]
        )


controlled : Html msg
controlled =
    Lustre.Ui.Tooltip.view
        [ Lustre.Ui.Tooltip.delay 50 ]
        (Lustre.Ui.Tooltip.popover
            [ Html.Attributes.class popoverStyle
            , Lustre.Ui.Tooltip.open True
            ]
            [ Html.text "Bold" ]
        )
        (Lustre.Ui.Tooltip.trigger []
            [ Html.button [ Html.Attributes.class buttonStyle ] [ Html.text "B" ] ]
        )

