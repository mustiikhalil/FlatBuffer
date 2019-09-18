//
//  File.swift
//  
//
//  Created by Mustafa Khalil on 9/16/19.
//

import Foundation

class Table {
    var _bb: FlatBuffer
    var _postion: Int32
    
    init(bb: FlatBuffer, position: Int32 = 0) {
        _bb = bb
        _postion = position
    }
    
    func offset(_ o: Int32) -> Int32 {
        let size = MemoryLayout<VOffset>.size
        let vTable = _bb.read(def: Int32.self, position: Int(o), with: size)
        let index = Int32(_postion) - Int32(vTable)
        return index < _bb.read(def: VOffset.self, position: Int(index), with: size) ? Int32(_bb.read(def: VOffset.self, position: Int(o + index), with: size)) : 0
    }
    
    func reader<T: Scaler>(def: T, position: Int) -> T {
        let r = _bb.read(def: T.self, position: position, with: MemoryLayout<T>.stride)
        return r
    }
    
}
