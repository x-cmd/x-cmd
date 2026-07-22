# cmp report formatter
# Input (TSV, 17 fields per line):
#   cmd count sum offset min max second third avg median stddev \
#   child_user child_sys shell_user shell_sys user sys
# Select output via: -v mode=<csv|csv0|tsv|tsv0|tty|yml>

BEGIN{
    FS = "\t"
    if (mode == "csv") {
        print "cmd,count,sum,offset,min,max,second,third,avg,median,stddev,child_user,child_sys,shell_user,shell_sys,user,sys"
    } else if (mode == "tsv") {
        print "cmd\tcount\tsum\toffset\tmin\tmax\tsecond\tthird\tavg\tmedian\tstddev\tchild_user\tchild_sys\tshell_user\tshell_sys\tuser\tsys"
    }
}

{
    if ($0 == "") next
    if (mode == "csv" || mode == "csv0") {
        c = $1
        gsub(/"/, "\"\"", c)
        printf "\"%s\",%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", c, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
    } else if (mode == "tsv" || mode == "tsv0") {
        print
    } else if (mode == "tty") {
        printf "# %s\n", $1
        printf "  avg:    %8.3f ± %.3f ms   median: %8.3f ms   total: %8.3f ms   [%d runs]\n", $9, $11, $10, $3, $2
        printf "  user:   %.3f ms (shell: %.3f + child: %.3f)\n", $16, $14, $12
        printf "  sys:    %.3f ms (shell: %.3f + child: %.3f)\n", $17, $15, $13
    } else if (mode == "yml") {
        printf "- cmd: \"%s\"\n", $1
        printf "  count: %d\n", $2
        printf "  sum: %.3f\n", $3
        printf "  offset: %.3f\n", $4
        printf "  min: %.3f\n", $5
        printf "  max: %.3f\n", $6
        printf "  second: %.3f\n", $7
        printf "  third: %.3f\n", $8
        printf "  avg: %.3f\n", $9
        printf "  median: %.3f\n", $10
        printf "  stddev: %.3f\n", $11
        printf "  child_user: %.3f\n", $12
        printf "  child_sys: %.3f\n", $13
        printf "  shell_user: %.3f\n", $14
        printf "  shell_sys: %.3f\n", $15
        printf "  user: %.3f\n", $16
        printf "  sys: %.3f\n", $17
    }
}
