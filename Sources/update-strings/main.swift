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
    
    @OptionGroup var options: UpdateStrings.Options
    
    struct Options: ParsableArguments {
        @Flag(
            name: [.short, .long],
            help: "Run without additional logging."
        )
        var quiet = false
    }
}

UpdateStrings.main()
