BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="SELECT,FROM,WHERE,INSERT,INTO,VALUES,UPDATE,SET,DELETE,CREATE,TABLE,DROP,ALTER,ADD,COLUMN,INDEX,VIEW,JOIN,INNER,LEFT,RIGHT,OUTER,FULL,CROSS,ON,AND,OR,NOT,IN,IS,NULL,LIKE,BETWEEN,EXISTS,DISTINCT,GROUP,BY,ORDER,ASC,DESC,HAVING,LIMIT,OFFSET,UNION,ALL,AS,CASE,WHEN,THEN,ELSE,END,PRIMARY,KEY,FOREIGN,REFERENCES,CONSTRAINT,DEFAULT,CHECK,UNIQUE,AUTO_INCREMENT,IF,BEGIN,COMMIT,ROLLBACK,GRANT,REVOKE"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    TYPE_LIST="INT,INTEGER,BIGINT,SMALLINT,TINYINT,FLOAT,DOUBLE,DECIMAL,NUMERIC,VARCHAR,CHAR,TEXT,BLOB,DATE,DATETIME,TIMESTAMP,TIME,BOOLEAN,BOOL,SERIAL"
    TYPE_REPR = convert_keywordlist_to_keywordrepr( TYPE_LIST )

    SYMBOL_LIST="!=,<>,<=,>=,=,<,>"
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # SQL -- comment
    match( text, "--[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    gsub(TYPE_REPR, TYPE_COLOR "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
