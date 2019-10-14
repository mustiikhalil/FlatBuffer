import XCTest
@testable import FlatBuffers

final class FlatBuffersStructsTests: XCTestCase {

    func testCreatingStruct() {
        let v = Vec(x: 3.0, y: 2.0, z: 1)
        let b = FlatBuffersBuilder(initialSize: 20)
        let end = VPointerVec.createVPointer(b: b, v: v)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 0, 0, 6, 0, 16, 0, 4, 0, 6, 0, 0, 0, 0, 0, 64, 64, 0, 0, 0, 64, 0, 0, 128, 63])
    }

    func testCreatingVectorStruct() {
        let b = FlatBuffersBuilder(initialSize: 20)
        let path = b.createVector(structs: [Vec(x: 1, y: 2, z: 3), Vec(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 8, 0, 0, 0, 4, 0, 8, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }
    
    func testCreatingVectorStructWithForcedDefaults() {
        let b = FlatBuffersBuilder(initialSize: 20, serializeDefaults: true)
        let path = b.createVector(structs: [Vec(x: 1, y: 2, z: 3), Vec(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 12, 0, 4, 0, 8, 0, 8, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }
    
    func testCreatingEnums() {
        let b = FlatBuffersBuilder(initialSize: 20)
        let path = b.createVector(structs: [Vec(x: 1, y: 2, z: 3), Vec(x: 4.0, y: 5.0, z: 6)])
        let end = VPointerVectorVec.createVPointer(b: b, color: .blue, v: path)
        b.finish(offset: end)
        XCTAssertEqual(b.sizedArray, [12, 0, 0, 0, 8, 0, 12, 0, 4, 0, 8, 0, 8, 0, 0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64])
    }
}

struct Vec: Struct {
    private var _x: Float32
    private var _y: Float32
    private var _z: Float32

    init(x: Float32, y: Float32, z: Float32) {
        _x = x
        _y = y
        _z = z
    }
}

enum Color: UInt32 { case red = 0, green = 1, blue = 2 }

struct VPointerVec {

    static func startVPointer(b: FlatBuffersBuilder) -> UOffset { b.startTable(s: 1) }
    static func addVector(b: FlatBuffersBuilder, v: Vec) { b.create(struct: v, field: 0) }
    static func finish(b: FlatBuffersBuilder, s: UOffset) -> Offset<UOffset> { return Offset(offset: b.endTable(at: s)) }

    static func createVPointer(b: FlatBuffersBuilder, v: Vec) -> Offset<UOffset> {
        let s = VPointerVec.startVPointer(b: b)
        VPointerVec.addVector(b: b, v: v)
        return VPointerVec.finish(b: b, s: s)
    }
}

private let VPointerVectorVecOffsets: (color: VOffset, vector: VOffset) = (0, 1)

struct VPointerVectorVec {

    static func startVPointer(b: FlatBuffersBuilder) -> UOffset { b.startTable(s: 2) }

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
