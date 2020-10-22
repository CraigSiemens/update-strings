import Foundation

struct StringsFile {
    let entries: [String: StringsEntry]
}

extension StringsFile {
    
    init(url: URL) throws {
        var entriesDictionary = [String: StringsEntry]()
        
        let string = try String(contentsOf: url)
        let scanner = Scanner(string: string)
        
        while let comment = scanner.scanUpToString(.endComment),
            let key = scanner.scanUpToString(.endKey),
            scanner.scanString(.endKey) != nil,
            let value = scanner.scanUpToString(.endValue) {
                entriesDictionary[key] = StringsEntry(
                    comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                    key: key.trimmingCharacters(in: .whitespacesAndNewlines),
                    value: value.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                _ = scanner.scanUpToString(.startComment)
        }
        
        self.entries = entriesDictionary
    }
    
    init(oldFile: StringsFile, newFile: StringsFile) {
        let mergedEntries = newFile.entries
            .map { StringsEntry(oldEntry: oldFile.entries[$0], newEntry: $1) }
        
        self.entries = Dictionary(grouping: mergedEntries, by: { $0.key })
            .mapValues { $0.first! }
    }
}

extension StringsFile: CustomStringConvertible {
    var description: String {
        get {
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
    
    static var startComment: String { "/* " }
    static var endComment: String { "\n\"" }
    static var endKey: String { "=" }
    static var endValue: String { ";" }
}
