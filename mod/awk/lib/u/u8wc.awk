function u8wc_isascii(){        return U8WC_TYPE ~ /^ascii/;    }
function u8wc_name( name ){     return U8WC_NAME == name;       }
function u8wc_type( type ){     return U8WC_TYPE == type;       }

function u8wc( ch ) {
    if (ch == "")  ch = "\r"

    if (_utf8_l != 0) {
        _wchar_buffer = _wchar_buffer ch
        _utf8_l --
        if (_utf8_l == 0) {
            U8WC_NAME   = ""
            U8WC_TYPE   = U8WC_TYPE_UTF8
            U8WC_VALUE  = _wchar_buffer
            return true
        } else {
            return false
        }
    }

    U8WC_ORD = ord( ch )

    if ( 0 == U8WC_ESC_MODE ) {
        if (U8WC_ORD == 27) {   # "\033"
            U8WC_ESC_MODE = 1
            return false
        }

        _wchar_buffer =ch
        _utf8_l = ord_leading1( U8WC_ORD )
        if ( 0 == _utf8_l ) {
            U8WC_NAME   = ""
            # U8WC_TYPE =U8WC_TYPE_ASCII
            U8WC_VALUE  =  ch
            U8WC_LEN    = 1
            u8wc_handle_ascii_name_type( ch, U8WC_ORD )
            return true
        } else {
            U8WC_LEN    =_utf8_l
            _utf8_l -= 1
            return false
        }
    }

    if ( 1 == U8WC_ESC_MODE ) {
        if (ch == "q") {
            U8WC_NAME     =  "QUIT"     # Original is quit
            U8WC_TYPE     =  U8WC_TYPE_SPECIAL
            U8WC_VALUE    =  "\033" ch
            U8WC_LEN      =  2
            U8WC_ESC_MODE =  0
            return true
        }

        if ((ch == "[") || (ch == "O")) {
            U8WC_ESC_MODE = 2
            return false
        }
    }

    if ( 2 == U8WC_ESC_MODE ) {
        U8WC_ESC_MODE = 0

        u8wc_handle_033_name( ch )
        U8WC_TYPE   =  U8WC_TYPE_SPECIAL
        U8WC_VALUE  =  "\033[" ch
        U8WC_LEN    =  3
        return true
    }

}

function u8wc_handle_033_name( ch ) {
    if (ch == "A")              U8WC_NAME  = U8WC_NAME_UP
    else if (ch == "B")         U8WC_NAME  = U8WC_NAME_DOWN
    else if (ch == "C")         U8WC_NAME  = U8WC_NAME_RIGHT
    else if (ch == "D")         U8WC_NAME  = U8WC_NAME_LEFT
    else                        U8WC_NAME  = ""
}

function u8wc_handle_ascii_name_type( ch, ordv ) {
    if (ordv <= 27)             U8WC_TYPE   = U8WC_TYPE_CONTROL
    else if (ordv <= 32)        U8WC_TYPE   = U8WC_TYPE_SEPERATOR
    else if (ordv <= 47)        U8WC_TYPE   = U8WC_TYPE_SYMBOL
    else if (ordv <= 57)        U8WC_TYPE   = U8WC_TYPE_DIGIT
    else if (ordv <= 64)        U8WC_TYPE   = U8WC_TYPE_SYMBOL
    else if (ordv <= 90)        U8WC_TYPE   = U8WC_TYPE_UPPER
    else if (ordv <= 96)        U8WC_TYPE   = U8WC_TYPE_SYMBOL
    else if (ordv <= 122)       U8WC_TYPE   = U8WC_TYPE_LOWER
    else if (ordv <= 126)       U8WC_TYPE   = U8WC_TYPE_SYMBOL
    else if (ordv <= 127)       U8WC_TYPE   = U8WC_TYPE_CONTROL

    U8WC_NAME  =U8WC_NAME_ASCII_MAP[ ordv ]
}

BEGIN{
    U8WC_TYPE = ""
    U8WC_ESC_MODE = 0
    true = 1
    false = 0

    U8WC_TYPE_UTF8              = "utf8"

    # U8WC_TYPE_ASCII         ="ascii"
    U8WC_TYPE_SPECIAL           =    "ascii-special"
    U8WC_TYPE_CONTROL           =    "ascii-control"
    U8WC_TYPE_SYMBOL            =    "ascii-symbol"
    U8WC_TYPE_SEPERATOR         =    "ascii-seperator"
    U8WC_TYPE_DIGIT             =    "ascii-digit"
    U8WC_TYPE_UPPER             =    "ascii-upper"
    U8WC_TYPE_LOWER             =    "ascii-lower"
                                                                                    #git bash              WSL                  mac
    U8WC_NAME_ASCII_MAP[ 0 ]    =    U8WC_NAME_NULL                 =    "NUL"
    U8WC_NAME_ASCII_MAP[ 1 ]    =    U8WC_NAME_START_OF_HEADLINE    =    "SOH"       #Ctrl-A                Ctrl-A               Ctrl-A
    U8WC_NAME_ASCII_MAP[ 2 ]    =    U8WC_NAME_START_OF_TEXT        =    "STX"       #Ctrl-B                Ctrl-B               Ctrl-B
    U8WC_NAME_ASCII_MAP[ 3 ]    =    U8WC_NAME_END_OF_TEXT          =    "EXT"
    U8WC_NAME_ASCII_MAP[ 4 ]    =    U8WC_NAME_END_OF_TRANSIMISSION =    "EOT"       #CTrl-D                Ctrl-D               Crtl-D
    U8WC_NAME_ASCII_MAP[ 5 ]    =    U8WC_NAME_ENQUIRY              =    "ENQ"       #Ctrl-E                Ctrl-E               Ctrl-E
    U8WC_NAME_ASCII_MAP[ 6 ]    =    U8WC_NAME_ACKNOWLEDGE          =    "ACK"       #Crtl-F
    U8WC_NAME_ASCII_MAP[ 7 ]    =    U8WC_NAME_BELL                 =    "BEL"       #Crtl-G                Crtl-G               Crtl-G
    U8WC_NAME_ASCII_MAP[ 8 ]    =    U8WC_NAME_BACKSPACE            =    "BS"        #Ctrl-H                Ctrl-H               Crtl-H
    U8WC_NAME_ASCII_MAP[ 9 ]    =    U8WC_NAME_HORIZONTAL_TAB       =    "HT"
    U8WC_NAME_ASCII_MAP[ 10 ]   =    U8WC_NAME_NEW_LINE             =    "LF"
    U8WC_NAME_ASCII_MAP[ 11 ]   =    U8WC_NAME_VERTICAL_TAB         =    "VT"        #Ctrl-K                                     Ctrl-K
    U8WC_NAME_ASCII_MAP[ 12 ]   =    U8WC_NAME_NEW_PAGE             =    "FF"        #Crtl-L                                     Ctrl-L
    U8WC_NAME_ASCII_MAP[ 13 ]   =    U8WC_NAME_CARRIAGE_RETURN      =    "CR"        #Crtl-J/M                                   Crtl-J/M
    U8WC_NAME_ASCII_MAP[ 14 ]   =    U8WC_NAME_SHIFT_OUT            =    "SO"        #Ctrl-N                Ctrl-N               Ctrl-N
    U8WC_NAME_ASCII_MAP[ 15 ]   =    U8WC_NAME_SHIFT_IN             =    "SI"        #Ctrl-O                                     nothing
    U8WC_NAME_ASCII_MAP[ 16 ]   =    U8WC_NAME_DATA_LINK_ESCAPE     =    "DLE"       #Ctrl-P                                     Ctrl-P
    U8WC_NAME_ASCII_MAP[ 17 ]   =    U8WC_NAME_DEVICE_CONTROL_1     =    "DC1"
    U8WC_NAME_ASCII_MAP[ 18 ]   =    U8WC_NAME_DEVICE_CONTROL_2     =    "DC2"       #Ctrl-R                                     Ctrl-R
    U8WC_NAME_ASCII_MAP[ 19 ]   =    U8WC_NAME_DEVICE_CONTROL_3     =    "DC3"
    U8WC_NAME_ASCII_MAP[ 20 ]   =    U8WC_NAME_DEVICE_CONTROL_4     =    "DC4"       #Ctrl-T                Ctrl-T               Ctrl-T
    U8WC_NAME_ASCII_MAP[ 21 ]   =    U8WC_NAME_NEGATIVE_ACKNOWLEDGE =    "NAK"       #Ctrl-U                Ctrl-u               Ctrl-u
    U8WC_NAME_ASCII_MAP[ 22 ]   =    U8WC_NAME_SYNCHRONOUS_IDLE     =    "SYN"       #Ctrl-V                                     Ctrl-v
    U8WC_NAME_ASCII_MAP[ 23 ]   =    U8WC_NAME_END_OF_TRANS_BLOCK   =    "ETB"       #Ctrl-W                Ctrl-W               Ctrl-W
    U8WC_NAME_ASCII_MAP[ 24 ]   =    U8WC_NAME_CANCEL               =    "CAN"       #Ctrl-X                                     Ctrl-X
    U8WC_NAME_ASCII_MAP[ 25 ]   =    U8WC_NAME_END_OF_MEDIUM        =    "EM"        #Ctrl-Y                                     exit
    U8WC_NAME_ASCII_MAP[ 26 ]   =    U8WC_NAME_SUBSTITUTE           =    "SUB"
    U8WC_NAME_ASCII_MAP[ 27 ]   =    U8WC_NAME_END_OF_ESCAPE        =    "ESC"
    U8WC_NAME_ASCII_MAP[ 29 ]   =    U8WC_NAME_GROUP_SEPARATOR      =    "GS"        #Ctrl-}                Ctrl-}               Ctrl-}
    U8WC_NAME_ASCII_MAP[ 30 ]   =    U8WC_NAME_RECORD_SEPARATOR     =    "RS"        #Ctrl-^                                     nothing
    U8WC_NAME_ASCII_MAP[ 31 ]   =    U8WC_NAME_UNIT_SEPARATOR       =    "US"        #Ctrl-?                Ctrl-?               nothing

    U8WC_NAME_ASCII_MAP[ 127 ]  =    U8WC_NAME_DELETE               =    "DEL"

    U8WC_NAME_UP                        = "UP"
    U8WC_NAME_DOWN                      = "DOWN"
    U8WC_NAME_LEFT                      = "LEFT"
    U8WC_NAME_RIGHT                     = "RIGHT"
}
