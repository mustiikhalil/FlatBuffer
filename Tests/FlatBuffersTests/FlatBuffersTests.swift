import XCTest
@testable import FlatBuffers

final class FlatBuffersTests: XCTestCase {

    let country = "Norway"
    
    func testEndian() { print("endian test: ", CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue)) }

    func testCreateString() {
        let helloWorld = "Hello, world!"
        let b = FlatBuffersBuilder(initialSize: 16)
        XCTAssertEqual(b.create(string: country).o, 12)
        XCTAssertEqual(b.create(string: helloWorld).o, 32)
        b.clear()
        XCTAssertEqual(b.create(string: helloWorld).o, 20)
        XCTAssertEqual(b.create(string: country).o, 32)
    }
    
    func testStartTable() {
        let b = FlatBuffersBuilder(initialSize: 16)
        XCTAssertNoThrow(b.startTable())
        b.clear()
        XCTAssertEqual(b.create(string: country).o, 12)
        XCTAssertEqual(b.startTable(), 12)
    }
    
    func testCreate() {
        var b = FlatBuffersBuilder(initialSize: 16)
        _ = Country.createCountry(builder: &b, name: country, log: 200, lan: 100)
        let v: [UInt8] = [10, 0, 16, 0, 4, 0, 8, 0, 12, 0, 10, 0, 0, 0, 12, 0, 0, 0, 100, 0, 0, 0, 200, 0, 0, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0]
        XCTAssertEqual(b.sizedArray, v)
    }
    
    func testCreateFinish() {
        var b = FlatBuffersBuilder(initialSize: 16)
        let countryOff = Country.createCountry(builder: &b, name: country, log: 200, lan: 100)
        b.finish(offset: countryOff)
        let v: [UInt8] = [16, 0, 0, 0, 0, 0, 10, 0, 16, 0, 4, 0, 8, 0, 12, 0, 10, 0, 0, 0, 12, 0, 0, 0, 100, 0, 0, 0, 200, 0, 0, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0]
        XCTAssertEqual(b.sizedArray, v)
    }
    
    func testCreateFinishWithPrefix() {
        var b = FlatBuffersBuilder(initialSize: 16)
        let countryOff = Country.createCountry(builder: &b, name: country, log: 200, lan: 100)
        b.finish(offset: countryOff, addPrefix: true)
        let v: [UInt8] = [44, 0, 0, 0, 16, 0, 0, 0, 0, 0, 10, 0, 16, 0, 4, 0, 8, 0, 12, 0, 10, 0, 0, 0, 12, 0, 0, 0, 100, 0, 0, 0, 200, 0, 0, 0, 6, 0, 0, 0, 78, 111, 114, 119, 97, 121, 0, 0, ]
        XCTAssertEqual(b.sizedArray, v)
    }
}

class Country {
    
    static let offsets: (name: VOffset, lan: VOffset, lng: VOffset) = (4,6,8)
    
    private var table: Table
    
    public var lan: Int { get {
        let o = table.offset(Int32(Country.offsets.lan))
        return o != 0 ? Int(table._bb.read(def: Int32.self, position: Int(o + table._postion), with: MemoryLayout<Int32>.size)) : 0
        }
    }
    
    private init(table t: Table) { table = t }
    
    @inlinable static func getRootAsCountry(_ bb: FlatBuffer) -> Country {
        let pos = bb.read(def: Int32.self, position: Int(bb.size), with: MemoryLayout<Int32>.size)
        return Country(table: Table(bb: bb, position: Int32(pos)))
    }
    
    @inlinable static func createCountry(builder: inout FlatBuffersBuilder, name: String, log: Int32, lan: Int32) -> Offset<Country> {
        return createCountry(builder: &builder, offset: builder.create(string: name), log: log, lan: lan)
    }
    
    @inlinable static func createCountry(builder: inout FlatBuffersBuilder, offset: Offset<String>, log: Int32, lan: Int32) -> Offset<Country> {
        let _start = builder.startTable()
        Country.add(builder: &builder, lng: log)
        Country.add(builder: &builder, lan: lan)
        Country.add(builder: &builder, name: offset)
        return Country.end(builder: &builder, startOffset: _start)
    }
    
    @inlinable static func end(builder: inout FlatBuffersBuilder, startOffset: UOffset) -> Offset<Country> {
        return Offset(offset: builder.endTable(at: startOffset))
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, name: String) {
        add(builder: &builder, name: builder.create(string: name))
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, name: Offset<String>) {
        builder.add(offset: name, at: Country.offsets.name)
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, lan: Int32) {
        builder.add(element: lan, def: 0, at: Country.offsets.lan)
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, lng: Int32) {
        builder.add(element: lng, def: 0, at: Country.offsets.lng)
    }
}
