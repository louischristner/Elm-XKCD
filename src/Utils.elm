module Utils exposing (errorToString)

import Http



errorToString : Http.Error -> String
errorToString error =
  case error of
    Http.BadUrl url ->
        "The URL " ++ url ++ " was invalid"
    Http.Timeout ->
        "Timeout: Unable to reach the server, try again"
    Http.NetworkError ->
        "Network error: Unable to reach the server, check your network connection"
    Http.BadStatus 500 ->
        "HTTP code 500: The server had a problem, try again later"
    Http.BadStatus 400 ->
        "HTTP code 400: Verify your information and try again"
    Http.BadStatus code ->
        "HTTP code " ++ String.fromInt code ++ ": Unknown error"
    Http.BadBody errorMessage ->
        errorMessage
