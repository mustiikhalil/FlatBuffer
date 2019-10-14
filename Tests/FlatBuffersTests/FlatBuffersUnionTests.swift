import XCTest
@testable import FlatBuffers

final class FlatBuffersUnionTests: XCTestCase {
    
    func testCreateMonstor() {
        var b = FlatBuffersBuilder(initialSize: 20)
        let dmg: Int16 = 5
        let str = "Axe"
        let axe = b.create(string: str)
        let weapon = Weapon.createWeapon(builder: &b, offset: axe, dmg: dmg)
        let weapons = b.createVector(ofOffsets: [weapon])
        let root = Monster.createMonster(builder: &b,
                                         offset: weapons,
                                         equipment: .Weapon,
                                         equippedOffset: weapon.o)
        b.finish(offset: root)
        let buffer = b.sizedArray
        XCTAssertEqual(buffer, [16, 0, 0, 0, 0, 0, 10, 0, 16, 0, 8, 0, 7, 0, 12, 0, 10, 0, 0, 0, 0, 0, 0, 1, 8, 0, 0, 0, 20, 0, 0, 0, 1, 0, 0, 0, 12, 0, 0, 0, 8, 0, 12, 0, 8, 0, 6, 0, 8, 0, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 3, 0, 0, 0, 65, 120, 101, 0])
        let monster = Monster.getRootAsMonster(bb: FlatBuffer(bytes: buffer))
        XCTAssertEqual(monster.weapon(at: 0)?.dmg, dmg)
        XCTAssertEqual(monster.weapon(at: 0)?.name, str)
        XCTAssertEqual(monster.weapon(at: 0)?.nameVector, [65, 120, 101])
        let p: Weapon? = monster.equiped()
        XCTAssertEqual(p?.dmg, dmg)
        XCTAssertEqual(p?.name, str)
        XCTAssertEqual(p?.nameVector, [65, 120, 101])
    }
}

enum Equipment: Byte { case none, Weapon }


struct Monster {
    
    private var __t: Table
    
    init(_ fb: FlatBuffer, o: Int32) { __t = Table(bb: fb, position: o) }
    init(_ t: Table) { __t = t }
    
    func weapon(at index: Int32) -> Weapon? { let o = __t.offset(4); return o == 0 ? nil : Weapon.assign(__t.indirect(__t.vector(at: o) + (index * 4)), __t.bb) }
    
    func equiped<T: FlatBufferObject>() -> T? {
        let o = __t.offset(8); return o == 0 ? nil : __t.union(o)
    }
    
    static func getRootAsMonster(bb: FlatBuffer) -> Monster {
        return Monster(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: 0))))
    }
    
    @inlinable static func createMonster(builder: inout FlatBuffersBuilder,
                                         offset: Offset<UOffset>,
                                         equipment: Equipment = .none,
                                         equippedOffset: UOffset) -> Offset<Monster> {
        let start = builder.startTable(with: 3)
        builder.add(element: equippedOffset, def: 0, at: 2)
        builder.add(offset: offset, at: 0)
        builder.add(element: equipment.rawValue, def: Equipment.none.rawValue, at: 1)
        return Offset(offset: builder.endTable(at: start))
    }
}


struct Weapon: FlatBufferObject {
    
    static let offsets: (name: VOffset, dmg: VOffset) = (0, 1)
    private var __t: Table
    
    init(_ t: Table) { __t = t }
    init(_ fb: FlatBuffer, o: Int32) { __t = Table(bb: fb, position: o)}
    
    var dmg: Int16 { let o = __t.offset(6); return o == 0 ? 0 : __t.readBuffer(of: Int16.self, offset: o) }
    var nameVector: [UInt8] { return __t.getVector(at: 4) }
    var name: String? { let o = __t.offset(4); return o == 0 ? nil : __t.string(at: o) }
    
    static func assign(_ i: Int32, _ bb: FlatBuffer) -> Weapon { return Weapon(Table(bb: bb, position: i)) }
    
    @inlinable static func createWeapon(builder: inout FlatBuffersBuilder, offset: Offset<String>, dmg: Int16) -> Offset<Weapon> {
        let _start = builder.startTable(with: 2)
        Weapon.add(builder: &builder, name: offset)
        Weapon.add(builder: &builder, dmg: dmg)
        return Weapon.end(builder: &builder, startOffset: _start)
    }
    
    @inlinable static func end(builder: inout FlatBuffersBuilder, startOffset: UOffset) -> Offset<Weapon> {
        return Offset(offset: builder.endTable(at: startOffset))
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, name: Offset<String>) {
        builder.add(offset: name, at: Weapon.offsets.name)
    }
    
    @inlinable static func add(builder: inout FlatBuffersBuilder, dmg: Int16) {
        builder.add(element: dmg, def: 0, at: Weapon.offsets.dmg)
    }
}
