import XCTest
@testable import FlatBuffers

final class FlatBuffersTests: XCTestCase {

    func testBuilderInit() {
        XCTAssertThrowsError(try FlatBuffersBuilder(initialSize: -1))
        XCTAssertThrowsError(try FlatBuffersBuilder(initialSize: 0))
        XCTAssertNoThrow(try FlatBuffersBuilder(initialSize: 1))
    }
    
    func testCreateString() {
        let b = try! FlatBuffersBuilder(initialSize: 16)
        XCTAssertEqual(try b.create(string: "Hello, world!"), 20)
        XCTAssertEqual(try b.create(string: "Hello, world!"), 40)
        b.clear()
        XCTAssertEqual(try b.create(string: "Hello, world!"), 20)
        XCTAssertEqual(try b.create(string: "Hello, world!"), 40)
    }
    
}
