//
//  File.swift
//  
//
//  Created by Mustafa Khalil on 9/16/19.
//

import Foundation

public struct Table {
    private var _bb: FlatBuffer
    private var _postion: Int32
    
    public var bb: FlatBuffer { return _bb }
    public var postion: Int32 { return _postion }
    
    public init(bb: FlatBuffer, position: Int32 = 0) {
        _bb = bb
        _postion = position
    }
    
    public func offset(_ o: Int32) -> Int32 {
        let vtable = _postion - _bb.read(def: Int32.self, position: Int(_postion))
        return o < _bb.read(def: VOffset.self, position: Int(vtable)) ? Int32(_bb.read(def: Int16.self, position: Int(vtable + o))) : 0
    }
    
    public func indirect(_ o: Int32) -> Int32 { return o + _bb.read(def: Int32.self, position: Int(o)) }
    
    public func string(at offset: Int32) -> String? {
        var offset = offset + _postion
        offset += _bb.read(def: Int32.self, position: Int(offset))
        let count = _bb.read(def: Int32.self, position: Int(offset))
        let position = offset + Int32(MemoryLayout<Int32>.size)
        return _bb.readString(at: position, count: count)
    }
    
    public func union<T: FlatBufferObject>(_ o: Int32) -> T {
        let o = o + _postion
        return T.init(_bb, o: o + bb.read(def: Int32.self, position: Int(o)))
    }
    
    public func getVector<T>(at off: Int32) -> [T] {
        guard isLitteEndian else { fatalError(FlatbufferError.endianCheck.errorDescription ?? "") }
        let o = offset(off)
        guard o != 0 else { return [] }
        return _bb.readSlice(index: vector(at: o), count: vector(count: o))
    }
    
    public func vector(count o: Int32) -> Int32 {
        var o = o
        o += _postion
        o += _bb.read(def: Int32.self, position: Int(o))
        return _bb.read(def: Int32.self, position: Int(o))
    }
    
    public func vector(at o: Int32) -> Int32 {
        var o = o
        o += _postion
        return o + _bb.read(def: Int32.self, position: Int(o)) + 4
    }
    
    public func readBuffer<T: Scalar>(of type: T.Type, offset o: Int32) -> T {
        let r = _bb.read(def: T.self, position: Int(o + _postion))
        return r
    }
    
}
