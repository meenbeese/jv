import std/tables
import std/algorithm
import std/strutils
import std/sequtils

type JavaVersion* = object
    distribution*: string
    fullVersion*: string
    majorVersion*: int
    vmType*: string

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
        case parts[0].toLowerAscii()
        of "openjdk-ri", "adopt-openj9", "graalvm-dev",
           "graalvm-ce-java8", "graalvm-ce-java11", "graalvm-ce-java16": 
            return JavaVersion(distribution: "", fullVersion: "", majorVersion: 0)
        else:
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
        if parsed.distribution.len == 0: continue
        if not versionMap.hasKey(parsed.distribution):
            versionMap[parsed.distribution] = @[]
        versionMap[parsed.distribution].add(parsed)

    echo "\nAvailable Java Versions:"
    echo "═══════════════════════\n"
    
    for dist in versionMap.keys.toSeq.sorted():
        if dist == "default" or versionMap[dist].len == 0:
            continue
            
        echo "Distribution: ", dist.toUpper()
        echo "───────────────────────"
        
        # Group versions by major version and keep only latest
        var latestVersions: Table[int, JavaVersion]
        for v in versionMap[dist]:
            if not latestVersions.hasKey(v.majorVersion) or
               latestVersions[v.majorVersion].fullVersion < v.fullVersion:
                latestVersions[v.majorVersion] = v
        
        # Display versions sorted by major version
        for v in latestVersions.values.toSeq.sortedByIt(it.majorVersion).reversed():
            echo "  • ", v.fullVersion
        echo ""
