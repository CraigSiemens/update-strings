import Foundation

struct StringsFile {
    let entries: [String: StringsEntry]
}

extension StringsFile {
    
    init(url: URL?) {
        guard let url = url,
            let content = try? String(contentsOf: url, encoding: String.Encoding.utf16) else {
                entries = [:]
                return
        }
        
//        let searchableContent = content as NSString
        let regex = try! NSRegularExpression(pattern: "(/\\*.*?\\*/)?\n\"(.*?)\" = \"(.*?)\";", options: [.dotMatchesLineSeparators])
        let results = regex.matches(in: content, options: [], range: NSMakeRange(0, content.characters.count))
        
//        let comment: String = content.substringWithRange(result.rangeAtIndex(1))
//        let key: String = content.substringWithRange(result.rangeAtIndex(2))
//        let value: String = content.substringWithRange(result.rangeAtIndex(3))
        
        entries = results.map { result -> StringsEntry in
            let comment = content.substringWithRange(result.rangeAt(1))
            let key = content.substringWithRange(result.rangeAt(2))
            let value = content.substringWithRange(result.rangeAt(3))
            return StringsEntry(comment: comment, key: key, value: value)
            }
            .reduce([:]) { dict, entry in
                var dict = dict
                dict[entry.key] = entry
                return dict
        }
    }
    
    init(oldFile: StringsFile, newFile: StringsFile) {
        entries = newFile.entries
            .map { StringsEntry(oldEntry: oldFile.entries[$0], newEntry: $1) }
            .reduce([:]) { dict, entry in
                var dict = dict
                dict[entry.key] = entry
                return dict
        }
    }
}

extension StringsFile: CustomStringConvertible {
    var description: String {
        get {
            let sortedEntries = entries.values.sorted { $0.key < $1.key }
            
            let defaultEntries = sortedEntries.filter { $0.isDefault }
                .map { (value) in value.description }
                .joined(separator: "\n")

            let nonDefaultEntries = sortedEntries.filter { !$0.isDefault }
                .map { (value) in value.description }
                .joined(separator: "\n")

            let showHeaders = !defaultEntries.isEmpty && !nonDefaultEntries.isEmpty
            let defaultHeader = "/*************************\\\n *    Default Strings    *\n\\*************************/\n"
            let nonDefaultHeader = "/*************************\\\n *  Non Default Strings  *\n\\*************************/\n"
            
            let parts = [
                showHeaders ? defaultHeader : "",
                defaultEntries,
                showHeaders ? nonDefaultHeader : "",
                nonDefaultEntries
            ]
            
            return parts.filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
    }
}

extension String {
    func substringWithRange(_ range: NSRange) -> String {
//        guard range.location != NSNotFound else { return "" }
        
        let start = characters.index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return substring(with: start..<end)
    }
}
