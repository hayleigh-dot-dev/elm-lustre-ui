module Lustre.Ui.Tabs exposing
    ( TabsContent, TabsList, TabsListItem, TabsPanel
    , view, list, trigger, indicator, content, panel
    , value, default_value, horizontal, vertical, automatic_activation, loop
    , on_value_change, on_select, on_open, on_close
    )

{-| Tabs are made up of one or more panels of content each with an associated
trigger. Only one panel is visible at a time, and can be changed by selecting
the associated trigger.

    Lustre.Ui.Tabs.view []
        (Lustre.Ui.Tabs.list []
            [ Lustre.Ui.Tabs.trigger "wibble" [] [ Html.text "Wibble" ]
            , Lustre.Ui.Tabs.trigger "wobble" [] [ Html.text "Wobble" ]
            , Lustre.Ui.Tabs.indicator [] []
            ]
        )
        (Lustre.Ui.Tabs.content []
            [ Lustre.Ui.Tabs.panel "wibble" [] [ Html.text "Wibble content..." ]
            , Lustre.Ui.Tabs.panel "wobble" [] [ Html.text "Wobble content..." ]
            ]
        )

  - [`tabs.view`](#view) is the root container for the tab triggers and
    panels. It controls the current active tab.

  - The [`tabs.list`](#list) is a container for one or more tab triggers. It
    manages keyboard interaction and focus between the triggers.

  - Each [`tabs.trigger`](#trigger) is a button that activates its associated
    panel. It must not contain any other interactive children.

  - The [`tabs.indicator`](#indicator) can be styled to match the position of
    the currently active tab. It is typically animated for smooth transitions.

  - [`tabs.content`](#content) is a container for one or more tab panels.

  - Each [`tabs.panel`](#panel) is a container for content that corresponds to
    one trigger. When the associated trigger is active, that panel's content
    will be visible.


## Accessibility

The tabs component follows the WAI-ARIA Authoring Practices for the
[tabs pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/). This means
appropriate roles, ARIA attributes, and keyboard interactions are handled for
you, including:

  - `role` "tablist" on the tabs list container with managed `aria-orientation`
    for horizontal or vertical layouts.

  - `role` "tab" on each tab trigger, with managed `aria-selected`, `aria-controls`,
    and `tabindex` attributes.

  - `role` "tabpanel" on each tab panel, with managed `aria-labelledby` and
    content visibility.

  - `role` "presentation" on the tabs indicator.

  - Keyboard interactions for navigating between tab triggers using Arrow Up/Down,
    Arrow Left/Right, Home, and End keys, as well as the ability to activate
    tabs when focus moves (automatic activation) or when a tab is selected with
    Enter or Space (manual activation).

  - Retention of focus when the active panel changes.


## Recipes

You can use these recipes as starting points for common tabs configurations.
Copy and paste them into your apps and adapt them as needed!


### Basic use

The basic scaffold for using the tabs component. In this default configuration,
the state of the active tab is uncontrolled and managed internally by the
component.

    Lustre.Ui.Tabs.view []
        (Lustre.Ui.Tabs.list []
            [ Lustre.Ui.Tabs.trigger "wibble" [] [ Debug.todo "..." ]
            , Lustre.Ui.Tabs.trigger "wobble" [] [ Debug.todo "..." ]
            ]
        )
        (Lustre.Ui.Tabs.content []
            [ Lustre.Ui.Tabs.panel "wibble" [] [ Debug.todo "..." ]
            , Lustre.Ui.Tabs.panel "wobble" [] [ Debug.todo "..." ]
            ]
        )


## Types

@docs TabsContent, TabsList, TabsListItem, TabsPanel


## Elements

@docs view, list, trigger, indicator, content, panel


## Attributes

@docs value, default_value, horizontal, vertical, automatic_activation, loop


## Events

@docs on_value_change, on_select, on_open, on_close

-}

import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode


{-| -}
type TabsContent a
    = TabsContent
        { attributes : List (Html.Attribute a)
        , children : List (TabsPanel a)
        }


{-| -}
type TabsList a
    = TabsList
        { attributes : List (Html.Attribute a)
        , children : List (TabsListItem a)
        }


{-| -}
type TabsListItem a
    = Trigger
        { name : String
        , attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }
    | Indicator
        { attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| -}
type TabsPanel a
    = TabsPanel
        { name : String
        , attributes : List (Html.Attribute a)
        , children : List (Html.Html a)
        }


{-| It is possible to configure how tabs are activated when using the keyboard
to navigate between tab triggers. By default, tabs use automatic activation,
meaning that when a tab trigger receives focus, it is automatically activated.

This behaviour can be disabled by setting this attribute to `False`. Manual
activation requires the user to press Enter or Space (or use a pointer device
to click) to activate the focused tab trigger.

> **Note**: it is important to consider the accessibility implications of
> enabling or disabling automatic activation. The Web Accessibility Initiative
> (WAI) have [some guidelines](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/#kbd_selection_follows_focus)
> on which option to prefer and when.

-}
automatic_activation : Bool -> Html.Attribute a
automatic_activation enabled =
    Html.Attributes.attribute "mode"
        (if enabled then
            "automatic"

         else
            "manual"
        )


{-| The content element contains one or more [panels](#panels) and manages which
is visible based on the currently active tab.


#### Tag

```html
<lustre-tabs-content>
```


#### Events

[`on_open`](#on_open), [`on_close`](#on_close).


#### Styling

This element has a default display of `block`.

-}
content : List (Html.Attribute a) -> List (TabsPanel a) -> TabsContent a
content attributes children =
    TabsContent { attributes = attributes, children = children }


{-| Set the default active tab for _uncontrolled_ tabs. This should correspond to
the name of one of the [tab triggers](#trigger) present in the [tabs list](#list).

> **Note**: an uncontrolled component is responsible for managing its own state
> and subsequent changes to the `default_value` will not be reflected in the
> component after the initial render.
>
> To control the tabs component's state from your application, use the [`value`](#value)
> attribute instead.

-}
default_value : String -> Html.Attribute a
default_value name_ =
    Html.Attributes.attribute "value" name_


{-| Set a [tabs list's](#list) orientation to horizontal. This changes how keyboard
navigation between tab triggers works, using Left/Right arrow keys instead of
Up/Down arrow keys. This is the default orientation for tabs lists.
-}
horizontal : Html.Attribute a
horizontal =
    Html.Attributes.attribute "orientation" "horizontal"


{-| A visual indicator that can be styled to match the size and position of the
currently active tab.


#### Tag

```html
<lustre-tabs-indicator>
```


#### Styling

This element has a default display of `inline`.

The following CSS custom properties can be used to style this element or
its children:

  - `--indicator-x`
  - `--indicator-y`
  - `--indicator-width`
  - `--indicator-height`


#### Accessibility notes

The indicator should only be used as a visual aid for sighted users. It should
not contain any meaningful content or interactive elements as it will be
ignored by assistive technologies and unavigable via keyboard.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `role`

-}
indicator : List (Html.Attribute a) -> List (Html.Html a) -> TabsListItem a
indicator attributes children =
    Indicator { attributes = attributes, children = children }


{-| The tabs list is a container for one or more tab triggers. It manages keyboard
interaction and focus between the triggers.


#### Tag

```html
<lustre-tabs-list>
```


#### Attributes

[`automatic_activation`](#automatic_activation), [`horizontal`](#horizontal),
[`loop`](#loop), [`vertical`](#vertical).

On attributes that are valid for both this element and the [root tabs](#view)
element, attributes set directly on this element will take precedence.


#### Events

[`on_select`](#on_select).


#### Styling

This element has a default display of `block`.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `aria-orientation`
  - `role`

-}
list : List (Html.Attribute a) -> List (TabsListItem a) -> TabsList a
list attributes children =
    TabsList { attributes = attributes, children = children }


{-| Controls whether keyboard navigation in a [tabs list](#list) loops from the
last tab back to the first and vice versa.
-}
loop : Bool -> Html.Attribute a
loop enabled =
    if enabled then
        Html.Attributes.attribute "loop" ""

    else
        Html.Attributes.classList []


{-| An event emitted by an individual [panel](#panel) when it is hidden.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_close : (String -> a) -> Html.Attribute a
on_close handler =
    Html.Events.on "tabs/panel:close"
        (Json.Decode.at [ "detail", "name" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| An event emitted by an individual [panel](#panel) when it is first made
visible.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_open : (String -> a) -> Html.Attribute a
on_open handler =
    Html.Events.on "tabs/panel:open"
        (Json.Decode.at [ "detail", "name" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| An event emitted by the [tabs list](#list) when a tab trigger is activated.
This does not account for the current active tab, so multiple select events
may be emitted without the active tab changing.

> **Note**: like other DOM events, this event bubbles and can be listened for
> on the containing accordion.

-}
on_select : (String -> a) -> Html.Attribute a
on_select handler =
    Html.Events.on "tabs/list:select"
        (Json.Decode.at [ "detail", "name" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| An event emitted by the root [tabs](#view) element when the active tab changes.
This will only be emitted when the active tab actually changes, not when the
same tab is re-selected.

In a controlled tabs, this event should be used to update your application
state with the new active tab. Your application may ignore this event to
prevent the open state of the tabs from changing.

In an uncontrolled tabs, this event can be used to respond to changes
in the tabs' open state, for example by loading content dynamically when
a trigger is activated.

-}
on_value_change : (String -> a) -> Html.Attribute a
on_value_change handler =
    Html.Events.on "tabs:change"
        (Json.Decode.at [ "detail", "name" ] Json.Decode.string
            |> Json.Decode.map handler
        )


{-| A panel is a container for content that corresponds to one trigger. When the
associated trigger is active, that panel's content will be visible.

Each panel inside the [`tabs.content`](#content) container must have a unique
name that matches one of the triggers inside the [`tabs.list`](#list) container.
Duplicate names, names without an associated trigger, or empty names will be
ignored.


#### Tag

```html
<lustre-tabs-panel>
```


#### Events

[`on_open`](#on_open), [`on_close`](#on_close).


#### Styling

This element has a default display of `block`.

The following CSS custom states can be used to style this element:

  - `:state(active)` is applied when the panel is active and visible.


#### Accessibility notes

When a panel is active it is automatically assigned a tabindex of `0` if it
has no interactive children. This is important to make sure the panel itself
is included in the tab sequence of the page.

If a panel does not have an explicit `id` attribute set, it will be assigned
one automatically. This is necessary to establish the `aria-controls` relationship
on the trigger.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `aria-labelledby`
  - `role`
  - `tabindex`

-}
panel : String -> List (Html.Attribute a) -> List (Html.Html a) -> TabsPanel a
panel name attributes children =
    TabsPanel { name = name, attributes = attributes, children = children }


{-| A tabs trigger is a button that activates its associated panel. It must not
contain any other interactive children.


#### Tag

```html
<lustre-tabs-trigger>
```


#### Events

> **Note**: only the parent [tabs list](#list) will emit the [`on_select`](#on_select)
> event. To listen for activation of an individual trigger, you can listen for
> standard events like `click` or `keydown`.


#### Styling

This element has a default display of `inline`.

The following CSS custom states can be used to style this element:

  - `:state(active)` is applied when the active tab matches this trigger's name.


#### Managed attributes

The following attributes **must not** be set manually on the element, as
these are managed by the component and are necessary for accessibility:

  - `aria-controls`
  - `aria-selected`
  - `role`
  - `tabindex`

-}
trigger : String -> List (Html.Attribute a) -> List (Html.Html a) -> TabsListItem a
trigger name attributes children =
    Trigger { name = name, attributes = attributes, children = children }


{-| Set the current active tab for _controlled_ tabs.

> **Note**: in a controlled component, the state is managed by your application
> and must be updated in response to user interaction by handling the
> [`on_value_change`](#on_value_change) or [`on_select`](#on_select) events.
>
> To let the component manage its own state, use the [`default_value`](#default_value)
> attribute to set the initial active tab instead.

-}
value : String -> Html.Attribute a
value name_ =
    Html.Attributes.property "value" (Json.Encode.string name_)


{-| Set a [tabs list's](#list) orientation to vertical. This changes how keyboard
navigation between tab triggers works, using Up/Down arrow keys instead of
Left/Right arrow keys.
-}
vertical : Html.Attribute a
vertical =
    Html.Attributes.attribute "orientation" "vertical"


{-| The root tabs element is a container for both the list of triggers and the
main tabs content.


#### Tag

```html
<lustre-tabs>
```


#### Attributes

[`automatic_activation`](#automatic_activation), [`default_value`](#default_value),
[`horizontal`](#horizontal), [`loop`](#loop, [`value`](#value),
[`vertical`](#vertical).


#### Events

[`on_value_change`](#on_value_change), [`on_select`](#on_select),
[`on_open`](#on_open), [`on_close`](#on_close).


#### Styling

This element has a default display of `block`.

-}
view : List (Html.Attribute a) -> TabsList a -> TabsContent a -> Html.Html a
view attributes (TabsList tabsList) (TabsContent tabsContent) =
    let
        ( triggers, seenNames ) =
            List.foldr
                (\listItem ( acc, seen ) ->
                    case listItem of
                        Trigger t ->
                            if t.name == "" || List.member t.name seen then
                                ( acc, seen )

                            else
                                ( Html.node "lustre-tabs-trigger"
                                    (Html.Attributes.attribute "name" t.name :: t.attributes)
                                    t.children
                                    :: acc
                                , t.name :: seen
                                )

                        Indicator i ->
                            ( Html.node "lustre-tabs-indicator" i.attributes i.children :: acc
                            , seen
                            )
                )
                ( [], [] )
                tabsList.children

        ( panels, _ ) =
            List.foldr
                (\(TabsPanel p) ( acc, remaining ) ->
                    if p.name == "" || not (List.member p.name remaining) then
                        ( acc, remaining )

                    else
                        ( Html.node "lustre-tabs-panel"
                            (Html.Attributes.attribute "slot" p.name :: p.attributes)
                            p.children
                            :: acc
                        , List.filter (\n -> n /= p.name) remaining
                        )
                )
                ( [], seenNames )
                tabsContent.children
    in
    Html.node "lustre-tabs"
        attributes
        [ Html.node "lustre-tabs-list" tabsList.attributes triggers
        , Html.node "lustre-tabs-content" tabsContent.attributes panels
        ]
