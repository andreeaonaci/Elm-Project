module Util.Time exposing (..)

import Time


type Date
    = Date { year : Int, month : Time.Month, day : Int }


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"


posixToDate : Time.Zone -> Time.Posix -> Date
posixToDate tz time =
    let
        year =
            Time.toYear tz time

        month =
            Time.toMonth tz time

        day =
            Time.toDay tz time
    in
    Date { year = year, month = month, day = day }


-- {-| Formats a `Date` instance.

--     import Time

--     formatDate (Date { year = 2022, month = Time.Apr, day =  4 }) {- ignore -} --> "2022 Apr 04"

--     formatDate (Date { year = 2022, month = Time.Jan, day = 12 }) {- ignore -} --> "2022 Jan 12"

-- -}
formatDate : Date -> String
formatDate (Date date) =
    let
        year = String.fromInt date.year

        month = monthToString date.month

        day = String.fromInt date.day |> String.padLeft 2 '0'
    in
    year ++ " " ++ month ++ " " ++ day


formatTime : Time.Zone -> Time.Posix -> String
formatTime tz time =
    let
        date = posixToDate tz time

        hour = Time.toHour tz time |> String.fromInt |> String.padLeft 2 '0'

        minute = Time.toMinute tz time |> String.fromInt |> String.padLeft 2 '0'
    in
    formatDate date ++ " " ++ hour ++ ":" ++ minute


type alias Duration =
    { seconds : Int
    , minutes : Int
    , hours : Int
    , days : Int
    }


{-| Calculates the amount of time that passed between two dates.

The first date (t1) must be **before** the second date (t2), if this not the case, the function should return `Nothing`.

Relevant library functions:

  - Use Time.posixToMillis

```
import Time

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (1000)) --> Just (Duration 1 0 0 0)

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (60 * 1000)) --> Just (Duration 0 1 0 0)

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (60 * 60 * 1000)) --> Just (Duration 0 0 1 0)

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (24 * 60 * 60 * 1000)) --> Just (Duration 0 0 0 1)

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (24 * 60 * 60 * 1000 + 1000)) --> Just (Duration 1 0 0 1)

durationBetween (Time.millisToPosix 0) (Time.millisToPosix (4 * 24 * 60 * 60 * 1000 + 3 * 60 * 60 * 1000 + 2 * 60 * 1000 + 1000)) --> Just (Duration 1 2 3 4)

durationBetween (Time.millisToPosix 1000) (Time.millisToPosix 0) --> Nothing

durationBetween (Time.millisToPosix 1000) (Time.millisToPosix 1000) --> Nothing
```

-}
durationBetween : Time.Posix -> Time.Posix -> Maybe Duration
durationBetween time1 time2 =
    let
        time1Millis = Time.posixToMillis time1
        time2Millis = Time.posixToMillis time2
    in
    if time1Millis >= time2Millis then
        Nothing
    else
        let
            durationInMilliseconds = time2Millis - time1Millis
            secondsTotal = durationInMilliseconds // 1000
            minutesTotal = secondsTotal // 60
            hoursTotal = minutesTotal // 60
            days = hoursTotal // 24
            hours = Basics.modBy 24 hoursTotal
            minutes = Basics.modBy 60 minutesTotal
            seconds = Basics.modBy 60 secondsTotal
        in
        Just { seconds = seconds, minutes = minutes, hours = hours, days = days }


{-| Format a `Duration` as a human readable string

    formatDuration (Duration 1 0 0 0) --> "1 second ago"

    formatDuration (Duration 2 0 0 0) --> "2 seconds ago"

    formatDuration (Duration 0 1 0 0) --> "1 minute ago"

    formatDuration (Duration 0 0 2 0) --> "2 hours ago"

    formatDuration (Duration 0 0 0 3) --> "3 days ago"

    formatDuration (Duration 0 1 1 1) --> "1 day 1 hour 1 minute ago"

    formatDuration (Duration 0 47 6 2) --> "2 days 6 hours 47 minutes ago"

    formatDuration (Duration 0 30 0 1) --> "1 day 30 minutes ago"

-}
formatDuration : Duration -> String
formatDuration duration =
    let
        days = duration.days
        hours = duration.hours
        minutes = duration.minutes
        seconds = duration.seconds
        formatPlural n unit = 
            if n == 1 then 
                "1 " ++ unit 
            else 
                String.fromInt n ++ " " ++ unit ++ "s"
        parts = 
            [ if days > 0 then Just (formatPlural days "day") else Nothing
            , if hours > 0 then Just (formatPlural hours "hour") else Nothing
            , if minutes > 0 then Just (formatPlural minutes "minute") else Nothing
            , if seconds > 0 then Just (formatPlural seconds "second") else Nothing
            ]
        filteredParts = List.filterMap identity parts
    in
    if List.isEmpty filteredParts then
        "now"
    else
        String.join " " filteredParts ++ " ago"
