import XCTest
@testable import FlatBuffers

final class FlatBuffersVectors: XCTestCase {
    
    func testCreatingTwoCountries() {
        let norway = "Norway"
        let denmark = "Denmark"
        var b = FlatBuffersBuilder(initialSize: 20)
        let noStr = b.create(string: norway)
        let deStr = b.create(string: denmark)
        let n = Country.createCountry(builder: &b, offset: noStr, log: 888, lan: 700)
        let d = Country.createCountry(builder: &b, offset: deStr, log: 200, lan: 100)
        let vector = [n, d]
        let vectorOffset = b.createVector(ofOffsets: vector)
        b.finish(offset: vectorOffset)
        XCTAssertEqual(b.sizedArray, [4, 0, 0, 0, 2, 0, 0, 0, 48, 0, 0, 0, 16, 0, 0, 0, 0, 0, 10, 0, 18, 0, 4, 0, 8, 0, 12, 0, 10, 0, 0, 0, 40, 0, 0, 0, 100, 0, 0, 0, 200, 0, 0, 0, 0, 0, 10, 0, 16, 0, 4, 0, 8, 0, 12, 0, 10, 0, 0, 0, 24, 0, 0, 0, 188, 2, 0, 0, 120, 3, 0, 0, 7, 0, 0, 0, 68, 101, 110, 109, 97, 114, 107, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0])
    }
    
    func testCreateIntArray() {
        let numbers: [Int32] = [1, 2, 3, 4, 5]
        let b = FlatBuffersBuilder(initialSize: 20)
        let o = b.createVector(numbers, size: Int32(numbers.count))
        b.finish(offset: o)
        XCTAssertEqual(b.sizedArray, [ 4, 0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0])
    }
    
    func testCreateVectorOfStrings() {
        let strs = ["Denmark", "Norway"]
        let b = FlatBuffersBuilder(initialSize: 20)
        let o = b.createVector(ofStrings: strs)
        b.finish(offset: o)
        XCTAssertEqual(b.sizedArray, [4, 0, 0, 0, 2, 0, 0, 0, 20, 0, 0, 0, 4, 0, 0, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0, 7, 0, 0, 0, 68, 101, 110, 109, 97, 114, 107, 0])
    }
    func testCreateSharedStringVector() {
        let norway = "Norway"
        let denmark = "Denmark"
        let b = FlatBuffersBuilder(initialSize: 20)
        let noStr = b.createShared(string: norway)
        let deStr = b.createShared(string: denmark)
        let _noStr = b.createShared(string: norway)
        let _deStr = b.createShared(string: denmark)
        let v = [noStr, deStr, _noStr, _deStr]
        let end = b.createVector(ofOffsets: v)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [4, 0, 0, 0, 4, 0, 0, 0, 28, 0, 0, 0, 12, 0, 0, 0, 20, 0, 0, 0, 4, 0, 0, 0, 7, 0, 0, 0, 68, 101, 110, 109, 97, 114, 107, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0])
    }
}
