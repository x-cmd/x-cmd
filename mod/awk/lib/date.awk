# linux: date -d '2022-11-09 12:31:27+00:00' +%s

function date_to_timestamp_linux( date,     t, _cmd ){
    _cmd = "date  +%s -ud '" date "' 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

# macos: date -j -f "%Y-%m-%d %H:%M:%S%z" "2022-11-09 12:31:27+0000" "+%s"
# macos: date -j -f "%Y-%m-%d %H:%M:%S" "2022-11-09 12:31:27" "+%s"
function date_to_timestamp_bsd( date,       t, _cmd ) {
    if (date ~ /:[0-9][0-9]$/) {
        date = substr(date, 1, length(date)-3) substr(date, length(date)-1)
    }
    _cmd = "date -j -f \"%Y-%m-%d %H:%M:%S%z\" \"" date "\" +%s 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function date_to_timestamp( date,   t ){
    return ( (t = date_to_timestamp_linux( date ) ) != "") ? t : date_to_timestamp_bsd( date )
}


function timestamp_to_date_linux( timestamp,   t, _cmd ){
    _cmd = "date \"+%Y-%m-%d %H:%M:%S\" -ud @'"timestamp"' 2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function timestamp_to_date_bsd( timestamp,   t, _cmd ){
    _cmd = "date -ur \"" timestamp "\" \"+%Y-%m-%d %H:%M:%S\"  2>/dev/null"
    _cmd | getline t
    close( _cmd )
    return t
}

function timestamp_to_date( timestamp,   t ){
    return ( (t = timestamp_to_date_linux( timestamp ) ) != "") ? t : timestamp_to_date_bsd( timestamp )
}

function date_epochminus(a, b,          c){
    c = sprintf("%.3f", a - b)
    gsub(/0+$/, "", c)
    gsub(/\.$/, "", c)
    return c
}

function date_humantime(t,          _res) {
    _res = (t % 60) "s"
    t = int(t)
    if (t >= 60) {
        _res = int((t / 60) % 60) "m " _res
        if (t >= 3600) {
            _res = int((t / 3600) % 24) "h " _res
            if (t >= 86400) {
                _res = int(t / 86400) "d " _res
            }
        }
    }
    return _res
}

# Pure AWK timestamp to date conversion
# No external date command required

# Global timezone offset in seconds (cached after init)
DATE_TZ_OFFSET = ""

# Get timezone offset (calls date +%z once, then cached)
# Returns: timezone offset in seconds
function date_tz(    tz_offset, sign, tz_h, tz_m) {
    if (DATE_TZ_OFFSET != "") return DATE_TZ_OFFSET

    "date +%z" | getline tz_offset
    close("date +%z")

    sign = (tz_offset ~ /^-/) ? -1 : 1
    tz_h = substr(tz_offset, 2, 2) + 0
    tz_m = substr(tz_offset, 4, 2) + 0
    DATE_TZ_OFFSET = sign * (tz_h * 3600 + tz_m * 60)

    return DATE_TZ_OFFSET
}

# Leap year check
function date___is_leap_year(year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

# Days in a specific month/year
function date___days_in_month(year, month) {
    if (month == 2) {
        return date___is_leap_year(year) ? 29 : 28
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
        return 30
    } else {
        return 31
    }
}

# Days in a specific year
function date___days_in_year(year) {
    return date___is_leap_year(year) ? 366 : 365
}

# Internal: Timestamp to date string (UTC, YYYY-MM-DD HH:MM:SS)
function date___timestamp_to_utc(timestamp,    days, secs, year, month, day, hour, minute, second, _days_in_year) {
    days = int(timestamp / 86400)
    secs = timestamp % 86400

    year = 1970
    while (1) {
        _days_in_year = date___days_in_year(year)
        if (days < _days_in_year) break
        days -= _days_in_year
        year++
    }

    month = 1
    while (1) {
        dim = date___days_in_month(year, month)
        if (days < dim) break
        days -= dim
        month++
    }
    day = days + 1

    hour = int(secs / 3600)
    secs %= 3600
    minute = int(secs / 60)
    second = secs % 60

    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
}

# Timestamp to ISO string with timezone
# If timezone initialized: returns local time (e.g., 2026-05-08 19:00:00+0800)
# Otherwise: returns UTC time (e.g., 2026-05-08 11:00:00+0000)
function date_timestamp_to_iso(timestamp,    utc_str, local_ts, tz_offset, tz_str, tz_h, tz_m) {
    tz_offset = date_tz()
    if (tz_offset == "") {
        return date___timestamp_to_utc(timestamp) "+0000"
    }

    local_ts = timestamp + tz_offset
    utc_str = date___timestamp_to_utc(local_ts)

    if (tz_offset >= 0) {
        tz_str = "+"
        tz_h = int(tz_offset / 3600)
        tz_m = (tz_offset % 3600) / 60
    } else {
        tz_str = "-"
        tz_h = int(-tz_offset / 3600)
        tz_m = (-tz_offset % 3600) / 60
    }

    return utc_str tz_str sprintf("%02d%02d", tz_h, tz_m)
}

# Internal: Date string to timestamp (UTC only)
# Format: YYYY-MM-DD HH:MM:SS
function date___utc_to_timestamp(date_str,    parts, date_part, time_part, year, month, day, hour, minute, second, total_days, y) {
    split(date_str, parts, " ")
    date_part = parts[1]
    time_part = parts[2]

    split(date_part, parts, "-")
    year = parts[1] + 0
    month = parts[2] + 0
    day = parts[3] + 0

    split(time_part, parts, ":")
    hour = parts[1] + 0
    minute = parts[2] + 0
    second = parts[3] + 0

    total_days = 0
    for (y = 1970; y < year; y++) {
        total_days += date___days_in_year(y)
    }

    for (m = 1; m < month; m++) {
        total_days += date___days_in_month(year, m)
    }

    total_days += day - 1

    return total_days * 86400 + hour * 3600 + minute * 60 + second
}

# ISO string to timestamp (UTC)
# Format: YYYY-MM-DD HH:MM:SS±HHMM (timezone optional)
function date_iso_to_timestamp(date_str,    parts, date_part, time_part, tz_str, tz_sign, tz_h, tz_m, tz_offset, ts, _p) {
    split(date_str, parts, " ")
    date_part = parts[1]

    split(parts[2], _p, /[+-]/)
    time_part = _p[1]

    if (parts[2] ~ /[+-][0-9][0-9][0-9][0-9]$/) {
        tz_str = substr(parts[2], length(_p[1]) + 1)
        tz_sign = (tz_str ~ /^-/) ? -1 : 1
        tz_h = substr(tz_str, 2, 2) + 0
        tz_m = substr(tz_str, 4, 2) + 0
        tz_offset = tz_sign * (tz_h * 3600 + tz_m * 60)
    } else {
        tz_offset = 0
    }

    ts = date___utc_to_timestamp(date_part " " time_part)
    return ts - tz_offset
}
