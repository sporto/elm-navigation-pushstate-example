# Example Elm app with push state navigation

This example application shows how to use push state navigation in Elm.

## Components

### Server

A server that matches any route and return the Elm application. For example when hitting `/` or `/users/` or `/users/1` the server needs to return the same html.

In this example I'm using `elm-live --pushstate` which does this automatically.

### Messages

- A message to change the location e.g. `ChangeLocation String`
- A message to react to location changes e.g. `OnLocationChange Navigation.Location`

### Links

- Is a good practice to provide links with a proper `href`. This allows users to copy the link and open a page in a new tap/window.
- Links should trigger a message to change the location when clicked, e.g. `ChangeLocation "/users"`
- But we need to prevent the default browser behaviour when clicked. The default behaviour is to load a new page. We want to navigate via the Navigation package instead.

### Navigation.newUrl

Change the browser location using `Navigation.newUrl` instead of a normal link. `newUrl` creates a new history entry via pushState.

__See commented example at [](./src/Main.elm).__

## Start

```bash
yarn
yarn start
```

Open `http://localhost:8000/`

