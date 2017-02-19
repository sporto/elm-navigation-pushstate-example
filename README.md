# Example Elm app with push state navigation

This example application shows how to use push state navigation in Elm.

## What you need

1. A server that matches any route and return the Elm application. For example when hitting `/` or `/users/` or `/users/1` the server needs to return the same html.

In this example I'm using `elm-live --pushstate` which does this automatically.

2. A message to change the location e.g. `ChangeLocation String`

3. Links that:

- Display the target path in the href e.g. "/users", this is nice to have so users can copy the link.
- Trigger a message to change the location when clicked, e.g. `ChangeLocation "/users"`
- Prevent the default browser behaviour when clicked. The default behaviour is to load a new page. We don't want this, we want to navigate via the Navigation package instead.

4. Change the browser location using `Navigation.newUrl`, this creates a new history entry via pushState.

__See commented example at <./src/Main.elm>.__

## Start

```bash
yarn
yarn start
```

Open `http://localhost:8000/`

