module Model.PostsConfig exposing (..)

import Html.Attributes exposing (..)
import Model.Post exposing (Post)
import Time
import Basics exposing (compare)

type SortBy
    = Score
    | Title
    | Posted
    | None


sortOptions : List SortBy
sortOptions =
    [ Score, Title, Posted, None ]


sortToString : SortBy -> String
sortToString sort =
    case sort of
        Score ->
            "Score"

        Title ->
            "Title"

        Posted ->
            "Posted"

        None ->
            "None"


{-|

    sortFromString "Score" --> Just Score

    sortFromString "Invalid" --> Nothing

    sortFromString "Title" --> Just Title

-}
sortFromString : String -> Maybe SortBy
sortFromString str =
    case str of
        "Score" ->
            Just Score

        "Title" ->
            Just Title
        _ ->
            Nothing

sortToCompareFn : SortBy -> (Post -> Post -> Order)
sortToCompareFn sort =
    case sort of
        Score ->
            \postA postB -> compare postB.score postA.score

        Title ->
            \postA postB -> compare postA.title postB.title

        Posted ->
            \postA postB -> compare (Time.posixToMillis postB.time) (Time.posixToMillis postA.time)

        None ->
            \_ _ -> EQ

type alias PostsConfig =
    { postsToFetch : Int
    , postsToShow : Int
    , sortBy : SortBy
    , showJobs : Bool
    , showTextOnly : Bool
    }


defaultConfig : PostsConfig
defaultConfig =
    PostsConfig 50 10 None False True


{-| A type that describes what option changed and how
-}
type Change
    = ChangePostsPerPage Int
    | ChangeSortBy String
    | ChangeShowJobPosts Bool
    | ChangeShowTextOnlyPosts Bool


{-| Given a change and the current configuration, return a new configuration with the changes applied
-- -}

applyChanges : Change -> PostsConfig -> PostsConfig
applyChanges change config =
    case change of
        ChangePostsPerPage newPerPage ->
            { config | postsToShow = newPerPage }

        ChangeSortBy newSortBy ->
            { config | sortBy = 
                if String.toLower newSortBy == "None"  then None
                else Maybe.withDefault None (sortFromString newSortBy)
            }

        ChangeShowJobPosts newBool ->
            { config | showJobs = newBool }

        ChangeShowTextOnlyPosts newBool ->
            { config | showTextOnly = newBool }

{-| Given the configuration and a list of posts, return the relevant subset of posts according to the configuration

Relevant local functions:

  - sortToCompareFn

Relevant library functions:

  - List.sortWith

-- -}

filterPosts : PostsConfig -> List Post -> List Post
filterPosts config posts =
    posts
        |> (if not config.showTextOnly then List.filter (\post -> post.url /= Nothing) else (\x -> x))
        |> (if not config.showJobs then List.filter (\post -> post.type_ /= "job") else (\x -> x))
        |> List.take config.postsToShow
        |> List.sortWith (sortToCompareFn config.sortBy)