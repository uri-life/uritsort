import Foundation
import PackagePlugin

@main
struct VersionsGeneratorPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: Target,
    ) async throws -> [Command] {
        let vgVersion = ProcessInfo.processInfo.environment["VG_VERSION", default: ""]
        let vgCommit = ProcessInfo.processInfo.environment["VG_COMMIT", default: ""]
        return [
            .prebuildCommand(
                displayName: "Generating versions file",
                executable:
                    context.package.directoryURL
                    .appending(path: "Scripts", directoryHint: .isDirectory)
                    .appending(path: "generate-versions.sh", directoryHint: .notDirectory),
                arguments: [context.pluginWorkDirectoryURL.path],
                environment: [
                    "VG_VERSION": vgVersion,
                    "VG_COMMIT": vgCommit,
                ],
                outputFilesDirectory: context.pluginWorkDirectoryURL,
            ),
        ]
    }
}
