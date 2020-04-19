//
//  UpdateStringsCommand.swift
//  
//
//  Created by Craig Siemens on 2020-04-19.
//

import ArgumentParser
import Foundation
import SwiftShell

struct UpdateStrings: ParsableCommand {
    @Option(name: [.short, .customLong("source")])
    var sourceFolder: String

    @Option(name: [.short, .customLong("output")])
    var outputFolder: String
    
    func run() throws {
        print("Finding Files")
        
        let files = SwiftShell
            .run("find", sourceFolder, "-name", "*.m", "-o", "-name", "*.swift")
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        print("  Found \(files.count)")
        
        print("Generating String")
        try runAndPrint("genstrings", "-o", "/tmp", files)
        
        let tempFileURL = URL(fileURLWithPath: "/tmp/Localizable.strings")
        let outputFileURL = URL(fileURLWithPath: outputFolder)
            .appendingPathComponent("Localizable.strings")
        
        print("Reading Files")
        
        let tempFile = try StringsFile(url: tempFileURL)
        print("  Temp contains \(tempFile.entries.count)")

        let outputFile = try StringsFile(url: outputFileURL)
        print("  Existing contains \(outputFile.entries.count)")

        print("Merging Files")
        let mergedFile = StringsFile(oldFile: outputFile, newFile: tempFile)
        print("  Contains \(mergedFile.entries.count)")

        print("Writing File")
        try mergedFile.description.write(to: outputFileURL, atomically: true, encoding: .utf8)
        
        print("Cleanup")
        try FileManager.default.removeItem(at: tempFileURL)
    }
}
