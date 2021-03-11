import ArgumentParser
import Foundation
import SwiftShell
import UpdateStringsModels

struct SortCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "sort",
        abstract: "Sorts the contents of strings files in a given folder"
    )

    @Option(name: .long, help: "Option to enable validation mode. It throws an error if a file is not sorted.")
    var dryRun = false
    
    @Argument(help: ArgumentHelp("The folder to search for strings files.", discussion: ""))
    var folder: String
    
    func run() throws {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(folder)
        
        print("Finding Files")
        
        let stringsFileURLs = SwiftShell
            .run("find", folder, "-name", "*.strings")
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .map { URL(fileURLWithPath: $0) }
        
        print("  Found \(stringsFileURLs.count)")
        
        var unsortedStringPaths: [String] = []
        
        for stringsFileURL in stringsFileURLs {
            let relativePath = stringsFileURL.path
                .replacingOccurrences(of: currentDirectoryURL.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            let currentStrings = try String(contentsOf: stringsFileURL)
            
            let stringsFile = try StringsFile(url: stringsFileURL)
            let newStrings = stringsFile.description
            
            guard currentStrings != newStrings else { continue }
            
            print("\(dryRun ? "Validating" : "Sorting") \(relativePath)")
            
            if dryRun {
                unsortedStringPaths.append(relativePath)
            } else {
                try stringsFile.description.write(to: stringsFileURL, atomically: true, encoding: .utf8)
            }
        }
        
        if dryRun, !unsortedStringPaths.isEmpty {
            throw ValidationError(
                unsortedStringPaths
                    .map { "\($0) is not sorted." }
                    .joined(separator: "\n")
            )
        }
    }
}
