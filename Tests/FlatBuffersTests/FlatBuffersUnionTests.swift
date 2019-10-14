import XCTest
@testable import FlatBuffers

final class FlatBuffersUnionTests: XCTestCase {
    
    func testCreateMonstor() {
        var b = FlatBuffersBuilder(initialSize: 20)
        let axe = b.create(string: "Axe")
        let weapon = Weapon.createWeapon(builder: &b, offset: axe, dmg: 5)
        let weapons = b.createVector(ofOffsets: [weapon])
        let root = Monster.createMonster(builder: &b,
                                         offset: weapons,
                                         equipment: .Weapon,
                                         equippedOffset: weapon.o)
        b.finish(offset: root)
        XCTAssertEqual(b.sizedArray, [16, 0, 0, 0, 0, 0, 10, 0, 16, 0, 8, 0, 7, 0, 12, 0, 10, 0, 0, 0, 0, 0, 0, 1, 8, 0, 0, 0, 20, 0, 0, 0, 1, 0, 0, 0, 12, 0, 0, 0, 8, 0, 12, 0, 8, 0, 6, 0, 8, 0, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 3, 0, 0, 0, 65, 120, 101, 0])
    }
}

enum Equipment: Byte { case none, Weapon }


struct Monster {
    
    @inlinable static func createMonster(builder: inout FlatBuffersBuilder,
                                         offset: Offset<UOffset>,
                                         equipment: Equipment = .none,
                                         equippedOffset: UOffset) -> Offset<Monster> {
        let start = builder.startTable(s: 3)
        builder.add(element: equippedOffset, def: 0, at: 2)
        builder.add(offset: offset, at: 0)
        builder.add(element: equipment.rawValue, def: Equipment.none.rawValue, at: 1)
        return Offset(offset: builder.endTable(at: start))
    }
}


struct Weapon {
    
    static let offsets: (name: VOffset, dmg: VOffset) = (0, 1)
    
    @inlinable static func createWeapon(builder: inout FlatBuffersBuilder, offset: Offset<String>, dmg: Int16) -> Offset<Weapon> {
        let _start = builder.startTable(s: 2)
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
