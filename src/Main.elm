module Main exposing (main)

import Browser
import Html exposing (Html, div, h2, text, button, img, ul, li, h3)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string)

import Utils exposing (errorToString)



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


type Load
  = Failure
  | Loading
  | Success String

type alias Model =
  { load : Load
  , errors : List String
  }

initModel : Model
initModel =
  Model Loading []

init : () -> (Model, Cmd Msg)
init _ =
  (initModel, getRandomCatGif)



-- UPDATE


type Msg
  = MorePlease
  | GotGif (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ({model | load = Loading}, getRandomCatGif)

    GotGif result ->
      case result of
        Ok url ->
          ({model | load = Success url}, Cmd.none)

        Err error ->
          ({model | load = Failure, errors = errorToString error :: model.errors}, Cmd.none)



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
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
        , img [ src url ] []
        ]



-- HTTP


getRandomCatGif : Cmd Msg
getRandomCatGif =
  Http.get
    { url = "https://xkcd.com/info.0.json"
    , expect = Http.expectJson GotGif gifDecoder
    }

gifDecoder : Decoder String
gifDecoder =
  field "img" string
