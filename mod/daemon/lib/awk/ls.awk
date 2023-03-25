BEGIN{ DAEMON_PROC_FILEPATH = ENVIRON[ "DAEMON_PROC_FILEPATH" ]; }
{
    FP = DAEMON_PROC_FILEPATH "/" $1
    getline PID <FP
    PID = substr(PID, 6)
    getline FILEPATH <FP
    FILEPATH = substr(FILEPATH, 5)

    CMDSTR = ""
    e = ""
    while (getline line < FP) {
        CMDSTR = CMDSTR "\n" e
        e = line
    }

    if (match(e, /^CODE:/)) {
        CODE = int(substr(e, RLENGTH+1))
    } else {
        CODE = -1
        CMDSTR = CMDSTR "\n" e
    }

    CMDSTR = substr(CMDSTR, 8)
    close(FP)
}

{
    (ENVIRON["PS_ALL"] != "") ? report_all() : report_ps()
}

function report_ps(){
    if (CODE != -1) return
    printf("%s\t%s\n", PID, CMDSTR)
}

function report_all(){
    if (CODE == -1){
        printf("%s\t%d\t%s\n", PID, CODE, CMDSTR)
    } else {
        # Stopped Jobs
        if (CODE == 0) {
            printf("%s\t%d\t%s\n", PID, CODE, CMDSTR)
        } else {
            # Stopped
            printf("%s\t%d\t%s\n", PID, CODE, CMDSTR)
        }
    }
}
