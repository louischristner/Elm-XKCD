module Main exposing (main)

import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Html exposing (Html)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Json.Decode exposing (Decoder, field, string, map4, int)
import Random
import Http
import Task

import Utils exposing (errorToString, randomInt)



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Comic =
    { src : String
    , num : Int
    , title : String
    , alt : String
    }

type Load
  = Failure
  | Loading
  | Success Comic

type alias Model =
  { load : Load
  , width : Float
  , height : Float
  , maxIndex : Int
  , comics : List Comic
  , errors : List String
  }

currentComicUrl : String
currentComicUrl = "https://xkcd.com/info.0.json"

initModel : Model
initModel =
  Model Loading 0.0 0.0 0 [] []

init : () -> (Model, Cmd Msg)
init _ =
  (initModel
  , getViewportCmd
    <| getComic GotCurrentComic currentComicUrl
  )



-- UPDATE


type Msg
  = MorePlease
  | NewNumber Int
  | GotViewport (Cmd Msg) Viewport
  | GotRandomComic (Result Http.Error Comic)
  | GotCurrentComic (Result Http.Error Comic)

newNumber : Int -> Cmd Msg
newNumber max =
  Random.generate NewNumber (randomInt max)

getViewportCmd : Cmd Msg -> Cmd Msg
getViewportCmd nextMsg =
  getViewport
    |> Task.perform (GotViewport nextMsg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ({model | comics = []}, getComic GotCurrentComic currentComicUrl)

    NewNumber nbr ->
      let
        url = "https://xkcd.com/" ++ String.fromInt nbr ++ "/info.0.json"
      in
        if nbr > 0 then
          (model, getComic GotRandomComic url)
        else
          (model, newNumber model.maxIndex)

    GotViewport nextMsg viewport ->
      ({model
        | width = viewport.scene.width
        , height = viewport.scene.height
      }, nextMsg)

    GotRandomComic result ->
      case result of
        Ok comic ->
          ({model | comics = comic :: model.comics}
          , if List.length model.comics < 1 && List.isEmpty model.errors then
            newNumber model.maxIndex
          else
            Cmd.none
          )

        Err error ->
          ({model
            | load = Failure
            , errors = errorToString error :: model.errors
          }, Cmd.none)

    GotCurrentComic result ->
      case result of
        Ok comic ->
          ({ model
            | load = Success comic
            , maxIndex = comic.num
          }, if List.length model.comics < 1 && List.isEmpty model.errors then
            newNumber model.maxIndex
          else
            Cmd.none
          )

        Err error ->
          ({model
            | load = Failure
            , errors = errorToString error :: model.errors
          }, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  layout []
    <| column [ height fill, width fill ]
      [ el
        [ centerX
        , paddingXY 15 15
        , Font.size 24
        , Font.extraBold
        ]
        <| text "XKCD - current comic"
      , viewComics model
      ]

viewError : String -> Element Msg
viewError error =
  el []
    <| text error

viewComic : Int -> Int -> Comic -> Element Msg
viewComic maxWidth maxHeight comic =
  column
    [ centerX
    , centerY
    , paddingXY 15 5
    , width shrink
    , height shrink
    ]
    [ el
      [ centerX
      , Font.bold
      ]
      <| text comic.title
    , link []
      { url = "https://xkcd.com/" ++ String.fromInt comic.num
      , label = image
        [ width (fill |> maximum maxWidth)
        , height (fill |> maximum maxHeight)
        ]
        { src = comic.src
        , description = comic.alt
        }
      }
    ]

viewComics : Model -> Element Msg
viewComics model =
  case model.load of
    Failure ->
      column [ width fill ]
        [ text "I could not load your XKCD comic. "
        , Input.button []
          { onPress = Just MorePlease
          , label = text "Try Again!"
          }
        , text "Errors"
        , Element.column [ width fill ]
          <| List.map viewError model.errors
        ]

    Loading ->
      text "Loading..."

    Success comic ->
      column [ width fill, centerX ]
        [ row [ centerX ]
          [ viewComic (round model.width) (round model.height // 3) comic ]
        , Input.button [ centerX, paddingXY 15 15 ]
          { onPress = Just MorePlease
          , label = text "More random comics!"
          }
        , if List.length model.comics > 0 then
          row [ centerY, centerX ]
            <| List.map (
              viewComic
                ((round model.width // List.length model.comics) - (List.length model.comics * 15))
                (round model.height // 3)
            ) model.comics
        else
          none
        ]



-- HTTP


getComic : (Result Http.Error Comic -> Msg) -> String -> Cmd Msg
getComic msg url =
  Http.get
    { url = url
    , expect = Http.expectJson msg comicDecoder
    }

comicDecoder : Decoder Comic
comicDecoder =
  map4 Comic
    (field "img" string)
    (field "num" int)
    (field "safe_title" string)
    (field "alt" string)
