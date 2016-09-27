import XCTest
@testable import HTTPCore

class HTTPCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(HTTPCore().text, "Hello, World!")
    }


    static var allTests : [(String, (HTTPCoreTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
