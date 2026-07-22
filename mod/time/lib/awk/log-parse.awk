# log formatter
# Input: 4 lines of `times` output (shell before, child before, shell after, child after),
#   each line "<user> <sys>" in Nm N.NNNNNNs format.
# Vars: -v wall=<ms> -v bs=<begin epoch ms> -v es=<end epoch ms>
#       ENVIRON["___X_CMD_TIME_CMD"] = the command string being timed
# Output: an x-cmd-style log block, numeric columns right-aligned on the decimal point.

{
    for(i=1;i<=2;i++){
        split($i, a, "m")
        gsub(/s/, "", a[2])
        split(a[2], b, ".")
        dec_len = length(b[2])
        dec_part = b[2] + 0
        if(dec_len < 6) dec_part = dec_part * (10^(6 - dec_len))
        else if(dec_len > 6) dec_part = substr(b[2], 1, 6) + 0
        val = a[1] * 60 + b[1] + dec_part / 1000000
        if(NR==1){ if(i==1) bsu=val; else bss=val }
        if(NR==2){ if(i==1) bcu=val; else bcs=val }
        if(NR==3){ if(i==1) asu=val; else ass=val }
        if(NR==4){ if(i==1) acu=val; else acs=val }
    }
}
END{
    cu = acu - bcu; cs = acs - bcs
    su = asu - bsu; ss = ass - bss

    printf "- I|time: %s\n", ENVIRON["___X_CMD_TIME_CMD"]
    printf "  more:\n"
    printf "    real: %8.3f s = %.3f - %.3f\n",                    wall/1000, es/1000, bs/1000
    printf "    user: %8.3f s = %8.3f s (shell) + %8.3f s (child)\n", cu+su, su, cu
    printf "    sys:  %8.3f s = %8.3f s (shell) + %8.3f s (child)\n", cs+ss, ss, cs
}
