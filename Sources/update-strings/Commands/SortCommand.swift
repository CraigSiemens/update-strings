import ArgumentParser
import Foundation
import SwiftShell

struct SortCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "sort",
        abstract: "Sorts the contents of strings files in a given folder"
    )
    
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
        
        for stringsFileURL in stringsFileURLs {
            let relativePath = stringsFileURL.path
                .replacingOccurrences(of: currentDirectoryURL.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            print("Sorting \(relativePath)")
            
            let stringsFile = try StringsFile(url: stringsFileURL)
            try stringsFile.description.write(to: stringsFileURL, atomically: true, encoding: .utf8)
        }
    }
}
