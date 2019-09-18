import Foundation

//// TODO: - add docs

class FlatBuffersBuilder {

    private var _vtable: [FieldLoc] = []
    private var _vtables: [UOffset] = []
    private var _bb: FlatBuffer
    private var _minAlignment: Int32 = 0
    private var isNested = false
    private var _numOfFields = 0
    private var _maxVOffset: VOffset = 0
    
    var data: Data { return Data(bytes: _bb.memory, count: _bb.capacity) }
    
    var sizedArray: [UInt8] {
        let cp = _bb.capacity
        let ptr = UnsafeBufferPointer(start: _bb.memory.bindMemory(to: UInt8.self, capacity: cp), count: cp)
        return Array(ptr)
    }
    
    var buffer: FlatBuffer { return _bb }
    
    ///
    /// - Parameter initialSize:
    init(initialSize: Int32 = 1024)  {
        guard initialSize > 0 else { fatalError( FlatbufferError.sizeIsZeroOrLess.errorDescription ?? "") }
        _bb = FlatBuffer(initialSize: Int(initialSize))
    }
    
    ///
    func clear() {
        _minAlignment = 0
        isNested = false
        _bb.clear()
    }
    
    func clearOffsets() {
        _maxVOffset = 0
        _numOfFields = 0
        _vtable = []
    }
}

// MARK: - Create Tables

extension FlatBuffersBuilder {
    
    ///
    func startTable()  -> UOffset {
        notNested()
        isNested = true
        return _bb.size
    }
    
    ///
    /// - Parameter offset:
    func endTable(at startOffset: UOffset)  -> UOffset {
        if !isNested { fatalError( FlatbufferError.serializingWithoutCallingStartVector.errorDescription ?? "") }
        
        let sizeofVoffset = MemoryLayout<VOffset>.size
        let vTableOffset = push(element: SOffset(0))
        
        _maxVOffset = max(_maxVOffset + VOffset(sizeofVoffset), fieldIndex(toOffset: 0))
        _bb.ensureSpace(size: UInt8(_maxVOffset))
        
        let tableObjectSize = vTableOffset - startOffset
        assert(tableObjectSize < 0x10000)
        
        for i in _vtable {
            _bb.push(value: VOffset(vTableOffset - i.uOffset), len: sizeofVoffset)
        }
        _bb.push(value: VOffset(tableObjectSize), len: sizeofVoffset)
        _bb.push(value: _maxVOffset, len: sizeofVoffset)
        
        clearOffsets()
        // FIXME: - check if there is a vtable already added and point to it
//        var isAlreadyAdded = false
        
        let size = MemoryLayout<Int32>.size
        _bb.write(pointer: pointer(c: Int32(_bb.size) - Int32(vTableOffset)),
                  len: size,
                  index: Int(_bb.size - vTableOffset) + size)
        
        debug()
        isNested = false
        return 0
    }
}

// MARK: - Builds Buffer

extension FlatBuffersBuilder {
    
    /// Checks if the flag isNested is true to fatalError( an error since nested serialization is not allowed
    fileprivate func notNested()  { if isNested { fatalError( FlatbufferError.nestedSerializationNotAllowed.errorDescription ?? "") } }

    ///
    /// - Parameter size:
    fileprivate func minAlignment(size: Int32) { if size > _minAlignment { _minAlignment = size } }

    ///
    fileprivate func padding(bufSize: UInt32, elementSize: UInt32) -> UInt32 { ((~bufSize) + 1) & (elementSize - 1) }

    ///
    /// - Parameter len:
    fileprivate func preAlign(len: Int32, alignment: Int32) {
        minAlignment(size: alignment)
        _bb.fill(padding: padding(bufSize: _bb.size + UOffset(len), elementSize: UOffset(alignment)))
    }

    ///
    /// - Parameter len:
    /// - Parameter type:
    func preAlign<T: Scaler>(len: Int32, type: T.Type) {
        preAlign(len: len, alignment: Int32(MemoryLayout<T>.size))
    }
    
    ///
    /// - Parameter off:
    func refer(to off: UOffset) -> UOffset {
        let size = Int32(MemoryLayout<UOffset>.size)
        preAlign(len: size, alignment: size)
        return _bb.size - off + UInt32(size)
    }
    
    ///
    /// - Parameter offset:
    /// - Parameter position:
    func track(offset: UOffset, at position: VOffset) {
        let lock = FieldLoc(vOffset: position, uOffset: offset)
        _vtable.append(lock)
        _numOfFields += 1
        _maxVOffset = max(_maxVOffset, position)
    }
    
    ///
    /// - Parameter fieldId:
    func fieldIndex(toOffset fieldId: VOffset) -> VOffset {
        let fixedSize: VOffset = 2
        return (fieldId + fixedSize) * VOffset(MemoryLayout<VOffset>.size)
    }
}

// MARK: - Inserting Elements to Buffer

extension FlatBuffersBuilder {
    
    ///
    /// - Parameter offset:
    /// - Parameter position:
    func add<T: Scaler>(offset: Offset<T>, at position: VOffset) {
        if offset.isNull { return }
        add(element: refer(to: offset.o), def: 0, at: position)
    }
    
    ///
    /// - Parameter e:
    /// - Parameter def:
    /// - Parameter position:
    func add<T: Scaler>(element: T, def: T, at position: VOffset) {
        if (element == def) { return }
        let off = push(element: element)
        track(offset: off, at: position)
    }
        
    ///
    /// - Parameter str:
    func create(string str: String)  -> Offset<String> {
        let len = str.count
        notNested()
        preAlign(len: Int32(len) + 1, type: UOffset.self)
        _bb.fill(padding: 1)
        _bb.push(string: str, len: len)
        _bb.push(value: UOffset(len), len: MemoryLayout.size(ofValue: UOffset(len)))
        return Offset(offset: _bb.size)
    }
    
    ///
    /// - Parameter element:
    fileprivate func push<T: Scaler>(element: T) -> UOffset {
        _bb.push(value: element, len: MemoryLayout<T>.size)
        return _bb.size
    }
}

#if DEBUG
extension FlatBuffersBuilder {
    func debug(str: String = "normal memory: ") { _bb.debugMemory(str: str) }
}
#endif
