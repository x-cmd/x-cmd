BEGIN{
  ROWS = int(ENVIRON[ "LINES" ])
  ROWS = int(ROWS/3)
  ROWS = ( ROWS > 5 ) ? ROWS : 5
  SIZE = int(ENVIRON[ "SIZE" ])
  SIZE = (SIZE <= 0) ? ROWS : SIZE

  PREFIX = ENVIRON[ "PREFIX" ]
  PROMPT_RUN = ENVIRON[ "PROMPT_RUN" ]
  PROMPT_END = ENVIRON[ "PROMPT_END" ]

  _errcode = ui_rotate_fromstdin( SIZE, PREFIX, PROMPT_RUN, PROMPT_END )
}

END{
  exit( _errcode )
}
