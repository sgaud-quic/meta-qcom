# do not override KBRANCH and SRCREV_machine, use default ones.
COMPATIBLE_MACHINE:qcom = "(qcom)"

FILESEXTRAPATHS:prepend:qcom := "${THISDIR}/${PN}:"

SRC_URI:append:qcom = " \
    file://workarounds/0001-QCLINUX-arm64-dts-qcom-qcm6490-disable-sdhc1-for-ufs.patch \
    file://workarounds/0001-PENDING-arm64-dts-qcom-Remove-voltage-vote-support-f.patch \
    file://hamoa-iot-evk-dts/0001-arm64-dts-qcom-hamoa-iot-evk-camera-imx577-Add-DT-ov.patch \
"

# Include additional kernel configs.
SRC_URI:append:qcom = " \
    file://configs/qcom.cfg \
    file://configs/localversion.cfg \
"

# Make the kernel release deterministic: the defconfig leaves
# CONFIG_LOCALVERSION_AUTO enabled, so setlocalversion derives the release
# from the git tree state at build time — unstable in a parallel build
# (transient -dirty from concurrent tasks in the shared source tree) and,
# with the qcom patches applied as git commits, dependent on per-build
# commit timestamps. Derive the -g<sha> suffix from the revision the
# fetcher resolved instead (localversion.cfg above disables the AUTO scm
# inspection), and drop the -yoctodev-standard extension so uname -r keeps
# its current <version>-g<sha> form.
require linux-qcom-localversion.inc
KERNEL_LOCALVERSION:qcom = "${@qcom_kernel_localversion(d)}"
LINUX_VERSION_EXTENSION:qcom = ""

# When a defconfig is provided, the linux-yocto configuration
# uses the filename as a trigger to use a 'allnoconfig' baseline
# before merging the defconfig into the build.
#
# If the defconfig file was created with make_savedefconfig,
# not all options are specified, and should be restored with their
# defaults, not set to 'n'. To properly expand a defconfig like
# this, specify: KCONFIG_MODE="--alldefconfig" in the kernel
# recipe.
KCONFIG_MODE:qcom = "--alldefconfig"

KBUILD_DEFCONFIG:qcom ?= "defconfig"
KBUILD_DEFCONFIG:qcom-armv7a = "qcom_defconfig"

do_install:append:qcom() {
	sed -i 's:${TMPDIR}::g' ${WORKDIR}/linux-${PACKAGE_ARCH}-${LINUX_KERNEL_TYPE}-build/drivers/gpu/drm/msm/generated/*
}
