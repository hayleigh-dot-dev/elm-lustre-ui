module Lustre.Ui.Toggle exposing
    ( Item
    , view, group, item
    , disabled, default_pressed, pressed, value, default_selected, selected, loop
    , on_press, on_selected_change
    )

{-| A toggle is a special kind of two-state button that can either on or off.
Unlike the native checkbox element, a toggle must be styled appropriately to
communicate on/off status to sighted users.

    Lustre.Ui.Toggle.view [] [ Html.text "B" ]

    Lustre.Ui.Toggle.group []
        [ Lustre.Ui.Toggle.item "b" [] [ Html.text "B" ]
        , Lustre.Ui.Toggle.item "i" [] [ Html.text "I" ]
        ]

  - [`toggle.view`](#view) is an individual toggle button. When activated it
    toggles between pressed and unpressed states.

  - [`toggle.group`](#group) is a container for one or more toggle items. It
    manages selection state among its children - similar to a radio group -
    and handles keyboard navigation between them.

  - Each [`toggle.item`](#item) in a group is an individual toggle button with
    a unique value that identifies it within the group.


## Accessibility

The toggle component follows the WAI-ARIA Authoring Practices for the
[toggle button pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/).
This means appropriate roles and ARIA attributes are handled for you,
including:

  - `role` "button" on the toggle element, as well as managed `aria-pressed`
    and `aria-disabled` attributes.

  - `role` "group" on the toggle group element, as well as managed `aria-orientation`.


## Usage notes

Because a toggle has no innate indicator of its pressed state, it's essential
that any toggle has appropriate visual styling to communicate its state to
sighted users.

Toggles and toggle groups can participate in HTML form submission the same
as native form controls by giving the control a [`name`](https://hexdocs.pm/lustre/lustre/attribute.html#name).


## Types

@docs Item


## Elements

@docs view, group, item


## Attributes

@docs disabled, default_pressed, pressed, value, default_selected, selected, loop


## Events

@docs on_press, on_selected_change

-}

import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode


{-| -}
type Item a
    = Item
        { value : String
        , attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| Set whether an individual [toggle](#root) is pressed when it is first rendered.
This is only useful for uncontrolled toggles or for server-side rendering. To
control the pressed state of a toggle in your app, use the [`pressed`](#pressed)
attribute instead.

> **Note**: an uncontrolled component is responsible for managing its own state
> and subsequent changes to `default_pressed` will not be reflected in the
> component after the initial render.
>
> To control the toggle component's state from your application, use the
> [`pressed`](#pressed) attribute instead.

-}
default_pressed : Bool -> Html.Attribute a
default_pressed val =
    if val then
        Html.Attributes.attribute "pressed" ""

    else
        Html.Attributes.classList []


{-| Set the default selected item in a [toggle group](#group) by value. This is
only useful for uncontrolled groups or for server-side rendering. To control
the selected item in your app, use the [`selected`](#selected) attribute instead.
-}
default_selected : Maybe String -> Html.Attribute a
default_selected val =
    case val of
        Just s ->
            Html.Attributes.attribute "value" s

        Nothing ->
            Html.Attributes.classList []


{-| Disable a [toggle](#root) or [toggle group](#group). Disabled toggles cannot
be interacted with and should be styled appropriately to communicate this to
sighted users. When a group is disabled, the user will still be able to navigate
to each item using the keyboard, but they will not be able to activate any of
the items.
-}
disabled : Bool -> Html.Attribute a
disabled val =
    if val then
        Html.Attributes.attribute "disabled" ""

    else
        Html.Attributes.classList []


{-| A group of toggle buttons. Only one toggle may be pressed at a time.


#### Tag

```html
<lustre-toggle>
```


#### Attributes

[`default_pressed`](#default_pressed), [`disabled`](#disabled), [`loop`](#loop),
[`pressed`](#pressed), [`value`](#value).


#### Events

[`on_selected_change`](#on_selected_change).


#### Styling

This element has a default display of `inline`.

The following CSS custom states can be used to style this element:

  - `:state(disabled)` is applied when the entire group is disabled.


#### Accessibility notes

The toggle group supports keyboard navigation between individual toggles
using the following keys _instead of_ to the standard tabbing behaviour:

  - When in a vertical group...
      - Arrow Up moves focus to the previous toggle.
      - Arrow Down moves focus to the next toggle.
  - When in a horizontal group...
      - Arrow Left moves focus to the previous toggle.
      - Arrow Right moves focus to the next toggle.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `aria-orientation`
  - `role`

-}
group : List (Html.Attribute a) -> List (Item a) -> Html.Html a
group attributes children =
    let
        ( rendered, _ ) =
            List.foldr
                (\(Item i) ( acc, seen ) ->
                    if i.value == "" || List.member i.value seen then
                        ( acc, seen )

                    else
                        ( view (Html.Attributes.attribute "value" i.value :: i.attributes) i.children :: acc
                        , i.value :: seen
                        )
                )
                ( [], [] )
                children
    in
    Html.node "lustre-toggle-group" attributes rendered


{-| An individual toggle as part of a [`group`](#group). Each item should have a
unique value in the group: empty or duplicate values will be ignored.

For more detailed documentation, refer to the [`toggle.view`](#view) element.

-}
item : String -> List (Html.Attribute a) -> List (Html.Html a) -> Item a
item val attributes children =
    Item { value = val, attributes = attributes, children = children }


{-| When `True`, the loop attribute allows users to cycle through the toggle
items in a group by navigating past the first or last item using the keyboard.

> **Note**: be mindful of the accessibility implications of this attribute.
> If the toggle group exists inside another container that also relies on
> keyboard navigation, like a menu or toolbar, you may trap users inside
> the toggle group by enabling looping.

-}
loop : Bool -> Html.Attribute a
loop val =
    if val then
        Html.Attributes.attribute "loop" ""

    else
        Html.Attributes.classList []


{-| An event emitted by individual [toggles](#view) when they are pressed.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on a parent [toggle group](#group).

-}
on_press : (Bool -> a) -> Html.Attribute a
on_press handler =
    Html.Events.on "toggle:press"
        (Json.Decode.field "detail" Json.Decode.bool
            |> Json.Decode.map handler
        )


{-| This event is emitted by a [toggle group](#group) when any of its child items
are pressed. The provided handler is called with either the value of the
pressed item, or `None` if an already-selected item is deselected.
-}
on_selected_change : (Maybe String -> a) -> Html.Attribute a
on_selected_change handler =
    Html.Events.on "toggle/group:change"
        (Json.Decode.field "detail" (Json.Decode.nullable Json.Decode.string)
            |> Json.Decode.map handler
        )


{-| Sets the pressed state for a _controlled_ toggle.

> **Note**: in a controlled component, the state is managed by your application
> and must be updated in response to user interaction by handling the
> [`on_press`](#on_press) event.
>
> To let the component manage its own state, use the [`default_pressed`](#default_pressed)
> attribute to set the initial pressed state of a toggle instead.

-}
pressed : Bool -> Html.Attribute a
pressed val =
    Html.Attributes.property "pressed" (Json.Encode.bool val)


{-| Set the selected item in a _controlled_ [toggle group](#group) by its value,
or `None` to clear any selection.

> **Note**: in a controlled component, the state is managed by your application
> and must be updated in response to user interaction by handling the
> [`on_selected_change`](#on_selected_change) event.

-}
selected : Maybe String -> Html.Attribute a
selected val =
    case val of
        Just s ->
            Html.Attributes.property "value" (Json.Encode.string s)

        Nothing ->
            Html.Attributes.property "value" Json.Encode.null


{-| Sets the value to be included in form submission for a pressed [toggle](#view).
If this attribute is not set, a toggle behaves like a HTML checkbox input and
sends the value `"on"` when pressed.
-}
value : String -> Html.Attribute a
value val =
    Html.Attributes.attribute "value" val


{-| An individual toggle button. When activated it toggles between pressed and
unpressed states.


#### Tag

```html
<lustre-toggle>
```


#### Attributes

[`default_pressed`](#default_pressed), [`disabled`](#disabled), [`pressed`](#pressed),
[`value`](#value).


#### Events

[`on_press`](#on_press).


#### Styling

This element has a default display of `inline`.

The following CSS custom states can be used to style this element:

  - `:state(pressed)` is applied when the toggle is pressed.
  - `:state(disabled)` is applied when the toggle is disabled.


#### Accessibility notes

A toggle can receive focus and be activated using the keyboard by pressing
either the Enter or Space keys.

The toggle must have an accessible text label for non-sighted uses. This can
be text content inside the toggle element itself, an associated `<label>` for
toggles used in forms, or an `aria-label` attribute.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `aria-disabled`
  - `aria-pressed`
  - `role`

-}
view : List (Html.Attribute a) -> List (Html.Html a) -> Html.Html a
view attributes children =
    Html.node "lustre-toggle" attributes children
