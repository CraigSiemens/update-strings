import Foundation

struct Logger {
    let options: UpdateStrings.Options
}

extension Logger {
    func info(_ message: Any?...) {
        guard !options.quiet else { return }
        log(message)
    }
    
    func warning(_ message: Any?...) {
        log(message)
    }
}

// MARK: - Base logging method
private extension Logger {
    func log(_ message: [Any?]) {
        let messageString = message
            .map {
                switch $0 {
                case let .some(value): return "\(value)"
                default: return String(describing: $0)
                }
            }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        print(messageString)
    }
}
