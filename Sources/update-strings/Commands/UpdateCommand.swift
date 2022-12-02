import ArgumentParser
import Foundation
import UpdateStringsModels

struct UpdateCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "update",
        abstract: "Updates the contents of the string file based on the source code in a folder."
    )
    
    @Option(
        name: [.short, .customLong("source")],
        help: "The folder containing source files to be searched for localizable strings."
    )
    var sourceFolder: String
    
    @Option(
        name: [.short, .customLong("output")],
        help: ArgumentHelp(
            "The destination folder for the strings file.",
            discussion: "If a strings file already exists, it will be updated to contain newly added strings. If it doesn't exist, a strings file will be created."
        )
    )
    var outputFolder: String
    
    @OptionGroup var options: UpdateStrings.Options
    
    func run() throws {
        let log = Logger(options: options)
        
        log.info("Finding Files")
        
        let files = try Process
            .execute("find", arguments: [sourceFolder, "-name", "*.m", "-o", "-name", "*.swift"])
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        log.info("  Found \(files.count)")
        
        log.info("Generating Strings")
        try Process.execute("/usr/bin/genstrings", arguments: ["-o", "/tmp"] + files)
        
        let tempFileURL = URL(fileURLWithPath: "/tmp/Localizable.strings")
        let outputFileURL = URL(fileURLWithPath: outputFolder)
            .appendingPathComponent("Localizable.strings")
        
        log.info("Reading Files")
        
        let tempFile = try StringsFile(url: tempFileURL)
        log.info("  Temp contains \(tempFile.entries.count)")
        
        let outputFile = try StringsFile(url: outputFileURL)
        log.info("  Existing contains \(outputFile.entries.count)")
        
        log.info("Merging Files")
        let mergedFile = StringsFile(oldFile: outputFile, newFile: tempFile)
        log.info("  Contains \(mergedFile.entries.count)")
        
        log.info("Writing File")
        try mergedFile.description.write(to: outputFileURL, atomically: true, encoding: .utf8)
        
        log.info("Cleanup")
        try FileManager.default.removeItem(at: tempFileURL)
    }
}
