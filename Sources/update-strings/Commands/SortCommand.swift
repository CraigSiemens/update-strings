import ArgumentParser
import Foundation
import SwiftShell
import UpdateStringsModels

struct SortCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "sort",
        abstract: "Sorts the contents of strings files in a given folder"
    )
    
    @Flag(
        help: "Run without making any changes to files. Exits with a non-zero error code if any files need to be sorted."
    )
    var dryRun = false
    
    @Argument(
        help: "The folder to search for strings files."
    )
    var folder: String
    
    @OptionGroup var options: UpdateStrings.Options
    
    func run() throws {
        let log = Logger(options: options)
        
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(folder)
        
        log.info("Finding Files")
        
        let stringsFileURLs = SwiftShell
            .run("find", folder, "-name", "*.strings")
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { URL(fileURLWithPath: $0) }
        
        log.info("  Found \(stringsFileURLs.count)")
        
        var unsortedStringPaths: [String] = []
        
        for stringsFileURL in stringsFileURLs {
            let relativePath = stringsFileURL.path
                .replacingOccurrences(of: currentDirectoryURL.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            let currentStrings = try String(contentsOf: stringsFileURL)
            
            let stringsFile = try StringsFile(url: stringsFileURL)
            let newStrings = stringsFile.description
            
            guard currentStrings != newStrings else { continue }
            
            log.info("Sorting \(relativePath)")
            
            if dryRun {
                unsortedStringPaths.append(relativePath)
            } else {
                try stringsFile.description.write(to: stringsFileURL, atomically: true, encoding: .utf8)
            }
        }
        
        if dryRun, !unsortedStringPaths.isEmpty {
            log.warning("The following files need to be sorted.")
            unsortedStringPaths.forEach { log.warning($0) }
            
            throw ExitCode.failure
        }
    }
}
