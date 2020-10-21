import Foundation

struct StringsEntry {
    let comment: String
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
    var description: String {
        """
        \(comment)
        \(key) = \(value);
        """
    }
}
