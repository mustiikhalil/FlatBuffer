import XCTest
@testable import FlatBuffers

final class FlatBuffersStructsTests: XCTestCase {

    func testCreatingStruct() {
        let v = Vec_Write(x: 1.0, y: 2.0, z: 3.0)
        let b = FlatBuffersBuilder(initialSize: 20)
        let o = Vec_Write.createVec(b, v: v)
        let end = VPointerVec.createVPointer(b: b, o: o)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 0, 0, 6, 0, 4, 0, 4, 0, 6, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64])
    }
    
    func testReadingStruct() {
        let v = Vec_Write(x: 1.0, y: 2.0, z: 3.0)
        let b = FlatBuffersBuilder(initialSize: 20)
        let o = Vec_Write.createVec(b, v: v)
        let end = VPointerVec.createVPointer(b: b, o: o)
        b.finish(offset: end)
        let buffer = b.sizedArray
        XCTAssertEqual(buffer, [12, 0, 0, 0, 0, 0, 6, 0, 4, 0, 4, 0, 6, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64])
        let point = VPointerVec.getRootAsCountry(FlatBuffer(bytes: buffer))
        XCTAssertEqual(point.vec?.z, v._z)
    }

    func testCreatingVectorStruct() {
        let b = FlatBuffersBuilder(initialSize: 20)
        let path = b.createVector(structs: [Vec_Write(x: 1, y: 2, z: 3), Vec_Write(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 8, 0, 0, 0, 4, 0, 8, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }

    func testCreatingVectorStructWithForcedDefaults() {
        let b = FlatBuffersBuilder(initialSize: 20, serializeDefaults: true)
        let path = b.createVector(structs: [Vec_Write(x: 1, y: 2, z: 3), Vec_Write(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 12, 0, 4, 0, 8, 0, 8, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }

    func testCreatingEnums() {
        let b = FlatBuffersBuilder(initialSize: 20)
        let path = b.createVector(structs: [Vec_Write(x: 1, y: 2, z: 3), Vec_Write(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, color: .blue, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 12, 0, 4, 0, 8, 0, 8, 0, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }

    func testReadingStructWithEnums() {
        let b = FlatBuffersBuilder(initialSize: 20)
        let vec = Vec2(x: 1.0, y: 2.0, z: 3.0, color: .red)
        let o = Vec2.createVec2(b, v: vec)
        let end = VPointerVec2.createVPointer(b: b, o: o, type: .vec)
        b.finish(offset: end)
        let buffer = b.sizedArray
        XCTAssertEqual(buffer, [16, 0, 0, 0, 0, 0, 10, 0, 12, 0, 12, 0, 11, 0, 4, 0, 10, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 0, 0])
        let point = VPointerVec2.getRootAsCountry(FlatBuffer(bytes: buffer))
        XCTAssertEqual(point.vec?.c, vec._c)
        XCTAssertEqual(point.vec?.x, vec._x)
        XCTAssertEqual(point.vec?.y, vec._y)
        XCTAssertEqual(point.vec?.z, vec._z)
        XCTAssertEqual(point.UType, Test.vec)
    }

}

struct Vec_Write: Writeable {
    var _x: Float32
    var _y: Float32
    var _z: Float32
    
    init(x: Float32 = 0, y: Float32 = 0, z: Float32 = 0) { _x = x; _y = y; _z = z; }
    static func createVec(_ bb: FlatBuffersBuilder, v: Vec_Write) -> Offset<UOffset> {
        return bb.create(struct: v)
    }
}

struct Vec_Read: Readable {
    private var __p: Struct
    init(_ fb: FlatBuffer, o: Int32) { __p = Struct(bb: fb, position: o) }
    var x: Float32 { return __p.readBuffer(of: Float32.self, at: 0)}
    var y: Float32 { return __p.readBuffer(of: Float32.self, at: 4)}
    var z: Float32 { return __p.readBuffer(of: Float32.self, at: 8)}
}

struct VPointerVec {

    private var __t: Table

    private init(_ t: Table) {
        __t = t
    }

    var vec: Vec_Read? { let o = __t.offset(4); return o == 0 ? nil : Vec_Read(__t.bb, o: o + __t.postion) }

    @inlinable static func getRootAsCountry(_ bb: FlatBuffer) -> VPointerVec {
        return VPointerVec(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: 0))))
    }

    static func startVPointer(b: FlatBuffersBuilder) -> UOffset { b.startTable(with: 1) }
    static func finish(b: FlatBuffersBuilder, s: UOffset) -> Offset<UOffset> { return Offset(offset: b.endTable(at: s)) }

    static func createVPointer(b: FlatBuffersBuilder, o: Offset<UOffset>) -> Offset<UOffset> {
        let s = VPointerVec.startVPointer(b: b)
        b.add(structOffset: 0)
        return VPointerVec.finish(b: b, s: s)
    }
}

enum Color: UInt32 { case red = 0, green = 1, blue = 2 }

private let VPointerVectorVecOffsets: (color: VOffset, vector: VOffset) = (0, 1)

struct VPointerVectorVec {

    static func startVPointer(b: FlatBuffersBuilder) -> UOffset { b.startTable(with: 2) }

    static func addVector(b: FlatBuffersBuilder, v: Offset<UOffset>) { b.add(offset: v, at: VPointerVectorVecOffsets.vector) }

    static func addColor(b: FlatBuffersBuilder, color: Color) { b.add(element: color.rawValue, def: 1, at: VPointerVectorVecOffsets.color) }

    static func finish(b: FlatBuffersBuilder, s: UOffset) -> Offset<UOffset> { return Offset(offset: b.endTable(at: s)) }

    static func createVPointer(b: FlatBuffersBuilder, color: Color = .green, v: Offset<UOffset>) -> Offset<UOffset> {
        let s = VPointerVectorVec.startVPointer(b: b)
        VPointerVectorVec.addVector(b: b, v: v)
        VPointerVectorVec.addColor(b: b, color: color)
        return VPointerVectorVec.finish(b: b, s: s)
    }
}

enum Color2: Int32 { case red = 0, green = 1, blue = 2 }
enum Test: Byte { case none = 0, vec = 1 }

struct Vec2: Writeable {
    var _x: Float32
    var _y: Float32
    var _z: Float32
    var _c: Color2
    
    init(x: Float32, y: Float32, z: Float32, color: Color2) { _c = color; _x = x; _y = y; _z = z }
    
    static func createVec2(_ bb: FlatBuffersBuilder, v: Vec2) -> Offset<UOffset> {
        return bb.create(struct: v)
    }
}

struct Vec2_Read: Readable {
    private var __p: Struct
    init(_ fb: FlatBuffer, o: Int32) { __p = Struct(bb: fb, position: o) }
    var c: Color2 { return Color2(rawValue: __p.readBuffer(of: Int32.self, at: 12)) ?? .red }
    var x: Float32 { return __p.readBuffer(of: Float32.self, at: 0)}
    var y: Float32 { return __p.readBuffer(of: Float32.self, at: 4)}
    var z: Float32 { return __p.readBuffer(of: Float32.self, at: 8)}
}

struct VPointerVec2 {

    private var __t: Table

    private init(_ t: Table) {
        __t = t
    }
    
    var vec: Vec2_Read? { let o = __t.offset(4); return o == 0 ? nil : Vec2_Read( __t.bb, o: o + __t.postion) }
    var UType: Test? { let o = __t.offset(6); return o == 0 ? Test.none : Test(rawValue: __t.readBuffer(of: Byte.self, offset: o)) }

    @inlinable static func getRootAsCountry(_ bb: FlatBuffer) -> VPointerVec2 {
        return VPointerVec2(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: 0))))
    }

    static func startVPointer(b: FlatBuffersBuilder) -> UOffset { b.startTable(with: 3) }
    static func finish(b: FlatBuffersBuilder, s: UOffset) -> Offset<UOffset> { return Offset(offset: b.endTable(at: s)) }

    static func createVPointer(b: FlatBuffersBuilder, o: Offset<UOffset>, type: Test) -> Offset<UOffset> {
        let s = VPointerVec2.startVPointer(b: b)
        b.add(structOffset: 0)
        b.add(element: type.rawValue, def: Test.none.rawValue, at: 1)
        b.add(offset: o, at: 2)
        return VPointerVec2.finish(b: b, s: s)
    }
}
