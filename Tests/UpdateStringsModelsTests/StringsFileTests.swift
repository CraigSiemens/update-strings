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
    
    func testInitWithSpecialCharacters() {
        let url = Bundle.module.fixture(name: "SpecialCharacters.strings")
        
        do {
            let file = try StringsFile(url: url)
            XCTAssertEqual(file.entries.count, 4)
            
            let key1 = "key1\""
            XCTAssertEqual(file.entries[key1]?.comment, "comment1\"")
            XCTAssertEqual(file.entries[key1]?.key, key1)
            XCTAssertEqual(file.entries[key1]?.value, "value1\"")

            let key2 = "key2\nasdf"
            XCTAssertEqual(file.entries[key2]?.comment, "comment2\n   Second Line")
            XCTAssertEqual(file.entries[key2]?.key, key2)
            XCTAssertEqual(file.entries[key2]?.value, "value2\nasdf")

            let key3 = "key3\nasdf"
            XCTAssertEqual(file.entries[key3]?.comment, "comment3\nSecond Line")
            XCTAssertEqual(file.entries[key3]?.key, key3)
            XCTAssertEqual(file.entries[key3]?.value, "value3\nasdf")
            
            let key4 = "key4 \"a\" = \"b\";"
            XCTAssertEqual(file.entries[key4]?.comment, "comment4 \"a\" = \"b\";")
            XCTAssertEqual(file.entries[key4]?.key, key4)
            XCTAssertEqual(file.entries[key4]?.value, "value4 \"a\" = \"b\";")
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
            
            print(file.description)
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
