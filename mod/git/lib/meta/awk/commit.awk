
function handle_email( e ){
    return substr(e, 2, length(e)-2)
}

BEGIN{
    on = 1
    # RS = "(\\r)|(\\n)|(\\r\\n)"
    RS = "(\n)|(\r\n)"
    printf( "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", "sha", "message", "tree_sha", "author_name", \
    "author_email", "author_date", "committer_name", "committer_email", "committer_date", "parent_sha", "gpgsig")
}

{
    while (on) {
        run()
    }
}

function run(){
    gsub("^\0", "", $1)
    hash = $1;    if (! getline) { on = 0; return 1; }

    tree_id = parent_id = gpgsig = author_name = author_email = author_time = author_timezone = committer_name = committer_email = committer_time = committer_timezone = msg = ""

    while (1) {
        if ($1 == "tree") {
            tree_id = $2
            getline
        } else if ($1 == "parent") {
            parent_id = ( parent_id == "" ) ? $2 : parent_id "," $2
            getline
        } else if ($1 == "gpgsig") {
            gpgsig = $0 "\n"
            getline
            while ($0 ~ "^[ ]") {
                gpgsig = gpgsig str_trim_left($0) "\n"
                getline
            }
        } else if ($1 == "author"){
            author_name = $2;
            author_email = handle_email($3);
            author_time = $4;
            author_timezone = $5;
            getline
        } else if ($1 == "committer") {
            committer_name = $2;
            committer_email = handle_email($3);
            committer_time = $4
            committer_timezone = $5
            getline
        } else break
    }

    getline

    while ($0 ~ "^[ ]+") {
        msg = msg substr($0, 5, length($0)-4) "\n"
        if (!getline) {
            on = 0
            break
        }
    }

    msg = str_remove_esc( substr(msg, 1, length(msg)-1) )
    author_date = timestamp_to_date(author_time) author_timezone
    committer_date = timestamp_to_date(committer_time) committer_timezone

    printf( \
        "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
        csv_quote(hash), csv_quote(msg),
        csv_quote(tree_id),
        csv_quote(author_name), csv_quote(author_email), csv_quote(author_date),
        csv_quote(committer_name), csv_quote(committer_email),csv_quote(committer_date),
        csv_quote(parent_id),
        csv_quote(str_trim_right(gpgsig)) );
    # exit(0)
}
