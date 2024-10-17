
function trim_key( e ) {    gsub("^[^=]+=", "", e);  gsub("ms", "", e); return e;  }

BEGIN{
    NORMAL_FORMAT = "%5d  %3d %5d %20s  %9s"
}

function get_verbose_header( _fmt ){
    _fmt = "\033[34;47;7m" "%5s %4s %5s %20s  %9s"
    return sprintf( _fmt , "SEQ", "BYTE", "TTL", "IP", "TIME(ms)" );
}

function print_verbose( seq, byte, ttl, ip, time   ){
    LINEDATA =  sprintf( colrmap( time ) NORMAL_FORMAT "\033[0m" , seq, byte, ttl, ip, time )
    if ( time == -1 ) LINEDATA = sprintf( colrmap( time ) NORMAL_FORMAT "\033[0m" , seq, byte, ttl, ip, "XXX" )
    LINEDATA    = line_dec_cleanup( INDENT_SPACE LINEDATA )

    # BOTTOM_INFO = line_dec_cleanup( INDENT_SPACE sprintf( "%-16s TTL=%-3d BYTE=%-3d SEQ=%-5d FAIL=%-3d", ip, ttl, byte, seq, sample_fail ) )

    HEADER_INFO = line_dec_cleanup( INDENT_SPACE get_verbose_header() )
    REPORT_INFO = line_dec_cleanup( INDENT_SPACE sample_report( time ) "FAIL =" sprintf("%3d", sample_fail) )

    printnl_fflush( "\n\033[5A\r" LINEDATA BLANK_80_LN HEADER_INFO BLANK_80_LN REPORT_INFO   )
}

function print_bar( seq, byte, ttl, ip, time,  COLR ){
    if (( (chartcount++) % 50) == 0) {  LINEDATA = BLANK_80 "\033[2m" sprintf("%5d", seq) " \033[0m"; printnl_fflush("\n"); }

    LINEDATA = LINEDATA colrmap( time ) barmap2( time )

    BOTTOM_INFO = sprintf( "%-16s TTL=%-3d BYTE=%-3d SEQ=%-5d FAIL=%-3d", ip, ttl, byte, seq, sample_fail )
    BOTTOM_INFO = line_dec_cleanup( INDENT_SPACE "\033[44m" BOTTOM_INFO "\033[0m" )

    REPORT_INFO = line_dec_cleanup( INDENT_SPACE sample_report( time ) )

    printnl_fflush( "\033[5A" LINEDATA "\n" BLANK_80_LN BLANK_80_LN REPORT_INFO BOTTOM_INFO )
}

function print_heatmap( seq, byte, ttl, ip, time,   e ){
    if (( (chartcount ++ ) % 10) == 0) {  LINEDATA = BLANK_80 "\033[2m" sprintf("%5d", seq) " \033[0m"; printnl_fflush("\n"); }

    if ( time == -1 )   e = "\033[40;7m" colrmap( time ) " XXX " "\033[0m"
    else                e = "\033[40;7m" colrmap( time ) sprintf("%4d ", time) "\033[0m"

    LINEDATA = LINEDATA e

    BOTTOM_INFO = sprintf( "%-16s TTL=%-3d BYTE=%-3d SEQ=%-5d FAIL=%-3d", ip, ttl, byte, seq, sample_fail )
    BOTTOM_INFO = line_dec_cleanup( INDENT_SPACE "\033[44m" BOTTOM_INFO "\033[0m" )

    REPORT_INFO = line_dec_cleanup( INDENT_SPACE sample_report( time ) )

    printnl_fflush( "\033[5A" LINEDATA "\n" BLANK_80_LN BLANK_80_LN REPORT_INFO BOTTOM_INFO )
}

function print_xsv_header( S ){     printf("%s" S "%s" S "%s" S "%s" S S "%s\n", "seq", "byte", "ttl", "ip", "time"); }
BEGIN{
    sample_init()

    if        ( mode == "tsv" ) {       print_xsv_header( "\t"  );       item_fmt = "%s\t%s\t%s\t%s\t%s\n"
    } else if ( mode == "csv" ) {       print_xsv_header( "," );         item_fmt = "%s,%s,%s,%s,%s\n"
    } else if ( mode == "bar" ) {       printf("\n\n\n\n\n")
    } else if ( mode == "heatmap" ) {   printf("\n\n\n\n\n")
    } else if ( mode == "verbose" ) {
        item_fmt = "%16s    %2d    %3d   %4d   %9s"
        INDENT_SPACE = "  "
        printf("\n\n\n\n\n")
    }
}

function print_auto( seq, byte, ttl, ip, time ){
    sample( time )

    if      ( mode == "bar" )       print_bar(          seq, byte, ttl, ip, time )
    else if ( mode == "verbose" )   print_verbose(      seq, byte, ttl, ip, time )
    else if ( mode == "heatmap" )   print_heatmap(      seq, byte, ttl, ip, time )
    else                            printf(item_fmt,    seq, byte, ttl, ip, time )
}
