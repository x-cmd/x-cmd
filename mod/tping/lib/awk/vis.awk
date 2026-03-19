
function print_xsv_header( S ){
    printf( \
        "%s" S "%s" S "%s" S "%s" S  "%s" S  "%s" S   "%s" S "%s\n", \
        "datetime", "seq", "dns", "con", "lip", "lport", "ip",  "port"      );
}


BEGIN{
    sample_init()

    if        ( mode == "csv" ) {       print_xsv_header( ","  );       item_fmt = "%s\t%s\t%s\t%s\t%s\n"
    } else if ( mode == "tsv" ) {       print_xsv_header( "\t" );       item_fmt = "%s,%s,%s,%s,%s\n"
    } else if ( mode == "bar" ) {       printf("\n\n\n\n\n\n\n")
    } else if ( mode == "heatmap" ) {   printf("\n\n\n\n\n\n\n")
    } else {
        item_fmt        = "%s %5d  %7.3f %8.3f %15s %d   %16s %d"
        item_fmt_fail   = "%s %5d  %7s %8s %15s %d   %16s %d"
        printf("\n\n\n\n\n")
        INDENT_SPACE = "  "
    }

    if        (mode == "csv")           fmt = "%s,%d,%f,%f,%s,%d,%s,%d\n"
    else if   (mode == "tsv")           fmt = "%s\t%d\t%f\t%f\t%s\t%d\t%s\t%d\n"
    else                                fmt = "%s\t%d\t%8.3f\t%8.3f\t%16s\t%6s\t%16s\t%6s\n"
}

function print_auto( ts, seq, dns, time, local_ip, local_port, ip, port ){
    sample( time )

    if      (mode == "verbose" )    print_verbose(      ts, seq, dns, time, local_ip, local_port, ip, port )
    else if (mode == "heatmap" )    print_heatmap(      ts, seq, dns, time, local_ip, local_port, ip, port )
    else if (mode == "bar" )        print_bar(          ts, seq, dns, time, local_ip, local_port, ip, port )
    else                            printf(fmt,         ts, seq, dns, time, local_ip, local_port, ip, port ); fflush();
}


function get_verbose_header(){
    return "\033[36;1;7m" sprintf( \
        "%9s %5s  %7s %8s %19s %19s", \
        "datetime", "seq", "dns", "con", "local-ip:port", "remote-ip:port"      )
}

function print_verbose( ts, seq, dns, time, local_ip, local_port, ip, port   ){
    LINEDATA =  sprintf( colrmap( time ) item_fmt "\033[0m" , substr(ts, 5), seq, dns, time, local_ip, local_port, ip, port )
    if ( time == -1 ) LINEDATA = sprintf( colrmap( time ) item_fmt_fail "\033[0m", substr(ts, 5), seq, "XXX", "XXX", local_ip, local_port, ip, port )
    LINEDATA    = line_dec_cleanup( INDENT_SPACE LINEDATA )

    HEADER_INFO = line_dec_cleanup( INDENT_SPACE get_verbose_header() )
    REPORT_INFO = line_dec_cleanup( INDENT_SPACE sample_report( time ) "FAIL=" sprintf("%3d", sample_fail) )

    printnl_fflush( "\n\033[5A\r" LINEDATA BLANK_80_LN HEADER_INFO BLANK_80_LN REPORT_INFO  )
}

function get_bottom_line( seq, dns, time, local_ip, local_port, ip, port ){
    BOTTOM_INFO1 = sprintf( "SEQ = %5d | DNS= %6.3f ms | FAIL=%-3d", seq, dns, sample_fail )
    BOTTOM_INFO1 = line_dec_cleanup( "    " INDENT_SPACE "\033[44m" BOTTOM_INFO1 "\033[0m" )

    BOTTOM_INFO2 = sprintf( "FROM: %s:%d", local_ip, local_port )
    BOTTOM_INFO2 = line_dec_cleanup( "    " INDENT_SPACE "\033[0m" BOTTOM_INFO2 "\033[0m" )

    BOTTOM_INFO3 = sprintf( "TO:   %s:%d", ip, port )
    BOTTOM_INFO3 = line_dec_cleanup( "    " INDENT_SPACE "\033[0m" BOTTOM_INFO3 "\033[0m" )

    return BOTTOM_INFO1 BOTTOM_INFO2 BOTTOM_INFO3
}

function print_bar( ts, seq, dns, time, local_ip, local_port, ip, port,  COLR ){
    if ((seq % 50) == 0) {  LINEDATA = BLANK_80 "\033[2m" sprintf("%9s", substr(ts, 5)) " \033[0m"; printnl_fflush("\n"); }

    LINEDATA = LINEDATA colrmap( time ) barmap2( time )

    BOTTOM = get_bottom_line( seq, dns, time, local_ip, local_port, ip, port )

    REPORT_INFO = line_dec_cleanup( "    "  INDENT_SPACE sample_report( time ) )

    printnl_fflush( "\033[7A" LINEDATA "\n" BLANK_80_LN BLANK_80_LN REPORT_INFO BOTTOM )
}

function print_heatmap( ts, seq, dns, time, local_ip, local_port, ip, port,   e ){
    if ((seq % 10) == 0) {  LINEDATA = BLANK_80 "\033[2m" sprintf("%9s", substr(ts, 5)) " \033[0m"; printnl_fflush("\n"); }

    if ( time == -1 )   e = "\033[40;7m" colrmap( time ) " XXX " "\033[0m"
    else                e = "\033[40;7m" colrmap( time ) sprintf("%4d ", time) "\033[0m"

    LINEDATA = LINEDATA e

    BOTTOM = get_bottom_line( seq, dns, time, local_ip, local_port, ip, port )

    REPORT_INFO = line_dec_cleanup( "    " INDENT_SPACE sample_report( time ) )

    printnl_fflush( "\033[7A" LINEDATA "\n" BLANK_80_LN BLANK_80_LN REPORT_INFO BOTTOM )
}
