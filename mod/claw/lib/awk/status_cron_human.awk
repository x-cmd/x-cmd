function fmt_last_run(start, end,    s, e) {
    if (start == "" || start <= 0) return c_dim "—" c_end
    s = date_timestamp_to_iso(start)
    if (s == "") return c_dim "—" c_end
    s = substr(s, 1, 16)
    if (end != "" && end > 0) {
        e = date_timestamp_to_iso(end)
        if (e != "") {
            e = substr(e, 1, 16)
            return s " → " e
        }
    }
    return s
}
function fmt_cron_status(st) {
    if (st == "success") return c_green "✓" c_end
    if (st == "failed") return c_red "✗" c_end
    return c_dim "—" c_end
}
function fmt_cron_expr(expr,    parts, min, hour, day, month, dow, n) {
    if (expr == "") return ""
    n = split(expr, parts, " ")
    if (n != 5) return expr
    min = parts[1]
    hour = parts[2]
    day = parts[3]
    month = parts[4]
    dow = parts[5]

    if (min == "0" && hour != "*" && day == "*" && month == "*" && dow == "*")
        return "每天 " hour ":00"
    if (min == "0" && hour != "*" && day != "*" && month != "*" && dow == "*")
        return "每年 " month " 月 " day " 日 " hour ":00"
    if (min ~ "^\\*/" && hour == "*" && day == "*" && month == "*" && dow == "*")
        return "每 " substr(min, 3) " 分钟"
    if (hour == "*" && day == "*" && month == "*" && dow == "*")
        return "每小时第 " min " 分钟"
    return expr
}
BEGIN { first = 1 }
{
    if (first) { first = 0; next }
    name = $1
    if (name == "") next
    expr = $2
    desc = $3
    last_start = $5
    last_end = $6
    last_status = $7

    printf "  ● %s%s%s\n", c_value, name, c_end
    printf "      %s%-11s%s %s\n", c_key, "Schedule:", c_end, expr
    printf "      %s%-11s%s %s\n", c_key, "Frequency:", c_end, fmt_cron_expr(expr)
    printf "      %s%-11s%s %s\n", c_key, "Description:", c_end, (desc != "" ? desc : c_dim "—" c_end)
    printf "      %s%-11s%s %s\n", c_key, "Last run:", c_end, fmt_last_run(last_start, last_end)
    if (last_status != "") {
        printf "      %s%-11s%s %s %s\n", c_key, "Status:", c_end, fmt_cron_status(last_status), last_status
    } else {
        printf "      %s%-11s%s %s\n", c_key, "Status:", c_end, c_dim "—" c_end
    }
    printf "\n"
}
