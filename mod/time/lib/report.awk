
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
}

{
    time[ count ++ ] = $0
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

    if (output == "avg") {
        printf "%9.3f\n", avg
    } else if (output == "csv") {
        printf "count,sum,offset,min,max,second,third,avg,median,stddev\n"
        printf "%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev
    } else if (output == "csv0") {
        printf "%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev
    } else if (output == "tsv") {
        printf "count\tsum\toffset\tmin\tmax\tsecond\tthird\tavg\tmedian\tstddev\n"
        printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev
    } else if (output == "tsv0") {
        printf "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", count, sum, CALIBRATION_OFFSET, min, max, second, third, avg, median, stddev
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
    }
}