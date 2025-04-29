import std/tables
import std/algorithm
import std/strutils
import std/sequtils

type JavaVersion* = object
    distribution*: string
    fullVersion*: string
    majorVersion*: int

proc extractMajorVersion(version: string): int =
    let parts = version.split('.')
    if parts.len >= 2:
        try:
            return parseInt(parts[1]) # Get the X in 1.X.0
        except ValueError:
            return 0
    return 0

proc parseVersion*(version: string): JavaVersion =
    let parts = version.split('@')
    var versionStr = version
    if parts.len > 1:
        result.distribution = parts[0]
        result.fullVersion = version
        versionStr = parts[1]
    else:
        result.distribution = "default"
        result.fullVersion = version
    result.majorVersion = extractMajorVersion(versionStr)

proc printVersionTable*(versions: seq[string]) =
    var versionMap = initTable[string, seq[JavaVersion]]()
    
    for version in versions:
        let parsed = parseVersion(version.strip())
        if not versionMap.hasKey(parsed.distribution):
            versionMap[parsed.distribution] = @[]
        versionMap[parsed.distribution].add(parsed)

    echo "\nAvailable Java Versions:"
    echo "═══════════════════════\n"
    
    for dist in versionMap.keys.toSeq.sorted():
        echo "Distribution: ", dist.toUpper()
        echo "───────────────────────"
        
        # Group versions by major version
        var majorVersions: Table[int, seq[JavaVersion]]
        for v in versionMap[dist]:
            if not majorVersions.hasKey(v.majorVersion):
                majorVersions[v.majorVersion] = @[]
            majorVersions[v.majorVersion].add(v)
        
        # Sort major versions in descending order
        let sortedMajors = majorVersions.keys.toSeq.sorted(Descending)
        for major in sortedMajors:
            # For each major version, show only the latest version
            let versions = majorVersions[major]
            let latest = versions.sortedByIt(it.fullVersion)[^1]
            echo "  • ", latest.fullVersion
        echo ""
