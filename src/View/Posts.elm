module View.Posts exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onCheck)
import Model exposing (Msg(..))
import Model.Post exposing (Post)
import Model.PostsConfig exposing (..)
import Time exposing (..)
import Util.Time exposing (..)
import Time exposing (Posix, now)
import Util.Time exposing (Date(..))


{-| Show posts as a HTML [table](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table)

Relevant local functions:

  - Util.Time.formatDate
  - Util.Time.formatTime
  - Util.Time.formatDuration (once implemented)
  - Util.Time.durationBetween (once implemented)

Relevant library functions:

  - [Html.table](https://package.elm-lang.org/packages/elm/html/latest/Html#table)
  - [Html.tr](https://package.elm-lang.org/packages/elm/html/latest/Html#tr)
  - [Html.th](https://package.elm-lang.org/packages/elm/html/latest/Html#th)
  - [Html.td](https://package.elm-lang.org/packages/elm/html/latest/Html#td)

-}

postTable : PostsConfig -> Time.Posix -> List Post -> Html Msg
postTable config currentTime posts =
    let
        filteredFinalPosts = filterPosts config posts

        header =
            tr []
                [ th [ class "post-score" ] [ text "Score" ]
                , th [ class "post-title" ] [ text "Title" ]
                , th [ class "post-type" ] [ text "Type" ]
                , th [ class "post-time" ] [ text "Posted Date" ]
                , th [ class "post-url" ] [ text "Link" ]
                ]
        rows =
            filteredFinalPosts
                |> List.map
                    (\post ->
                        let
                            formattedTime =  Util.Time.formatTime Time.utc post.time
                            maybeDuration =  Util.Time.durationBetween post.time currentTime
                            formatDuration =
                                case maybeDuration of
                                    Just duration ->
                                        Util.Time.formatDuration duration

                                    Nothing ->
                                        "Unknown time ago"
                            displayedTime =
                                formattedTime ++ " (" ++ formatDuration ++ ")"
                        in
                        Html.tr []
                            [ Html.td [ Html.Attributes.class "post-score" ] [ Html.text (String.fromInt post.score) ]
                            , Html.td [ Html.Attributes.class "post-title" ] [ Html.text post.title ]
                            , Html.td [ Html.Attributes.class "post-type" ] [ Html.text post.type_ ]
                            , Html.td [ Html.Attributes.class "post-time" ] [ Html.text displayedTime ]
                            , Html.td [ Html.Attributes.class "post-url" ] [ Html.a [ Html.Attributes.href (Maybe.withDefault "" post.url) ] [ Html.text "Link" ] ]
                            ]
                    )

    in
    table [] (header :: rows)

{-| Show the configuration options for the posts table

Relevant functions:

  - [Html.select](https://package.elm-lang.org/packages/elm/html/latest/Html#select)
  - [Html.option](https://package.elm-lang.org/packages/elm/html/latest/Html#option)
  - [Html.input](https://package.elm-lang.org/packages/elm/html/latest/Html#input)
  - [Html.Attributes.type\_](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#type_)
  - [Html.Attributes.checked](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#checked)
  - [Html.Attributes.selected](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#selected)
  - [Html.Events.onCheck](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onCheck)
  - [Html.Events.onInput](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput)

-}

postsConfigView : PostsConfig -> Html Msg
postsConfigView config =
    div []
        [ select [ id "select-posts-per-page", onInput (String.toInt >> Maybe.withDefault 10 >> ChangePostsPerPage >> ConfigChanged) ]
            [ option [ value "10", selected (config.postsToShow == 10) ] [ text "10" ]
            , option [ value "25", selected (config.postsToShow == 25) ] [ text "25" ]
            , option [ value "50", selected (config.postsToShow == 50) ] [ text "50" ]
            ]
        , select [ id "select-sort-by", onInput (String.trim >> ChangeSortBy >> ConfigChanged) ]
            [ option [ value "Score", selected (config.sortBy == Score) ] [ text "Score" ]
            , option [ value "Title", selected (config.sortBy == Title) ] [ text "Title" ]
            , option [ value "Date", selected (config.sortBy == Posted) ] [ text "Date Posted" ]
            , option [ value "None", selected (config.sortBy == None) ] [ text "None" ] 
            ]
        , div []
            [ label [ for "checkbox-show-job-posts" ] [ text "Show job posts" ]
            , input [ type_ "checkbox", id "checkbox-show-job-posts", checked config.showJobs, onCheck (ChangeShowJobPosts >> ConfigChanged) ] []
            ]
        , div []
            [ label [ for "checkbox-show-text-only-posts" ] [ text "Show text only posts" ]
            , input [ type_ "checkbox", id "checkbox-show-text-only-posts", checked config.showTextOnly, onCheck (ChangeShowTextOnlyPosts >> ConfigChanged) ] []
            ]
        ]
