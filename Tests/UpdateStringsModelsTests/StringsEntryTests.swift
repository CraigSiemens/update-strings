import XCTest
@testable import UpdateStringsModels

final class StringsEntryTests: XCTestCase {
    
    func testDescription() {
        let entry = StringsEntry(comment: "comment", key: "key", value: "value")
        let expected = #"""
        /* comment */
        "key" = "value";
        """#
        
        XCTAssertEqual(entry.description, expected)
    }
    
    func testDescriptionWithoutComment() {
        let entry = StringsEntry(key: "key", value: "value")
        let expected = #"""
        "key" = "value";
        """#
        
        XCTAssertEqual(entry.description, expected)
    }
    
    
    func testDescriptionWithSpecialCharacters() {
        let entry = StringsEntry(comment: #"comment"asdf""#,
                                 key: #"key="asdf""#,
                                 value: #"value;"asdf""#)
        let expected = #"""
        /* comment"asdf" */
        "key=\"asdf\"" = "value;\"asdf\"";
        """#
        
        XCTAssertEqual(entry.description, expected)
    }
}
