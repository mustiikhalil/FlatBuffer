import XCTest
@testable import FlatBuffers

final class FlatBuffersUnionTests: XCTestCase {

    func testCreateMonstor() {

        var b = FlatBufferBuilder(initialSize: 20)
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
        let buffer = b.sizedByteArray
        XCTAssertEqual(buffer, [16, 0, 0, 0, 0, 0, 10, 0, 16, 0, 8, 0, 7, 0, 12, 0, 10, 0, 0, 0, 0, 0, 0, 1, 8, 0, 0, 0, 20, 0, 0, 0, 1, 0, 0, 0, 12, 0, 0, 0, 8, 0, 12, 0, 8, 0, 6, 0, 8, 0, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 3, 0, 0, 0, 65, 120, 101, 0])
        let monster = Monster.getRootAsMonster(bb: ByteBuffer(bytes: buffer))
        XCTAssertEqual(monster.weapon(at: 0)?.dmg, dmg)
        XCTAssertEqual(monster.weapon(at: 0)?.name, str)
        XCTAssertEqual(monster.weapon(at: 0)?.nameVector, [65, 120, 101])
        let p: Weapon? = monster.equiped()
        XCTAssertEqual(p?.dmg, dmg)
        XCTAssertEqual(p?.name, str)
        XCTAssertEqual(p?.nameVector, [65, 120, 101])
    }

    func testEndTableFinish() {
        var builder = FlatBufferBuilder(initialSize: 20)
        let sword = builder.create(string: "Sword")
        let axe = builder.create(string: "Axe")
        let weaponOne = Weapon.createWeapon(builder: &builder, offset: sword, dmg: 3)
        let weaponTwo = Weapon.createWeapon(builder: &builder, offset: axe, dmg: 5)
        let name = builder.create(string: "Orc")
        let inventory: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let inv = builder.createVector(inventory, size: 10)
        let weapons = builder.createVector(ofOffsets: [weaponOne, weaponTwo])
        var vecArray: [UnsafeMutableRawPointer] = []
        vecArray.append(createVecWrite(x: 4.0, y: 5.0, z: 6.0))
        vecArray.append(createVecWrite(x: 1.0, y: 2.0, z: 3.0))
        let path = builder.createVector(structs: vecArray, type: Vec.self)
        let orc = FinalMonster.createMonster(builder: &builder,
                                             position: builder.create(struct: createVecWrite(x: 1.0, y: 2.0, z: 3.0), type: Vec.self),
                                             hp: 300,
                                             name: name,
                                             inventory: inv,
                                             color: .red,
                                             weapons: weapons,
                                             equipment: .Weapon,
                                             equippedOffset: weaponTwo,
                                             path: path)
        builder.finish(offset: orc)
        XCTAssertEqual(builder.sizedByteArray, [32, 0, 0, 0, 0, 0, 26, 0, 36, 0, 36, 0, 0, 0, 34, 0, 28, 0, 0, 0, 24, 0, 23, 0, 16, 0, 15, 0, 8, 0, 4, 0, 26, 0, 0, 0, 44, 0, 0, 0, 104, 0, 0, 0, 0, 0, 0, 1, 60, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 76, 0, 0, 0, 0, 0, 44, 1, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 2, 0, 0, 0, 0, 0, 128, 64, 0, 0, 160, 64, 0, 0, 192, 64, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 2, 0, 0, 0, 52, 0, 0, 0, 28, 0, 0, 0, 10, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 3, 0, 0, 0, 79, 114, 99, 0, 244, 255, 255, 255, 0, 0, 5, 0, 24, 0, 0, 0, 8, 0, 12, 0, 8, 0, 6, 0, 8, 0, 0, 0, 0, 0, 3, 0, 12, 0, 0, 0, 3, 0, 0, 0, 65, 120, 101, 0, 5, 0, 0, 0, 83, 119, 111, 114, 100, 0, 0, 0])
    }
    
    func testEnumVector() {
        let vectorOfEnums: [ColorsNameSpace.RGB] = [.blue, .green]
        
        let builder = FlatBufferBuilder(initialSize: 1)
        let off = builder.createVector(vectorOfEnums)
        let start = ColorsNameSpace.Monster.startMonster(builder)
        ColorsNameSpace.Monster.add(colors: off, builder)
        let end = ColorsNameSpace.Monster.endMonster(builder, start: start)
        builder.finish(offset: end)
        XCTAssertEqual(builder.sizedByteArray, [12, 0, 0, 0, 0, 0, 6, 0, 8, 0, 4, 0, 6, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0])
        let monster = ColorsNameSpace.Monster.getRootAsMonster(bb: builder.buffer)
        XCTAssertEqual(monster.colorsCount, 2)
        XCTAssertEqual(monster.colors(at: 0), .blue)
        XCTAssertEqual(monster.colors(at: 1), .green)
    }
    
    func testUnionVector() {
        let networkData: [UInt8] = [16, 0, 0, 0, 12, 0, 20, 0, 19, 0, 12, 0, 8, 0, 4, 0, 12, 0, 0, 0, 16, 0, 0, 0, 24, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0, 3, 2, 0, 0, 0, 36, 0, 0, 0, 16, 0, 0, 0, 2, 0, 0, 0, 3, 1, 6, 0, 10, 0, 4, 0, 6, 0, 0, 0, 20, 0, 0, 0, 0, 0, 6, 0, 8, 0, 4, 0, 6, 0, 0, 0, 16, 0, 0, 0, 4, 0, 0, 0, 48, 48, 48, 48, 0, 0, 0, 0, 17, 0, 0, 0, 101, 109, 97, 105, 108, 64, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109, 0, 0, 0]
        let _email = "email@example.com"
        let _number = "0000"
        let fb = FlatBufferBuilder(initialSize: 1)
        let email = fb.create(string: _email)
        let number = fb.create(string: _number)
        let emailStart = Email.startEmail(fb)
        Email.add(value: email, fb)
        let emailOffset = Email.endEmail(fb, start: emailStart)
        
        let telefonStart = Telefon.startTelefon(fb)
        Telefon.add(number: number, fb)
        let telefonOffset = Telefon.endTelefon(fb, start: telefonStart)
        
        let types: [Address] = [.email, .telefon]
        let otherTypes = fb.createVector(types)
        let otherAddress = fb.createVector(ofOffsets: [emailOffset, telefonOffset])
        
        let personStart = Person.startPerson(fb)
        Person.add(mainAddressType: .email, fb)
        Person.add(mainAddress: emailOffset, fb)
        Person.add(otherAddressesType: otherTypes, fb)
        Person.add(otherAddresses: otherAddress, fb)
        let root = Person.endPerson(fb, start: personStart)
        fb.finish(offset: root)
        
        let array = fb.sizedByteArray
        XCTAssertEqual(array, networkData)
        
        let person = Person.getRootAsPerson(bb: ByteBuffer(bytes: networkData))
        
        XCTAssertEqual(person.mainAddressType, .email)
        XCTAssertEqual(person.mainAddress(type: Email.self)?.value, _email)
        
        XCTAssertEqual(person.otherAddressesCount, 2)
        XCTAssertEqual(person.otherAddressesTypeCount, 2)
        XCTAssertEqual(person.otherAddressesType(at: 0), .email)
        XCTAssertEqual(person.otherAddressesType(at: 1), .telefon)
        XCTAssertEqual(person.otherAddresses(at: 0, type: Email.self)?.value, _email)
        XCTAssertEqual(person.otherAddresses(at: 1, type: Telefon.self)?.number, _number)
    }
}

public enum ColorsNameSpace {

enum RGB: Int32, Enum {
    typealias T = Int32
    static var byteSize: Int { return MemoryLayout<Int32>.size }
    var value: Int32 { return self.rawValue }
    case red = 0, green = 1, blue = 2
}

struct Monster: FlatBufferObject {
    private var _accessor: Table
    static func getRootAsMonster(bb: ByteBuffer) -> Monster { return Monster(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    init(_ t: Table) { _accessor = t }
    init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var colorsCount: Int32 { let o = _accessor.offset(4); return o == 0 ? 0 : _accessor.vector(count: o) }
    public func colors(at index: Int32) -> ColorsNameSpace.RGB? { let o = _accessor.offset(4); return o == 0 ? ColorsNameSpace.RGB(rawValue: 0)! : ColorsNameSpace.RGB(rawValue: _accessor.directRead(of: Int32.self, offset: _accessor.vector(at: o) + index * 4)) }
    static func startMonster(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    static func add(colors: Offset<UOffset>, _ fbb: FlatBufferBuilder) { fbb.add(offset: colors, at: 0)  }
    static func endMonster(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
}
}


enum Equipment: Byte { case none, Weapon }

enum Color3: Int8 { case red = 0, green, blue }

struct FinalMonster {

    @inlinable static func createMonster(builder: inout FlatBufferBuilder,
                                         position: Offset<UOffset>,
                                         hp: Int16,
                                         name: Offset<String>,
                                         inventory: Offset<UOffset>,
                                         color: Color3,
                                         weapons: Offset<UOffset>,
                                         equipment: Equipment = .none,
                                         equippedOffset: Offset<Weapon>,
                                         path: Offset<UOffset>) -> Offset<Monster> {
        let start = builder.startTable(with: 11)
        builder.add(structOffset: 0)
        builder.add(element: hp, def: 100, at: 2)
        builder.add(offset: name, at: 3)
        builder.add(offset: inventory, at: 5)
        builder.add(element: color.rawValue, def: Color3.green.rawValue, at: 6)
        builder.add(offset: weapons, at: 7)
        builder.add(element: equipment.rawValue, def: Equipment.none.rawValue, at: 8)
        builder.add(offset: equippedOffset, at: 9)
        builder.add(offset: path, at: 10)
        return Offset(offset: builder.endTable(at: start))
    }
}

struct Monster {

    private var __t: Table

    init(_ fb: ByteBuffer, o: Int32) { __t = Table(bb: fb, position: o) }
    init(_ t: Table) { __t = t }

    func weapon(at index: Int32) -> Weapon? { let o = __t.offset(4); return o == 0 ? nil : Weapon.assign(__t.indirect(__t.vector(at: o) + (index * 4)), __t.bb) }

    func equiped<T: FlatBufferObject>() -> T? {
        let o = __t.offset(8); return o == 0 ? nil : __t.union(o)
    }

    static func getRootAsMonster(bb: ByteBuffer) -> Monster {
        return Monster(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: 0))))
    }

    @inlinable static func createMonster(builder: inout FlatBufferBuilder,
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
    init(_ fb: ByteBuffer, o: Int32) { __t = Table(bb: fb, position: o)}

    var dmg: Int16 { let o = __t.offset(6); return o == 0 ? 0 : __t.readBuffer(of: Int16.self, at: o) }
    var nameVector: [UInt8]? { return __t.getVector(at: 4) }
    var name: String? { let o = __t.offset(4); return o == 0 ? nil : __t.string(at: o) }

    static func assign(_ i: Int32, _ bb: ByteBuffer) -> Weapon { return Weapon(Table(bb: bb, position: i)) }

    @inlinable static func createWeapon(builder: inout FlatBufferBuilder, offset: Offset<String>, dmg: Int16) -> Offset<Weapon> {
        let _start = builder.startTable(with: 2)
        Weapon.add(builder: &builder, name: offset)
        Weapon.add(builder: &builder, dmg: dmg)
        return Weapon.end(builder: &builder, startOffset: _start)
    }

    @inlinable static func end(builder: inout FlatBufferBuilder, startOffset: UOffset) -> Offset<Weapon> {
        return Offset(offset: builder.endTable(at: startOffset))
    }

    @inlinable static func add(builder: inout FlatBufferBuilder, name: Offset<String>) {
        builder.add(offset: name, at: Weapon.offsets.name)
    }

    @inlinable static func add(builder: inout FlatBufferBuilder, dmg: Int16) {
        builder.add(element: dmg, def: 0, at: Weapon.offsets.dmg)
    }
}

typealias Person = Contacts.Person
typealias Address = Contacts.Address
typealias Email = Contacts.Email
typealias Telefon = Contacts.Telefon

public enum Contacts {

public enum Mood: Int8, Enum {
    public typealias T = Int8
    public static var byteSize: Int { return MemoryLayout<Int8>.size }
    public var value: Int8 { return self.rawValue }
    case good = 0, bad = 1, its_something = 2
}

public enum Address: UInt8, Enum {
    public typealias T = UInt8
    public static var byteSize: Int { return MemoryLayout<UInt8>.size }
    public var value: UInt8 { return self.rawValue }
    case none = 0, telefon = 1, urls = 2, email = 3
}

public struct Telefon: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsTelefon(bb: ByteBuffer) -> Telefon { return Telefon(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var number: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
    public var numberSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
    public static func startTelefon(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    public static func add(number: Offset<String>, _ fbb: FlatBufferBuilder) { fbb.add(offset: number, at: 0)  }
    public static func endTelefon(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
}

public struct URLs: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsURLs(bb: ByteBuffer) -> URLs { return URLs(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var value: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
    public var valueSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
    public static func startURLs(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    public static func add(value: Offset<String>, _ fbb: FlatBufferBuilder) { fbb.add(offset: value, at: 0)  }
    public static func endURLs(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
}

public struct Email: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsEmail(bb: ByteBuffer) -> Email { return Email(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var value: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
    public var valueSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
    public static func startEmail(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    public static func add(value: Offset<String>, _ fbb: FlatBufferBuilder) { fbb.add(offset: value, at: 0)  }
    public static func endEmail(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
}

public struct Person: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsPerson(bb: ByteBuffer) -> Person { return Person(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var mainAddressType: Contacts.Address { let o = _accessor.offset(4); return o == 0 ? Contacts.Address(rawValue: 0)! : Contacts.Address(rawValue: _accessor.readBuffer(of: UInt8.self, at: o)) ?? Contacts.Address(rawValue: 0)! }
    public func mutate(mainAddressType: Contacts.Address) -> Bool {let o = _accessor.offset(4);  return _accessor.mutate(mainAddressType.rawValue, index: o) }
    public func mainAddress<T: FlatBufferObject>(type: T.Type) -> T? { let o = _accessor.offset(6); return o == 0 ? nil : _accessor.union(o) }
    public var otherAddressesTypeCount: Int32 { let o = _accessor.offset(8); return o == 0 ? 0 : _accessor.vector(count: o) }
    public func otherAddressesType(at index: Int32) -> Contacts.Address? { let o = _accessor.offset(8); return o == 0 ? Contacts.Address(rawValue: 0)! : Contacts.Address(rawValue: _accessor.directRead(of: UInt8.self, offset: _accessor.vector(at: o) + index * 1)) }
    public var otherAddressesCount: Int32 { let o = _accessor.offset(10); return o == 0 ? 0 : _accessor.vector(count: o) }
    public func otherAddresses<T: FlatBufferObject>(at index: Int32, type: T.Type) -> T? { let o = _accessor.offset(10); return o == 0 ? nil : _accessor.directUnion(_accessor.vector(at: o) + index * 4) }
    public static func startPerson(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 4) }
    public static func add(mainAddressType: Contacts.Address, _ fbb: FlatBufferBuilder) { fbb.add(element: mainAddressType.rawValue, def: 0, at: 0) }
    public static func add(mainAddress: Offset<UOffset>, _ fbb: FlatBufferBuilder) { fbb.add(offset: mainAddress, at: 1)  }
    public static func add(otherAddressesType: Offset<UOffset>, _ fbb: FlatBufferBuilder) { fbb.add(offset: otherAddressesType, at: 2)  }
    public static func add(otherAddresses: Offset<UOffset>, _ fbb: FlatBufferBuilder) { fbb.add(offset: otherAddresses, at: 3)  }
    public static func endPerson(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
}

}

// MARK: - Contacts


