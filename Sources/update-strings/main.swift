//
//  main.swift
//  spool
//
//  Created by Craig Siemens on 2016-06-20.
//  Copyright © 2016 Craig Siemens. All rights reserved.
//

import Foundation
import Commander
import SwiftShell

let generate = command(
    Option("source-folder", default: ".", flag: "s", description: "Folder containing the source files"),
    Option("output", default: ".", flag: "o", description: "Output file")
) { sourceFolder, output in
    print("Finding Files")
    let findResults = run("find", sourceFolder, "-name", "*.m", "-o", "-name", "*.swift")
    
    let files = findResults.stdout.components(separatedBy: "\n").filter { !$0.isEmpty }//.map { "\"\($0)\"" }
    print("  Found \(files.count)")
    
    print("Generating String")
    try runAndPrint("genstrings", "-o", "/tmp", files)
    
    let tempFileURL = URL(fileURLWithPath: "/tmp/Localizable.strings")
    let outputFileURL = URL(fileURLWithPath: output).appendingPathComponent("Localizable.strings")
    
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

generate.run()
