import ArgumentParser
import Foundation
import SwiftShell
import UpdateStringsModels

struct UpdateStrings: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Tools for working with strings files.",
        subcommands: [
            UpdateCommand.self,
            SortCommand.self
        ],
        defaultSubcommand: UpdateCommand.self
    )
}

UpdateStrings.main()
