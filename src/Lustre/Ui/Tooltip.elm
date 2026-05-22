module Lustre.Ui.Tooltip exposing
    ( Alignment(..), Popover, Side(..), Trigger
    , view, popover, trigger
    , align, default_open, delay, offset, open, side
    , on_open_change, on_activate, on_dismiss
    )

{-| A tooltip is a hint for sighted users that appears when an element is hovered
or receives keyboard focus. Tooltips are helpful in visually dense interfaces
to provide additional context or information about an action or element.

    Lustre.Ui.Tooltip.view []
        (Lustre.Ui.Tooltip.popover [] [ Html.text "Tooltip content" ])
        (Lustre.Ui.Tooltip.trigger [] [ Html.text "Hover me" ])

  - [`tooltip.view`](#view) is the root container for both the trigger element
    and its popopver.

  - The [`tooltip.popover`](#popover) contains the content that should be
    revealed on hover.

  - The [`tooltip.trigger`](#trigger) contains the element that will trigger
    the popover when hovered or focused.


## Accessibility

Tooltips are supplementary aides for sighted users, and have some important
accessibility concerns that must be accounted for. For non-sighted users,
**tooltips are never a substitute for accessible labels** as the popover
content is not accessible to screen readers. Additionally, users of touch
devices may not be able to reliably trigger the tooltip. Because of this,
the content rendered inside a tooltip's popover is considered inert and must
not be interactive.


## Usage notes

The content inside the tooltip's popover is marked as inert and should not
contain interactive elements like links or buttons.


## Recipes

You can use these recipes as starting points for tooltips. Copy and paste
them into your apps and adapt them as needed!


### Basic use

    Lustre.Ui.Tooltip.view []
        (Lustre.Ui.Tooltip.popover [] [ Html.text "Tooltip content" ])
        (Lustre.Ui.Tooltip.trigger [] [ Html.text "Hover me" ])


### No delay

    Lustre.Ui.Tooltip.view [ Lustre.Ui.Tooltip.delay 0 ]
        (Lustre.Ui.Tooltip.popover [] [ Html.text "Tooltip content" ])
        (Lustre.Ui.Tooltip.trigger [] [ Html.text "Hover me" ])


### Right side, end aligned

    Lustre.Ui.Tooltip.view []
        (Lustre.Ui.Tooltip.popover
            [ Lustre.Ui.Tooltip.side Right, Lustre.Ui.Tooltip.align End ]
            [ Html.text "Tooltip content" ]
        )
        (Lustre.Ui.Tooltip.trigger [] [ Html.text "Hover me" ])


## Types

@docs Alignment, Popover, Side, Trigger


## Elements

@docs view, popover, trigger


## Attributes

@docs align, default_open, delay, offset, open, side


## Events

@docs on_open_change, on_activate, on_dismiss

-}

import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode


{-| The alignment of the tooltip popover relative to the trigger element.
Used with the [`align`](#align) attribute.
-}
type Alignment
    = Start
    | Centre
    | End


{-| -}
type Popover a
    = Popover
        { attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| The side of the trigger element that the tooltip popover should appear on.
Used with the [`side`](#side) attribute.
-}
type Side
    = Top
    | Right
    | Bottom
    | Left


{-| -}
type Trigger a
    = Trigger
        { attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| Sets the alignment of the tooltip popover relative to the trigger element
along the axis perpendicular to the placement side. Defaults to
[`Centre`](#Centre).
-}
align : Alignment -> Html.Attribute a
align val =
    case val of
        Start ->
            Html.Attributes.attribute "align" "start"

        Centre ->
            Html.Attributes.classList []

        End ->
            Html.Attributes.attribute "align" "end"


{-| Set whether the tooltip popover is open by default when first rendered in
an _uncontrolled_ tooltip.

> **Note**: an uncontrolled component is responsible for managing its own
> state and subsequent changes to `default_open` will not be reflected in
> the component after the initial render.
>
> To control the tooltip's open state from your application, use the
> [`open`](#open) attribute instead.

-}
default_open : Bool -> Html.Attribute a
default_open val =
    if val then
        Html.Attributes.attribute "open" ""

    else
        Html.Attributes.classList []


{-| Sets the delay in milliseconds before the tooltip popover is shown after the
trigger is hovered. Defaults to `50`. Set to `0` to show the tooltip
immediately on hover.
-}
delay : Int -> Html.Attribute a
delay val =
    Html.Attributes.attribute "delay" (String.fromInt (max 0 val))


{-| Sets the distance in pixels between the trigger element and the tooltip
popover. The offset is applied along the placement side, so if the popover is
placed on the [`Left`](#Left) of the trigger, an offset of `10` will move the
popover 10 pixels to the left of the trigger element.
-}
offset : Float -> Html.Attribute a
offset val =
    Html.Attributes.attribute "offset" (String.fromFloat val)


{-| An event emitted by the [trigger](#trigger) when the tooltip is activated,
i.e. the trigger is hovered or focused.

> **Note**: like other DOM events, this event bubbles and can be listened
> for on the containing tooltip.

-}
on_activate : a -> Html.Attribute a
on_activate handler =
    Html.Events.on "tooltip/trigger:activate" (Json.Decode.succeed handler)


{-| An event emitted by the [trigger](#trigger) when the tooltip is dismissed,
i.e. the trigger loses hover or focus.

> **Note**: like other DOM events, this event bubbles and can be listened
> for on the containing tooltip.

-}
on_dismiss : a -> Html.Attribute a
on_dismiss handler =
    Html.Events.on "tooltip/trigger:dismiss" (Json.Decode.succeed handler)


{-| An event emitted by the [tooltip](#view) when its open state changes. In a
controlled tooltip, this event should be used to update your application
state with the new open state. Your application may ignore this event to
prevent the open state of the tooltip from changing.

In an uncontrolled tooltip, this event can be used to respond to changes
in the tooltip's open state.

-}
on_open_change : (Bool -> a) -> Html.Attribute a
on_open_change handler =
    Html.Events.on "tooltip:change"
        (Json.Decode.field "detail" Json.Decode.bool
            |> Json.Decode.map handler
        )


{-| Set the open state of the tooltip popover, making it controlled by your
application.

> **Note**: in a controlled component, the state is managed by your
> application. Set this to `True` to force the popover to remain visible
> regardless of user interaction.
>
> To set whether the tooltip is initially open when first rendered, consider
> using the [`default_open`](#default_open) attribute instead.

-}
open : Bool -> Html.Attribute a
open val =
    Html.Attributes.property "open" (Json.Encode.bool val)


{-| The tooltip popover contains the content that is revealed when the
associated trigger is hovered or receives keyboard focus.


#### Tag

```html
<lustre-tooltip-popover>
```


#### Attributes

[`align`](#align), [`default_open`](#default_open), [`offset`](#offset),
[`open`](#open), [`side`](#side).


#### Styling

This element has a default display of `inline` when open and `none` when
closed.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the popover is visible.
  - `:state(top)`, `:state(right)`, `:state(bottom)`, `:state(left)` reflect
    the current placement side.
  - `:state(start)` and `:state(end)` reflect the current alignment.

The following CSS custom properties are set on this element and can be
used to position the popover or style its children:

  - `--tooltip-popover-x`
  - `--tooltip-popover-y`


#### Accessibility notes

The content inside the tooltip popover is marked as
[inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert)
and must not contain any interactive elements such as links or buttons.


#### Managed attributes

The following attributes **must not** be set manually on the popover, as
these are managed by the component and are necessary for accessibility:

  - `popover`
  - `role`

-}
popover : List (Html.Attribute a) -> List (Html.Html a) -> Popover a
popover attributes children =
    Popover { attributes = attributes, children = children }


{-| Sets which side of the trigger element the tooltip popover should appear on.
Defaults to [`Top`](#Top).
-}
side : Side -> Html.Attribute a
side val =
    Html.Attributes.attribute "side"
        (case val of
            Top ->
                "top"

            Right ->
                "right"

            Bottom ->
                "bottom"

            Left ->
                "left"
        )


{-| The tooltip trigger wraps the element that will show and hide the popover
when hovered or focused.


#### Tag

```html
<lustre-tooltip-trigger>
```


#### Attributes

[`delay`](#delay).


#### Styling

This element has a default display of `inline`.

The following CSS custom states can be used to style this element:

  - `:state(open)` is applied when the associated tooltip popover is visible.


#### Managed attributes

The following attributes **must not** be set manually on the trigger, as
these are managed by the component and are necessary for accessibility:

  - `aria-describedby`

-}
trigger : List (Html.Attribute a) -> List (Html.Html a) -> Trigger a
trigger attributes children =
    Trigger { attributes = attributes, children = children }


{-| The root tooltip element is a container for both the trigger and popover
content.


#### Tag

```html
<lustre-tooltip>
```


#### Attributes

[`default_open`](#default_open), [`delay`](#delay), [`open`](#open).


#### Styling

This element has a default display of `contents` and does not affect layout
on its own. Prefer styling the trigger and popover elements directly where
possible.

-}
view : List (Html.Attribute a) -> Popover a -> Trigger a -> Html.Html a
view attributes (Popover p) (Trigger t) =
    Html.node "lustre-tooltip"
        attributes
        [ Html.node "lustre-tooltip-trigger" t.attributes t.children
        , Html.node "lustre-tooltip-popover" p.attributes p.children
        ]
