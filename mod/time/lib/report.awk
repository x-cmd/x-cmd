
function time_cal_offset(){
    o0 = ENVIRON[ "___X_CMD_TIME_OFFSET0" ]
    o1 = ENVIRON[ "___X_CMD_TIME_OFFSET1" ]
    o2 = ENVIRON[ "___X_CMD_TIME_OFFSET2" ]

    if (o1 > o0) {
        return o2 - (o1 - o0)
    } else {
        return o2
    }
}

BEGIN{
    getline
    begin = $0

    CALIBRATION_OFFSET = time_cal_offset()

    times_idx = 0
}

# Detect times output (contains "m" and "s")
/m.*s/{
    split($0, a, " ")
    call = int(times_idx / 2)
    pair = times_idx % 2  # 0=shell line, 1=child line

    if(call == 0){
        # init: store as prev
        if(pair == 0){
            prev_shell_user = parse_time(a[1])
            prev_shell_sys = parse_time(a[2])
        } else {
            prev_child_user = parse_time(a[1])
            prev_child_sys = parse_time(a[2])
        }
    } else {
        # compute delta
        if(pair == 0){
            curr_shell_user = parse_time(a[1])
            curr_shell_sys = parse_time(a[2])
            total_shell_user += curr_shell_user - prev_shell_user
            total_shell_sys += curr_shell_sys - prev_shell_sys
            prev_shell_user = curr_shell_user
            prev_shell_sys = curr_shell_sys
        } else {
            curr_child_user = parse_time(a[1])
            curr_child_sys = parse_time(a[2])
            total_child_user += curr_child_user - prev_child_user
            total_child_sys += curr_child_sys - prev_child_sys
            prev_child_user = curr_child_user
            prev_child_sys = curr_child_sys
        }
    }
    times_idx++
    next
}

/^[0-9]/{
    time[ count ++ ] = $0
}

function parse_time(s){
    # Format: 0m1.234567s or 0m1s
    split(s, t, "m")
    gsub(/s/, "", t[2])
    split(t[2], u, ".")
    dec_len = length(u[2])
    dec = u[2] + 0
    if(dec_len < 6){
        dec = dec * (10^(6 - dec_len))
    } else if(dec_len > 6){
        dec = substr(u[2], 1, 6) + 0
    }
    return t[1] * 60 + u[1] + dec / 1000000
}

END{
    if (count < 1) {
        print "count:", count
        exit
    }

    for (i = 0; i < count; i++) {
        if (i == 0) {
            diff[i] = (time[i] - begin) * 1000
        } else {
            diff[i] = (time[i] - time[i-1]) * 1000
        }
    }

    for (i = 0; i < count; i++) {
        diff[i] = diff[i] - CALIBRATION_OFFSET
        if (diff[i] < 0) diff[i] = 0
    }

    if (batch != "") {
        for (i = 0; i < count; i++) {
            diff[i] = diff[i] / batch
        }
    }

    # Sort to find min/max/median
    for (i = 0; i < count; i++) {
        for (j = i + 1; j < count; j++) {
            if (diff[i] > diff[j]) {
                tmp = diff[i]; diff[i] = diff[j]; diff[j] = tmp
            }
        }
    }

    sum = 0
    for (i = 0; i < count; i++) {
        sum += diff[i]
    }
    avg = sum / count

    # Standard deviation
    sqsum = 0
    for (i = 0; i < count; i++) {
        sqsum += (diff[i] - avg) * (diff[i] - avg)
    }
    stddev = sqrt(sqsum / count)

    min = diff[0]
    max = diff[count-1]
    second = (count >= 2) ? diff[count-2] : max
    third = (count >= 3) ? diff[count-3] : second
    median = (count % 2 == 1) ? diff[int(count/2)] : (diff[count/2-1] + diff[count/2]) / 2

    # Compute CPU averages: (total - init) / (iterations)
    n = int(times_idx / 2) - 1
    if(n > 0){
        child_user = (total_child_user / n) * 1000
        child_sys = (total_child_sys / n) * 1000
        shell_user = (total_shell_user / n) * 1000
        shell_sys = (total_shell_sys / n) * 1000
        user = child_user + shell_user
        sys = child_sys + shell_sys
    }

    if (output == "avg") {
        printf "%9.3f\n", avg
    } else if (output == "csv") {
        printf "count,sum,offset,min,max,second,third,avg,median,stddev,child_user,child_sys,shell_user,shell_sys,user,sys\n"
        printf "%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev, child_user, child_sys, shell_user, shell_sys, user, sys
    } else if (output == "csv0") {
        printf "%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev, child_user, child_sys, shell_user, shell_sys, user, sys
    } else if (output == "tsv") {
        printf "count\tsum\toffset\tmin\tmax\tsecond\tthird\tavg\tmedian\tstddev\tchild_user\tchild_sys\tshell_user\tshell_sys\tuser\tsys\n"
        printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev, child_user, child_sys, shell_user, shell_sys, user, sys
    } else if (output == "tsv0") {
        printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev, child_user, child_sys, shell_user, shell_sys, user, sys
    } else if (output == "yml") {
        printf "count: %d\n", count
        printf "sum: %.3f\n", sum
        printf "offset: %.3f\n", CALIBRATION_OFFSET
        printf "min: %.3f\n", min
        printf "max: %.3f\n", max
        printf "second: %.3f\n", second
        printf "third: %.3f\n", third
        printf "avg: %.3f\n", avg
        printf "median: %.3f\n", median
        printf "stddev: %.3f\n", stddev
        printf "child_user: %.3f\n", child_user
        printf "child_sys: %.3f\n", child_sys
        printf "shell_user: %.3f\n", shell_user
        printf "shell_sys: %.3f\n", shell_sys
        printf "user: %.3f\n", user
        printf "sys: %.3f\n", sys
    } else {
        printf "count:   %9d\n", count
        printf "total:   %9.3f ms\n", sum
        printf "offset:  %9.3f ms\n", CALIBRATION_OFFSET
        printf "min:     %9.3f ms\n", min
        printf "max:     %9.3f ms\n", max
        printf "second:  %9.3f ms\n", second
        printf "third:   %9.3f ms\n", third
        printf "avg:     %9.3f ms\n", avg
        printf "median:  %9.3f ms\n", median
        printf "stddev:  %9.3f ms\n", stddev
        printf "child_user: %.3f ms\n", child_user
        printf "child_sys: %.3f ms\n", child_sys
        printf "shell_user: %.3f ms\n", shell_user
        printf "shell_sys: %.3f ms\n", shell_sys
        printf "user: %.3f ms\n", user
        printf "sys: %.3f ms\n", sys
    }
}