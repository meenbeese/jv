import std/tables
import std/algorithm
import std/strutils
import std/sequtils

type JavaVersion* = object
    distribution*: string
    fullVersion*: string

proc parseVersion*(version: string): JavaVersion =
    let parts = version.split('@')
    if parts.len > 1:
        result.distribution = parts[0]
        result.fullVersion = version
    else:
        result.distribution = "default"
        result.fullVersion = version

proc printVersionTable*(versions: seq[string]) =
    var versionMap = initTable[string, seq[string]]()
    
    for version in versions:
        let parsed = parseVersion(version.strip())
        if not versionMap.hasKey(parsed.distribution):
            versionMap[parsed.distribution] = @[]
        versionMap[parsed.distribution].add(parsed.fullVersion)

    echo "\nAvailable Java Versions:"
    echo "═══════════════════════\n"
    
    for dist in versionMap.keys.toSeq.sorted():
        echo "Distribution: ", dist.toUpper()
        echo "───────────────────────"
        for version in versionMap[dist]:
            echo "  • ", version
        echo ""
