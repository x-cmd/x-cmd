NR==1 { PKG_NAME = $0 }
NR==2 { VERSION_NAME = $0 }
NR==3 { OSARCH = $0 }
NR==4 { PKG_RAWPATH = $0 }
NR==5 { NET_REGION = $0 }

NR==6 { meta_json = $0 }
NR==7 {
    version_json = $0
    parse_pkg_meta_json( jobj, PKG_NAME, meta_json )
    parse_pkg_version_json( jobj, PKG_NAME, version_json )

    pkg_init_table( jobj, table, jqu(PKG_NAME),
        PKG_NAME, VERSION_NAME, OSARCH )
    VERSION_REALNAME = jobj[ prefix, k, jqu("version") ]
}
