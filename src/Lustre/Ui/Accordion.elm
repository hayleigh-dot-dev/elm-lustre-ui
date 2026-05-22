module Lustre.Ui.Accordion exposing
    ( AccordionItem, AccordionPanel, AccordionTrigger
    , view, item, heading, trigger, panel, close
    , label, loop, open, default_open, value, default_value, single, multiple, horizontal, vertical, level
    , on_value_change, on_open_change, on_show, on_hide
    )

{-| An accordion is made up of one or more collapsible sections with content.
Each accordion item is made up of a header and a trigger button, and the
panel that contains the collapsible content.

    Lustre.Ui.Accordion.view []
        [ Lustre.Ui.Accordion.item
            "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger []
                    [ Html.span [] [ Html.text "..." ] ]
                ]
            )
            (Lustre.Ui.Accordion.panel []
                [ Html.p [] [ Html.text "..." ]
                , Lustre.Ui.Accordion.close []
                    [ Html.text "..." ]
                ]
            )
        ]

  - [`accordion.view`](#view) is the container for all accordion items. It
    manages keyboard interaction and open state for each item.

  - Each [`accordion.item`](#item) represents a single collapsible section
    within the accordion. It must have a unique name within the accordion to
    identify it.

  - An [`accordion.heading`](#heading) contains the trigger button for the
    item as its only child.

  - The [`accordion.trigger`](#trigger) is the button that toggles the open
    state of an accordion item. It must not contain any other interactive
    elements.

  - The [`accordion.panel`](#panel) contains the collapsible content for the
    item.

  - The optional [`accordion.close`](#close) trigger can be placed within the
    panel content to provide an additional way to close the accordion item.


## Accessibility

The accordion component follows the WAI-ARIA Authoring Practices for the
[accordion pattern](https://www.w3.org/WAI/ARIA/apg/patterns/accordion/).
This means appropriate roles, ARIA attributes, and keyboard interactions are
handled for you, including:

  - `role` "region" on the accordion root, with managed `aria-orientation`
    for horizontal or vertical accordions.

  - `role` "heading" on each accordion item heading, with a default `aria-level`
    of 3.

  - `role` "button" on each accordion item trigger, with managed `aria-expanded`,
    and `aria-controls` attributes.

  - `role` "region" on each accordion item panel, with managed `aria-labelledby`
    attribute.

  - Keyboard interactions for navigation between accordion item triggers using
    Arrow Up/Down, Arrow Left/Right, Home, and End keys.

  - Retention of focus when accordion items are closed.


## Usage notes

Avoid accordions with only one item, as they do not provide any functionality
not already provided by the native `<details>` HTML element.


## Recipes

You can use these recipes as starting points to build common types of
accordions. Copy and paste them into your apps and adapt them as needed!


### Basic use

The basic scaffold for any accordion. In this default configuration, the state
of the accordion is uncontrolled and managed internally. Only one item can
open at a time and keyboard navigation does not loop when reaching the first
or last item.

    Lustre.Ui.Accordion.view []
        [ Lustre.Ui.Accordion.item "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.span [] [ Html.text "..." ] ] ]
            )
            (Lustre.Ui.Accordion.panel []
                [ Html.p [] [ Html.text "..." ]
                , Lustre.Ui.Accordion.close [] [ Html.text "..." ]
                ]
            )
        , Lustre.Ui.Accordion.item "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.span [] [ Html.text "..." ] ] ]
            )
            (Lustre.Ui.Accordion.panel []
                [ Html.p [] [ Html.text "..." ]
                , Lustre.Ui.Accordion.close [] [ Html.text "..." ]
                ]
            )
        ]


### Multiple open items, looping navigation

This configuration allows multiple accordion items to be open at once, and
keyboard navigation will loop back to the first item after the last, and vice
versa.

    Lustre.Ui.Accordion.view
        [ Lustre.Ui.Accordion.multiple, Lustre.Ui.Accordion.loop True ]
        [ Lustre.Ui.Accordion.item "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.span [] [ Html.text "..." ] ] ]
            )
            (Lustre.Ui.Accordion.panel []
                [ Html.p [] [ Html.text "..." ]
                , Lustre.Ui.Accordion.close [] [ Html.text "..." ]
                ]
            )
        , Lustre.Ui.Accordion.item "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.span [] [ Html.text "..." ] ] ]
            )
            (Lustre.Ui.Accordion.panel []
                [ Html.p [] [ Html.text "..." ]
                , Lustre.Ui.Accordion.close [] [ Html.text "..." ]
                ]
            )
        ]


### Force item open

By explicitly setting the `open` attribute on an accordion item, it becomes
controlled and will always be open unless the the `open` attribute is changed.
This lets you pin certain items open or closed regardless of user interaction.

    Lustre.Ui.Accordion.view
        [ Lustre.Ui.Accordion.open True ]
        [ Lustre.Ui.Accordion.item "..."
            [ Lustre.Ui.Accordion.open True ]
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.text "..." ] ]
            )
            (Lustre.Ui.Accordion.panel [] [ todo ])
        , Lustre.Ui.Accordion.item "..."
            []
            (Lustre.Ui.Accordion.heading []
                [ Lustre.Ui.Accordion.trigger [] [ Html.text "..." ] ]
            )
            (Lustre.Ui.Accordion.panel [] [ Html.text "..." ])
        ]


## Types

@docs AccordionItem, AccordionPanel, AccordionTrigger


## Elements

@docs view, item, heading, trigger, panel, close


## Attributes

@docs label, loop, open, default_open, value, default_value, single, multiple, horizontal, vertical, level


## Events

@docs on_value_change, on_open_change, on_show, on_hide

-}

import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode


{-| -}
type AccordionItem a
    = AccordionItem
        { name : String
        , attributes : List (Html.Attribute a)
        , heading : Html.Html a
        , panel : AccordionPanel a
        }


{-| -}
type AccordionPanel a
    = AccordionPanel
        { attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| -}
type AccordionTrigger a
    = AccordionTrigger
        { attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| The optional accordion close trigger can be placed within the panel content
to provide an additional way to collapse the containing accordion item without
navigating back to the item header.


#### Tag

```html
<lustre-accordion-trigger>
```


#### Attributes

[`label`](#label).


#### Styling

This element has a default display of `inline`.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the containing accordion item is expanded.


#### Managed attributes

The following attributes **must not** be set manually on the accordion, as
these are managed by the component and are necessary for accessibility:

  - `aria-controls`
  - `aria-expanded`
  - `role`

-}
close : List (Html.Attribute a) -> List (Html.Html a) -> Html.Html a
close attributes children =
    Html.node "lustre-accordion-trigger" attributes children


{-| Set whether an individual [accordion item](#item) is open by default when
first rendered in an _uncontrolled_ accordion. This value is only taken into
account if the containing accordion does not have its own [`default_value`](#default_value)
attribute.
-}
default_open : Bool -> Html.Attribute a
default_open val =
    if val then
        Html.Attributes.attribute "open" ""

    else
        Html.Attributes.classList []


{-| Set the default open items for an _uncontrolled_ accordion. This is a list
of item names that should be open when the accordion first renders.

> **Note**: an uncontrolled component is responsible for managing its own state
> and subsequent changes to the `default_value` will not be reflected in the
> component after the initial render.
>
> To control the accordion's state from your application, use the [`value`](#value)
> attribute instead.

-}
default_value : List String -> Html.Attribute a
default_value items =
    Html.Attributes.attribute "value" (String.join " " items)


{-| An accordion heading heading contains the trigger button for an accordion
item as its only child.


#### Tag

```html
<lustre-accordion-heading>
```


#### Attributes

[`level`](#level).


#### Styling

This element has a default display of `block`.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the containing accordion item is expanded.


#### Managed attributes

The following attributes **must not** be set manually on the heading, as
these are managed by the component and are necessary for accessibility:

  - `role`

-}
heading : List (Html.Attribute a) -> AccordionTrigger a -> Html.Html a
heading attributes (AccordionTrigger t) =
    Html.node "lustre-accordion-heading"
        attributes
        [ Html.node "lustre-accordion-trigger" t.attributes t.children ]


{-| Set an [accordion's](#view) orientation to horizontal. This changes keyboard
navigation to use Arrow Left and Right keys instead of Up and Down.
-}
horizontal : Html.Attribute a
horizontal =
    Html.Attributes.attribute "aria-orientation" "horizontal"


{-| Each accordion item represents a single collapsible section within the
accordion. It must have a unique name within the accordion to identify it.


#### Tag

```html
<lustre-accordion-item>
```


#### Attributes

[`default_open`](#default_open), [`open`](#open).


#### Events

[`on_hide`](#on_hide), [`on_open_change`](#on_open_change), [`on_show`](#on_show).


#### Styling

This element has a default display of `block`.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the accordion item is expanded.

-}
item : String -> List (Html.Attribute a) -> Html.Html a -> AccordionPanel a -> AccordionItem a
item name attributes headingEl panelEl =
    AccordionItem { name = name, attributes = attributes, heading = headingEl, panel = panelEl }


{-| Provides an accessible label to an [accordion](#view) or an [item trigger](#trigger).
When used on an accordion, it is announced by assistive technologies to help
identify the accordion.

It should be used on an accordion item trigger if the trigger's content does
not contain that can be used to automatically generate an accessible label.

In both cases, the label is used for assistive technolgies only and is not
visible to sighted users.

-}
label : String -> Html.Attribute a
label val =
    Html.Attributes.attribute "aria-label" val


{-| Set the heading level for an accordion item's [heading](#heading). This sets
the `aria-level` attribute on the heading element to help assistive technologies
understand the structure of the page. The value is clamped between 1 and 9.
-}
level : Int -> Html.Attribute a
level val =
    Html.Attributes.attribute "aria-level" (String.fromInt (clamp 1 9 val))


{-| Controls whether keyboard navigation in an [accordion](#view) loops from the
last item back to the first and vice versa.
-}
loop : Bool -> Html.Attribute a
loop val =
    if val then
        Html.Attributes.attribute "loop" ""

    else
        Html.Attributes.classList []


{-| Allow multiple accordion items to be open at the same time.
-}
multiple : Html.Attribute a
multiple =
    Html.Attributes.attribute "type" "multiple"


{-| An event emitted by an individual [accordion item](#item) when it is collapsed.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_hide : (String -> a) -> Html.Attribute a
on_hide handler =
    Html.Events.on "accordion/item:hide"
        (Json.Decode.at [ "detail", "id" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| An event emitted by an individual [accordion item](#item) when its open state
changes. The handler is passed the name of the item and its new open state.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_open_change : (( String, Bool ) -> a) -> Html.Attribute a
on_open_change handler =
    Html.Events.on "accordion/item:change"
        (Json.Decode.map2
            (\id_ open_ -> handler ( id_, open_ ))
            (Json.Decode.at [ "detail", "id" ] Json.Decode.string)
            (Json.Decode.at [ "detail", "open" ] Json.Decode.bool)
        )


{-| An event emitted by an individual [accordion item](#item) when it is expanded.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_show : (String -> a) -> Html.Attribute a
on_show handler =
    Html.Events.on "accordion/item:show"
        (Json.Decode.at [ "detail", "id" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| An event emitted by an [accordion](#view) when the open state of any of its
items changes. The handler is passed a list of the names of all currently
open items.

In a controlled accordion, this event should be used to update your application
state with the new open items. Your application may ignore this event to
prevent the open state of the accordion from changing.

In an uncontrolled accordion, this event can be used to respond to changes
in the accordion's open state, for example by loading content dynamically when
an item is opened.

-}
on_value_change : (List String -> a) -> Html.Attribute a
on_value_change handler =
    Html.Events.on "accordion:change"
        (Json.Decode.field "detail" (Json.Decode.list Json.Decode.string)
            |> Json.Decode.map handler
        )


{-| Set the open state of an individual [accordion item](#item), making it
controlled by your application and overriding any state managed by the
containing accordion.

Where possible, it is preferable to manage the open state of accordion items
centrally using the [`value`](#value) attribute on the containing accordion,
but this attribute can be useful when you need to pin certain items open or
closed regardless of user interaction.

> **Note**: in a controlled component, the state is managed by your application
> and must be updated in response to user interaction by handling the
> [`on_open_change`](#on_open_change) event.
>
> To set whether an accordion item is initially open when first rendered,
> consider using the [`default_open`](#default_open) attribute instead.

-}
open : Bool -> Html.Attribute a
open val =
    Html.Attributes.property "open" (Json.Encode.bool val)


{-| The accordion panel contains the collapsible content for the containing
accordion item.


#### Tag

```html
<lustre-accordion-panel>
```


#### Styling

This element has a default display of `block`.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the containing accordion item is expanded.

The following CSS custom properties can be used to style this element or
its children:

  - `--accordion-panel-width`
  - `--accordion-panel-height`


#### Accessibility notes

When the panel is collapsed, any content within is made [inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert).
This prevents focus from moving into the hidden content and ensures screen
readers and other assistive technologies do not announce it. Because of this,
it's important to make sure that the accordion panel is made _visually hidden_
when collapsed so that sighted users do not try to interact with the panel's
content.


#### Managed attributes

The following attributes **must not** be set manually on the accordion, as
these are managed by the component and are necessary for accessibility:

  - `aria-labelledby`

-}
panel : List (Html.Attribute a) -> List (Html.Html a) -> AccordionPanel a
panel attributes children =
    AccordionPanel { attributes = attributes, children = children }


{-| Constrain an accordion to only allow a single item to be open at a time.
-}
single : Html.Attribute a
single =
    Html.Attributes.attribute "type" "single"


{-| The accordion trigger is the button that toggles the open state of an
accordion item. It must not contain any other interactive elements.


#### Tag

```html
<lustre-accordion-trigger>
```


#### Attributes

[`label`](#label).


#### Styling

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the containing accordion item is expanded.


#### Managed attributes

The following attributes **must not** be set manually on the accordion, as
these are managed by the component and are necessary for accessibility:

  - `aria-controls`
  - `aria-expanded`
  - `role`

-}
trigger : List (Html.Attribute a) -> List (Html.Html a) -> AccordionTrigger a
trigger attributes children =
    AccordionTrigger { attributes = attributes, children = children }


{-| Set the current open items for a _controlled_ accordion.

> **Note**: in a controlled component, the state is managed by your application
> and must be updated in response to user interaction by handling the
> [`on_value_change`](#on_value_change) or [`on_open_change`](#on_open_change)
> events.
>
> To let the component manage its own state, use the [`default_value`](#default_value)
> attribute to set the initial open items instead.

-}
value : List String -> Html.Attribute a
value items =
    Html.Attributes.property "value" (Json.Encode.list Json.Encode.string items)


{-| Set an [accordion's](#view) orientation to vertical. This is the default
behaviour for an accordion and uses Arrow Up and Down keys for keyboard
navigation.
-}
vertical : Html.Attribute a
vertical =
    Html.Attributes.attribute "aria-orientation" "vertical"


{-| The root accordion element is a container for multiple accordion items.


#### Tag

```html
<lustre-accordion>
```


#### Attributes

[`default_value`](#default_value), [`horizontal`](#horizontal), [`label`](#label),
[`loop`](#loop), [`multiple`](#multiple), [`single`](#single), [`value`](#value),
[`vertical`](#vertical).


#### Events

[`on_value_change`](#on_value_change)


#### Styling

This element has a default display of `block`.


#### Accessibility notes

The accordion supports keyboard navigation between accordion item triggers
using the following keys _in addition_ to the standard tabbing behaviour:

  - Home moves focus to the first accordion item trigger.
  - End moves focus to the last accordion item trigger.
  - When in a vertical accordion...
      - Arrow Up moves focus to the previous accordion item trigger.
      - Arrow Down moves focus to the next accordion item trigger.
  - When in a horizontal accordion...
      - Arrow Left moves focus to the previous accordion item trigger.
      - Arrow Right moves focus to the next accordion item trigger.

Authors may provide an accessible [`label`](#label) for the accordion to
help assistive technologies identify it, but this is not required.


#### Managed attributes

The following attributes **must not** be set manually on the accordion, as
these are managed by the component and are necessary for accessibility:

  - `role`

-}
view : List (Html.Attribute a) -> List (AccordionItem a) -> Html.Html a
view attributes children =
    Html.node "lustre-accordion"
        attributes
        (List.filterMap
            (\(AccordionItem i) ->
                if i.name == "" then
                    Nothing

                else
                    let
                        (AccordionPanel p) =
                            i.panel
                    in
                    Just
                        (Html.node "lustre-accordion-item"
                            (Html.Attributes.attribute "name" i.name :: i.attributes)
                            [ i.heading
                            , Html.node "lustre-accordion-panel" p.attributes p.children
                            ]
                        )
            )
            children
        )
