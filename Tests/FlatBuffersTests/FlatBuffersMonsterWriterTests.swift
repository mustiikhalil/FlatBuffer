import XCTest
import Foundation
@testable import FlatBuffers

class FlatBuffersMonsterWriterTests: XCTestCase {
    
    func testData() {
        let data = Data([48, 0, 0, 0, 77, 79, 78, 83, 0, 0, 0, 0, 36, 0, 72, 0, 40, 0, 0, 0, 38, 0, 32, 0, 0, 0, 28, 0, 0, 0, 27, 0, 20, 0, 16, 0, 12, 0, 4, 0, 0, 0, 0, 0, 0, 0, 11, 0, 36, 0, 0, 0, 164, 0, 0, 0, 0, 0, 0, 1, 60, 0, 0, 0, 68, 0, 0, 0, 76, 0, 0, 0, 0, 0, 0, 1, 88, 0, 0, 0, 120, 0, 0, 0, 0, 0, 80, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 64, 2, 0, 5, 0, 6, 0, 0, 0, 2, 0, 0, 0, 64, 0, 0, 0, 48, 0, 0, 0, 2, 0, 0, 0, 30, 0, 40, 0, 10, 0, 20, 0, 152, 255, 255, 255, 4, 0, 0, 0, 4, 0, 0, 0, 70, 114, 101, 100, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 50, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 49, 0, 0, 0, 9, 0, 0, 0, 77, 121, 77, 111, 110, 115, 116, 101, 114, 0, 0, 0, 3, 0, 0, 0, 20, 0, 0, 0, 36, 0, 0, 0, 4, 0, 0, 0, 240, 255, 255, 255, 32, 0, 0, 0, 248, 255, 255, 255, 36, 0, 0, 0, 12, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 0, 12, 0, 0, 0, 28, 0, 0, 0, 5, 0, 0, 0, 87, 105, 108, 109, 97, 0, 0, 0, 6, 0, 0, 0, 66, 97, 114, 110, 101, 121, 0, 0, 5, 0, 0, 0, 70, 114, 111, 100, 111, 0, 0, 0])
        let _data = FlatBuffer(data: data)
        readMonster(fb: _data)
    }
    
    func testReadFromOtherLangagues() {
        let path = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path, isDirectory: true).appendingPathComponent("monsterdata_test").appendingPathExtension("mon")
        guard let data = try? Data(contentsOf: url) else { return }
        let _data = FlatBuffer(data: data)
        readMonster(fb: _data)
    }
    
    func testCreateMonster() {
        let bytes = createMonster(withPrefix: false)
        XCTAssertEqual(bytes.sizedByteArray, [48, 0, 0, 0, 77, 79, 78, 83, 0, 0, 0, 0, 36, 0, 72, 0, 40, 0, 0, 0, 38, 0, 32, 0, 0, 0, 28, 0, 0, 0, 27, 0, 20, 0, 16, 0, 12, 0, 4, 0, 0, 0, 0, 0, 0, 0, 11, 0, 36, 0, 0, 0, 164, 0, 0, 0, 0, 0, 0, 1, 60, 0, 0, 0, 68, 0, 0, 0, 76, 0, 0, 0, 0, 0, 0, 1, 88, 0, 0, 0, 120, 0, 0, 0, 0, 0, 80, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 64, 2, 0, 5, 0, 6, 0, 0, 0, 2, 0, 0, 0, 64, 0, 0, 0, 48, 0, 0, 0, 2, 0, 0, 0, 30, 0, 40, 0, 10, 0, 20, 0, 152, 255, 255, 255, 4, 0, 0, 0, 4, 0, 0, 0, 70, 114, 101, 100, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 50, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 49, 0, 0, 0, 9, 0, 0, 0, 77, 121, 77, 111, 110, 115, 116, 101, 114, 0, 0, 0, 3, 0, 0, 0, 20, 0, 0, 0, 36, 0, 0, 0, 4, 0, 0, 0, 240, 255, 255, 255, 32, 0, 0, 0, 248, 255, 255, 255, 36, 0, 0, 0, 12, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 0, 12, 0, 0, 0, 28, 0, 0, 0, 5, 0, 0, 0, 87, 105, 108, 109, 97, 0, 0, 0, 6, 0, 0, 0, 66, 97, 114, 110, 101, 121, 0, 0, 5, 0, 0, 0, 70, 114, 111, 100, 111, 0, 0, 0])
        readMonster(fb: bytes.buffer)
        mutateMonster(fb: bytes.buffer)
        readMonster(fb: bytes.buffer)
    }
    
    func testCreateMonsterResizedBuffer() {
        let bytes = createMonster(withPrefix: false)
        XCTAssertEqual(bytes.sizedByteArray, [48, 0, 0, 0, 77, 79, 78, 83, 0, 0, 0, 0, 36, 0, 72, 0, 40, 0, 0, 0, 38, 0, 32, 0, 0, 0, 28, 0, 0, 0, 27, 0, 20, 0, 16, 0, 12, 0, 4, 0, 0, 0, 0, 0, 0, 0, 11, 0, 36, 0, 0, 0, 164, 0, 0, 0, 0, 0, 0, 1, 60, 0, 0, 0, 68, 0, 0, 0, 76, 0, 0, 0, 0, 0, 0, 1, 88, 0, 0, 0, 120, 0, 0, 0, 0, 0, 80, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 64, 2, 0, 5, 0, 6, 0, 0, 0, 2, 0, 0, 0, 64, 0, 0, 0, 48, 0, 0, 0, 2, 0, 0, 0, 30, 0, 40, 0, 10, 0, 20, 0, 152, 255, 255, 255, 4, 0, 0, 0, 4, 0, 0, 0, 70, 114, 101, 100, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 50, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 49, 0, 0, 0, 9, 0, 0, 0, 77, 121, 77, 111, 110, 115, 116, 101, 114, 0, 0, 0, 3, 0, 0, 0, 20, 0, 0, 0, 36, 0, 0, 0, 4, 0, 0, 0, 240, 255, 255, 255, 32, 0, 0, 0, 248, 255, 255, 255, 36, 0, 0, 0, 12, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 0, 12, 0, 0, 0, 28, 0, 0, 0, 5, 0, 0, 0, 87, 105, 108, 109, 97, 0, 0, 0, 6, 0, 0, 0, 66, 97, 114, 110, 101, 121, 0, 0, 5, 0, 0, 0, 70, 114, 111, 100, 111, 0, 0, 0])
        readMonster(fb: FlatBuffer(data: Data(bytes.sizedByteArray)))
    }
    
    func testCreateMonsterPrefixed() {
        let bytes = createMonster(withPrefix: true)
        XCTAssertEqual(bytes.sizedByteArray, [44, 1, 0, 0, 44, 0, 0, 0, 77, 79, 78, 83, 36, 0, 72, 0, 40, 0, 0, 0, 38, 0, 32, 0, 0, 0, 28, 0, 0, 0, 27, 0, 20, 0, 16, 0, 12, 0, 4, 0, 0, 0, 0, 0, 0, 0, 11, 0, 36, 0, 0, 0, 164, 0, 0, 0, 0, 0, 0, 1, 60, 0, 0, 0, 68, 0, 0, 0, 76, 0, 0, 0, 0, 0, 0, 1, 88, 0, 0, 0, 120, 0, 0, 0, 0, 0, 80, 0, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 64, 2, 0, 5, 0, 6, 0, 0, 0, 2, 0, 0, 0, 64, 0, 0, 0, 48, 0, 0, 0, 2, 0, 0, 0, 30, 0, 40, 0, 10, 0, 20, 0, 152, 255, 255, 255, 4, 0, 0, 0, 4, 0, 0, 0, 70, 114, 101, 100, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 50, 0, 0, 0, 5, 0, 0, 0, 116, 101, 115, 116, 49, 0, 0, 0, 9, 0, 0, 0, 77, 121, 77, 111, 110, 115, 116, 101, 114, 0, 0, 0, 3, 0, 0, 0, 20, 0, 0, 0, 36, 0, 0, 0, 4, 0, 0, 0, 240, 255, 255, 255, 32, 0, 0, 0, 248, 255, 255, 255, 36, 0, 0, 0, 12, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 0, 12, 0, 0, 0, 28, 0, 0, 0, 5, 0, 0, 0, 87, 105, 108, 109, 97, 0, 0, 0, 6, 0, 0, 0, 66, 97, 114, 110, 101, 121, 0, 0, 5, 0, 0, 0, 70, 114, 111, 100, 111, 0, 0, 0])
        
        let newBuf = FlatBuffersUtils.removeSizePrefix(bb: bytes.buffer)
        readMonster(fb: newBuf)
        let monster = Monster_1.getRootAsMonster(bb: newBuf)
        let secondaryBuf = FlatBuffer(bytes: bytes.sizedByteArray)
        _ = monster.mutate(testType: .NONE)
        let sBuf = FlatBuffersUtils.removeSizePrefix(bb: secondaryBuf)
        readMonster(fb: sBuf)
        _ = monster.mutate(testType: .Monster)
        readMonster(fb: newBuf)
    }
    
    func createMonster(withPrefix prefix: Bool) -> FlatBuffersBuilder {
        let fbb = FlatBuffersBuilder(initialSize: 1)
        let names = [fbb.create(string: "Frodo"), fbb.create(string: "Barney"), fbb.create(string: "Wilma")]
        var offsets: [Offset<UOffset>] = []
        let start1 = Monster_1.startMonster(fbb)
        Monster_1.addName(fbb, offset: names[0])
        offsets.append(Monster_1.endMonster(fbb, start: start1))
        let start2 = Monster_1.startMonster(fbb)
        Monster_1.addName(fbb, offset: names[1])
        offsets.append(Monster_1.endMonster(fbb, start: start2))
        let start3 = Monster_1.startMonster(fbb)
        Monster_1.addName(fbb, offset: names[2])
        offsets.append(Monster_1.endMonster(fbb, start: start3))
        
        let sortedArray = Monster_1.sortVectorOfMonsters(fbb, offsets: offsets)
        
        let str = fbb.create(string: "MyMonster")
        let test1 = fbb.create(string: "test1")
        let test2 = fbb.create(string: "test2")
        
        let inv = Monster_1.create(inventory: [1, 2, 3, 4], fbb)
        
        let fred = fbb.create(string: "Fred")
        let mon1Start = Monster_1.startMonster(fbb)
        Monster_1.addName(fbb, offset: fred)
        let mon2 = Monster_1.endMonster(fbb, start: mon1Start)
        let test4 = Monster_1.createTest(structs: [createTestable(a: 30, b: 40), createTestable(a: 10, b: 20)], fbb)
        
        let stringTestVector = fbb.createVector(ofOffsets: [test1, test2])
        
        let mStart = Monster_1.startMonster(fbb)
        Monster_1.addPostion(fbb, offset: fbb.create(struct: createVec3(x: 1, y: 2, z: 3, test1: 3, color: .green, testA: 5, testB: 6), type: Vec3.self))
        Monster_1.addHp(fbb, 80)
        Monster_1.addName(fbb, offset: str)
        Monster_1.addInv(fbb, offset: inv)
        Monster_1.addTestType(fbb, Type.Monster)
        Monster_1.addTest(fbb, mon2)
        Monster_1.addTest4(fbb, test4)
        Monster_1.addTestArrayOfStrings(fbb, offset: stringTestVector)
        Monster_1.addBool(fbb, condition: true)
        Monster_1.addSortedTables(fbb, sortedArray)
        let end = Monster_1.endMonster(fbb, start: mStart)
        Monster_1.finish(fbb, end: end, prefix: prefix)
        return fbb
    }
    
    func mutateMonster(fb: FlatBuffer) {
        let monster = Monster_1.getRootAsMonster(bb: fb)
        XCTAssertFalse(monster.mutate(mana: 10))
        XCTAssertEqual(monster.testArrayOfTables(at: 0)?.name, "Barney")
        XCTAssertEqual(monster.testArrayOfTables(at: 1)?.name, "Frodo")
        XCTAssertEqual(monster.testArrayOfTables(at: 2)?.name, "Wilma")
        
        //            // Example of searching for a table by the key
        //            Assert.IsTrue(monster.TestarrayoftablesByKey("Frodo") != null);
        //            Assert.IsTrue(monster.TestarrayoftablesByKey("Barney") != null);
        //            Assert.IsTrue(monster.TestarrayoftablesByKey("Wilma") != null);
        
        XCTAssertEqual(monster.testType, .Monster)
        XCTAssertEqual(monster.mutate(testType: .NONE), true)
        XCTAssertEqual(monster.testType, .NONE)
        XCTAssertEqual(monster.mutate(testType: .Monster), true)
        XCTAssertEqual(monster.testType, .Monster)
        
        XCTAssertEqual(monster.mutate(inventory: 1, at: 0), true)
        XCTAssertEqual(monster.mutate(inventory: 2, at: 1), true)
        XCTAssertEqual(monster.mutate(inventory: 3, at: 2), true)
        XCTAssertEqual(monster.mutate(inventory: 4, at: 3), true)
        XCTAssertEqual(monster.mutate(inventory: 5, at: 4), true)
        
        for i in 0..<monster.inventoryCount {
            XCTAssertEqual(monster.inventory(at: i), Byte(i + 1))
        }
        
        XCTAssertEqual(monster.mutate(inventory: 0, at: 0), true)
        XCTAssertEqual(monster.mutate(inventory: 1, at: 1), true)
        XCTAssertEqual(monster.mutate(inventory: 2, at: 2), true)
        XCTAssertEqual(monster.mutate(inventory: 3, at: 3), true)
        XCTAssertEqual(monster.mutate(inventory: 4, at: 4), true)
        
        let vec = monster.pos
        XCTAssertEqual(vec?.x, 1)
        XCTAssertTrue(vec?.mutate(x: 55.0) ?? false)
        XCTAssertTrue(vec?.mutate(test1: 55) ?? false)
        XCTAssertEqual(vec?.x, 55.0)
        XCTAssertEqual(vec?.test1, 55.0)
        XCTAssertTrue(vec?.mutate(x: 1) ?? false)
        XCTAssertEqual(vec?.x, 1)
        XCTAssertTrue(vec?.mutate(test1: 3) ?? false)
    }
    
    func readMonster(fb: FlatBuffer) {
        let monster = Monster_1.getRootAsMonster(bb: fb)
        XCTAssertEqual(monster.hp, 80)
        XCTAssertEqual(monster.mana, 150)
        XCTAssertEqual(monster.name, "MyMonster")
        let pos = monster.pos
        XCTAssertEqual(pos?.x, 1)
        XCTAssertEqual(pos?.y, 2)
        XCTAssertEqual(pos?.z, 3)
        XCTAssertEqual(pos?.test1, 3)
        XCTAssertEqual(pos?.color, .green)
        let test = pos?.test
        XCTAssertEqual(test?.a, 5)
        XCTAssertEqual(test?.b, 6)
        XCTAssertEqual(monster.testType, .Monster)
        let monster2 = monster.Test(type: Monster_1.self)
        XCTAssertEqual(monster2?.name, "Fred")
        XCTAssertEqual(monster.mutate(testType: .NONE), true)
        XCTAssertNotEqual(monster.testType, .Monster)
        XCTAssertEqual(monster.mutate(testType: .Monster), true)
        XCTAssertEqual(monster.mutate(mana: 10), false)
        XCTAssertEqual(monster.mana, 150)
        XCTAssertEqual(monster.inventoryCount, 5)
        var sum: Byte = 0
        for i in 0...monster.inventoryCount {
            sum += monster.inventory(at: i)
        }
        XCTAssertEqual(sum, 10)
        XCTAssertEqual(monster.test4Count, 2)
        let test0 = monster.test4(at: 0)
        let test1 = monster.test4(at: 1)
        var sum0 = 0
        var sum1 = 0
        if let a = test0?.a, let b = test0?.b {
            sum0 = Int(a) + Int(b)
        }
        if let a = test1?.a, let b = test1?.b {
            sum1 = Int(a) + Int(b)
        }
        XCTAssertEqual(sum0 + sum1, 100)
        XCTAssertEqual(monster.testArrayOfStrings, 2)
        XCTAssertEqual(monster.testArrayOfStrings(at: 0), "test1")
        XCTAssertEqual(monster.testArrayOfStrings(at: 1), "test2")
        XCTAssertEqual(monster.testBool, true)
        
        let array = monster.nameSegmentArray
        XCTAssertEqual(String(bytes: array ?? [], encoding: .utf8), "MyMonster")
        
        if 0 == monster.testArrayOfBoolsCount  {
            XCTAssertEqual(monster.testArrayOfBools.isEmpty, true)
        } else {
            XCTAssertEqual(monster.testArrayOfBools.isEmpty, false)
        }
    }
}

enum Type: Byte {
    case NONE = 0, Monster = 1, TestSimpleTableWithEnum = 2, MyGame_Example2_Monster = 3
}

enum Color_1: Int8 {
    case red = 1
    case green = 2
    case blue = 8
}

func createTestable(a: Int16, b: Int8) -> UnsafeMutableRawPointer {
    let memory = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 2)
    memory.initializeMemory(as: UInt8.self, repeating: 0, count: 4)
    memory.storeBytes(of: a, toByteOffset: 0, as: Int16.self)
    memory.storeBytes(of: b, toByteOffset: 2, as: Int8.self)
    return memory
}

struct Test1: Readable {
    static var size = 4
    static var alignment = 2
    private var __s: Struct
    
    init(_ bb: FlatBuffer, o: Int32) {
        __s = Struct(bb: bb, position: o)
    }
    
    var a: Int16 { return __s.readBuffer(of: Int16.self, at: 0)}
    var b: Int8 { return __s.readBuffer(of: Int8.self, at: 2)}
}


func createVec3(x: Float32, y: Float32, z: Float32, test1: Double, color: Color_1, testA: Int16, testB: Int8) -> UnsafeMutableRawPointer {
    let memory = UnsafeMutableRawPointer.allocate(byteCount: Vec3.size, alignment: Vec3.alignment)
    memory.initializeMemory(as: UInt8.self, repeating: 0, count: Vec3.size)
    memory.storeBytes(of: x, toByteOffset: 0, as: Float32.self)
    memory.storeBytes(of: y, toByteOffset: 4, as: Float32.self)
    memory.storeBytes(of: z, toByteOffset: 8, as: Float32.self)
    memory.storeBytes(of: test1, toByteOffset: 16, as: Double.self)
    memory.storeBytes(of: color.rawValue, toByteOffset: 24, as: Int8.self)
    memory.storeBytes(of: 0, toByteOffset: 25, as: Int8.self)
    memory.storeBytes(of: testA, toByteOffset: 26, as: Int16.self)
    memory.storeBytes(of: testB, toByteOffset: 28, as: Int8.self)
    return memory
}

struct Vec3: Readable {
    static var size = 32
    static var alignment = 8
    var __s: Struct
    
    init(_ bb: FlatBuffer, o: Int32) {
        __s = Struct(bb: bb, position: o)
    }
    
    var x: Float32 { return __s.readBuffer(of: Float32.self, at: 0)}
    var y: Float32 { return __s.readBuffer(of: Float32.self, at: 4)}
    var z: Float32 { return __s.readBuffer(of: Float32.self, at: 8)}
    
    func mutate(x: Float32) -> Bool { return __s.mutate(x, index: 0) }
    func mutate(y: Float32) -> Bool { return __s.mutate(y, index: 4) }
    func mutate(z: Float32) -> Bool { return __s.mutate(z, index: 8) }
    func mutate(test1: Double) -> Bool { return __s.mutate(test1, index: 16) }
    
    var test1: Double { return __s.readBuffer(of: Double.self, at: 16) }
    var color: Color_1 { return Color_1(rawValue: __s.readBuffer(of: Int8.self, at: 24)) ?? .green }
    var test: Test1 { return Test1(__s.bb, o: __s.postion + 26) }
}

struct Monster_1: FlatBufferObject {
    
    var __t: Table
    
    init(_ fb: FlatBuffer, o: Int32) { __t = Table(bb: fb, position: o) }
    init(_ t: Table) { __t = t }
    
    static func getRootAsMonster(bb: FlatBuffer) -> Monster_1 {
        return Monster_1(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader)))
    }
    
    public var pos: Vec3? { let o = __t.offset(4); return o == 0 ? nil : Vec3(__t.bb, o: o + __t.postion) }
    public var hp: Int16 { let o = __t.offset(8); return o == 0 ? 100 : __t.readBuffer(of: Int16.self, at: o) }
    public var mana: Int16 { let o = __t.offset(6); return o == 0 ? 150 : __t.readBuffer(of: Int16.self, at: o) }
    public func mutate(mana m: Int16) -> Bool { let o = __t.offset(6); return __t.mutate(m, index: o) }
    
    public var inventoryCount: Int32 { let o = __t.offset(14); return o == 0 ? 0 : __t.vector(count: o) }
    public func inventory(at index: Int32) -> Byte { let o = __t.offset(14); return o == 0 ? 0 : __t.directRead(of: Byte.self, offset: __t.vector(at: o) + index * 1) }
    public func mutate(inventory: Byte, at index: Int32) -> Bool { let o = __t.offset(14); return __t.directMutate(inventory, index: __t.vector(at: o) + index * 1) }
    public var name: String? { let o = __t.offset(10); return o == 0 ? nil : __t.string(at: o) }
    public var nameSegmentArray: [UInt8]? { return __t.getVector(at: 10) }
    
    public var testType: Type { let o = __t.offset(18); return o == 0 ? .NONE : Type(rawValue: __t.readBuffer(of: Byte.self, at: o)) ?? .NONE }
    public func mutate(testType t: Type) -> Bool { let o = __t.offset(18); return __t.mutate(t.rawValue, index: o) }
    
    
    public func test<T: FlatBufferObject>(type: T.Type) -> T? { let o = __t.offset(20); return o == 0 ? nil : __t.union(o) }
    public func Test<T: FlatBufferObject>(type: T.Type) -> T? { let o = __t.offset(20); return o == 0 ? nil : __t.union(o) }
    
    public var test4Count: Int32 { let o = __t.offset(22); return o == 0 ? 0 : __t.vector(count: o) }
    public func test4(at index: Int32) -> Test1? { let o = __t.offset(22); return o == 0 ? nil : Test1(__t.bb, o: __t.vector(at: o) + index * 4) }
    
    public var testArrayOfStrings: Int32 { let o = __t.offset(24); return o == 0 ? 0 : __t.vector(count: o) }
    public func testArrayOfStrings(at index: Int32) -> String? { let o = __t.offset(24); return o == 0 ? nil : __t.directString(at: __t.vector(at: o) + index * 4) }
    
    public var testArrayOfBoolsCount: Int32 { let o = __t.offset(52); return o == 0 ? 0 : __t.vector(count: o) }
    public var testArrayOfBools: [Byte] { return __t.getVector(at: 52) ?? [] }
    
    public var testBool: Bool { let o = __t.offset(34); return o == 0 ? false : 0 != __t.readBuffer(of: Byte.self, at: o) }
    
    public var testArrayOfTablesCount: Int32 { let o = __t.offset(26); return o == 0 ? 0 : __t.vector(count: o) }
    public func testArrayOfTables(at index: Int32) -> Monster_1? { let o = __t.offset(26); return o == 0 ? nil : Monster_1(__t.bb, o: __t.indirect(__t.vector(at: o) + index * 4)) }
    
    static func startMonster(_ fbb: FlatBuffersBuilder) -> UOffset { fbb.startTable(with: 49) }
    static func endMonster(_ fbb: FlatBuffersBuilder, start: UOffset) -> Offset<UOffset> {
        let end = Offset<UOffset>(offset: fbb.endTable(at: start))
        fbb.require(table: end, fields: [10])
        return end
    }
    
    static func finish(_ fbb: FlatBuffersBuilder, end: Offset<UOffset>, prefix: Bool) {
        fbb.finish(offset: end, fileId: "MONS", addPrefix: prefix)
    }
    
    static func addTestType(_ fbb: FlatBuffersBuilder, _ type: Type) { fbb.add(element: type.rawValue, def: 0, at: 7) }
    
    static func addTest(_ fbb: FlatBuffersBuilder, _ offset: Offset<UOffset>) { fbb.add(offset: offset, at: 8) }
    
    static func addSortedTables(_ fbb: FlatBuffersBuilder, _ offset: Offset<UOffset>) { fbb.add(offset: offset, at: 11) }
    
    static func addTest4(_ fbb: FlatBuffersBuilder, _ offset: Offset<UOffset>) { fbb.add(offset: offset, at: 9) }
    
    static func addPostion(_ fbb: FlatBuffersBuilder, offset: Offset<UOffset>) { fbb.add(structOffset: 0) }
    
    static func addHp(_ fbb: FlatBuffersBuilder, _ hp: Int16) { fbb.add(element: hp, def: 100, at: 2) }
    
    static func addInv(_ fbb: FlatBuffersBuilder, offset: Offset<UOffset>) { fbb.add(offset: offset, at: 5) }
    
    static func addTestArrayOfStrings(_ fbb: FlatBuffersBuilder, offset: Offset<UOffset>) { fbb.add(offset: offset, at: 10) }
    
    static func addBool(_ fbb: FlatBuffersBuilder, condition: Bool) { fbb.add(condition: condition, def: false, at: 15) }
    
    static func addName(_ fbb: FlatBuffersBuilder, offset: Offset<String>) { fbb.add(offset: offset, at: 3) }
    static func createTest(structs: [UnsafeMutableRawPointer], _ fbb: FlatBuffersBuilder) -> Offset<UOffset> { return fbb.createVector(structs: structs, type: Test1.self) }
    
    static func create(inventory: [Byte], _ fbb: FlatBuffersBuilder) -> Offset<UOffset> { fbb.createVector(inventory, size: inventory.count + 1) }
    static func sortVectorOfMonsters(_ fbb: FlatBuffersBuilder, offsets: [Offset<UOffset>]) -> Offset<UOffset> {
        var off = offsets
        off.sort { (off1, off2) -> Bool in
            return Table.compare(Table.offset(Int32(off2.o), vOffset: 10, fbb: fbb.buffer), Table.offset(Int32(off1.o), vOffset: 10, fbb: fbb.buffer), fbb: fbb.buffer) < 0
        }
        return fbb.createVector(ofOffsets: off)
    }
}
