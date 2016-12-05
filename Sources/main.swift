//
//  main.swift
//  spool
//
//  Created by Craig Siemens on 2016-06-20.
//  Copyright © 2016 Craig Siemens. All rights reserved.
//

import Foundation
import Commander
import Runner

let settings = { (settings: RunSettings) in
//    settings.echo = [.Command, .Stdout, .Stderr]
}

let generate = command(
    Option("source-folder", ".", flag: "s", description: "Folder containing the source files"),
    Option("output", ".", flag: "o", description: "Output file")
) { sourceFolder, output in
    
    let findResults = run("find -name *.m -o -name *.swift", settings: settings)
    let files = findResults.stdout.components(separatedBy: "\n")
    
    _ = run("genstrings -o /tmp \(files.joined(separator: " "))", settings: settings)
    
    let tempFileURL = URL(fileURLWithPath: "/tmp/Localizable.strings")
    let outputFileURL = URL(fileURLWithPath: output).appendingPathComponent("Localizable.strings")
    
    let tempFile = StringsFile(url: tempFileURL)
    let outputFile = StringsFile(url: outputFileURL)
    let mergedFile = StringsFile(oldFile: outputFile, newFile: tempFile)
    
    try! mergedFile.description.write(to: outputFileURL, atomically: true, encoding: String.Encoding.utf16)
}

generate.run()
