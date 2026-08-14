# Derive a deterministic kernel localversion from the recipe metadata.
#
# The qcom kernels build from the upstream arm64 defconfig, which leaves
# CONFIG_LOCALVERSION_AUTO enabled: kbuild's setlocalversion then derives
# the kernel release from the state of the git tree at whatever moment a
# kernel task runs it. In a parallel build that string is not stable:
# concurrent tasks touching the shared work-shared source tree can
# transiently mark it dirty, so the kernel can package itself under a
# "-dirty" release while the module dependencies were computed from the
# clean one, and the git-describe output also changes with the clone
# shape (a shallow clone has no tags, dropping the commit count).
#
# The revision is already pinned metadata, so compute the same -g<sha>
# suffix from SRCREV instead, and disable LOCALVERSION_AUTO through the
# localversion.cfg fragment in each consuming recipe. AUTOREV variants
# (where SRCREV expands to AUTOINC) ask the fetcher for the revision
# resolved for this build: still a deterministic function of the task
# signatures, unlike the git working tree state.
#
# Consumers set:
#   KERNEL_LOCALVERSION = "${@qcom_kernel_localversion(d)}"
# and add file://configs/localversion.cfg to SRC_URI.

def qcom_kernel_localversion(d):
    rev = d.getVar('SRCREV_machine') or d.getVar('SRCREV')
    if not rev or rev in ('AUTOINC', 'INVALID'):
        # AUTOREV: resolve through the fetcher, like SRCPV would
        try:
            fetcher = bb.fetch2.Fetch(d.getVar('SRC_URI').split(), d)
            scms = [ud for ud in fetcher.ud.values() if ud.method.supports_srcrev()]
            machine = [ud for ud in scms if ud.name == 'machine']
            ud = (machine or scms)[0]
            rev = ud.method.sortable_revision(ud, d, ud.name)[1]
        except (bb.fetch2.BBFetchException, IndexError):
            return ''
    rev = (rev or '').lower()
    if len(rev) < 12 or any(c not in '0123456789abcdef' for c in rev):
        return ''
    return '-g' + rev[:12]
