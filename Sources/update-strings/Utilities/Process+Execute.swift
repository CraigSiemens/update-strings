import Foundation

extension Process {
    @discardableResult
    static func execute(
        _ command: String,
        arguments: [String],
        environment: [String: String] = [:]
    ) throws -> String {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        process.environment = ProcessInfo.processInfo.environment
            .merging(environment) { $1 }
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self)
    }
}
