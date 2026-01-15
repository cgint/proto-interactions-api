# Directory Structure
_Includes files where the actual content might be omitted. This way the LLM can still use the file structure to understand the project._
```
.
└── guides
    ├── cheatsheets
    │   └── html-attrs.cheatmd
    ├── client
    │   ├── bindings.md
    │   ├── external-uploads.md
    │   ├── form-bindings.md
    │   ├── js-interop.md
    │   └── syncing-changes.md
    ├── introduction
    │   └── welcome.md
    └── server
        ├── assigns-eex.md
        ├── deployments.md
        ├── error-handling.md
        ├── gettext.md
        ├── live-layouts.md
        ├── live-navigation.md
        ├── security-model.md
        ├── telemetry.md
        └── uploads.md
```

# File Contents

## File: `guides/cheatsheets/html-attrs.cheatmd`
```
# `phx-` HTML attributes

A summary of special HTML attributes used in Phoenix LiveView templates.
Each attribute is linked to its documentation for more details.

## Event Handlers
{: .col-2}

Attribute values can be:

* An event name for the [`handle_event`](`c:Phoenix.LiveView.handle_event/3`) server callback
* [JS commands](../client/bindings.md#js-commands) to be executed directly on the client

> Use [`phx-value-*`](../client/bindings.md#click-events) attributes to pass params to the server.

> Use [`phx-debounce` and `phx-throttle`](../client/bindings.md#rate-limiting-events-with-debounce-and-throttle) to control the frequency of events.

### Click

| Attributes                                                                                               |
|----------------------------------------------------------------------------------------------------------|
| [`phx-click`](../client/bindings.md#click-events) [`phx-click-away`](../client/bindings.md#click-events) |

### Focus

| Attributes                                                                                                                         |
|------------------------------------------------------------------------------------------------------------------------------------|
| [`phx-blur`](../client/bindings.md#focus-and-blur-events) [`phx-focus`](../client/bindings.md#focus-and-blur-events)               |
| [`phx-window-blur`](../client/bindings.md#focus-and-blur-events) [`phx-window-focus`](../client/bindings.md#focus-and-blur-events) |

### Keyboard

| Attributes                                                                                                      |
|-----------------------------------------------------------------------------------------------------------------|
| [`phx-keydown`](../client/bindings.md#key-events) [`phx-keyup`](../client/bindings.md#key-events)               |
| [`phx-window-keydown`](../client/bindings.md#key-events) [`phx-window-keyup`](../client/bindings.md#key-events) |

> Use the `phx-key` attribute to listen to specific keys.

### Scroll

| Attributes                                                                                                                                                                           |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`phx-viewport-top`](../client/bindings.md#scroll-events-and-infinite-stream-pagination) [`phx-viewport-bottom`](../client/bindings.md#scroll-events-and-infinite-stream-pagination) |

### Example

#### lib/hello_web/live/hello_live.html.heex

```heex
<button type="button" phx-click="click" phx-value-user={@current_user.id}>Click Me</button>
<button type="button" phx-click={JS.toggle(to: "#example")}>Toggle</button>
```
{: .wrap}

## Form Event Handlers
{: .col-2}

### On `<form>` elements

| Attribute                                             | Value                                                                      |
|-------------------------------------------------------|----------------------------------------------------------------------------|
| [`phx-change`](../client/form-bindings.md)            | Event name or [JS commands](../client/bindings.md#js-commands)             |
| [`phx-submit`](../client/form-bindings.md)            | Event name or [JS commands](../client/bindings.md#js-commands)             |
| [`phx-auto-recover`](../client/form-bindings.md)      | Event name, [JS commands](../client/bindings.md#js-commands) or `"ignore"` |
| [`phx-trigger-action`](../client/form-bindings.md)    | `true` or `false`                                                          |
| [`phx-no-usage-tracking`](../client/form-bindings.md) | `true` or `false`                                                          |

### On `<button>` elements

| Attribute                                                                    | Value                                |
|------------------------------------------------------------------------------|--------------------------------------|
| [`phx-disable-with`](../client/form-bindings.md#javascript-client-specifics) | Text to show during event submission |

### Form Example

#### lib/hello_web/live/hello_live.html.heex

```heex
<form phx-change="validate" phx-submit="save">
  <input type="text" name="name" phx-debounce="500" phx-throttle="500" />
  <button type="submit" phx-disable-with="Saving...">Save</button>
</form>
```
{: .wrap}

## Socket Connection Lifecycle

| Attribute                                                    | Value                                                                                                                   |
|--------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| [`phx-connected`](../client/bindings.md#lifecycle-events)    | [JS commands](../client/bindings.md#js-commands) executed after the [`LiveSocket`](../client/js-interop.md) connects    |
| [`phx-disconnected`](../client/bindings.md#lifecycle-events) | [JS commands](../client/bindings.md#js-commands) executed after the [`LiveSocket`](../client/js-interop.md) disconnects |

#### lib/hello_web/live/hello_live.html.heex

```heex
<div id="status" class="hidden" phx-disconnected={JS.show()} phx-connected={JS.hide()}>
  Attempting to reconnect...
</div>
```

## DOM Element Lifecycle

| Attribute                                           | Value                                                                                  |
|-----------------------------------------------------|----------------------------------------------------------------------------------------|
| [`phx-mounted`](../client/bindings.md#dom-patching) | [JS commands](../client/bindings.md#js-commands) executed after the element is mounted |
| [`phx-remove`](../client/bindings.md#dom-patching)  | [JS commands](../client/bindings.md#js-commands) executed during the element removal   |
| [`phx-update`](../client/bindings.md#dom-patching)  | `"replace"` (default), `"stream"` or `"ignore"`, configures DOM patching behavior      |

#### lib/hello_web/live/hello_live.html.heex

```heex
<div
  id="iframe-container"
  phx-mounted={JS.transition("animate-bounce", time: 2000)}
  phx-remove={JS.hide(transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"})}
>
  <button type="button" phx-click={JS.exec("phx-remove", to: "#iframe-container")}>Hide</button>
  <iframe id="iframe" src="https://example.com" phx-update="ignore"></iframe>
</div>
```

## Client Hooks

| Attribute                                                       | Value                                                                                           |
|-----------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| [`phx-hook`](../client/js-interop.md#client-hooks-via-phx-hook) | The name of a previously defined JavaScript hook in the [`LiveSocket`](../client/js-interop.md) |

Client hooks provide bidirectional communication between client and server using
`this.pushEvent` and `this.handleEvent` to send and receive events.

#### lib/hello_web/live/hello_live.html.heex

```heex
<div id="example" phx-hook="Example">
  <h1>Events</h1>
  <ul id="example-events"></ul>
</div>
```

#### assets/js/app.js

```javascript
let Hooks = {}
Hooks.Example = {
  // Callbacks
  mounted()      { this.appendEvent("Mounted") },
  beforeUpdate() { this.appendEvent("Before Update") },
  updated()      { this.appendEvent("Updated") },
  destroyed()    { this.appendEvent("Destroyed") },
  disconnected() { this.appendEvent("Disconnected") },
  reconnected()  { this.appendEvent("Reconnected") },

  // Custom Helper
  appendEvent(name) {
    console.log(name)
    let li = document.createElement("li")
    li.innerText = name
    this.el.querySelector("#example-events").appendChild(li)
  }
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
```

## Tracking Static Assets

| Attribute                                                  | Value                               |
|------------------------------------------------------------|-------------------------------------|
| [`phx-track-static`](`Phoenix.LiveView.static_changed?/1`) | None, used to annotate static files |

#### lib/hello_web/components/layouts/root.html.heex

```heex
<link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
<script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}></script>
```
```

## File: `guides/client/bindings.md`
```
# Bindings

Phoenix supports DOM element bindings for client-server interaction. For
example, to react to a click on a button, you would render the element:

```heex
<button phx-click="inc_temperature">+</button>
```

Then on the server, all LiveView bindings are handled with the `handle_event`
callback, for example:

    def handle_event("inc_temperature", _value, socket) do
      {:ok, new_temp} = Thermostat.inc_temperature(socket.assigns.id)
      {:noreply, assign(socket, :temperature, new_temp)}
    end

| Binding                | Attributes |
|------------------------|------------|
| [Params](#click-events) | `phx-value-*` |
| [Click Events](#click-events) | `phx-click`, `phx-click-away` |
| [Form Events](form-bindings.md) | `phx-change`, `phx-submit`, `phx-disable-with`, `phx-trigger-action`, `phx-auto-recover` |
| [Focus Events](#focus-and-blur-events) | `phx-blur`, `phx-focus`, `phx-window-blur`, `phx-window-focus` |
| [Key Events](#key-events) | `phx-keydown`, `phx-keyup`, `phx-window-keydown`, `phx-window-keyup`, `phx-key` |
| [Scroll Events](#scroll-events-and-infinite-pagination) | `phx-viewport-top`, `phx-viewport-bottom` |
| [DOM Patching](#dom-patching) | `phx-update`, `phx-mounted`, `phx-remove` |
| [JS Interop](js-interop.md#client-hooks-via-phx-hook) | `phx-hook` |
| [Lifecycle Events](#lifecycle-events) | `phx-connected`, `phx-disconnected` |
| [Rate Limiting](#rate-limiting-events-with-debounce-and-throttle) | `phx-debounce`, `phx-throttle` |
| [Static tracking](`Phoenix.LiveView.static_changed?/1`) | `phx-track-static` |

If you need to trigger commands actions via JavaScript, see [JavaScript interoperability](js-interop.md#js-commands).

## Click Events

The `phx-click` binding is used to send click events to the server.
When any client event, such as a `phx-click` click is pushed, the value
sent to the server will be chosen with the following priority:

  * The `:value` specified in `Phoenix.LiveView.JS.push/3`, such as:

    ```heex
    <div phx-click={JS.push("inc", value: %{myvar1: @val1})}>
    ```

  * Any number of optional `phx-value-` prefixed attributes, such as:

    ```heex
    <div phx-click="inc" phx-value-myvar1="val1" phx-value-myvar2="val2">
    ```

    will send the following map of params to the server:

        def handle_event("inc", %{"myvar1" => "val1", "myvar2" => "val2"}, socket) do

    If the `phx-value-` prefix is used, the server payload will also contain a `"value"`
    if the element's value attribute exists.

  * The payload will also include any additional user defined metadata of the client event.
    For example, the following `LiveSocket` client option would send the coordinates and
    `altKey` information for all clicks:

    ```javascript
    let liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: csrfToken},
      metadata: {
        click: (e, el) => {
          return {
            altKey: e.altKey,
            clientX: e.clientX,
            clientY: e.clientY
          }
        }
      }
    })
    ```

The `phx-click-away` event is fired when a click event happens outside of the element.
This is useful for hiding toggled containers like drop-downs.

## Focus and Blur Events

Focus and blur events may be bound to DOM elements that emit
such events, using the `phx-blur`, and `phx-focus` bindings, for example:

```heex
<input name="email" phx-focus="myfocus" phx-blur="myblur"/>
```

To detect when the page itself has received focus or blur,
`phx-window-focus` and `phx-window-blur` may be specified. These window
level events may also be necessary if the element in consideration
(most often a `div` with no tabindex) cannot receive focus. Like other
bindings, `phx-value-*` can be provided on the bound element, and those
values will be sent as part of the payload. For example:

```heex
<div class="container"
    phx-window-focus="page-active"
    phx-window-blur="page-inactive"
    phx-value-page="123">
  ...
</div>
```

## Key Events

The `onkeydown`, and `onkeyup` events are supported via the `phx-keydown`,
and `phx-keyup` bindings. Each binding supports a `phx-key` attribute, which triggers
the event for the specific key press. If no `phx-key` is provided, the event is triggered
for any key press. When pushed, the value sent to the server will contain the `"key"`
that was pressed, plus any user-defined metadata. For example, pressing the
Escape key looks like this:

    %{"key" => "Escape"}

To capture additional user-defined metadata, the `metadata` option for keydown events
may be provided to the `LiveSocket` constructor. For example:

```javascript
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  metadata: {
    keydown: (e, el) => {
      return {
        key: e.key,
        metaKey: e.metaKey,
        repeat: e.repeat
      }
    }
  }
})
```

To determine which key has been pressed you should use `key` value. The
available options can be found on
[MDN](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values)
or via the [Key Event Viewer](https://w3c.github.io/uievents/tools/key-event-viewer.html).

*Note*: `phx-keyup` and `phx-keydown` are not supported on inputs.
Instead use form bindings, such as `phx-change`, `phx-submit`, etc.

*Note*: it is possible for certain browser features like autofill to trigger key events
with no `"key"` field present in the value map sent to the server. For this reason, we
recommend always having a fallback catch-all event handler for LiveView key bindings.
By default, the bound element will be the event listener, but a
window-level binding may be provided via `phx-window-keydown` or `phx-window-keyup`,
for example:

    def render(assigns) do
      ~H"""
      <div id="thermostat" phx-window-keyup="update_temp">
        Current temperature: {@temperature}
      </div>
      """
    end

    def handle_event("update_temp", %{"key" => "ArrowUp"}, socket) do
      {:ok, new_temp} = Thermostat.inc_temperature(socket.assigns.id)
      {:noreply, assign(socket, :temperature, new_temp)}
    end

    def handle_event("update_temp", %{"key" => "ArrowDown"}, socket) do
      {:ok, new_temp} = Thermostat.dec_temperature(socket.assigns.id)
      {:noreply, assign(socket, :temperature, new_temp)}
    end

    def handle_event("update_temp", _, socket) do
      {:noreply, socket}
    end

## Rate limiting events with Debounce and Throttle

All events can be rate-limited on the client by using the
`phx-debounce` and `phx-throttle` bindings, with the exception of the `phx-blur`
binding, which is fired immediately.

Rate limited and debounced events have the following behavior:

  * `phx-debounce` - Accepts either an integer timeout value (in milliseconds),
    or `"blur"`. When an integer is provided, emitting the event is delayed by
    the specified milliseconds. When `"blur"` is provided, emitting the event is
    delayed until the field is blurred by the user. When the value is omitted
    a default of 300ms is used. Debouncing is typically used for input elements.

  * `phx-throttle` - Accepts an integer timeout value to throttle the event in milliseconds.
    Unlike debounce, throttle will immediately emit the event, then rate limit it at once
    per provided timeout. When the value is omitted a default of 300ms is used.
    Throttling is typically used to rate limit clicks, mouse and keyboard actions.

For example, to avoid validating an email until the field is blurred, while validating
the username at most every 2 seconds after a user changes the field:

```heex
<form phx-change="validate" phx-submit="save">
  <input type="text" name="user[email]" phx-debounce="blur"/>
  <input type="text" name="user[username]" phx-debounce="2000"/>
</form>
```

And to rate limit a volume up click to once every second:

```heex
<button phx-click="volume_up" phx-throttle="1000">+</button>
```

Likewise, you may throttle held-down keydown:

```heex
<div phx-window-keydown="keydown" phx-throttle="500">
  ...
</div>
```

Unless held-down keys are required, a better approach is generally to use
`phx-keyup` bindings which only trigger on key up, thereby being self-limiting.
However, `phx-keydown` is useful for games and other use cases where a constant
press on a key is desired. In such cases, throttle should always be used.

### Debounce and Throttle special behavior

The following specialized behavior is performed for forms and keydown bindings:

  * When a `phx-submit`, or a `phx-change` for a different input is triggered,
    any current debounce or throttle timers are reset for existing inputs.

  * A `phx-keydown` binding is only throttled for key repeats. Unique keypresses
    back-to-back will dispatch the pressed key events.

## JS commands

LiveView bindings support a JavaScript command interface via the `Phoenix.LiveView.JS` module, which allows you to specify utility operations that execute on the client when firing `phx-` binding events, such as `phx-click`, `phx-change`, etc. Commands compose together to allow you to push events, add classes to elements, transition elements in and out, and more.
See the `Phoenix.LiveView.JS` documentation for full usage.

For a small example of what's possible, imagine you want to show and hide a modal on the page without needing to make the round trip to the server to render the content:

```heex
<div id="modal" class="modal">
  My Modal
</div>

<button phx-click={JS.show(to: "#modal", transition: "fade-in")}>
  show modal
</button>

<button phx-click={JS.hide(to: "#modal", transition: "fade-out")}>
  hide modal
</button>

<button phx-click={JS.toggle(to: "#modal", in: "fade-in", out: "fade-out")}>
  toggle modal
</button>
```

Or if your UI library relies on classes to perform the showing or hiding:

```heex
<div id="modal" class="modal">
  My Modal
</div>

<button phx-click={JS.add_class("show", to: "#modal", transition: "fade-in")}>
  show modal
</button>

<button phx-click={JS.remove_class("show", to: "#modal", transition: "fade-out")}>
  hide modal
</button>
```

Commands compose together. For example, you can push an event to the server and
immediately hide the modal on the client:

```heex
<div id="modal" class="modal">
  My Modal
</div>

<button phx-click={JS.push("modal-closed") |> JS.remove_class("show", to: "#modal", transition: "fade-out")}>
  hide modal
</button>
```

It is also useful to extract commands into their own functions:

```elixir
alias Phoenix.LiveView.JS

def hide_modal(js \\ %JS{}, selector) do
  js
  |> JS.push("modal-closed")
  |> JS.remove_class("show", to: selector, transition: "fade-out")
end
```

```heex
<button phx-click={hide_modal("#modal")}>hide modal</button>
```

The `Phoenix.LiveView.JS.push/3` command is particularly powerful in allowing you to customize the event being pushed to the server. For example, imagine you start with a familiar `phx-click` which pushes a message to the server when clicked:

```heex
<button phx-click="clicked">click</button>
```

Now imagine you want to customize what happens when the `"clicked"` event is pushed, such as which component should be targeted, which element should receive CSS loading state classes, etc. This can be accomplished with options on the JS push command. For example:

```heex
<button phx-click={JS.push("clicked", target: @myself, loading: ".container")}>click</button>
```

See `Phoenix.LiveView.JS.push/3` for all supported options.

## DOM patching

A container can be marked with `phx-update` to configure how the DOM
is updated. The following values are supported:

  * `replace` - the default operation. Replaces the element with the contents

  * `stream` - supports stream operations. Streams are used to manage large
    collections in the UI without having to store the collection on the server

  * `ignore` - ignores updates to the DOM regardless of new content changes.
    This is useful for client-side interop with existing libraries that do
    their own DOM operations

When using `phx-update`, a unique DOM ID must always be set in the
container. If using "stream", a DOM ID must also be set
for each child. When inserting stream elements containing an
ID already present in the container, LiveView will replace the existing
element with the new content. See `Phoenix.LiveView.stream/3` for more
information.

The "ignore" behaviour is frequently used when you need to integrate
with another JS library. Updates from the server to the element's content
and attributes are ignored, *except for data attributes*. Changes, additions,
and removals from the server to data attributes are merged with the ignored
element which can be used to pass data to the JS handler.

To react to elements being mounted to the DOM, the `phx-mounted` binding
can be used. For example, to animate an element on mount:

```heex
<div phx-mounted={JS.transition("animate-ping", time: 500)}>
```

If `phx-mounted` is used on the initial page render, it will be invoked only
after the initial WebSocket connection is established.

To react to elements being removed from the DOM, the `phx-remove` binding
may be specified, which can contain a `Phoenix.LiveView.JS` command to execute.
The `phx-remove` command is only executed for the removed parent element.
It does not cascade to children.

To react to elements being updated in the DOM, you'll need to use a
[hook](js-interop.md#client-hooks-via-phx-hook), which gives you full access
to the element life-cycle.

## Lifecycle events

LiveView supports the `phx-connected` and `phx-disconnected` bindings to react
to connection lifecycle events with JS commands. For example, to show an element
when the LiveView has lost its connection and hide it when the connection
recovers:

```heex
<div id="status" class="hidden" phx-disconnected={JS.show()} phx-connected={JS.hide()}>
  Attempting to reconnect...
</div>
```

`phx-connected` and `phx-disconnected` are only executed when operating
inside a LiveView container. For static templates, they will have no effect.

## LiveView events prefix

The `lv:` event prefix supports LiveView specific features that are handled
by LiveView without calling the user's `handle_event/3` callbacks. Today,
the following events are supported:

  - `lv:clear-flash` – clears the flash when sent to the server. If a
    `phx-value-key` is provided, the specific key will be removed from the flash.

For example:

```heex
<p class="alert" phx-click="lv:clear-flash" phx-value-key="info">
  {Phoenix.Flash.get(@flash, :info)}
</p>
```

## Scroll events and infinite pagination

The `phx-viewport-top` and `phx-viewport-bottom` bindings allow you to detect when a container's
first child reaches the top of the viewport, or the last child reaches the bottom of the viewport.
This is useful for infinite scrolling where you want to send paging events for the next results set or previous results set as the user is scrolling up and down and reaches the top or bottom of the viewport.

Generally, applications will add padding above and below a container when performing infinite scrolling to allow smooth scrolling as results are loaded. Combined with `Phoenix.LiveView.stream/3`, the `phx-viewport-top` and `phx-viewport-bottom` allow for infinite virtualized list that only keeps a small set of actual elements in the DOM. For example:

```elixir
def mount(_, _, socket) do
  {:ok,
    socket
    |> assign(page: 1, per_page: 20)
    |> paginate_posts(1)}
end

defp paginate_posts(socket, new_page) when new_page >= 1 do
  %{per_page: per_page, page: cur_page} = socket.assigns
  posts = Blog.list_posts(offset: (new_page - 1) * per_page, limit: per_page)

  {posts, at, limit} =
    if new_page >= cur_page do
      {posts, -1, per_page * 3 * -1}
    else
      {Enum.reverse(posts), 0, per_page * 3}
    end

  case posts do
    [] ->
      assign(socket, end_of_timeline?: at == -1)

    [_ | _] = posts ->
      socket
      |> assign(end_of_timeline?: false)
      |> assign(:page, new_page)
      |> stream(:posts, posts, at: at, limit: limit)
  end
end
```

Our `paginate_posts` function fetches a page of posts, and determines if the user is paging to a previous page or next page. Based on the direction of paging, the stream is either prepended to, or appended to with `at` of `0` or `-1` respectively. We also set the `limit` of the stream to three times the `per_page` to allow enough posts in the UI to appear as an infinite list, but small enough to maintain UI performance. We also set an `@end_of_timeline?` assign to track whether the user is at the end of results or not. Finally, we update the `@page` assign and posts stream. We can then wire up our container to support the viewport events:

```heex
<ul
  id="posts"
  phx-update="stream"
  phx-viewport-top={@page > 1 && JS.push("prev-page", page_loading: true)}
  phx-viewport-bottom={!@end_of_timeline? && JS.push("next-page", page_loading: true)}
  class={[
    if(@end_of_timeline?, do: "pb-10", else: "pb-[calc(200vh)]"),
    if(@page == 1, do: "pt-10", else: "pt-[calc(200vh)]")
  ]}
>
  <li :for={{id, post} <- @streams.posts} id={id}>
    <.post_card post={post} />
  </li>
</ul>
<div :if={@end_of_timeline?} class="mt-5 text-[50px] text-center">
  🎉 You made it to the beginning of time 🎉
</div>
```

There's not much here, but that's the point! This little snippet of UI is driving a fully virtualized list with bidirectional infinite scrolling. We use the `phx-viewport-top` binding to send the `"prev-page"` event to the LiveView, but only if the user is beyond the first page. It doesn't make sense to load negative page results, so we remove the binding entirely in those cases. Next, we wire up `phx-viewport-bottom` to send the `"next-page"` event, but only if we've yet to reach the end of the timeline. Finally, we conditionally apply some CSS classes which sets a large top and bottom padding to twice the viewport height based on the current pagination for smooth scrolling.

To complete our solution, we only need to handle the `"prev-page"` and `"next-page"` events in the LiveView:

```elixir
def handle_event("next-page", _, socket) do
  {:noreply, paginate_posts(socket, socket.assigns.page + 1)}
end

def handle_event("prev-page", %{"_overran" => true}, socket) do
  {:noreply, paginate_posts(socket, 1)}
end

def handle_event("prev-page", _, socket) do
  if socket.assigns.page > 1 do
    {:noreply, paginate_posts(socket, socket.assigns.page - 1)}
  else
    {:noreply, socket}
  end
end
```

This code simply calls the `paginate_posts` function we defined as our first step, using the current or next page to drive the results. Notice that we match on a special `"_overran" => true` parameter in our `"prev-page"` event. The viewport events send this parameter when the user has "overran" the viewport top or bottom. Imagine the case where the user is scrolling back up through many pages of results, but grabs the scrollbar and returns immediately to the top of the page. This means our `<ul id="posts">` container was overrun by the top of the viewport, and we need to reset the the UI to page the first page.

When testing, you can use `Phoenix.LiveViewTest.render_hook/3` to test the viewport events:

```elixir
view
|> element("#posts")
|> render_hook("next-page")
```
```

## File: `guides/client/external-uploads.md`
```
# External uploads

> This guide continues from the configuration started in the
> server [Uploads guide](uploads.html).

Uploads to external cloud providers, such as Amazon S3,
Google Cloud, etc., can be achieved by using the
`:external` option in [`allow_upload/3`](`Phoenix.LiveView.allow_upload/3`).

You provide a 2-arity function to allow the server to
generate metadata for each upload entry, which is passed to
a user-specified JavaScript function on the client.

Typically when your function is invoked, you will generate a
pre-signed URL, specific to your cloud storage provider, that
will provide temporary access for the end-user to upload data
directly to your cloud storage.

## Chunked HTTP Uploads

For any service that supports large file
uploads via chunked HTTP requests with `Content-Range`
headers, you can use the UpChunk JS library by Mux to do all
the hard work of uploading the file. For small file uploads
or to get started quickly, consider [uploading directly to S3](#direct-to-s3)
instead.

You only need to wire the UpChunk instance to the LiveView
UploadEntry callbacks, and LiveView will take care of the rest.

Install [UpChunk](https://github.com/muxinc/upchunk) by
saving [its contents](https://unpkg.com/@mux/upchunk@2)
to `assets/vendor/upchunk.js` or by installing it with `npm`:

```shell
$ npm install --prefix assets --save @mux/upchunk
```

Configure your uploader on `c:Phoenix.LiveView.mount/3`:

    def mount(_params, _session, socket) do
      {:ok,
       socket
       |> assign(:uploaded_files, [])
       |> allow_upload(:avatar, accept: :any, max_entries: 3, external: &presign_upload/2)}
    end

Supply the `:external` option to
`Phoenix.LiveView.allow_upload/3`. It requires a 2-arity
function that generates a signed URL where the client will
push the bytes for the upload entry. This function must
return either `{:ok, meta, socket}` or `{:error, meta, socket}`,
where `meta` must be a map.

For example, if you were using a context that provided a
[`start_session`](https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol##Start_Resumable_Session)
function, you might write something like this:

    defp presign_upload(entry, socket) do
      {:ok, %{"Location" => link}} =
        SomeTube.start_session(%{
          "uploadType" => "resumable",
          "x-upload-content-length" => entry.client_size
        })

      {:ok, %{uploader: "UpChunk", entrypoint: link}, socket}
    end

Finally, on the client-side, we use UpChunk to create an
upload from the temporary URL generated on the server and
attach listeners for its events to the entry's callbacks:

```javascript
import * as UpChunk from "@mux/upchunk"

let Uploaders = {}

Uploaders.UpChunk = function(entries, onViewError){
  entries.forEach(entry => {
    // create the upload session with UpChunk
    let { file, meta: { entrypoint } } = entry
    let upload = UpChunk.createUpload({ endpoint: entrypoint, file })

    // stop uploading in the event of a view error
    onViewError(() => upload.pause())

    // upload error triggers LiveView error
    upload.on("error", (e) => entry.error(e.detail.message))

    // notify progress events to LiveView
    upload.on("progress", (e) => {
      if(e.detail < 100){ entry.progress(e.detail) }
    })

    // success completes the UploadEntry
    upload.on("success", () => entry.progress(100))
  })
}

// Don't forget to assign Uploaders to the liveSocket
let liveSocket = new LiveSocket("/live", Socket, {
  uploaders: Uploaders,
  params: {_csrf_token: csrfToken}
})
```

## Direct to S3

The largest object that can be uploaded to S3 in a single PUT is 5 GB
according to [S3 FAQ](https://aws.amazon.com/s3/faqs/). For larger file
uploads, consider using chunking as shown above.

This guide assumes an existing S3 bucket is set up with the correct CORS configuration
which allows uploading directly to the bucket.

An example CORS config is:

```json
[
    {
        "AllowedHeaders": [ "*" ],
        "AllowedMethods": [ "PUT", "POST" ],
        "AllowedOrigins": [ "*" ],
        "ExposeHeaders": []
    }
]
```

You may put your domain in the "allowedOrigins" instead. More information on configuring CORS for
S3 buckets is [available on AWS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ManageCorsUsing.html).

In order to enforce all of your file constraints when uploading to S3,
it is necessary to perform a multipart form POST with your file data.
You should have the following S3 information ready before proceeding:

1. aws_access_key_id
2. aws_secret_access_key
3. bucket_name
4. region

We will first implement the LiveView portion:

```elixir
def mount(_params, _session, socket) do
  {:ok,
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: :any, max_entries: 3, external: &presign_upload/2)}
end

defp presign_upload(entry, socket) do
  uploads = socket.assigns.uploads
  bucket = "phx-upload-example"
  key = "public/#{entry.client_name}"

  config = %{
    region: "us-east-1",
    access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
  }

  {:ok, fields} =
    SimpleS3Upload.sign_form_upload(config, bucket,
      key: key,
      content_type: entry.client_type,
      max_file_size: uploads[entry.upload_config].max_file_size,
      expires_in: :timer.hours(1)
    )

  meta = %{uploader: "S3", key: key, url: "http://#{bucket}.s3-#{config.region}.amazonaws.com", fields: fields}
  {:ok, meta, socket}
end
```

Here, we implemented a `presign_upload/2` function, which we passed as a
captured anonymous function to `:external`. It generates a pre-signed URL
for the upload and returns our `:ok` result, with a payload of metadata
for the client, along with our unchanged socket. 

Next, we add a missing module `SimpleS3Upload` to generate pre-signed URLs
for S3. Create a file called `simple_s3_upload.ex`. Get the file's content
from this zero-dependency module called [`SimpleS3Upload`](https://gist.github.com/chrismccord/37862f1f8b1f5148644b75d20d1cb073)
written by Chris McCord.

> Tip: if you encounter errors with the `:crypto` module or with S3 blocking ACLs, 
> please read the comments in the gist above for solutions.

Next, we add our JavaScript client-side uploader. The metadata *must* contain the
`:uploader` key, specifying the name of the JavaScript client-side uploader.
In this case, it's `"S3"`, as shown above.

Add a new file `uploaders.js` in the following directory `assets/js/` next to `app.js`.
The content for this `S3` client uploader:

```javascript
let Uploaders = {}

Uploaders.S3 = function(entries, onViewError){
  entries.forEach(entry => {
    let formData = new FormData()
    let {url, fields} = entry.meta
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val))
    formData.append("file", entry.file)
    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 204 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable){
        let percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100){ entry.progress(percent) }
      }
    })

    xhr.open("POST", url, true)
    xhr.send(formData)
  })
}

export default Uploaders;
```

We define an `Uploaders.S3` function, which receives our entries. It then
performs an AJAX request for each entry, using the `entry.progress()` and
`entry.error()` functions to report upload events back to the LiveView.
The name of the uploader must match the one we return on the `:uploader`
metadata in LiveView.

Finally, head over to `app.js` and add the `uploaders: Uploaders` key to
the `LiveSocket` constructor to tell phoenix where to find the uploaders returned 
within the external metadata.

```javascript
// for uploading to S3
import Uploaders from "./uploaders"

let liveSocket = new LiveSocket("/live",
   Socket, {
     params: {_csrf_token: csrfToken},
     uploaders: Uploaders
  }
)
```

Now "S3" returned from the server will match the one in the client.
To debug client-side JavaScript when trying to upload, you can inspect your
browser and look at the console or networks tab to view the error logs.

### Direct to S3-Compatible

> This section assumes that you installed and configured [ExAws](https://hexdocs.pm/ex_aws/readme.html)
> and [ExAws.S3](https://hexdocs.pm/ex_aws_s3/ExAws.S3.html) correctly in your project and can execute
> the examples in the page without errors.

Most S3 compatible platforms like Cloudflare R2 don't support `POST` when
uploading files so we need to use `PUT` with a signed URL instead of the
signed `POST`and send the file straight to the service, to do so we need to
change the `presign_upload/2` function and the `Uploaders.S3` that does the upload.

The new `presign_upload/2`:

```elixir
def presign_upload(entry, socket) do
  config = ExAws.Config.new(:s3)
  bucket = "bucket"
  key = "public/#{entry.client_name}"

  {:ok, url} =
    ExAws.S3.presigned_url(config, :put, bucket, key,
      expires_in: 3600,
      query_params: [{"Content-Type", entry.client_type}]
    )
   {:ok, %{uploader: "S3", key: key, url: url}, socket}
end
```

The new `Uploaders.S3`:

```javascript
Uploaders.S3 = function (entries, onViewError) {
  entries.forEach(entry => {
    let xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort())
    xhr.onload = () => xhr.status === 200 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()

    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable){
        let percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100){ entry.progress(percent) }
      }
    })

    let url = entry.meta.url
    xhr.open("PUT", url, true)
    xhr.send(entry.file)
  })
}
```
```

## File: `guides/client/form-bindings.md`
```
# Form bindings

## Form events

To handle form changes and submissions, use the `phx-change` and `phx-submit`
events. In general, it is preferred to handle input changes at the form level,
where all form fields are passed to the LiveView's callback given any
single input change. For example, to handle real-time form validation and
saving, your form would use both `phx-change` and `phx-submit` bindings.
Let's get started with an example:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input type="text" field={@form[:username]} />
  <.input type="email" field={@form[:email]} />
  <button>Save</button>
</.form>
```

`.form` is the function component defined in `Phoenix.Component.form/1`,
we recommend reading its documentation for more details on how it works
and all supported options. `.form` expects a `@form` assign, which can
be created from a changeset or user parameters via `Phoenix.Component.to_form/1`.

`input/1` is a function component for rendering inputs, most often
defined in your own application, often encapsulating labelling,
error handling, and more. Here is a simple version to get started with:

    attr :field, Phoenix.HTML.FormField
    attr :rest, :global, include: ~w(type)
    def input(assigns) do
      ~H"""
      <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
      """
    end

> ### The `CoreComponents` module {: .info}
>
> If your application was generated with Phoenix v1.7, then `mix phx.new`
> automatically imports many ready-to-use function components, such as
> `.input` component with built-in features and styles.

With the form rendered, your LiveView picks up the events in `handle_event`
callbacks, to validate and attempt to save the parameter accordingly:

    def render(assigns) ...

    def mount(_params, _session, socket) do
      {:ok, assign(socket, form: to_form(Accounts.change_user(%User{})))}
    end

    def handle_event("validate", %{"user" => params}, socket) do
      form =
        %User{}
        |> Accounts.change_user(params)
        |> to_form(action: :validate)

      {:noreply, assign(socket, form: form)}
    end

    def handle_event("save", %{"user" => user_params}, socket) do
      case Accounts.create_user(user_params) do
        {:ok, user} ->
          {:noreply,
           socket
           |> put_flash(:info, "user created")
           |> redirect(to: ~p"/users/#{user}")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    end

The validate callback simply updates the changeset based on all form input
values, then convert the changeset to a form and assign it to the socket.
If the form changes, such as generating new errors, [`render/1`](`c:Phoenix.LiveView.render/1`)
is invoked and the form is re-rendered.

Likewise for `phx-submit` bindings, the same callback is invoked and
persistence is attempted. On success, a `:noreply` tuple is returned and the
socket is annotated for redirect with `Phoenix.LiveView.redirect/2` to
the new user page, otherwise the socket assigns are updated with the errored
changeset to be re-rendered for the client.

You may wish for an individual input to use its own change event or to target
a different component. This can be accomplished by annotating the input itself
with `phx-change`, for example:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  ...
  <.input field={@form[:email]}  phx-change="email_changed" phx-target={@myself} />
</.form>
```

Then your LiveView or LiveComponent would handle the event:

```elixir
def handle_event("email_changed", %{"user" => %{"email" => email}}, socket) do
  ...
end
```

> #### Note {: .warning}
> 1. Only the individual input is sent as params for an input marked with `phx-change`.
> 2. While it is possible to use `phx-change` on individual inputs, those inputs
>    must still be within a form.

## Error feedback

For proper error feedback on form updates, LiveView sends special parameters on form events
starting with `_unused_` to indicate that the input for the specific field has not been interacted with yet.

When creating a form from these parameters through `Phoenix.Component.to_form/2` or `Phoenix.Component.form/1`,
`Phoenix.Component.used_input?/1` can be used to filter error messages.

For example, your `MyAppWeb.CoreComponents` may use this function:

```elixir
def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

  assigns
  |> assign(field: nil, id: assigns.id || field.id)
  |> assign(:errors, Enum.map(errors, &translate_error(&1)))
```

Now only errors for fields that were interacted with are shown.

To disable sending of `_unused` parameters, you can annotate individual inputs or the whole form with
`phx-no-usage-tracking`.

## Number inputs

Number inputs are a special case in LiveView forms. On programmatic updates,
some browsers will clear invalid inputs. So LiveView will not send change events
from the client when an input is invalid, instead allowing the browser's native
validation UI to drive user interaction. Once the input becomes valid, change and
submit events will be sent normally.

```heex
<input type="number">
```

This is known to have a plethora of problems including accessibility, large numbers
are converted to exponential notation, and scrolling can accidentally increase or
decrease the number.

One alternative is the `inputmode` attribute, which may serve your application's needs
and users much better. According to [Can I Use?](https://caniuse.com/#search=inputmode),
the following is supported by 94% of the global market (as of Nov 2024):

```heex
<input type="text" inputmode="numeric" pattern="[0-9]*">
```

## Password inputs

Password inputs are also special cased in `Phoenix.HTML`. For security reasons,
password field values are not reused when rendering a password input tag. This
requires explicitly setting the `:value` in your markup, for example:

```heex
<.input field={f[:password]} value={input_value(f[:password].value)} />
<.input field={f[:password_confirmation]} value={input_value(f[:password_confirmation].value)} />
```

## Nested inputs

Nested inputs are handled using `.inputs_for` function component. By default
it will add the necessary hidden input fields for tracking ids of Ecto associations.

```heex
<.inputs_for :let={fp} field={f[:friends]}>
  <.input field={fp[:name]} type="text" />
</.inputs_for>
```

## File inputs

LiveView forms support [reactive file inputs](uploads.md),
including drag and drop support via the `phx-drop-target`
attribute:

```heex
<div class="container" phx-drop-target={@uploads.avatar.ref}>
  ...
  <.live_file_input upload={@uploads.avatar} />
</div>
```

See `Phoenix.Component.live_file_input/1` for more.

## Submitting the form action over HTTP

The `phx-trigger-action` attribute can be added to a form to trigger a standard
form submit on DOM patch to the URL specified in the form's standard `action`
attribute. This is useful to perform pre-final validation of a LiveView form
submit before posting to a controller route for operations that require
Plug session mutation. For example, in your LiveView template you can
annotate the `phx-trigger-action` with a boolean assign:

```heex
<.form :let={f} for={@changeset}
  action={~p"/users/reset_password"}
  phx-submit="save"
  phx-trigger-action={@trigger_submit}>
```

Then in your LiveView, you can toggle the assign to trigger the form with the current
fields on next render:

    def handle_event("save", params, socket) do
      case validate_change_password(socket.assigns.user, params) do
        {:ok, changeset} ->
          {:noreply, assign(socket, changeset: changeset, trigger_submit: true)}

        {:error, changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end

Once `phx-trigger-action` is true, LiveView disconnects and then submits the form.

## Recovery following crashes or disconnects

By default, all forms marked with `phx-change` and having `id`
attribute will recover input values automatically after the user has
reconnected or the LiveView has remounted after a crash. This is
achieved by the client triggering the same `phx-change` to the server
as soon as the mount has been completed.

**Note:** if you want to see form recovery working in development, please
make sure to disable live reloading in development by commenting out the
LiveReload plug in your `endpoint.ex` file or by setting `code_reloader: false`
in your `config/dev.exs`. Otherwise live reloading may cause the current page
to be reloaded whenever you restart the server, which will discard all form
state.

For most use cases, this is all you need and form recovery will happen
without consideration. In some cases, where forms are built step-by-step in a
stateful fashion, it may require extra recovery handling on the server outside
of your existing `phx-change` callback code. To enable specialized recovery,
provide a `phx-auto-recover` binding on the form to specify a different event
to trigger for recovery, which will receive the form params as usual. For example,
imagine a LiveView wizard form where the form is stateful and built based on what
step the user is on and by prior selections:

```heex
<form id="wizard" phx-change="validate_wizard_step" phx-auto-recover="recover_wizard">
```

On the server, the `"validate_wizard_step"` event is only concerned with the
current client form data, but the server maintains the entire state of the wizard.
To recover in this scenario, you can specify a recovery event, such as `"recover_wizard"`
above, which would wire up to the following server callbacks in your LiveView:

    def handle_event("validate_wizard_step", params, socket) do
      # regular validations for current step
      {:noreply, socket}
    end

    def handle_event("recover_wizard", params, socket) do
      # rebuild state based on client input data up to the current step
      {:noreply, socket}
    end

To forgo automatic form recovery, set `phx-auto-recover="ignore"`.

## Resetting forms

To reset a LiveView form, you can use the standard `type="reset"` on a
form button or input. When clicked, the form inputs will be reset to their
original values.
After the form is reset, a `phx-change` event is emitted with the `_target` param
containing the reset `name`. For example, the following element:

```heex
<form phx-change="changed">
  ...
  <button type="reset" name="reset">Reset</button>
</form>
```

Can be handled on the server differently from your regular change function:

    def handle_event("changed", %{"_target" => ["reset"]} = params, socket) do
      # handle form reset
    end

    def handle_event("changed", params, socket) do
      # handle regular form change
    end

## JavaScript client specifics

The JavaScript client is always the source of truth for current input values.
For any given input with focus, LiveView will never overwrite the input's current
value, even if it deviates from the server's rendered updates. This works well
for updates where major side effects are not expected, such as form validation
errors, or additive UX around the user's input values as they fill out a form.

For these use cases, the `phx-change` input does not concern itself with disabling
input editing while an event to the server is in flight. When a `phx-change` event
is sent to the server, the input tag and parent form tag receive the
`phx-change-loading` CSS class, then the payload is pushed to the server with a
`"_target"` param in the root payload containing the keyspace of the input name
which triggered the change event.

For example, if the following input triggered a change event:

```heex
<input name="user[username]"/>
```

The server's `handle_event/3` would receive a payload:

    %{"_target" => ["user", "username"], "user" => %{"username" => "Name"}}

The `phx-submit` event is used for form submissions where major side effects
typically happen, such as rendering new containers, calling an external
service, or redirecting to a new page.

On submission of a form bound with a `phx-submit` event:

1. The form's inputs are set to `readonly`
2. Any submit button on the form is disabled
3. The form receives the `"phx-submit-loading"` class

On completion of server processing of the `phx-submit` event:

1. The submitted form is reactivated and loses the `"phx-submit-loading"` class
2. The last input with focus is restored (unless another input has received focus)
3. Updates are patched to the DOM as usual

To handle latent events, the `<button>` tag of a form can be annotated with
`phx-disable-with`, which swaps the element's `innerText` with the provided
value during event submission. For example, the following code would change
the "Save" button to "Saving...", and restore it to "Save" on acknowledgment:

```heex
<button type="submit" phx-disable-with="Saving...">Save</button>
```

> #### A note on disabled buttons {: .info}
>
> By default, LiveView only disables submit buttons and inputs within forms
> while waiting for a server acknowledgement. If you want a button outside of
> a form to be disabled without changing its text, you can add `phx-disable-with`
> without a value:
>
> ```heex
>  <button type="button" phx-disable-with>...</button>
> ```
>
> Note also that LiveView ignores clicks on elements that are currently awaiting
> an acknowledgement from the server. This means that although a regular button
> without `phx-disable-with` is not semantically disabled while waiting for a
> server response, it will not trigger duplicate events.
>
> Finally, `phx-disable-with` works with an element‘s `innerText`,
> therefore nested DOM elements, like `svg` or icons, won't be preserved.
> See "CSS loading states" for alternative approaches to this.

You may also take advantage of LiveView's CSS loading state classes to
swap out your form content while the form is submitting. For example,
with the following rules in your `app.css`:

```css
.while-submitting { display: none; }
.inputs { display: block; }

.phx-submit-loading .while-submitting { display: block; }
.phx-submit-loading .inputs { display: none; }
```

You can show and hide content with the following markup:

```heex
<form phx-change="update">
  <div class="while-submitting">Please wait while we save our content...</div>
  <div class="inputs">
    <input type="text" name="text" value={@text}>
  </div>
</form>
```

Additionally, we strongly recommend including a unique HTML "id" attribute on the form.
When DOM siblings change, elements without an ID will be replaced rather than moved,
which can cause issues such as form fields losing focus.

## Triggering `phx-` form events with JavaScript

Often it is desirable to trigger an event on a DOM element without explicit
user interaction on the element. For example, a custom form element such as a
date picker or custom select input which utilizes a hidden input element to
store the selected state.

In these cases, the event functions on the DOM API can be used, for example
to trigger a `phx-change` event:

```javascript
document.getElementById("my-select").dispatchEvent(
  new Event("input", {bubbles: true})
)
```

When using a client hook, `this.el` can be used to determine the element as
outlined in the "Client hooks" documentation.

It is also possible to trigger a `phx-submit` using a "submit" event:

```javascript
document.getElementById("my-form").dispatchEvent(
  new Event("submit", {bubbles: true, cancelable: true})
)
```

## Preventing form submission with JavaScript

In some cases, you may want to conditionally prevent form submission based on client-side validation or other business logic before allowing a `phx-submit` to be processed by the server.

JavaScript can be used to prevent the default form submission behavior, for example with a [hook](js-interop.md#client-hooks-via-phx-hook):

```javascript
/**
 * @type {import("phoenix_live_view").HooksOptions}
 */
let Hooks = {}
Hooks.CustomFormSubmission = {
  mounted() {
    this.el.addEventListener("submit", (event) => {
      if (!this.shouldSubmit()) {
        // prevent the event from bubbling to the default LiveView handler
        event.stopPropagation()
        // prevent the default browser behavior (submitting the form over HTTP)
        event.preventDefault()
      }
    })
  },
  shouldSubmit() {
    // Check if we should submit the form
    ...
  }
}
```

This hook can be set on your form as such:

```heex
<form phx-hook="CustomFormSubmission">
  <input type="text" name="text" value={@text}>
</form>
```
```

## File: `guides/client/js-interop.md`
```
# JavaScript interoperability

To enable LiveView client/server interaction, we instantiate a LiveSocket. For example:

```javascript
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
```

All options are passed directly to the `Phoenix.Socket` constructor,
except for the following LiveView specific options:

  * `bindingPrefix` - the prefix to use for phoenix bindings. Defaults `"phx-"`
  * `params` - the `connect_params` to pass to the view's mount callback. May be
    a literal object or closure returning an object. When a closure is provided,
    the function receives the view's element.
  * `hooks` - a reference to a user-defined hooks namespace, containing client
    callbacks for server/client interop. See the [Client hooks](#client-hooks-via-phx-hook)
    section below for details.
  * `uploaders` - a reference to a user-defined uploaders namespace, containing
    client callbacks for client-side direct-to-cloud uploads. See the
    [External uploads guide](external-uploads.md) for details.
  * `metadata` - additional user-defined metadata that is sent along events to the server.
    See the [Key events](bindings.html#key-events) section in the bindings guide
    for an example.

The `liveSocket` instance exposes the following methods:
- `connect()` - call this once after creation to connect to the server
- `enableDebug()` -  turns on debug logging, see [Debugging client events](#debugging-client-events)
- `disableDebug()` -  turns off debug logging
- `enableLatencySim(milliseconds)` - turns on latency simulation, see [Simulating latency](#simulating-latency)
- `disableLatencySim()` - turns off latency simulation
- `execJS(el, encodedJS)` - executes encoded JavaScript in the context of the element
- `js()` - returns an object with methods to manipluate the DOM and execute JavaScript. The applied changes integrate with server DOM patching. See [JS commands](#js-commands).

## Debugging client events

To aid debugging on the client when troubleshooting issues, the `enableDebug()`
and `disableDebug()` functions are exposed on the `LiveSocket` JavaScript instance.
Calling `enableDebug()` turns on debug logging which includes LiveView life-cycle and
payload events as they come and go from client to server. In practice, you can expose
your instance on `window` for quick access in the browser's web console, for example:

```javascript
// app.js
let liveSocket = new LiveSocket(...)
liveSocket.connect()
window.liveSocket = liveSocket

// in the browser's web console
>> liveSocket.enableDebug()
```

The debug state uses the browser's built-in `sessionStorage`, so it will remain in effect
for as long as your browser session lasts.

## Simulating Latency

Proper handling of latency is critical for good UX. LiveView's CSS loading states allow
the client to provide user feedback while awaiting a server response. In development,
near zero latency on localhost does not allow latency to be easily represented or tested,
so LiveView includes a latency simulator with the JavaScript client to ensure your
application provides a pleasant experience. Like the `enableDebug()` function above,
the `LiveSocket` instance includes `enableLatencySim(milliseconds)` and `disableLatencySim()`
functions which apply throughout the current browser session. The `enableLatencySim` function
accepts an integer in milliseconds for the one-way latency to and from the server. For example:

```javascript
// app.js
let liveSocket = new LiveSocket(...)
liveSocket.connect()
window.liveSocket = liveSocket

// in the browser's web console
>> liveSocket.enableLatencySim(1000)
[Log] latency simulator enabled for the duration of this browser session.
      Call disableLatencySim() to disable
```

## Handling server-pushed events

When the server uses `Phoenix.LiveView.push_event/3`, the event name
will be dispatched in the browser with the `phx:` prefix. For example,
imagine the following template where you want to highlight an existing
element from the server to draw the user's attention:

```heex
<div id={"item-#{item.id}"} class="item">
  {item.title}
</div>
```

Next, the server can issue a highlight using the standard `push_event`:

```elixir
def handle_info({:item_updated, item}, socket) do
  {:noreply, push_event(socket, "highlight", %{id: "item-#{item.id}"})}
end
```

Finally, a window event listener can listen for the event and conditionally
execute the highlight command if the element matches:

```javascript
let liveSocket = new LiveSocket(...)
window.addEventListener("phx:highlight", (e) => {
  let el = document.getElementById(e.detail.id)
  if(el) {
    // logic for highlighting
  }
})
```

If you desire, you can also integrate this functionality with Phoenix'
JS commands, executing JS commands for the given element whenever highlight
is triggered. First, update the element to embed the JS command into a data
attribute:

```heex
<div id={"item-#{item.id}"} class="item" data-highlight={JS.transition("highlight")}>
  {item.title}
</div>
```

Now, in the event listener, use `LiveSocket.execJS` to trigger all JS
commands in the new attribute:

```javascript
let liveSocket = new LiveSocket(...)
window.addEventListener("phx:highlight", (e) => {
  document.querySelectorAll(`[data-highlight]`).forEach(el => {
    if(el.id == e.detail.id){
      liveSocket.execJS(el, el.getAttribute("data-highlight"))
    }
  })
})
```

## Client hooks via `phx-hook`

To handle custom client-side JavaScript when an element is added, updated,
or removed by the server, a hook object may be provided via `phx-hook`.
`phx-hook` must point to an object with the following life-cycle callbacks:

  * `mounted` - the element has been added to the DOM and its server
    LiveView has finished mounting
  * `beforeUpdate` - the element is about to be updated in the DOM.
    *Note*: any call here must be synchronous as the operation cannot
    be deferred or cancelled.
  * `updated` - the element has been updated in the DOM by the server
  * `destroyed` - the element has been removed from the page, either
    by a parent update, or by the parent being removed entirely
  * `disconnected` - the element's parent LiveView has disconnected from the server
  * `reconnected` - the element's parent LiveView has reconnected to the server

*Note:* When using hooks outside the context of a LiveView, `mounted` is the only
callback invoked, and only those elements on the page at DOM ready will be tracked.
For dynamic tracking of the DOM as elements are added, removed, and updated, a LiveView
should be used.

The above life-cycle callbacks have in-scope access to the following attributes:

  * `el` - attribute referencing the bound DOM node
  * `liveSocket` - the reference to the underlying `LiveSocket` instance
  * `pushEvent(event, payload, (reply, ref) => ...)` - method to push an event from the client to the LiveView server.
    If no callback function is passed, a promise that resolves to the `reply` is returned.
  * `pushEventTo(selectorOrTarget, event, payload, (reply, ref) => ...)` - method to push targeted events from the client
    to LiveViews and LiveComponents. It sends the event to the LiveComponent or LiveView the `selectorOrTarget` is
    defined in, where its value can be either a query selector or an actual DOM element. If the query selector returns
    more than one element it will send the event to all of them, even if all the elements are in the same LiveComponent
    or LiveView. `pushEventTo` supports passing the node element e.g. `this.el` instead of selector e.g. `"#" + this.el.id`
    as the first parameter for target.
    As there can be multiple targets, if no callback is passed, a promise is returned that matches the return value of
    [`Promise.allSettled()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/allSettled#return_value). Individual fulfilled values are of the format `{ reply, ref }`.
  * `handleEvent(event, (payload) => ...)` - method to handle an event pushed from the server. Returns a value that can be passed to `removeHandleEvent` to remove the event handler.
  * `removeHandleEvent(ref)` - method to remove an event handler added via `handleEvent`
  * `upload(name, files)` - method to inject a list of file-like objects into an uploader.
  * `uploadTo(selectorOrTarget, name, files)` - method to inject a list of file-like objects into an uploader.
    The hook will send the files to the uploader with `name` defined by [`allow_upload/3`](`Phoenix.LiveView.allow_upload/3`)
    on the server-side. Dispatching new uploads triggers an input change event which will be sent to the
    LiveComponent or LiveView the `selectorOrTarget` is defined in, where its value can be either a query selector or an
    actual DOM element. If the query selector returns more than one live file input, an error will be logged.
  * `js()` - returns an object with methods to manipluate the DOM and execute JavaScript. The applied changes integrate with server DOM patching. See [JS commands](#js-commands).

For example, the markup for a controlled input for phone-number formatting could be written
like this:

```heex
<input type="text" name="user[phone_number]" id="user-phone-number" phx-hook="PhoneNumber" />
```

Then a hook callback object could be defined and passed to the socket:

```javascript
/**
 * @type {import("phoenix_live_view").HooksOptions}
 */
let Hooks = {}
Hooks.PhoneNumber = {
  mounted() {
    this.el.addEventListener("input", e => {
      let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
      if(match) {
        this.el.value = `${match[1]}-${match[2]}-${match[3]}`
      }
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, ...})
...
```

*Note*: when using `phx-hook`, a unique DOM ID must always be set.

For integration with client-side libraries which require a broader access to full
DOM management, the `LiveSocket` constructor accepts a `dom` option with an
`onBeforeElUpdated` callback. The `fromEl` and `toEl` DOM nodes are passed to the
function just before the DOM patch operations occurs in LiveView. This allows external
libraries to (re)initialize DOM elements or copy attributes as necessary as LiveView
performs its own patch operations. The update operation cannot be cancelled or deferred,
and the return value is ignored.

For example, the following option could be used to guarantee that some attributes set on the client-side are kept intact:

```javascript
...
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      for (const attr of from.attributes) {
        if (attr.name.startsWith("data-js-")) {
          to.setAttribute(attr.name, attr.value);
        }
      }
    }
  }
})
```

In the example above, all attributes starting with `data-js-` won't be replaced when the DOM is patched by LiveView.

A hook can also be defined as a subclass of `ViewHook`:

```javascript
import { ViewHook } from "phoenix_live_view"

class MyHook extends ViewHook {
  mounted() {
    ...
  }
}

let liveSocket = new LiveSocket(..., {
  hooks: {
    MyHook
  }
})
```

### Colocated Hooks / Colocated JavaScript

When writing components that require some more control over the DOM, it often feels inconvenient to
have to write a hook in a separate file. Instead, one wants to have the hook logic right next to the component
code. For such cases, HEEx supports `Phoenix.LiveView.ColocatedHook` and `Phoenix.LiveView.ColocatedJS`.

Let's see an example:

```elixir
def phone_number_input(assigns) do
  ~H"""
  <input type="text" name="user[phone_number]" id="user-phone-number" phx-hook=".PhoneNumber" />
  <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
    export default {
      mounted() {
        this.el.addEventListener("input", e => {
          let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
          if(match) {
            this.el.value = `${match[1]}-${match[2]}-${match[3]}`
          }
        })
      }
    }
  </script>
  """
end
```

When LiveView finds a `<script>` element with `:type={ColocatedHook}`, it will extract the
hook code at compile time and write it into a special folder inside the `_build/` directory.
To use the hooks, all that needs to be done is to import the manifest into your JS bundle,
which is automatically done in the `app.js` file generated by `mix phx.new` for new Phoenix 1.8 apps:

```diff
...
  import {Socket} from "phoenix"
  import {LiveSocket} from "phoenix_live_view"
  import topbar from "../vendor/topbar"
+ import {hooks as colocatedHooks} from "phoenix-colocated/my_app"

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
+   hooks: {...colocatedHooks}
 })
```

The `"phoenix-colocated"` package is a folder inside the `Mix.Project.build_path()`,
which is included by default in the [`esbuild`](https://hexdocs.pm/esbuild) configuration of new
Phoenix projects (requires `{:esbuild, "~> 0.10"}` or later):

```elixir
config :esbuild,
  ...
  my_app: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]
    }
  ]
```

When rendering a component that includes a colocated hook, the `<script>` tag is omitted
from the rendered output. Furthermore, to prevent conflicts with other components, colocated hooks
require you to use the special dot syntax when naming the hook, as well as in the `phx-hook` attribute.
LiveView will prefix the hook name by the current module name at compile time. This also means
that in cases where a hook is meant to be used in multiple components across a project, the hook
should be defined as a regular, non-colocated hook instead.

You can read more about colocated hooks [in the module documentation for `ColocatedHook`](`Phoenix.LiveView.ColocatedHook`).
LiveView also supports colocating other JavaScript code, for more information, see `Phoenix.LiveView.ColocatedJS`.

### Client-server communication

A hook can push events to the LiveView by using the `pushEvent` function and receive a
reply from the server via a `{:reply, map, socket}` return value. The reply payload will be
passed to the optional `pushEvent` response callback.

Communication with the hook from the server can be done by reading data attributes on the
hook element or by using `Phoenix.LiveView.push_event/3` on the server and `handleEvent` on the client.

An example of responding with `:reply` might look like this.

```heex
<div phx-hook="ClickMeHook" id="click-me">
  Click me for a message!
</div>
```

```javascript
Hooks.ClickMeHook = {
  mounted() {
    this.el.addEventListener("click", () => {
      // Push event to LiveView with callback for reply
      this.pushEvent("get_message", {}, (reply) => {
        console.debug(reply.message);
      });
    });
  }
}
```

Then in your callback you respond with `{:reply, map, socket}`

```elixir
def handle_event("get_message", _params, socket) do
  # Use :reply to respond to the pushEvent
  {:reply, %{message: "Hello from LiveView!"}, socket}
end
```

Another example, to implement infinite scrolling, one can pass the current page using data attributes:

```heex
<div id="infinite-scroll" phx-hook="InfiniteScroll" data-page={@page}>
```

And then in the client:

```javascript
/**
 * @type {import("phoenix_live_view").Hook}
 */
Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted(){
    this.pending = this.page()
    window.addEventListener("scroll", e => {
      if(this.pending == this.page() && scrollAt() > 90){
        this.pending = this.page() + 1
        this.pushEvent("load-more", {})
      }
    })
  },
  updated(){ this.pending = this.page() }
}
```

However, the data attribute approach is not a good approach if you need to frequently push data to the client. To push out-of-band events to the client, for example to render charting points, one could do:

```heex
<div id="chart" phx-hook="Chart">
```

And then on the client:

```javascript
/**
 * @type {import("phoenix_live_view").Hook}
 */
Hooks.Chart = {
  mounted(){
    this.handleEvent("points", ({points}) => MyChartLib.addPoints(points))
  }
}
```

And then you can push events as:

    {:noreply, push_event(socket, "points", %{points: new_points})}

Events pushed from the server via `push_event` are global and will be dispatched
to all active hooks on the client who are handling that event. If you need to scope events
(for example when pushing from a live component that has siblings on the current live view),
then this must be done by namespacing them:

    def update(%{id: id, points: points} = assigns, socket) do
      socket =
        socket
        |> assign(assigns)
        |> push_event("points-#{id}", points)

      {:ok, socket}
    end

And then on the client:

```javascript
Hooks.Chart = {
  mounted(){
    this.handleEvent(`points-${this.el.id}`, (points) => MyChartLib.addPoints(points));
  }
}
```

*Note*: In case a LiveView pushes events and renders content, `handleEvent` callbacks are invoked after the page is updated. Therefore, if the LiveView redirects at the same time it pushes events, callbacks won't be invoked on the old page's elements. Callbacks would be invoked on the redirected page's newly mounted hook elements.

## JS commands

*Note*: If possible, construct commands via Elixir using `Phoenix.LiveView.JS` and trigger them via Phoenix DOM [Bindings](bindings.md).

While `Phoenix.LiveView.JS` allows you to construct a declarative representation of a command, it may not cover all use cases.
In addition, you can execute commands that integrate with server DOM patching via JavaScript using:
- Client hooks: `this.js()` or the
- LiveSocket instance: `liveSocket.js()`.

The command interface returned by `js()` above offers the following functions:
- `show(el, opts = {})` - shows an element. Options: `display`, `transition`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.show/1`.
- `hide(el, opts = {})` - hides an element. Options: `transition`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.hide/1`.
- `toggle(el, opts = {})` - toggles the visibility of an element. Options: `display`, `in`, `out`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.toggle/1`.
- `addClass(el, names, opts = {})` - adds CSS class(es) to an element. Options: `transition`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.add_class/1`.
- `removeClass(el, names, opts = {})` - removes CSS class(es) to an element. Options: `transition`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.remove_class/1`.
- `toggleClass(el, names, opts = {})` - toggles CSS class(es) to an element. Options: `transition`, `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.toggle_class/1`.
- `transition(el, transition, opts = {})` - applies a CSS transition to an element. Options: `time`, `blocking`. For more details, see `Phoenix.LiveView.JS.transition/1`.
- `setAttribute(el, attr, val)` - sets an attribute on an element
- `removeAttribute(el, attr)` - removes an attribute from an element
- `toggleAttribute(el, attr, val1, val2)` - toggles an attribute on an element between two values
- `push(el, type, opts = {})` - pushes an event to the server. To target a LiveComponent by its ID, pass a separate `target` in the options. Options: `target`, `loading`, `page_loading`, `value`. For more details, see `Phoenix.LiveView.JS.push/1`.
- `navigate(href, opts = {})` - sends a navigation event to the server and updates the browser's pushState history. Options: `replace`. For more details, see `Phoenix.LiveView.JS.navigate/1`.
- `patch(href, opts = {})` - sends a patch event to the server and updates the browser's pushState history. Options: `replace`. For more details, see `Phoenix.LiveView.JS.patch/1`.
- `exec(encodedJS)` - *only via Client hook `this.js()`*: executes encoded JavaScript in the context of the hook's root node. The encoded JS command should be constructed via `Phoenix.LiveView.JS` and is usually stored as an HTML attribute. Example: `this.js().exec(this.el.getAttribute('phx-remove'))`.
- `exec(el, encodedJS)` - *only via `liveSocket.js()`*: executes encoded JavaScript in the context of any element.
```

## File: `guides/client/syncing-changes.md`
```
# Syncing changes and optimistic UIs

When using LiveView, whenever you change the state in your LiveView process, changes are automatically sent and applied in the client.

However, in many occasions, the client may have its own state: inputs, buttons, focused UI elements, and more. In order to avoid server updates from destroying state on the client, LiveView provides several features and out-of-the-box conveniences.

Let's start by discussing which problems may arise from client-server integration, which may apply to any web application, and explore how LiveView solves it automatically. If you want to focus on the more practical aspects, you can jump to later sections or watch the video below:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/fCdi7SEPrTs?si=ai_gcKZALmzc1Gy8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## The problem in a nutshell

Imagine your web application has a form. The form has a single email input and a button. We have to validate that the email is unique in our database and render a tiny “✗” or “✓“ accordingly close to the input. Because we are using server-side rendering, we are debouncing/throttling form changes to the server. And, to avoid double-submissions, we want to disable the button as soon as it is clicked.

Here is what could happen. The user has typed “hello@example.” and debounce kicks in, causing the client to send an event to the server. Here is how the client looks like at this moment:

```plain
[ hello@example.    ]

    ------------
       SUBMIT
    ------------
```

While the server is processing this information, the user finishes typing the email and presses submit. The client sends the submit event to the server, then proceeds to disable the button, and change its value to “SUBMITTING”:

```plain
[ hello@example.com ]

    ------------
     SUBMITTING
    ------------
```

Immediately after pressing submit, the client receives an update from the server, but this is an update from the debounce event! If the client were to simply render this server update, the client would effectively roll back the form to the previous state shown below, which would be a disaster:

```plain
[ hello@example.    ] ✓

    ------------
       SUBMIT
    ------------
```

This is a simple example of how client and server state can evolve and differ for periods of times, due to the latency (distance) between them, in any web application, not only LiveView.

LiveView solves this in two ways:

* The JavaScript client is always the source of truth for current input values

* LiveView tracks how many events are currently in flight in a given input/button/form. The changes to the form are applied behind the scenes as they arrive, but LiveView only shows them once all in-flight events have been resolved

In other words, for the most common cases, **LiveView will automatically sync client and server state for you**. This is a huge benefit of LiveView, as many other stacks would require developers to tackle these problems themselves. For complete detail in how LiveView handles forms, see [the JavaScript client specifics in the Form Bindings page](form-bindings.md#javascript-client-specifics).

## Optimistic UIs via loading classes

Whenever an HTML element pushes an event to the server, LiveView will attach a `-loading` class to it. For example the following markup:

```heex
<button phx-click="clicked" phx-window-keydown="key">...</button>
```

On click, would receive the `phx-click-loading` class, and on keydown would receive the `phx-keydown-loading` class. The CSS loading classes are maintained until an acknowledgement is received on the client for the pushed event. If the element is triggered several times, the loading state is removed only when all events are resolved.

This means the most trivial optimistic UI enhancements can be done in LiveView by simply adding a CSS rule. For example, imagine you want to fade the text of an element when it is clicked, while it waits for a response:

```css
.phx-click-loading.opaque-on-click {
  opacity: 50%;
}
```

Now, by adding the class `opaque-on-click` to any element, the elements give an immediate feedback on click.

The following events receive CSS loading classes:

  - `phx-click` - `phx-click-loading`
  - `phx-change` - `phx-change-loading`
  - `phx-submit` - `phx-submit-loading`
  - `phx-focus` - `phx-focus-loading`
  - `phx-blur` - `phx-blur-loading`
  - `phx-window-keydown` - `phx-keydown-loading`
  - `phx-window-keyup` - `phx-keyup-loading`

Events that happen inside a form have their state applied to both the element and the form. When an input changes, `phx-change-loading` applies to both input and form. On submit, both button and form get the `phx-submit-loading` classes. Buttons, in particular, also support a `phx-disabled-with` attribute, which allows you to customize the text of the button on click:

```heex
<button phx-disable-with="Submitting...">Submit</button>
```

### Tailwind integration

If you are using Tailwind, you may want to use [the `addVariant` plugin](https://tailwindcss.com/docs/plugins#adding-variants) to make it even easier to customize your elements loading state.

```javascript
plugins: [
  plugin(({ addVariant }) => {
    addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &",]);
    addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &",]);
    addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &",]);
  }),
],
```

Now to fade one element on click, you simply need to add:

```heex
<button phx-click="clicked" class="phx-click-loading:opacity-50">...</button>
```

## Optimistic UIs via JS commands

While loading classes are extremely handy, they only apply to the element currently clicked. Sometimes, you may to click a "Delete" button but mark the whole row that holds the button as loading (for example, to fade it out).

By using JS commands, you can tell LiveView which elements get the loading state:

```heex
<button phx-click={JS.push("delete", loading: "#post-row-13")}>Delete</button>
```

Besides custom loading elements, you can use [JS commands](`Phoenix.LiveView.JS`) for a huge variety of operations, such as adding/removing classes, toggling attributes, hiding elements, transitions, and more.

For example, imagine that you want to immediately remove an element from the page on click, you can do this:

```heex
<button phx-click={JS.push("delete") |> JS.hide()}>Delete</button>
```

If the element you want to delete is not the clicked button, but its parent (or other element), you can pass a selector to hide:

```heex
<button phx-click={JS.push("delete") |> JS.hide("#post-row-13")}>Delete</button>
```

Or if you'd rather add a class instead:

```heex
<button phx-click={JS.push("delete") |> JS.add_class("opacity-50")}>Delete</button>
```

One key property of JS commands, such as `hide` and `add_class`, is that they are DOM-patch aware, so operations applied by the JS APIs will stick to elements across patches from the server.

JS commands also include a `dispatch` function, which dispatches an event to the DOM element to trigger client-specific functionality. For example, to trigger copying to a clipboard, you may implement this event listener:

```javascript
window.addEventListener("app:clipcopy", (event) => {
  if ("clipboard" in navigator) {
    if (event.target.tagName === "INPUT") {
      navigator.clipboard.writeText(event.target.value);
    } else {
      navigator.clipboard.writeText(event.target.textContent);
    }
  } else {
    alert(
      "Sorry, your browser does not support clipboard copy.\nThis generally requires a secure origin — either HTTPS or localhost.",
    );
  }
});
```

And then trigger it as follows:

```heex
<button phx-click={JS.dispatch("app:clipcopy", to: "#printed-output")}>Copy</button>
```

Transitions are also only a few characters away:

```heex
<div id="item">My Item</div>
<button phx-click={JS.transition("shake", to: "#item")}>Shake!</button>
```

See `Phoenix.LiveView.JS` for more examples and documentation.

## Optimistic UIs via JS hooks

On the most complex cases, you can assume control of a DOM element, and control exactly how and when server updates apply to the element on the page. See [the Client hooks via `phx-hook` section in the JavaScript interoperability page](js-interop.md#client-hooks-via-phx-hook) to learn more.

## Live navigation

LiveView also provides mechanisms to customize and interact with navigation events.

### Navigation classes

The following classes are applied to the LiveView's parent container:

  - `"phx-connected"` - applied when the view has connected to the server
  - `"phx-loading"` - applied when the view is not connected to the server
  - `"phx-error"` - applied when an error occurs on the server. Note, this
    class will be applied in conjunction with `"phx-loading"` if connection
    to the server is lost.

### Navigation events

For live page navigation via `<.link navigate={...}>` and `<.link patch={...}>`, their server-side equivalents `push_navigate` and `push_patch`, as well as form submits via `phx-submit`, the JavaScript events `"phx:page-loading-start"` and `"phx:page-loading-stop"` are dispatched on window. This is useful for showing main page loading status, for example:

```javascript
// app.js
import topbar from "topbar"
window.addEventListener("phx:page-loading-start", info => topbar.show(500))
window.addEventListener("phx:page-loading-stop", info => topbar.hide())
```

Within the callback, `info.detail` will be an object that contains a `kind`
key, with a value that depends on the triggering event:

  - `"redirect"` - the event was triggered by a redirect
  - `"patch"` - the event was triggered by a patch
  - `"initial"` - the event was triggered by initial page load
  - `"element"` - the event was triggered by a `phx-` bound element, such as `phx-click`
  - `"error"` - the event was triggered by an error, such as a view crash or socket disconnection

Additionally, `Phoenix.LiveView.JS.push/3` may dispatch page loading events by passing `page_loading: true` option.

For all kinds of page loading events, all but `"element"` will receive an additional `to` key in the info metadata pointing to the href associated with the page load. In the case of an `"element"` page loading event, the info will contain a `"target"` key containing the DOM element which triggered the page loading state.

A lower level `phx:navigate` event is also triggered any time the browser's URL bar is programmatically changed by Phoenix or the user navigation forward or back. The `info.detail` will contain the following information:

  - `"href"` - the location the URL bar was navigated to.
  - `"patch"` - the boolean flag indicating this was a patch navigation.
  - `"pop"` - the boolean flag indication this was a navigation via `popstate`
    from a user navigation forward or back in history.
```

## File: `guides/introduction/welcome.md`
```
# Welcome

Welcome to Phoenix LiveView documentation. Phoenix LiveView enables
rich, real-time user experiences with server-rendered HTML. A general
overview of LiveView and its benefits is [available in our README](https://github.com/phoenixframework/phoenix_live_view).

## What is a LiveView?

LiveViews are processes that receive events, update their state,
and render updates to a page as diffs.

The LiveView programming model is declarative: instead of saying
"once event X happens, change Y on the page", events in LiveView
are regular messages which may cause changes to the state. Once
the state changes, the LiveView will re-render the relevant parts of
its HTML template and push it to the browser, which updates the page
in the most efficient manner.

LiveView state is nothing more than functional and immutable
Elixir data structures. The events are either internal application messages
(usually emitted by `Phoenix.PubSub`) or sent by the client/browser.

Every LiveView is first rendered statically as part of a regular
HTTP request, which provides quick times for "First Meaningful
Paint", in addition to helping search and indexing engines.
A persistent connection is then established between the client and
server. This allows LiveView applications to react faster to user
events as there is less work to be done and less data to be sent
compared to stateless requests that have to authenticate, decode, load,
and encode data on every request.

## Example

LiveView is included by default in Phoenix applications.
Therefore, to use LiveView, you must have already installed Phoenix
and created your first application. If you haven't done so,
check [Phoenix' installation guide](https://hexdocs.pm/phoenix/installation.html)
to get started.

The behaviour of a LiveView is outlined by a module which implements
a series of functions as callbacks. Let's see an example. Write the
file below to `lib/my_app_web/live/thermostat_live.ex`:

```elixir
defmodule MyAppWeb.ThermostatLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    ~H"""
    Current temperature: {@temperature}°F
    <button phx-click="inc_temperature">+</button>
    """
  end

  def mount(_params, _session, socket) do
    temperature = 70 # Let's assume a fixed temperature for now
    {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_event("inc_temperature", _params, socket) do
    {:noreply, update(socket, :temperature, &(&1 + 1))}
  end
end
```

The module above defines three functions (they are callbacks
required by LiveView). The first one is `render/1`,
which receives the socket `assigns` and is responsible for returning
the content to be rendered on the page. We use the `~H` sigil to define
a HEEx template, which stands for HTML+EEx. They are an extension of
Elixir's builtin EEx templates, with support for HTML validation, syntax-based
components, smart change tracking, and more. You can learn more about
the template syntax in `Phoenix.Component.sigil_H/2` (note
`Phoenix.Component` is automatically imported when you use `Phoenix.LiveView`).

The data used on rendering comes from the `mount` callback. The
`mount` callback is invoked when the LiveView starts. In it, you
can access the request parameters, read information stored in the
session (typically information which identifies who is the current
user), and a socket. The socket is where we keep all state, including
assigns. `mount` proceeds to assign a default temperature to the socket.
Because Elixir data structures are immutable, LiveView APIs often
receive the socket and return an updated socket. Then we return
`{:ok, socket}` to signal that we were able to mount the LiveView
successfully. After `mount`, LiveView will render the page with the
values from `assigns` and send it to the client.

If you look at the HTML rendered, you will notice there is a button
with a `phx-click` attribute. When the button is clicked, a
`"inc_temperature"` event is sent to the server, which is matched and
handled by the `handle_event` callback. This callback updates the socket
and returns `{:noreply, socket}` with the updated socket.
`handle_*` callbacks in LiveView (and in Elixir in general) are
invoked based on some action, in this case, the user clicking a button.
The `{:noreply, socket}` return means there is no additional replies
sent to the browser, only that a new version of the page is rendered.
LiveView then computes diffs and sends them to the client.

Now we are ready to render our LiveView. You can serve the LiveView
directly from your router:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    ...
  end

  scope "/", MyAppWeb do
    pipe_through :browser
    ...

    live "/thermostat", ThermostatLive
  end
end
```

Once the LiveView is rendered, a regular HTML response is sent. In your
app.js file, you should find the following:

```javascript
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
```

Now the JavaScript client will connect over WebSockets and `mount/3` will be invoked
inside a spawned LiveView process.

## Parameters and session

The mount callback receives three arguments: the request parameters, the session, and the socket.

The parameters can be used to read information from the URL. For example, assuming you have a `Thermostat` module defined somewhere that can read this information based on the house name, you could write this:

```elixir
def mount(%{"house" => house}, _session, socket) do
  temperature = Thermostat.get_house_reading(house)
  {:ok, assign(socket, :temperature, temperature)}
end
```

And then in your router:

```elixir
live "/thermostat/:house", ThermostatLive
```

The session retrieves information from a signed (or encrypted) cookie. This is where you can store authentication information, such as `current_user_id`:

```elixir
def mount(_params, %{"current_user_id" => user_id}, socket) do
  temperature = Thermostat.get_user_reading(user_id)
  {:ok, assign(socket, :temperature, temperature)}
end
```

> Phoenix comes with built-in authentication generators. See `mix phx.gen.auth`.

Most times, in practice, you will use both:

```elixir
def mount(%{"house" => house}, %{"current_user_id" => user_id}, socket) do
  temperature = Thermostat.get_house_reading(user_id, house)
  {:ok, assign(socket, :temperature, temperature)}
end
```

In other words, you want to read the information about a given house, as long as the user has access to it.

## Bindings

Phoenix supports DOM element bindings for client-server interaction. For
example, to react to a click on a button, you would render the element:

```heex
<button phx-click="inc_temperature">+</button>
```

Then on the server, all LiveView bindings are handled with the `handle_event/3`
callback, for example:

    def handle_event("inc_temperature", _value, socket) do
      {:noreply, update(socket, :temperature, &(&1 + 1))}
    end

To update UI state, for example, to open and close dropdowns, switch tabs,
etc, LiveView also supports JS commands (`Phoenix.LiveView.JS`), which
execute directly on the client without reaching the server. To learn more,
see [our bindings page](bindings.md) for a complete list of all LiveView
bindings as well as our [JavaScript interoperability guide](js-interop.md).

LiveView has built-in support for forms, including uploads and association
management. See `Phoenix.Component.form/1` as a starting point and
`Phoenix.Component.inputs_for/1` for working with associations.
The [Uploads](uploads.md) and [Form bindings](form-bindings.md) guides provide
more information about advanced features.

## Navigation

LiveView provides functionality to allow page navigation using the
[browser's pushState API](https://developer.mozilla.org/en-US/docs/Web/API/History_API).
With live navigation, the page is updated without a full page reload.

You can either *patch* the current LiveView, updating its URL, or
*navigate* to a new LiveView. You can learn more about them in the
[Live Navigation](live-navigation.md) guide.

## Generators

Phoenix v1.6 and later includes code generators for LiveView. If you want to see
an example of how to structure your application, from the database all the way up
to LiveViews, run the following:

```shell
$ mix phx.gen.live Blog Post posts title:string body:text
```

For more information, run `mix help phx.gen.live`.

For authentication, with built-in LiveView support, run `mix phx.gen.auth Account User users`.

## Compartmentalize state, markup, and events in LiveView

LiveView supports two extension mechanisms: function components, provided by
`HEEx` templates, and stateful components, known as LiveComponents.

### Function components to organize markup and event handling

Similar to `render(assigns)` in our LiveView, a function component is any
function that receives an assigns map and returns a `~H` template. For example:

    def weather_greeting(assigns) do
      ~H"""
      <div title="My div" class={@class}>
        <p>Hello {@name}</p>
        <MyApp.Weather.city name="Kraków"/>
      </div>
      """
    end

You can learn more about function components in the `Phoenix.Component`
module. At the end of the day, they are a useful mechanism for code organization
and to reuse markup in your LiveViews.

Sometimes you need to share more than just markup across LiveViews. When you also
want to move events to a separate module, or use the same event handler in multiple
places, function components can be paired with
[`Phoenix.LiveView.attach_hook/4`](`Phoenix.LiveView.attach_hook/4#sharing-event-handling-logic`).

### Live components to encapsulate additional state

A component will occasionally need control over not only its own events,
but also its own separate state. For these cases, LiveView
provides `Phoenix.LiveComponent`, which are rendered using
[`live_component/1`](`Phoenix.Component.live_component/1`):

```heex
<.live_component module={UserComponent} id={user.id} user={user} />
```

LiveComponents have their own `mount/1` and `handle_event/3` callbacks, as well
as their own state with change tracking support, similar to LiveViews. They are
lightweight since they "run" in the same process as the parent LiveView, but
are more complex than function components themselves. Given they all run in the
same process, errors in components cause the whole view to fail to render.
For a complete rundown, see `Phoenix.LiveComponent`.

When in doubt over [Functional components or live components?](`Phoenix.LiveComponent#functional-components-or-live-components`), default to the former.
Rely on the latter only when you need the additional state.

### live_render/3 to encapsulate state (with error isolation)

Finally, if you want complete isolation between parts of a LiveView, you can
always render a LiveView inside another LiveView by calling
[`live_render/3`](`Phoenix.Component.live_render/3`). This child LiveView
runs in a separate process than the parent, with its own callbacks. If a child
LiveView crashes, it won't affect the parent. If the parent crashes, all children
are terminated.

When rendering a child LiveView, the `:id` option is required to uniquely
identify the child. A child LiveView will only ever be rendered and mounted
a single time, provided its ID remains unchanged. To force a child to re-mount
with new session data, a new ID must be provided.

Given that it runs in its own process, a nested LiveView is an excellent tool
for creating completely isolated UI elements, but it is a slightly expensive
abstraction if all you want is to compartmentalize markup or events (or both).

### Summary
  * use `Phoenix.Component` for code organization and reusing markup (optionally with [`attach_hook/4`](`Phoenix.LiveView.attach_hook/4#sharing-event-handling-logic`) for event handling reuse)
  * use `Phoenix.LiveComponent` for sharing state, markup, and events between LiveViews
  * use nested `Phoenix.LiveView` to compartmentalize state, markup, and events (with error isolation)

## Guides

This documentation is split into two categories. We have the API
reference for all LiveView modules, that's where you will learn
more about `Phoenix.Component`, `Phoenix.LiveView`, and so on.

LiveView also has many guides to help you on your journey,
split on server-side and client-side:

### Server-side

These guides focus on server-side functionality:

* [Assigns and HEEx templates](assigns-eex.md)
* [Deployments and recovery](deployments.md)
* [Error and exception handling](error-handling.md)
* [Gettext for internationalization](gettext.md)
* [Live layouts](live-layouts.md)
* [Live navigation](live-navigation.md)
* [Security considerations](security-model.md)
* [Telemetry](telemetry.md)
* [Uploads](uploads.md)

### Client-side

These guides focus on LiveView bindings and client-side integration:

* [Bindings](bindings.md)
* [External uploads](external-uploads.md)
* [Form bindings](form-bindings.md)
* [JavaScript interoperability](js-interop.md)
* [Syncing changes and optimistic UIs](syncing-changes.md)
```

## File: `guides/server/assigns-eex.md`
```
# Assigns and HEEx templates

All of the data in a LiveView is stored in the socket, which is a server
side struct called `Phoenix.LiveView.Socket`. Your own data is stored
under the `assigns` key of said struct. The server data is never shared
with the client beyond what your template renders.

Phoenix template language is called HEEx (HTML+EEx). EEx is Embedded
Elixir, an Elixir string template engine. Those templates
are either files with the `.heex` extension or they are created
directly in source files via the `~H` sigil. You can learn more about
the HEEx syntax by checking the docs for [the `~H` sigil](`Phoenix.Component.sigil_H/2`).

The `Phoenix.Component.assign/2` and `Phoenix.Component.assign/3`
functions help store those values. Those values can be accessed
in the LiveView as `socket.assigns.name` but they are accessed
inside HEEx templates as `@name`.

In this section, we are going to cover how LiveView minimizes
the payload over the wire by understanding the interplay between
assigns and templates.

## Change tracking

When you first render a `.heex` template, it will send all of the
static and dynamic parts of the template to the client. Imagine the
following template:

```heex
<h1>{expand_title(@title)}</h1>
```

It has two static parts, `<h1>` and `</h1>` and one dynamic part
made of `expand_title(@title)`. Further rendering of this template
won't resend the static parts and it will only resend the dynamic
part if it changes.

The tracking of changes is done via assigns. If the `@title` assign
changes, then LiveView will execute the dynamic parts of the template,
`expand_title(@title)`, and send the new content. If `@title` is the same,
nothing is executed and nothing is sent.

Change tracking also works when accessing map/struct fields.
Take this template:

```heex
<div id={"user_#{@user.id}"}>
  {@user.name}
</div>
```

If the `@user.name` changes but `@user.id` doesn't, then LiveView
will re-render only `@user.name` and it will not execute or resend `@user.id`
at all.

The change tracking also works when rendering other templates as
long as they are also `.heex` templates:

```heex
{render("child_template.html", assigns)}
```

Or when using function components:

```heex
<.show_name name={@user.name} />
```

The assign tracking feature also implies that you MUST avoid performing
direct operations in the template. For example, if you perform a database
query in your template:

```heex
<%= for user <- Repo.all(User) do %>
  {user.name}
<% end %>
```

Then Phoenix will never re-render the section above, even if the number of
users in the database changes. Instead, you need to store the users as
assigns in your LiveView before it renders the template:

    assign(socket, :users, Repo.all(User))

Generally speaking, **data loading should never happen inside the template**,
regardless if you are using LiveView or not. The difference is that LiveView
enforces this best practice.

## Common pitfalls

There are some common pitfalls to keep in mind when using the `~H` sigil
or `.heex` templates inside LiveViews.

### Variables

Due to the scope of variables, LiveView has to disable change tracking
whenever variables are used in the template, with the exception of
variables introduced by Elixir block constructs such as `case`,
`for`, `if`, and others. Therefore, you **must avoid** code like
this in your HEEx templates:

```heex
<% some_var = @x + @y %>
{some_var}
```

Instead, use a function:

```heex
{sum(@x, @y)}
```

Similarly, **do not** define variables at the top of your `render` function
for LiveViews or LiveComponents. Since LiveView cannot track `sum` or `title`,
if either value changes, both must be re-rendered by LiveView.

    def render(assigns) do
      sum = assigns.x + assigns.y
      title = assigns.title

      ~H"""
      <h1>{title}</h1>

      {sum}
      """
    end

Instead use the `assign/2`, `assign/3`, `assign_new/3`, and `update/3`
functions to compute it. Any assign defined or updated this way will be marked as
changed, while other assigns like `@title` will still be tracked by LiveView.

    assign(assigns, sum: assigns.x + assigns.y)

The same functions can be used inside function components too:

    attr :x, :integer, required: true
    attr :y, :integer, required: true
    attr :title, :string, required: true
    def sum_component(assigns) do
      assigns = assign(assigns, sum: assigns.x + assigns.y)

      ~H"""
      <h1>{@title}</h1>

      {@sum}
      """
    end

Generally speaking, avoid accessing variables inside `HEEx` templates, as code that
access variables is always executed on every render. The exception are variables
introduced by Elixir's block constructs, such as `if` and `for` comprehensions.
For example, accessing the `post` variable defined by the comprehension below
works as expected:

```heex
<%= for post <- @posts do %>
  ...
<% end %>
```

### The `assigns` variable

When talking about variables, it is also worth discussing the `assigns`
special variable. Every time you use the `~H` sigil, you must define an
`assigns` variable, which is also available on every `.heex` template.
However, we must avoid accessing this variable directly inside templates
and instead use `@` for accessing specific keys. This also applies to
function components. Let's see some examples.

Sometimes you might want to pass all assigns from one function component to
another. For example, imagine you have a complex `card` component with
header, content and footer section. You might refactor your component
into three smaller components internally:

```elixir
def card(assigns) do
  ~H"""
  <div class="card">
    <.card_header {assigns} />
    <.card_body {assigns} />
    <.card_footer {assigns} />
  </div>
  """
end

defp card_header(assigns) do
  ...
end

defp card_body(assigns) do
  ...
end

defp card_footer(assigns) do
  ...
end
```

Because of the way function components handle attributes, the above code will
not perform change tracking and it will always re-render all three components
on every change.

Generally, you should avoid passing all assigns and instead be explicit about
which assigns the child components need:

```elixir
def card(assigns) do
  ~H"""
  <div class="card">
    <.card_header title={@title} class={@title_class} />
    <.card_body>
      {render_slot(@inner_block)}
    </.card_body>
    <.card_footer on_close={@on_close} />
  </div>
  """
end
```

If you really need to pass all assigns you should instead use the regular
function call syntax. This is the only case where accessing `assigns` inside
templates is acceptable:

```elixir
def card(assigns) do
  ~H"""
  <div class="card">
    {card_header(assigns)}
    {card_body(assigns)}
    {card_footer(assigns)}
  </div>
  """
end
```

This ensures that the change tracking information from the parent component
is passed to each child component, only re-rendering what is necessary.
However, generally speaking, it is best to avoid passing `assigns` altogether
and instead let LiveView figure out the best way to track changes.

### Comprehensions

HEEx supports comprehensions in templates, which is a way to traverse lists
and collections. For example:

```heex
<%= for post <- @posts do %>
  <section>
    <h1>{expand_title(post.title)}</h1>
  </section>
<% end %>
```

Or using the special `:for` attribute:

```heex
<section :for={post <- @posts}>
  <h1>{expand_title(post.title)}</h1>
</section>
```

Comprehensions in templates are optimized so the static parts of
a comprehension are only sent once, regardless of the number of items.
Furthermore, LiveView tracks changes within the collection given to the
comprehension. In the ideal case, if only a single entry in `@posts`
changes, only this entry is sent again. By default, the index is used
to track changes. This means that if an entry is appended, most items
will be considered changed and sent again. To optimize this, you can
also pass a `:key` on tags in HEEx:

```heex
<section :for={post <- @posts} :key={post.id}>
  <h1>{expand_title(post.title)}</h1>
</section>
```

You can read more about `:key` in the [documentation for `sigil_H/2`](Phoenix.Component.html#sigil_H/2-special-attributes).

To track changes in comprehensions, LiveView needs to perform additional
bookkeeping, which requires extra memory on the server. If memory usage is a
concern, you should also consider to use `Phoenix.LiveView.stream/4`, which
allows you to manage collections without keeping them in memory.

### Summary

To sum up:

  1. Avoid defining local variables inside HEEx templates, except within Elixir's constructs

  2. Avoid passing or accessing the `assigns` variable inside HEEx templates
```

## File: `guides/server/deployments.md`
```
# Deployments and recovery

One of the questions that arise from LiveView stateful model is what considerations are necessary when deploying a new version of LiveView (or when recovering from an error).

First off, whenever LiveView disconnects, it will automatically attempt to reconnect to the server using exponential back-off. This means it will try immediately, then wait 2s and try again, then 5s and so on. If you are deploying, this typically means the next reconnection will immediately succeed and your load balancer will automatically redirect to the new servers.

However, your LiveView _may_ still have state that will be lost in this transition. How to deal with it? The good news is that there are a series of practices you can follow that will not only help with deployments but it will improve your application in general.

1. Keep state in the query parameters when appropriate. For example, if your application has tabs and the user clicked a tab, instead of using `phx-click` and `c:Phoenix.LiveView.handle_event/3` to manage it, you should implement it using `<.link patch={...}>` passing the tab name as parameter. You will then receive the new tab name `c:Phoenix.LiveView.handle_params/3` which will set the relevant assign to choose which tab to display. You can even define specific URLs for each tab in your application router. By doing this, you will reduce the amount of server state, make tab navigation shareable via links, improving search engine indexing, and more.

2. Consider storing other relevant state in the database. For example, if you are building a chat app and you want to store which messages have been read, you can store so in the database. Once the page is loaded, you retrieve the index of the last read message. This makes the application more robust, allow data to be synchronized across devices, etc.

3. If your application uses forms (which is most likely the case), keep in mind that Phoenix performs automatic form recovery: in case of disconnections, Phoenix will collect the form data and resubmit it on reconnection. This mechanism works out of the box for most forms but you may want to customize it or test it for your most complex forms. See the relevant section [in the "Form bindings" document](../client/form-bindings.md) to learn more.

The idea is that: if you follow the practices above, most of your state is already handled within your app and therefore deployments should not bring additional concerns. Not only that, it will bring overall benefits to your app such as indexing, link sharing, device sharing, and so on.

If you really have complex state that cannot be immediately handled, then you may need to resort to special strategies. This may be persisting "old" state to Redis/S3/Database and loading the new state on the new connections. Or you may take special care when migrating connections (for example, if you are building a game, you may want to wait for on-going sessions to finish before turning down the old server while routing new sessions to the new ones). Such cases will depend on your requirements (and they would likely exist regardless of which application stack you are using).
```

## File: `guides/server/error-handling.md`
```
# Error and exception handling

As with any other Elixir code, exceptions may happen during the LiveView
life-cycle. This page describes how LiveView handles errors at different
stages.

## Expected scenarios

In this section, we will talk about error cases that you expect to happen
within your application. For example, a user filling in a form with invalid
data is expected. In a LiveView, we typically handle those cases by storing
the form state in LiveView assigns and rendering any relevant error message
back to the client.

We may also use `flash` messages for this. For example, imagine you have a
page to manage all "Team members" in an organization. However, if there is
only one member left in the organization, they should not be allowed to
leave. You may want to handle this by using flash messages:

    if MyApp.Org.leave(socket.assigns.current_org, member) do
      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "last member cannot leave organization")}
    end

However, one may argue that, if the last member of an organization cannot
leave it, it may be better to not even show the "Leave" button in the UI
when the organization has only one member.

Given the button does not appear in the UI, triggering the "leave" action when
the organization has only one member is an unexpected scenario. This means we
can rewrite the code above to:

    true = MyApp.Org.leave(socket.assigns.current_org, member)
    {:noreply, socket}

If `leave` does not return `true`, Elixir will raise a `MatchError`
exception. Or you could provide a `leave!` function that raises a specific
exception:

    MyApp.Org.leave!(socket.assigns.current_org, member)
    {:noreply, socket}

However, what will happen with a LiveView in case of exceptions?
Let's talk about unexpected scenarios.

## Unexpected scenarios

Elixir developers tend to write assertive code. This means that, if we
expect `leave` to always return true, we can explicitly match on its
result, as we did above:

    true = MyApp.Org.leave(socket.assigns.current_org, member)
    {:noreply, socket}

If `leave` fails and returns `false`, an exception is raised. It is common
for Elixir developers to use exceptions for unexpected scenarios in their
Phoenix applications.

For example, if you are building an application where a user may belong to
one or more organizations, when accessing the organization page, you may want to
check that the user has access to it like this:

    organizations_query = Ecto.assoc(socket.assigns.current_user, :organizations)
    Repo.get!(organizations_query, params["org_id"])

The code above builds a query that returns all organizations that belongs to
the current user and then validates that the given `org_id` belongs to the
user. If there is no such `org_id` or if the user has no access to it,
`Repo.get!` will raise an `Ecto.NoResultsError` exception.

During a regular controller request, this exception will be converted to a
404 exception and rendered as a custom error page, as
[detailed here](https://hexdocs.pm/phoenix/custom_error_pages.html).
LiveView will react to exceptions in three different ways, depending on
where it is in its life-cycle.

### Exceptions during HTTP mount

When you first access a LiveView, a regular HTTP request is sent to the server
and processed by the LiveView. The `mount` callback is invoked and then a page
is rendered. Any exception here is caught, logged, and converted to an exception
page by Phoenix error views - exactly how it works with controllers too.

### Exceptions during connected mount

If the initial HTTP request succeeds, LiveView will connect to the server
using a stateful connection, typically a WebSocket. This spawns a long-running
lightweight Elixir process on the server, which invokes the `mount` callback
and renders an updated version of the page.

An exception during this stage will crash the LiveView process, which will be logged.
Once the client notices the crash, it fully reloads the page. This will cause `mount`
to be invoked again during a regular HTTP request (the exact scenario of the previous
subsection).

In other words, LiveView will reload the page in case of errors, making it
fail as if LiveView was not involved in the rendering in the first place.

### Exceptions after connected mount

Once your LiveView is mounted and connected, any error will cause the LiveView process
to crash and be logged. Once the client notices the error, it will remount the LiveView
over the stateful connection, without reloading the page (the exact scenario of the
previous subsection). If remounting succeeds, the LiveView goes back to a working
state, updating the page and showing the user the latest information.

For example, let's say two users try to leave the organization at the same time.
In this case, both of them see the "Leave" button, but our `leave` function call
will succeed only for one of them:

    true = MyApp.Org.leave(socket.assigns.current_org, member)
    {:noreply, socket}

When the exception raises, the client will remount the LiveView. Once you remount,
your code will now notice that there is only one user in the organization and
therefore no longer show the "Leave" button. In other words, by remounting,
we often update the state of the page, allowing exceptions to be automatically
handled.

Note that the choice between conditionally checking on the result of the `leave`
function with an `if`, or simply asserting it returns `true`, is completely
up to you. If the likelihood of everyone leaving the organization at the same
time is low, then you may as well treat it as an unexpected scenario. Although
other developers will be more comfortable by explicitly handling those cases.
In both scenarios, LiveView has you covered.

Finally, if your LiveView crashes, its current state will be lost. Luckily,
LiveView has a series of mechanisms and best practices you can follow to ensure
the user is shown the same page as before during reconnections. See the
["Deployments and recovery"](deployments.md) guide for more information.```

## File: `guides/server/gettext.md`
```
# Gettext for internationalization

For internationalization with [gettext](https://hexdocs.pm/gettext/Gettext.html),
you must call `Gettext.put_locale/2` on the LiveView mount callback to instruct
the LiveView which locale should be used for rendering the page.

However, one question that has to be answered is how to retrieve the locale in
the first place. There are many approaches to solve this problem:

1. The locale could be stored in the URL as a parameter
2. The locale could be stored in the session
3. The locale could be stored in the database

We will briefly cover these approaches to provide some direction.

## Locale from parameters

You can say all URLs have a locale parameter. In your router:

    scope "/:locale" do
      live ...
      get ...
    end

Accessing a page without a locale should automatically redirect
to a URL with locale (the best locale could be fetched from
HTTP headers, which is outside of the scope of this guide).

Then, assuming all URLs have a locale, you can set the Gettext
locale accordingly:

    def mount(%{"locale" => locale}, _session, socket) do
      Gettext.put_locale(MyApp.Gettext, locale)
      {:ok, socket}
    end


You can also use the [`on_mount`](`Phoenix.LiveView.on_mount/1`) hook to
automatically restore the locale for every LiveView in your application:

    defmodule MyAppWeb.RestoreLocale do
      def on_mount(:default, %{"locale" => locale}, _session, socket) do
        Gettext.put_locale(MyApp.Gettext, locale)
        {:cont, socket}
      end

      # catch-all case
      def on_mount(:default, _params, _session, socket), do: {:cont, socket}
    end

Then, add this hook to `def live_view` under `MyAppWeb`, to run it on all
LiveViews by default:

    def live_view do
      quote do
        use Phoenix.LiveView

        on_mount MyAppWeb.RestoreLocale
        unquote(view_helpers())
      end
    end

Note that, because the Gettext locale is not stored in the assigns, if you
want to change the locale, you must use `<.link navigate={...} />`, instead
of simply patching the page.

## Locale from session

You may also store the locale in the Plug session. For example, in a controller
you might do:

    def put_user_session(conn, current_user) do
      Gettext.put_locale(MyApp.Gettext, current_user.locale)

      conn
      |> put_session(:user_id, current_user.id)
      |> put_session(:locale, current_user.locale)
    end

and then restore the locale from session within your LiveView mount:

    def mount(_params, %{"locale" => locale}, socket) do
      Gettext.put_locale(MyApp.Gettext, locale)
      {:ok, socket}
    end

You can also encapsulate this in a hook, as done in the previous section.

However, if the locale is stored in the session, you can only change it
by using regular controller requests. Therefore you should always use
`<.link to={...} />` to point to a controller that change the session
accordingly, reloading any LiveView.

## Locale from database

You may also allow users to store their locale configuration in the database.
Then, on `mount/3`, you can retrieve the user id from the session and load
the locale:

    def mount(_params, %{"user_id" => user_id}, socket) do
      user = Users.get_user!(user_id)
      Gettext.put_locale(MyApp.Gettext, user.locale)
      {:ok, socket}
    end

In practice, you may end-up mixing more than one approach listed here.
For example, reading from the database is great once the user is logged in
but, before that happens, you may need to store the locale in the session
or in the URL.

Similarly, you can keep the locale in the URL, but change the URL accordingly
to the user preferred locale once they sign in. Hopefully this guide gives
some suggestions on how to move forward and explore the best approach for your
application.
```

## File: `guides/server/live-layouts.md`
```
# Live layouts

Your LiveView applications can be made of two layouts:

  * the root layout - this layout typically contains the `<html>`
    definition alongside the head and body tags. Any content defined
    in the root layout will remain the same, even as you live navigate
    across LiveViews. The root layout is typically declared on the
    router with `put_root_layout` and defined as "root.html.heex"
    in your layouts folder. It calls `{@inner_content}` to inject the
    content rendered by the layout

  * the app layout - this is the dynamic layout part of your application,
    it often includes the menu, sidebar, flash messages, and more.
    From Phoenix v1.8, this layout is explicitly rendered in your templates
    by calling the `<Layouts.app />` component. In Phoenix v1.7 and earlier,
    the layout was typically configured as part of the `lib/my_app_web.ex`
    file, such as `use Phoenix.LiveView, layout: ...`

Overall, those layouts are found in `components/layouts` and are
embedded within `MyAppWeb.Layouts`.

## Root layout

The "root" layout is rendered only on the initial request and
therefore it has access to the `@conn` assign. The root layout
is typically defined in your router:

    plug :put_root_layout, html: {MyAppWeb.Layouts, :root}

The root layout can also be set via the `:root_layout` option
in your router via `Phoenix.LiveView.Router.live_session/2`.

## Updating document title

Because the root layout from the Plug pipeline is rendered outside of
LiveView, the contents cannot be dynamically changed. The one exception
is the `<title>` of the HTML document. Phoenix LiveView special cases
the `@page_title` assign to allow dynamically updating the title of the
page, which is useful when using live navigation, or annotating the browser
tab with a notification. For example, to update the user's notification
count in the browser's title bar, first set the `page_title` assign on
mount:

    def mount(_params, _session, socket) do
      socket = assign(socket, page_title: "Latest Posts")
      {:ok, socket}
    end

Then access `@page_title` in the root layout:

```heex
<title>{@page_title}</title>
```

You can also use the `Phoenix.Component.live_title/1` component to support
adding automatic prefix and suffix to the page title when rendered and
on subsequent updates:

```heex
<Phoenix.Component.live_title default="Welcome" prefix="MyApp – ">
  {assigns[:page_title]}
</Phoenix.Component.live_title>
```

Although the root layout is not updated by LiveView, by simply assigning
to `page_title`, LiveView knows you want the title to be updated:

    def handle_info({:new_messages, count}, socket) do
      {:noreply, assign(socket, page_title: "Latest Posts (#{count} new)")}
    end

*Note*: If you find yourself needing to dynamically patch other parts of the
base layout, such as injecting new scripts or styles into the `<head>` during
live navigation, *then a regular, non-live, page navigation should be used
instead*. Assigning the `@page_title` updates the `document.title` directly,
and therefore cannot be used to update any other part of the base layout.
```

## File: `guides/server/live-navigation.md`
```
# Live navigation

LiveView provides functionality to allow page navigation using the
[browser's pushState API](https://developer.mozilla.org/en-US/docs/Web/API/History_API).
With live navigation, the page is updated without a full page reload.

You can trigger live navigation in two ways:

  * From the client - this is done by passing either `patch={url}` or `navigate={url}`
    to the `Phoenix.Component.link/1` component.

  * From the server - this is done by `Phoenix.LiveView.push_patch/2` or `Phoenix.LiveView.push_navigate/2`.

For example, instead of writing the following in a template:

```heex
<.link href={~p"/pages/#{@page + 1}"}>Next</.link>
```

You would write:

```heex
<.link patch={~p"/pages/#{@page + 1}"}>Next</.link>
```

Or in a LiveView:

```elixir
{:noreply, push_patch(socket, to: ~p"/pages/#{@page + 1}")}
```

The "patch" operations must be used when you want to navigate to the
current LiveView, simply updating the URL and the current parameters,
without mounting a new LiveView. When patch is used, the
[`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) callback is
invoked and the minimal set of changes are sent to the client.
See the next section for more information.

The "navigate" operations must be used when you want to dismount the
current LiveView and mount a new one. You can only "navigate" between
LiveViews in the same session. While redirecting, a `phx-loading` class
is added to the LiveView, which can be used to indicate to the user a
new page is being loaded.

If you attempt to patch to another LiveView or navigate across live sessions,
a full page reload is triggered. This means your application continues to work,
in case your application structure changes and that's not reflected in the navigation.

Here is a quick breakdown:

  * `<.link href={...}>` and [`redirect/2`](`Phoenix.Controller.redirect/2`)
    are HTTP-based, work everywhere, and perform full page reloads

  * `<.link navigate={...}>` and [`push_navigate/2`](`Phoenix.LiveView.push_navigate/2`)
    work across LiveViews in the same session. They mount a new LiveView
    while keeping the current layout

  * `<.link patch={...}>` and [`push_patch/2`](`Phoenix.LiveView.push_patch/2`)
    updates the current LiveView and sends only the minimal diff while also
    maintaining the scroll position

## `handle_params/3`

The [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) callback is invoked
after [`mount/3`](`c:Phoenix.LiveView.mount/3`) and before the initial render.
It is also invoked every time `<.link patch={...}>`
or [`push_patch/2`](`Phoenix.LiveView.push_patch/2`) are used.
It receives the request parameters as first argument, the url as second,
and the socket as third.

For example, imagine you have a `UserTable` LiveView to show all users in
the system and you define it in the router as:

    live "/users", UserTable

Now to add live sorting, you could do:

```heex
<.link patch={~p"/users?sort_by=name"}>Sort by name</.link>
```

When clicked, since we are navigating to the current LiveView,
[`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) will be invoked.
Remember you should never trust the received params, so you must use the callback to
validate the user input and change the state accordingly:

    def handle_params(params, _uri, socket) do
      socket =
        case params["sort_by"] do
          sort_by when sort_by in ~w(name company) -> assign(socket, sort_by: sort_by)
          _ -> socket
        end

      {:noreply, load_users(socket)}
    end

Note we returned `{:noreply, socket}`, where `:noreply` means no
additional information is sent to the client. As with other `handle_*`
callbacks, changes to the state inside
[`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) will trigger
a new server render.

Note the parameters given to [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`)
are the same as the ones given to [`mount/3`](`c:Phoenix.LiveView.mount/3`).
So how do you decide which callback to use to load data?
Generally speaking, data should always be loaded on [`mount/3`](`c:Phoenix.LiveView.mount/3`),
since [`mount/3`](`c:Phoenix.LiveView.mount/3`) is invoked once per LiveView life-cycle.
Only the params you expect to be changed via
`<.link patch={...}>` or
[`push_patch/2`](`Phoenix.LiveView.push_patch/2`) must be loaded on
[`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`).

For example, imagine you have a blog. The URL for a single post is:
"/blog/posts/:post_id". In the post page, you have comments and they are paginated.
You use `<.link patch={...}>` to update the shown
comments every time the user paginates, updating the URL to "/blog/posts/:post_id?page=X".
In this example, you will access `"post_id"` on [`mount/3`](`c:Phoenix.LiveView.mount/3`) and
the page of comments on [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`).

## Replace page address

LiveView also allows the current browser URL to be replaced. This is useful when you
want certain events to change the URL but without polluting the browser's history.
This can be done by passing the `<.link replace>` option to any of the navigation helpers.

## Multiple LiveViews in the same page

LiveView allows you to have multiple LiveViews in the same page by calling
`Phoenix.Component.live_render/3` in your templates. However, only
the LiveViews defined directly in your router can use the "Live Navigation"
functionality described here. This is important because LiveViews work
closely with your router, guaranteeing you can only navigate to known
routes.
```

## File: `guides/server/security-model.md`
```
# Security considerations

LiveView begins its life-cycle as a regular HTTP request. Then a stateful
connection is established. Both the HTTP request and the stateful connection
receive the client data via parameters and session.

This means that any session validation must happen both in the HTTP request
(plug pipeline) and the stateful connection (LiveView mount).

## Authentication vs authorization

When speaking about security, there are two terms commonly used:
authentication and authorization. Authentication is about identifying
a user. Authorization is about telling if a user has access to a certain
resource or feature in the system.

In a regular web application, once a user is authenticated, for example by
entering their email and password, or by using a third-party service such as
Google, Twitter, or Facebook, a token identifying the user is stored in the
session, which is a cookie (a key-value pair) stored in the user's browser.

Every time there is a request, we read the value from the session, and, if
valid, we fetch the user stored in the session from the database. The session
is automatically validated by Phoenix and tools like `mix phx.gen.auth` can
generate the building blocks of an authentication system for you.

Once the user is authenticated, they may perform many actions on the page,
and some of those actions require specific permissions. This is called
authorization and the specific rules often change per application.

In a regular web application, we perform authentication and authorization
checks on every request. Given LiveViews start as a regular HTTP request,
they share the authentication logic with regular requests through plugs.
The request starts in your endpoint, which then invokes the router.
Plugs are used to ensure the user is authenticated and stores the
relevant information in the session.

Once the user is authenticated, we typically validate the sessions on
the `mount` callback. Authorization rules generally happen on `mount`
(for instance, is the user allowed to see this page?) and also on
`handle_event` (is the user allowed to delete this item?).

## `live_session`

The primary mechanism for grouping LiveViews is via the
`Phoenix.LiveView.Router.live_session/2`. LiveView will then ensure
that navigation events within the same `live_session` skip the regular
HTTP requests without going through the plug pipeline. Events across
live sessions will go through the router.

For example, imagine you need to authenticate two distinct types of users.
Your regular users login via email and password, and you have an admin
dashboard that uses HTTP auth. You can specify different `live_session`s
for each authentication flow:

    scope "/" do
      pipe_through [:authenticate_user]
      get ...

      live_session :default do
        live ...
      end
    end

    scope "/admin" do
      pipe_through [:http_auth_admin]
      get ...

      live_session :admin do
        live ...
      end
    end

Now every time you try to navigate to an admin panel, and out of it,
a regular page navigation will happen and a brand new live connection
will be established.

It is worth remembering that LiveViews require their own security checks,
so we use `pipe_through` above to protect the regular routes (get, post, etc.)
and the LiveViews should run their own checks on the `mount` callback
(or using `Phoenix.LiveView.on_mount/1` hooks).

For this purpose, you can combine `live_session` with `on_mount`, as well
as other options, such as the `:root_layout`. Instead of declaring `on_mount`
on every LiveView, you can declare it at the router level and it will enforce
it on all LiveViews under it:

    scope "/" do
      pipe_through [:authenticate_user]

      live_session :default, on_mount: MyAppWeb.UserLiveAuth do
        live ...
      end
    end

    scope "/admin" do
      pipe_through [:authenticate_admin]

      live_session :admin, on_mount: MyAppWeb.AdminLiveAuth do
        live ...
      end
    end

Each live route under the `:default` `live_session` will invoke
the `MyAppWeb.UserLiveAuth` hook on mount. This module was defined
earlier in this guide. We will also pipe regular web requests through
`:authenticate_user`, which must execute the same checks as
`MyAppWeb.UserLiveAuth`, but tailored to plug.

Similarly, the `:admin` `live_session` has its own authentication
flow, powered by `MyAppWeb.AdminLiveAuth`. It also defines a plug
equivalent named `:authenticate_admin`, which will be used by any
regular request. If there are no regular web requests defined under
a live session, then the `pipe_through` checks are not necessary.

Declaring the `on_mount` on `live_session` is exactly the same as
declaring it in each LiveView. Let's talk about which logic we typically
execute on mount.

## Mounting considerations

The [`mount/3`](`c:Phoenix.LiveView.mount/3`) callback is invoked both on
the initial HTTP mount and when LiveView is connected. Therefore, any
authorization performed during mount will cover all scenarios.

Once the user is authenticated and stored in the session, the logic to fetch the user and further authorize its account needs to happen inside LiveView. For example, if you have the following plugs:

    plug :ensure_user_authenticated
    plug :ensure_user_confirmed

Then the [`mount/3`](`c:Phoenix.LiveView.mount/3`) callback of your LiveView
should execute those same verifications:

    def mount(_params, %{"user_id" => user_id} = _session, socket) do
      socket = assign(socket, current_user: Accounts.get_user!(user_id))

      socket =
        if socket.assigns.current_user.confirmed_at do
          socket
        else
          redirect(socket, to: "/login")
        end

      {:ok, socket}
    end

The `on_mount` hook allows you to encapsulate this logic and execute it on every mount:

    defmodule MyAppWeb.UserLiveAuth do
      import Phoenix.Component
      import Phoenix.LiveView
      alias MyAppWeb.Accounts # from `mix phx.gen.auth`

      def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
        socket =
          assign_new(socket, :current_user, fn ->
            Accounts.get_user_by_session_token(user_token)
          end)

        if socket.assigns.current_user.confirmed_at do
          {:cont, socket}
        else
          {:halt, redirect(socket, to: "/login")}
        end
      end
    end

We use [`assign_new/3`](`Phoenix.Component.assign_new/3`). This is a
convenience to avoid fetching the `current_user` multiple times across
parent-child LiveViews.

Now we can use the hook whenever relevant. One option is to specify
the hook in your router under `live_session`:

    live_session :default, on_mount: MyAppWeb.UserLiveAuth do
      # Your routes
    end

Alternatively, you can either specify the hook directly in the LiveView:

    defmodule MyAppWeb.PageLive do
      use MyAppWeb, :live_view
      on_mount MyAppWeb.UserLiveAuth

      ...
    end

If you prefer, you can add the hook to `def live_view` under `MyAppWeb`,
to run it on all LiveViews by default:

    def live_view do
      quote do
        use Phoenix.LiveView

        on_mount MyAppWeb.UserLiveAuth
        unquote(html_helpers())
      end
    end

## Events considerations

Every time the user performs an action on your system, you should verify if the user
is authorized to do so, regardless if you are using LiveViews or not. For example,
imagine a user can see all projects in a web application, but they may not have
permission to delete any of them. At the UI level, you handle this accordingly
by not showing the delete button in the projects listing, but a savvy user can
directly talk to the server and request a deletion anyway. For this reason, **you
must always verify permissions on the server**.

In LiveView, most actions are handled by the `handle_event` callback. Therefore,
you typically authorize the user within those callbacks. In the scenario just
described, one might implement this:

    on_mount MyAppWeb.UserLiveAuth

    def mount(_params, _session, socket) do
      {:ok, load_projects(socket)}
    end

    def handle_event("delete_project", %{"project_id" => project_id}, socket) do
      Project.delete!(socket.assigns.current_user, project_id)
      {:noreply, update(socket, :projects, &Enum.reject(&1, fn p -> p.id == project_id end)}
    end

    defp load_projects(socket) do
      projects = Project.all_projects(socket.assigns.current_user)
      assign(socket, projects: projects)
    end

First, we used `on_mount` to authenticate the user based on the data stored in
the session. Then we load all projects based on the authenticated user. Now,
whenever there is a request to delete a project, we still pass the current user
as argument to the `Project` context, so it verifies if the user is allowed to
delete it or not. In case it cannot delete, it is fine to just raise an exception.
After all, users are not meant to trigger this code path anyway (unless they are
fiddling with something they are not supposed to!).

## Disconnecting all instances of a live user

So far, the security model between LiveView and regular web applications have
been remarkably similar. After all, we must always authenticate and authorize
every user. The main difference between them happens on logout or when revoking
access.

Because LiveView is a permanent connection between client and server, if a user
is logged out, or removed from the system, this change won't reflect on the
LiveView part unless the user reloads the page.

Luckily, it is possible to address this by setting a `live_socket_id` in the
session. For example, when logging in a user, you could do:

    conn
    |> put_session(:current_user_id, user.id)
    |> put_session(:live_socket_id, "users_socket:#{user.id}")

Now all LiveView sockets will be identified and listen to the given `live_socket_id`.
You can then disconnect all live users identified by said ID by broadcasting on
the topic:

    MyAppWeb.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})

> Note: If you use `mix phx.gen.auth` to generate your authentication system,
> lines to that effect are already present in the generated code. The generated
> code uses a `user_token` instead of referring to the `user_id`.

Once a LiveView is disconnected, the client will attempt to reestablish
the connection and re-execute the [`mount/3`](`c:Phoenix.LiveView.mount/3`)
callback. In this case, if the user is no longer logged in or it no longer has
access to the current resource, `mount/3` will fail and the user will be
redirected.

This is the same mechanism provided by `Phoenix.Channel`s. Therefore, if
your application uses both channels and LiveViews, you can use the same
technique to disconnect any stateful connection.

## Summing up

The important concepts to keep in mind are:

  * `live_session` can be used to draw boundaries between groups of
    LiveViews. While you could use `live_session` to draw lines between
    different authorization rules, doing so would lead to frequent page
    reloads. For this reason, we typically use `live_session` to enforce
    different *authentication* requirements or whenever you need to
    change root layouts

  * Your authentication logic (logging the user in) is typically part of
    your regular web request pipeline and it is shared by both controllers
    and LiveViews. Authentication then stores the user information in the
    session. Regular web requests use `plug` to read the user from a session,
    LiveViews read it inside an `on_mount` callback. This is typically a
    single database lookup on both cases. Running `mix phx.gen.auth` sets
    up all that is necessary

  * Once authenticated, your authorization logic in LiveViews will happen
    both during `mount` (such as "can the user see this page?") and during
    events (like "can the user delete this item?"). Those rules are often
    domain/business specific, and typically happen in your context modules.
    This is also a requirement for regular requests and responses
```

## File: `guides/server/telemetry.md`
```
# Telemetry

LiveView currently exposes the following [`telemetry`](https://hexdocs.pm/telemetry) events:

  * `[:phoenix, :live_view, :mount, :start]` - Dispatched by a `Phoenix.LiveView`
    immediately before [`mount/3`](`c:Phoenix.LiveView.mount/3`) is invoked.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            params: unsigned_params | :not_mounted_at_router,
            session: map,
            uri: String.t() | nil
          }

  * `[:phoenix, :live_view, :mount, :stop]` - Dispatched by a `Phoenix.LiveView`
    when the [`mount/3`](`c:Phoenix.LiveView.mount/3`) callback completes successfully.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            params: unsigned_params | :not_mounted_at_router,
            session: map,
            uri: String.t() | nil
          }

  * `[:phoenix, :live_view, :mount, :exception]` - Dispatched by a `Phoenix.LiveView`
    when an exception is raised in the [`mount/3`](`c:Phoenix.LiveView.mount/3`) callback.

    * Measurement: `%{duration: native_time}`

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            params: unsigned_params | :not_mounted_at_router,
            session: map,
            uri: String.t() | nil
          }

  * `[:phoenix, :live_view, :handle_params, :start]` - Dispatched by a `Phoenix.LiveView`
    immediately before [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) is invoked.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            params: unsigned_params,
            uri: String.t()
          }

  * `[:phoenix, :live_view, :handle_params, :stop]` - Dispatched by a `Phoenix.LiveView`
    when the [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) callback completes successfully.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            params: unsigned_params,
            uri: String.t()
          }

  * `[:phoenix, :live_view, :handle_params, :exception]` - Dispatched by a `Phoenix.LiveView`
    when an exception is raised in the [`handle_params/3`](`c:Phoenix.LiveView.handle_params/3`) callback.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            params: unsigned_params,
            uri: String.t()
          }

  * `[:phoenix, :live_view, :handle_event, :start]` - Dispatched by a `Phoenix.LiveView`
    immediately before [`handle_event/3`](`c:Phoenix.LiveView.handle_event/3`) is invoked.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_view, :handle_event, :stop]` - Dispatched by a `Phoenix.LiveView`
    when the [`handle_event/3`](`c:Phoenix.LiveView.handle_event/3`) callback completes successfully.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_view, :handle_event, :exception]` - Dispatched by a `Phoenix.LiveView`
    when an exception is raised in the [`handle_event/3`](`c:Phoenix.LiveView.handle_event/3`) callback.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_view, :render, :start]` - Dispatched by a `Phoenix.LiveView`
    immediately before [`render/1`](`c:Phoenix.LiveComponent.render/1`) is invoked.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            force?: boolean,
            changed?: boolean
          }

  * `[:phoenix, :live_view, :render, :stop]` - Dispatched by a `Phoenix.LiveView`
    when the [`render/1`](`c:Phoenix.LiveView.render/1`) callback completes successfully.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            force?: boolean,
            changed?: boolean
          }

  * `[:phoenix, :live_view, :render, :exception]` - Dispatched by a `Phoenix.LiveView`
    when an exception is raised in the [`render/1`](`c:Phoenix.LiveView.render/1`) callback.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            force?: boolean,
            changed?: boolean
          }

  * `[:phoenix, :live_component, :update, :start]` - Dispatched by a `Phoenix.LiveComponent`
    immediately before [`update/2`](`c:Phoenix.LiveComponent.update/2`) or a
    [`update_many/1`](`c:Phoenix.LiveComponent.update_many/1`) is invoked.

    In the case of[`update/2`](`c:Phoenix.LiveComponent.update/2`) it might dispatch one event
    for multiple calls.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            component: atom,
            assigns_sockets: [{map(), Phoenix.LiveView.Socket.t}]
          }

  * `[:phoenix, :live_component, :update, :stop]` - Dispatched by a `Phoenix.LiveComponent`
    when the [`update/2`](`c:Phoenix.LiveComponent.update/2`) or a
    [`update_many/1`](`c:Phoenix.LiveComponent.update_many/1`) callback completes successfully.

    In the case of[`update/2`](`c:Phoenix.LiveComponent.update/2`) it might dispatch one event
    for multiple calls. The `sockets` metadata contain the updated sockets.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            component: atom,
            assigns_sockets: [{map(), Phoenix.LiveView.Socket.t}],
            sockets: [Phoenix.LiveView.Socket.t]
          }

  * `[:phoenix, :live_component, :update, :exception]` - Dispatched by a `Phoenix.LiveComponent`
    when an exception is raised in the [`update/2`](`c:Phoenix.LiveComponent.update/2`) or a
    [`update_many/1`](`c:Phoenix.LiveComponent.update_many/1`) callback.

    In the case of[`update/2`](`c:Phoenix.LiveComponent.update/2`) it might dispatch one event
    for multiple calls.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            component: atom,
            assigns_sockets: [{map(), Phoenix.LiveView.Socket.t}]
          }

  * `[:phoenix, :live_component, :handle_event, :start]` - Dispatched by a `Phoenix.LiveComponent`
    immediately before [`handle_event/3`](`c:Phoenix.LiveComponent.handle_event/3`) is invoked.

    * Measurement:

          %{system_time: System.monotonic_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            component: atom,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_component, :handle_event, :stop]` - Dispatched by a `Phoenix.LiveComponent`
    when the [`handle_event/3`](`c:Phoenix.LiveComponent.handle_event/3`) callback completes successfully.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            component: atom,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_component, :handle_event, :exception]` - Dispatched by a `Phoenix.LiveComponent`
    when an exception is raised in the [`handle_event/3`](`c:Phoenix.LiveComponent.handle_event/3`) callback.

    * Measurement:

          %{duration: native_time}

    * Metadata:

          %{
            socket: Phoenix.LiveView.Socket.t,
            kind: atom,
            reason: term,
            component: atom,
            event: String.t(),
            params: unsigned_params
          }

  * `[:phoenix, :live_component, :destroyed]` - Dispatched by a `Phoenix.LiveComponent`
    after it is destroyed. No measurement.

    * Metadata:

        %{
          socket: Phoenix.LiveView.Socket.t,
          component: atom,
          cid: integer(),
          live_view_socket: Phoenix.LiveView.Socket.t
        }
```

## File: `guides/server/uploads.md`
```
# Uploads

LiveView supports interactive file uploads with progress for
both direct to server uploads as well as direct-to-cloud
[external uploads](external-uploads.html) on the client.

## Built-in Features

  * Accept specification - Define accepted file types, max
    number of entries, max file size, etc. When the client
    selects file(s), the file metadata is automatically
    validated against the specification. See
    `Phoenix.LiveView.allow_upload/3`.

  * Reactive entries - Uploads are populated in an
    `@uploads` assign in the socket. Entries automatically
    respond to progress, errors, cancellation, etc.

  * Drag and drop - Use the `phx-drop-target` attribute to
    enable. See `Phoenix.Component.live_file_input/1`.

## Allow uploads

You enable an upload, typically on mount, via [`allow_upload/3`].

For this example, we will also keep a list of uploaded files in
a new assign named `uploaded_files`, but you could name it
something else if you wanted.

```elixir
@impl Phoenix.LiveView
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> assign(:uploaded_files, [])
   |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2)}
end
```

That's it for now! We will come back to the LiveView to
implement some form- and upload-related callbacks later, but
most of the functionality around uploads takes place in the
template.

## Render reactive elements

Use the `Phoenix.Component.live_file_input/1` component
to render a file input for the upload:

```heex
<%!-- lib/my_app_web/live/upload_live.html.heex --%>

<form id="upload-form" phx-submit="save" phx-change="validate">
  <.live_file_input upload={@uploads.avatar} />
  <button type="submit">Upload</button>
</form>
```

> **Important:** You must bind `phx-submit` and `phx-change` on the form.

Note that while [`live_file_input/1`]
allows you to set additional attributes on the file input,
many attributes such as `id`, `accept`, and `multiple` will
be set automatically based on the [`allow_upload/3`] spec.

Reactive updates to the template will occur as the end-user
interacts with the file input.

### Upload entries

Uploads are populated in an `@uploads` assign in the socket.
Each allowed upload contains a _list_ of entries,
irrespective of the `:max_entries` value in the
[`allow_upload/3`] spec. These entry structs contain all the
information about an upload, including progress, client file
info, errors, etc.

Let's look at an annotated example:

```heex
<%!-- lib/my_app_web/live/upload_live.html.heex --%>

<%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
<section phx-drop-target={@uploads.avatar.ref}>
  <%!-- render each avatar entry --%>
  <article :for={entry <- @uploads.avatar.entries} class="upload-entry">
    <figure>
      <.live_img_preview entry={entry} />
      <figcaption>{entry.client_name}</figcaption>
    </figure>

    <%!-- entry.progress will update automatically for in-flight entries --%>
    <progress value={entry.progress} max="100"> {entry.progress}% </progress>

    <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
    <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">&times;</button>

    <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
    <p :for={err <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">{error_to_string(err)}</p>
  </article>

  <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
  <p :for={err <- upload_errors(@uploads.avatar)} class="alert alert-danger">
    {error_to_string(err)}
  </p>
</section>
```

The `section` element in the example acts as the
`phx-drop-target` for the `:avatar` upload. Users can interact
with the file input or they can drop files over the element
to add new entries.

Upload entries are created when a file is added to the form
input and each will exist until it has been consumed,
following a successfully completed upload.

### Entry validation

Validation occurs automatically based on any conditions
that were specified in [`allow_upload/3`] however, as
mentioned previously you are required to bind `phx-change`
on the form in order for the validation to be performed.
Therefore you must implement at least a minimal callback:

```elixir
@impl Phoenix.LiveView
def handle_event("validate", _params, socket) do
  {:noreply, socket}
end
```

Entries for files that do not match the [`allow_upload/3`]
spec will contain errors. Use
`Phoenix.Component.upload_errors/2` and your own
helper function to render a friendly error message:

```elixir
defp error_to_string(:too_large), do: "Too large"
defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
```

For error messages that affect all entries, use
`Phoenix.Component.upload_errors/1`, and your own
helper function to render a friendly error message:

```elixir
defp error_to_string(:too_many_files), do: "You have selected too many files"
```

### Cancel an entry

Upload entries may also be canceled, either programmatically
or as a result of a user action. For instance, to handle the
click event in the template above, you could do the following:

```elixir
@impl Phoenix.LiveView
def handle_event("cancel-upload", %{"ref" => ref}, socket) do
  {:noreply, cancel_upload(socket, :avatar, ref)}
end
```

## Consume uploaded entries

When the end-user submits a form containing a [`live_file_input/1`],
the JavaScript client first uploads the file(s) before
invoking the callback for the form's `phx-submit` event.

Within the callback for the `phx-submit` event, you invoke
the `Phoenix.LiveView.consume_uploaded_entries/3` function
to process the completed uploads, persisting the relevant
upload data alongside the form data:

```elixir
@impl Phoenix.LiveView
def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join(Application.app_dir(:my_app, "priv/static/uploads"), Path.basename(path))
      # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)

  {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
end
```

> **Note**: While client metadata cannot be trusted, max file size validations
> are enforced as each chunk is received when performing direct to server uploads.

This example writes the file directly to disk, under the `priv` folder.
In order to access your upload, for example in an `<img />` tag, you need
to add the `uploads` directory to `static_paths/0`.  In a vanilla Phoenix
project, this is found in `lib/my_app_web.ex`.

Another thing to be aware of is that in development, changes to
`priv/static/uploads` will be picked up by `live_reload`.  This means that as
soon as your upload succeeds, your app will be reloaded in the browser.  This
can be temporarily disabled by setting `code_reloader: false` in `config/dev.exs`.

Besides the above, this approach also has limitations in production. If you are
running multiple instances of your application, the uploaded file will be stored
only in one of the instances. Any request routed to the other machine will
ultimately fail.

For these reasons, it is best if uploads are stored elsewhere, such as the
database (depending on the size and contents) or a separate storage service.
For more information on implementing client-side, direct-to-cloud uploads,
see the [External uploads guide](external-uploads.md) for details.

## Appendix A: UploadLive

A complete example of the LiveView from this guide:

```elixir
# lib/my_app_web/live/upload_live.ex
defmodule MyAppWeb.UploadLive do
  use MyAppWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:my_app), "static", "uploads", Path.basename(path)])
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
```

To access your uploads via your app, make sure to add `uploads` to
`MyAppWeb.static_paths/0`.

[`allow_upload/3`]: `Phoenix.LiveView.allow_upload/3`
[`live_file_input/1`]: `Phoenix.Component.live_file_input/1`
```
