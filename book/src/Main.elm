module Main exposing (main)

import Chapters.Accordion
import Chapters.Tabs
import Chapters.Toggle
import Chapters.Tooltip
import ElmBook exposing (book, withChapters)
import ElmBook.ThemeOptions


main =
    book "Lustre UI"
        |> ElmBook.withThemeOptions
            [ ElmBook.ThemeOptions.subtitle "Unstyled ui components for accessible elm apps."
            ]
        |> withChapters
            [ Chapters.Accordion.chapter_
            , Chapters.Tabs.chapter_
            , Chapters.Toggle.chapter_
            , Chapters.Tooltip.chapter_
            ]
