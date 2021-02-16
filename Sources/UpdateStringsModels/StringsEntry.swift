import Foundation

public struct StringsEntry {
    var comment: String?
    let key: String
    let value: String
    
    var isDefault: Bool {
        key == value.replacingOccurrences(of: "[0-9]\\$+", with: "", options: .regularExpression)
    }
}

extension StringsEntry {
    init(oldEntry: StringsEntry?, newEntry: StringsEntry) {
        let newValue: String
        
        if let oldEntry = oldEntry {
            newValue = (oldEntry.isDefault ? newEntry.value : oldEntry.value)
        } else {
            newValue = newEntry.value
        }
        
        self.init(comment: newEntry.comment, key: newEntry.key, value: newValue)
    }
}

extension StringsEntry: CustomStringConvertible {
    public var description: String {
        var string = ""
        
        if let comment = comment {
            string.append("/* \(comment) */\n")
        }
        
        string.append("\"\(key.escapingQuotes())\" = \"\(value.escapingQuotes())\";")
        
        return string
    }
}

private extension String {
    func escapingQuotes() -> String {
        replacingOccurrences(of: "\"", with: "\\\"")
    }
}
