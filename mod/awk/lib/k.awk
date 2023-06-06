
BEGIN{  K_IFS = SUBSEP;  }
function k_ifs_set( ch ){   K_IFS = ch;             }
function k_ifs_reset(){     k_ifs_set( SUBSEP );    }
function ks( k1, k2, k3, k4, k5, k6, k7, k8, k9,    kp ){
    kp = k1
    if (k2 == "") return kp;  kp = kp K_IFS k2
    if (k3 == "") return kp;  kp = kp K_IFS k3
    if (k4 == "") return kp;  kp = kp K_IFS k4
    if (k5 == "") return kp;  kp = kp K_IFS k5
    if (k6 == "") return kp;  kp = kp K_IFS k6
    if (k7 == "") return kp;  kp = kp K_IFS k7
    if (k8 == "") return kp;  kp = kp K_IFS k8
    if (k9 == "") return kp;  kp = kp K_IFS k9
    return kp
}

# key wrap
function kw( k1, k2, k3, k4, k5, k6, k7, k8, k9,    kp ){
    kp = "\"" k1 "\""
    if (k2 == "") return kp;  kp = kp K_IFS "\"" k2 "\""
    if (k3 == "") return kp;  kp = kp K_IFS "\"" k3 "\""
    if (k4 == "") return kp;  kp = kp K_IFS "\"" k4 "\""
    if (k5 == "") return kp;  kp = kp K_IFS "\"" k5 "\""
    if (k6 == "") return kp;  kp = kp K_IFS "\"" k6 "\""
    if (k7 == "") return kp;  kp = kp K_IFS "\"" k7 "\""
    if (k8 == "") return kp;  kp = kp K_IFS "\"" k8 "\""
    if (k9 == "") return kp;  kp = kp K_IFS "\"" k9 "\""
    return kp
}
