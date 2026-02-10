PLATFORM = "lemans"
PBT_BUILD_DATE = "260208"

require common.inc

SRC_URI[camxlib.sha256sum]     = "df682423cc6338c5b254d7cb1de58e9045e09f6675bd6a150513d96b9b037eef"
SRC_URI[camx.sha256sum]        = "9c27a94c6db21f72b82e995da6e601c54bb00f6497b9af10a22d842adad5f271"
SRC_URI[chicdk.sha256sum]      = "e11af0aead3aafa8accd020e0958b95e428fa974ba8bfbfa01a3e8587d033c9c"
SRC_URI[camxcommon.sha256sum]  = "99f23f28d112d862680743c956c1b524227efed34443d9258e8ae37a0034e584"

do_install:append() {
    install -d ${D}${sysconfdir}/camera/test/NHX/

    cp -r ${S}/etc/camera/test/NHX/*.json ${D}${sysconfdir}/camera/test/NHX/
}

RPROVIDES:${PN} = "camxlib-monaco"
PACKAGE_BEFORE_PN += "camx-nhx"

FILES:camx-nhx = "\
    ${bindir}/nhx.sh \
    ${sysconfdir}/camera/test/NHX/ \
"
