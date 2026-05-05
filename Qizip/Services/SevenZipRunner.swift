import Foundation

struct SevenZipProcessResult: Equatable {
    var stdout: String
    var stderr: String
    var exitCode: Int32
}

struct SevenZipRunner {
    func run(executableURL: URL, arguments: [String]) async throws -> SevenZipProcessResult {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = executableURL
            process.arguments = arguments

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            process.standardInput = Pipe()

            let stdoutTask = Task.detached(priority: .userInitiated) {
                stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            }
            let stderrTask = Task.detached(priority: .userInitiated) {
                stderrPipe.fileHandleForReading.readDataToEndOfFile()
            }

            try process.run()
            process.waitUntilExit()
            let stdoutData = await stdoutTask.value
            let stderrData = await stderrTask.value

            return SevenZipProcessResult(
                stdout: String(data: stdoutData, encoding: .utf8) ?? "",
                stderr: String(data: stderrData, encoding: .utf8) ?? "",
                exitCode: process.terminationStatus
            )
        }.value
    }
}
