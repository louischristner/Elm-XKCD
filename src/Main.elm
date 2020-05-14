module Main exposing (main)

import Browser
import Html exposing (Html, div, h2, text, button, img, ul, li, h3)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string, map2, int)
import Random

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
    }

type Load
  = Failure
  | Loading
  | Success Comic

type alias Model =
  { load : Load
  , maxIndex : Int
  , comics : List Comic
  , errors : List String
  , urls : List String
  }

currentComicUrl : String
currentComicUrl = "https://xkcd.com/info.0.json"

initModel : Model
initModel =
  Model Loading 0 [] [] []

init : () -> (Model, Cmd Msg)
init _ =
  (initModel, getComic GotCurrentComic currentComicUrl)



-- UPDATE


type Msg
  = MorePlease
  | NewNumber Int
  | GotRandomComic (Result Http.Error Comic)
  | GotCurrentComic (Result Http.Error Comic)

newNumber : Int -> Cmd Msg
newNumber max =
  Random.generate NewNumber (randomInt max)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ({model | comics = []}, newNumber model.maxIndex)

    NewNumber nbr ->
      let
        url = "https://xkcd.com/" ++ String.fromInt nbr ++ "/info.0.json"
      in
        if nbr > 0 then
          ({model | urls = url :: model.urls}
          , getComic GotRandomComic url)
        else
          (model, newNumber model.maxIndex)

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
  div []
    [ h2 [] [ text "XKCD - current comic" ]
    , viewGif model
    ]

viewError : String -> Html Msg
viewError error =
  li [] [ text error ]

viewComic : Comic -> Html Msg
viewComic comic =
  li [] [ img [ src comic.src ] [] ]

viewGif : Model -> Html Msg
viewGif model =
  case model.load of
    Failure ->
      div []
        [ text "I could not load your XKCD comic. "
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        , h3 [] [ text "Errors" ]
        , ul []
          (List.map viewError model.errors)
        , ul []
          (List.map viewError model.urls)
        ]

    Loading ->
      text "Loading..."

    Success comic ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
        , img [ src comic.src ] []
        , ul []
          (List.map viewComic model.comics)
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
  map2 Comic
    (field "img" string)
    (field "num" int)
