BEGIN{
    FS = "\t"
}

function present_(data,  i, j, l, m, line, linearr, section){

    l = split(data, linearr, "\\n")
    for (i=1; i<=l; ++i) {
        line = linearr[i]

        m = split(line, part, "，")

        if (m==2){
            printf("%35s%s\r", "", part[2])
            printf("%-30s\n", part[1] "，")

            continue
        }

        printf("%s\n", line)
    }

}

function present(data) {
    printf("\033[36m");
    # present_(data)
    #  ○ ◍
    gsub(/\\n/, "\n\n  • ", data)
    print("  • " data)
    printf("\033[0m\n");
}

NR==ENVIRON["a"]{

    if (NF==2) {
        printf("\n  \033[2m[id=%d]\033[0m\n", $1);
    } else if (NF==3) {
        printf("\n  \033[34m%s\033[2m[id=%d]\033[0m\n", $2, $1);
    } else if (NF==4) {
        printf("\n  \033[34m%s\033[32m    %s  \033[2m[id=%d]\033[0m\n", $2, $3, $1);
    } else {
        printf("\n  \033[34m%s\033[32m    %s %s  \033[2m[id=%d]\033[0m\n", $2, $3, $4, $1);
    }

    data = $NF
    # gsub(/[《》、：]/, "", data)
    # gsub(/[，？]/,  " ，     ", data)

    printf("\n")

    present( data );

    exit(0)

}
