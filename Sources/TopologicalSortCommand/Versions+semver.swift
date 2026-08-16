extension Versions {

    static nonisolated var semver: String {
        let versionRegex =
            /^v?(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>[\w.-]+))?$/
        let version: String
        if let match = try? versionRegex.wholeMatch(in: Versions.version) {
            let major = match.major
            let minor = match.minor
            let patch = match.patch
            if let prerelease = match.prerelease {
                version = "\(major).\(minor).\(patch)-\(prerelease)"
            }
            else {
                version = "\(major).\(minor).\(patch)"
            }
        }
        else {
            version = "dev"
        }
        if commit.isEmpty {
            return version
        }
        else {
            return "\(version)+\(commit.prefix(7))"
        }
    }
}
