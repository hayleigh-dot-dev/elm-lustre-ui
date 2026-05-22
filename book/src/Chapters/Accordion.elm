module Chapters.Accordion exposing (chapter_)

import ElmBook.Chapter exposing (Chapter, chapter, renderComponentList)
import Html
import Html.Attributes
import Lustre.Ui.Accordion


chapter_ : Chapter x
chapter_ =
    chapter "Accordion"
        |> renderComponentList
            [ ( "Basic", basic )
            , ( "Default open", defaultOpen )
            , ( "Multiple", playgroundMultiple )
            , ( "Loop", playgroundLoop )
            ]



-- STYLES ----------------------------------------------------------------------


accordion : String
accordion =
    ""


accordionItem : String
accordionItem =
    "border-b border-gray-100"


accordionTrigger : String
accordionTrigger =
    "block w-full bg-gray-50 p-2 text-left hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-800"


accordionPanel : String
accordionPanel =
    "h-(--accordion-panel-height) overflow-hidden transition-[height] ease-out"


accordionClose : String
accordionClose =
    "float-right mt-2 rounded px-2 py-1 text-sm hover:bg-gray-100"

-- DATA ------------------------------------------------------------------------


items : List ( String, String )
items =
    [ ( "What is lustre/ui?"
      , "Lustre/ui is a collection of unstyled Web Components components developed with a focus on accessibility and usability."
      )
    , ( "What does accessibility mean?"
      , "Accessibility means that Lustre components are built to be usable by as many people as possible. We follow WAI-ARIA guidelines to ensure these components are accessible to keyboard and screen reader users."
      )
    , ( "How do I use lustre/ui?"
      , "The hayleigh-dot-dev/elm-lustre-ui package provides Elm bindings for each Web Component and a prebuilt JavaScript bundle: then it's as simple as using any other HTML element!"
      )
    ]



-- STORIES ---------------------------------------------------------------------


basic : Html.Html msg
basic =
    Lustre.Ui.Accordion.view [ Html.Attributes.class accordion ] <|
        List.indexedMap
            (\index ( question, answer ) ->
                Lustre.Ui.Accordion.item
                    ("item-" ++ String.fromInt index)
                    [ Html.Attributes.class accordionItem ]
                    (Lustre.Ui.Accordion.heading []
                        (Lustre.Ui.Accordion.trigger [ Html.Attributes.class accordionTrigger ]
                            [ Html.text question ]
                        )
                    )
                    (Lustre.Ui.Accordion.panel [ Html.Attributes.class accordionPanel ]
                        [ Html.p [ Html.Attributes.class "p-2" ] [ Html.text answer ]
                        , Lustre.Ui.Accordion.close [ Html.Attributes.class accordionClose] [ Html.text "Close" ]
                        ]
                    )
            )
            items


defaultOpen : Html.Html msg
defaultOpen =
    Lustre.Ui.Accordion.view [ Html.Attributes.class accordion ] <|
        List.indexedMap
            (\index ( question, answer ) ->
                Lustre.Ui.Accordion.item
                    ("item-" ++ String.fromInt index)
                    [ Html.Attributes.class accordionItem
                    , Lustre.Ui.Accordion.default_open (index == 1)
                    ]
                    (Lustre.Ui.Accordion.heading []
                        (Lustre.Ui.Accordion.trigger [ Html.Attributes.class accordionTrigger ]
                            [ Html.text question ]
                        )
                    )
                    (Lustre.Ui.Accordion.panel [ Html.Attributes.class accordionPanel ]
                        [ Html.p [ Html.Attributes.class "p-2" ] [ Html.text answer ] ]
                    )
            )
            items


playgroundMultiple : Html.Html msg
playgroundMultiple =
    Lustre.Ui.Accordion.view [ Html.Attributes.class accordion, Lustre.Ui.Accordion.multiple ] <|
        List.indexedMap
            (\index ( question, answer ) ->
                Lustre.Ui.Accordion.item
                    ("item-" ++ String.fromInt index)
                    [ Html.Attributes.class accordionItem ]
                    (Lustre.Ui.Accordion.heading []
                        (Lustre.Ui.Accordion.trigger [ Html.Attributes.class accordionTrigger ]
                            [ Html.text question ]
                        )
                    )
                    (Lustre.Ui.Accordion.panel [ Html.Attributes.class accordionPanel ]
                        [ Html.p [ Html.Attributes.class "p-2" ] [ Html.text answer ] ]
                    )
            )
            items


playgroundLoop : Html.Html msg
playgroundLoop =
    Lustre.Ui.Accordion.view [ Html.Attributes.class accordion, Lustre.Ui.Accordion.loop True ] <|
        List.indexedMap
            (\index ( question, answer ) ->
                Lustre.Ui.Accordion.item
                    ("item-" ++ String.fromInt index)
                    [ Html.Attributes.class accordionItem ]
                    (Lustre.Ui.Accordion.heading []
                        (Lustre.Ui.Accordion.trigger [ Html.Attributes.class accordionTrigger ]
                            [ Html.text question ]
                        )
                    )
                    (Lustre.Ui.Accordion.panel [ Html.Attributes.class accordionPanel ]
                        [ Html.p [ Html.Attributes.class "p-2" ] [ Html.text answer ] ]
                    )
            )
            items

