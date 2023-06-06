BEGIN {
    if (ARGV[1] !="")  print jiter_tokenized_normalized(ARGV[1])
}

{
    jiter_tokenized_normalized( $0 )
    fflush()
}
