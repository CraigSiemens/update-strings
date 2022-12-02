import Foundation

public struct StringsFile {
    public let entries: [String: StringsEntry]
}

extension StringsFile {
    public init(url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    init(string: String) throws {
        try self.init(data: Data(string.utf8))
    }
    
    init(data: Data) throws {
        guard !data.isEmpty else {
            self.entries = [:]
            return
        }
        
        let decoder = PropertyListDecoder()
        let entries = try decoder.decode([String: String].self, from: data)
            .map { (key, value) -> (String, StringsEntry) in
                (key, StringsEntry(key: key, value: value))
            }
        
        var entriesDictionary = Dictionary(uniqueKeysWithValues: entries)
        
        let scanner = Scanner(string: String(decoding: data, as: UTF8.self))
        while let comment = scanner.scanComment(),
              let key = scanner.scanKey() {
            entriesDictionary[key]?.comment = comment
        }
        
        self.entries = entriesDictionary

    }
    
    public init(oldFile: StringsFile, newFile: StringsFile) {
        let mergedEntries = newFile.entries
            .map { StringsEntry(oldEntry: oldFile.entries[$0], newEntry: $1) }
        
        self.entries = Dictionary(grouping: mergedEntries, by: { $0.key })
            .mapValues { $0.first! }
    }
}

extension StringsFile: CustomStringConvertible {
    public var description: String {
        get {
            guard !entries.isEmpty else { return "" }
            
            let sortedEntries = entries.values.sorted { $0.key < $1.key }
            
            let defaultEntries = sortedEntries.filter { $0.isDefault }
                .map { (value) in value.description }
                .joined(separator: "\n\n")

            let nonDefaultEntries = sortedEntries.filter { !$0.isDefault }
                .map { (value) in value.description }
                .joined(separator: "\n\n")

            let showHeaders = !defaultEntries.isEmpty && !nonDefaultEntries.isEmpty
            
            let defaultHeader = #"""
            /*************************\
             *    Default Strings    *
            \*************************/
            """#
            
            let nonDefaultHeader = #"""
            /*************************\
             *  Non Default Strings  *
            \*************************/
            """#
            
            let parts = [
                showHeaders ? defaultHeader : "",
                defaultEntries,
                showHeaders ? nonDefaultHeader : "",
                nonDefaultEntries
            ]
            
            return parts.filter { !$0.isEmpty }
                .joined(separator: "\n\n")
                + "\n"
        }
    }
}

private extension String {
    func substringWithRange(_ range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return String(self[start..<end])
    }
    
    static var startComment: String { "/*" }
    static var endComment: String { "*/" }
    static var quote: String { "\"" }
    static var equals: String { "=" }
    static var semicolon: String { ";" }

    static var endKey: String { "=" }
    static var endValue: String { ";" }
}

private extension Scanner {
    func scanComment() -> String? {
        _ = scanUpToString(.startComment)
        
        guard scanString(.startComment) != nil,
              let comment = scanUpToString(.endComment) else {
            return nil
        }
        
        _ = scanString(.endComment)
        return comment.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func scanKey() -> String? {
        let startingCharactersToBeSkipped = charactersToBeSkipped
        charactersToBeSkipped = nil
        
        _ = scanCharacters(from: .whitespacesAndNewlines)
        
        charactersToBeSkipped = startingCharactersToBeSkipped
        
        if string[currentIndex] == "\"" {
            return scanQuotedKey()
        } else {
            return scanUnquotedKey()
        }
    }
    
    private func scanQuotedKey() -> String? {
        guard scanString(.quote) != nil else {
            return nil
        }
        
        var key = ""
        
        let startingCharactersToBeSkipped = charactersToBeSkipped
        charactersToBeSkipped = nil
        defer { charactersToBeSkipped = startingCharactersToBeSkipped }
        
        while let character = scanCharacter(),
              character != "\"" {
            if character == "\\",
               let escapedCharacter = scanEscapedCharacter() {
                key.append(escapedCharacter)
            } else {
                key.append(character)
            }
        }
        
        _ = scanString(.quote)
        return key
    }
    
    private func scanUnquotedKey() -> String? {
        scanUpToString(.equals)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Loosely based on
    /// https://opensource.apple.com/source/CF/CF-550/CFPropertyList.c.auto.html
    func scanEscapedCharacter() -> Character? {
        let character = scanCharacter()
        
        switch character {
        case "n":
            return "\n"
        case "t":
            return "\t"
        case "\"":
            return "\""
        default:
            return character
        }
    }
}
