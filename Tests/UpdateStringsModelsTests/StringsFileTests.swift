import XCTest
@testable import UpdateStringsModels

final class StringsFileTests: XCTestCase {
    
    // MARK: - Init
    func testInit() {
        let url = Bundle.module.fixture(name: "Simple.strings")
        
        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 3)
            
            XCTAssertEqual(file.entries["key1"]?.comment, "comment1")
            XCTAssertEqual(file.entries["key1"]?.key, "key1")
            XCTAssertEqual(file.entries["key1"]?.value, "value1")

            XCTAssertEqual(file.entries["key2"]?.comment, "comment2")
            XCTAssertEqual(file.entries["key2"]?.key, "key2")
            XCTAssertEqual(file.entries["key2"]?.value, "value2")

            XCTAssertEqual(file.entries["key3"]?.comment, "comment3")
            XCTAssertEqual(file.entries["key3"]?.key, "key3")
            XCTAssertEqual(file.entries["key3"]?.value, "value3")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInitKeysWithoutQuotes() {
        let url = Bundle.module.fixture(name: "KeysWithoutQuotes.strings")
        
        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 3)
            
            XCTAssertEqual(file.entries["key1"]?.comment, "comment1")
            XCTAssertEqual(file.entries["key1"]?.key, "key1")
            XCTAssertEqual(file.entries["key1"]?.value, "value1")

            XCTAssertEqual(file.entries["key2"]?.comment, "comment2")
            XCTAssertEqual(file.entries["key2"]?.key, "key2")
            XCTAssertEqual(file.entries["key2"]?.value, "value2")

            XCTAssertEqual(file.entries["key3"]?.comment, "comment3")
            XCTAssertEqual(file.entries["key3"]?.key, "key3")
            XCTAssertEqual(file.entries["key3"]?.value, "value3")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInitWithSpecialCharacters() {
        let url = Bundle.module.fixture(name: "SpecialCharacters.strings")
        
        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 3)
            
            let key1 = "key1\""
            XCTAssertEqual(file.entries[key1]?.comment, "comment1\"")
            XCTAssertEqual(file.entries[key1]?.key, key1)
            XCTAssertEqual(file.entries[key1]?.value, "value1\"")
            
            let key2 = "key2 \"a\" = \"b\";"
            XCTAssertEqual(file.entries[key2]?.comment, "comment2 \"a\" = \"b\";")
            XCTAssertEqual(file.entries[key2]?.key, key2)
            XCTAssertEqual(file.entries[key2]?.value, "value2 \"a\" = \"b\";")
            
            let key3 = "key3 ; asdf"
            XCTAssertEqual(file.entries[key3]?.comment, "comment3 ; asdf")
            XCTAssertEqual(file.entries[key3]?.key, key3)
            XCTAssertEqual(file.entries[key3]?.value, "value3 ; asdf")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInitWithEscapedNewLines() {
        let url = Bundle.module.fixture(name: "NewLinesEscaped.strings")

        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 1)
            
            let key = "key\nasdf"
            XCTAssertEqual(file.entries[key]?.comment, "comment\n   Second Line")
            XCTAssertEqual(file.entries[key]?.key, key)
            XCTAssertEqual(file.entries[key]?.value, "value\nasdf")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInitWithUnescapedNewLines() {
        let url = Bundle.module.fixture(name: "NewLinesUnescaped.strings")

        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 1)
            
            let key = "key\nasdf"
            XCTAssertEqual(file.entries[key]?.comment, "comment\n   Second Line")
            XCTAssertEqual(file.entries[key]?.key, key)
            XCTAssertEqual(file.entries[key]?.value, "value\nasdf")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: - Description
    func testDescription() {
        do {
            let url = Bundle.module.fixture(name: "Simple.strings")
            let file = try StringsFile(url: url)
            
            XCTAssertEqual(file.description, try String(contentsOf: url))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDescriptionWithSpecialCharacters() {
        do {
            let url = Bundle.module.fixture(name: "SpecialCharacters.strings")
            let file = try StringsFile(url: url)
            
            XCTAssertEqual(file.description, try String(contentsOf: url))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDescriptionWithEscapedNewLines() {
        do {
            let url = Bundle.module.fixture(name: "NewLinesEscaped.strings")
            let file = try StringsFile(url: url)
            
            XCTAssertEqual(
                file.description,
                try String(contentsOf: Bundle.module.fixture(name: "NewLinesUnescaped.strings"))
            )
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDescriptionWithUnescapedNewLines() {
        do {
            let url = Bundle.module.fixture(name: "NewLinesUnescaped.strings")
            let file = try StringsFile(url: url)
            
            XCTAssertEqual(file.description, try String(contentsOf: url))
        } catch {
            XCTFail("\(error)")
        }
    }
}

private extension Bundle {
    func fixture(name: String) -> URL {
        resourceURL!
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)
    }
}
