NR == 1 { next }

{
  rows[NR,1] = $1
  rows[NR,2] = $2
  rows[NR,3] = $3

  w[1] = (length($1) > w[1] ? length($1) : w[1])
  w[2] = (length($2) > w[2] ? length($2) : w[2])
  w[3] = (length($3) > w[3] ? length($3) : w[3])
  maxNR = NR
}

END {
  GRAY   = "\033[90m"
  GREENB = "\033[1;32m"
  YELLOW = "\033[33m"
  RESET  = "\033[0m"

  for (i = 2; i <= maxNR; i++) {
    printf "%s%-*s%s  %s%-*s%s  %s%-*s%s\n",
      GRAY,   w[1], rows[i,1], RESET,
      GREENB, w[2], rows[i,2], RESET,
      YELLOW, w[3], rows[i,3], RESET
  }
}