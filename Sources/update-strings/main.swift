//
//  main.swift
//
//  Created by Craig Siemens on 2016-06-20.
//  Copyright © 2016 Craig Siemens. All rights reserved.
//

import ArgumentParser
import Foundation
import SwiftShell

struct UpdateStrings: ParsableCommand {
    @Option(name: [.short, .customLong("source")],
            help: "The folder containing source files to be searched for localizable strings.")
    var sourceFolder: String

    @Option(name: [.short, .customLong("output")],
            help: ArgumentHelp("The destination folder for the strings file.",
                               discussion: "If a strings file already exists, it will be updated to contain newly added strings. If it doesn't exist, a strings file will be created."))
    var outputFolder: String
    
    func run() throws {
        print("Finding Files")
        
        let files = SwiftShell
            .run("find", sourceFolder, "-name", "*.m", "-o", "-name", "*.swift")
            .stdout
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        print("  Found \(files.count)")
        
        print("Generating Strings")
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

UpdateStrings.main()
