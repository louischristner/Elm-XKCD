# Elm-XKCD

Basic application that display XKCD comics for learning purposes.

## Ressources

Official Elm website [here](https://elm-lang.org)
Elm packages website [here](https://package.elm-lang.org/)

How to Install Elm [here](https://guide.elm-lang.org/install/elm.html).
XKCD API documentation [here](https://xkcd.com/json.html).

Basically man elm with `elm --help`.

## Tutorial

### Create a new Elm project

Run `elm init` and create `Main.elm` file in `src` folder and `index.html` at root (See [here](https://guide.elm-lang.org/interop/) for a basic `index.html` file).

### Compile Elm files

To compile `Main.elm` to a JavaScript file:
```bash
elm make src/Main.elm --output=main.js
```

---

You can also launch a server that will compile Elm file when you click on it with:
```bash
elm reactor
```

## Notes

#### If repetitive Network error it may be a CORS problem

Firefox CORS Everywhere add-on [here](https://addons.mozilla.org/en-US/firefox/addon/cors-everywhere/).
Chrome Moesif Orign & CORS Changer extension [here](https://chrome.google.com/webstore/detail/moesif-orign-cors-changer/digfbfaphojjndkpccljibejjbppifbc).

