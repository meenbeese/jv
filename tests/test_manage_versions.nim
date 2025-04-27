import src/commands/manage_versions

proc testListVersions() =
    let versions = listVersions()
    assert versions.len > 0, "Expected at least one Java version to be listed."

proc testInstallVersion() =
    let versionToInstall = "11"
    installVersion(versionToInstall)
    let versions = listVersions()
    assert versionToInstall in versions, "Expected version to be installed."

proc testSetVersion() =
    let versionToSet = "11"
    setVersion(versionToSet)
    let currentVersion = getCurrentVersion()
    assert currentVersion == versionToSet, "Expected current version to be set correctly."

testListVersions()
testInstallVersion()
testSetVersion()
