import Foundation

public struct Table {
    private var _bb: FlatBuffer
    private var _postion: Int32
    
    public var bb: FlatBuffer { return _bb }
    public var postion: Int32 { return _postion }
    
    public init(bb: FlatBuffer, position: Int32 = 0) {
        guard isLitteEndian else { fatalError(FlatbufferError.endianCheck.errorDescription ?? "") }
        _bb = bb
        _postion = position
    }
    
    public func offset(_ o: Int32) -> Int32 {
        let vtable = _postion - _bb.read(def: Int32.self, position: Int(_postion))
        return o < _bb.read(def: VOffset.self, position: Int(vtable)) ? Int32(_bb.read(def: Int16.self, position: Int(vtable + o))) : 0
    }
    
    public func indirect(_ o: Int32) -> Int32 { return o + _bb.read(def: Int32.self, position: Int(o)) }

    /// String reads from the buffer with respect to position of the current table.
    /// - Parameter offset: Offset of the string
    public func string(at offset: Int32) -> String? {
        return directString(at: offset + _postion)
    }
    
    /// Direct string reads from the buffer disregarding the position of the table.
    /// It would be preferable to use string unless the current position of the table is not needed
    /// - Parameter offset: Offset of the string
    public func directString(at offset: Int32) -> String? {
         var offset = offset
         offset += _bb.read(def: Int32.self, position: Int(offset))
         let count = _bb.read(def: Int32.self, position: Int(offset))
         let position = offset + Int32(MemoryLayout<Int32>.size)
         return _bb.readString(at: position, count: count)
    }
    
    /// Reads from the buffer with respect to the position in the table.
    /// - Parameters:
    ///   - type: Type of Scalar that needs to be read from the buffer
    ///   - o: Offset of the Element
    public func readBuffer<T: Scalar>(of type: T.Type, offset o: Int32) -> T {
        return directRead(of: T.self, offset: o + _postion)
    }
    
    /// Reads from the buffer disregarding the position of the table.
    /// It would be used when reading from an
    ///   ```
    ///   let offset = __t.offset(10)
    ///   //Only used when the we already know what is the
    ///   // position in the table since __t.vector(at:)
    ///   // returns the index with respect to the position
    ///   __t.directRead(of: Byte.self,
    ///                  offset: __t.vector(at: offset) + index * 1)
    ///   ```
    /// - Parameters:
    ///   - type: Type of Scalar that needs to be read from the buffer
    ///   - o: Offset of the Element
    public func directRead<T: Scalar>(of type: T.Type, offset o: Int32) -> T {
        let r = _bb.read(def: T.self, position: Int(o))
        return r
    }
    
    public func union<T: FlatBufferObject>(_ o: Int32) -> T {
        let o = o + _postion
        return T.init(_bb, o: o + bb.read(def: Int32.self, position: Int(o)))
    }
    
    public func getVector<T>(at off: Int32) -> [T]? {
        let o = offset(off)
        guard o != 0 else { return nil }
        return _bb.readSlice(index: vector(at: o), count: vector(count: o))
    }
    
    /// Vector count gets the count of Elements within the array
    /// - Parameter o: start offset of the vector
    /// - returns: Count of elements
    public func vector(count o: Int32) -> Int32 {
        var o = o
        o += _postion
        o += _bb.read(def: Int32.self, position: Int(o))
        return _bb.read(def: Int32.self, position: Int(o))
    }
    
    /// Vector start index in the buffer
    /// - Parameter o:start offset of the vector
    /// - returns: the start index of the vector
    public func vector(at o: Int32) -> Int32 {
        var o = o
        o += _postion
        return o + _bb.read(def: Int32.self, position: Int(o)) + 4
    }
}

extension Table {
    
    static public func offset(_ o: Int32, vOffset: Int32, fbb: FlatBuffer) -> Int32 {
        let vTable = Int32(fbb.capacity) - o
        return vTable + Int32(fbb.read(def: Int16.self, position: Int(vTable + vOffset - fbb.read(def: Int32.self, position: Int(vTable)))))
    }
    
    static public func compare(_ off1: Int32, _ off2: Int32, fbb: FlatBuffer) -> Int32 {
        let memorySize = Int32(MemoryLayout<Int32>.size)
        let _off1 = off1 + fbb.read(def: Int32.self, position: Int(off1))
        let _off2 = off2 + fbb.read(def: Int32.self, position: Int(off2))
        let len1 = fbb.read(def: Int32.self, position: Int(_off1))
        let len2 = fbb.read(def: Int32.self, position: Int(_off2))
        let startPos1 = _off1 + memorySize
        let startPos2 = _off2 + memorySize
        let minValue = min(len1, len2)
        for i in 0...minValue {
            let b1 = fbb.read(def: Int8.self, position: Int(i + startPos1))
            let b2 = fbb.read(def: Int8.self, position: Int(i + startPos2))
            if b1 != b2 {
                return Int32(b2 - b1)
            }
        }
        return len1 - len2
    }
}
