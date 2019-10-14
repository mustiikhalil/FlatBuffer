import Foundation

//// TODO: - add docs
public final class FlatBuffersBuilder {
    
    private var _vtable: [UInt32] = []
    private var _vtables: [UOffset] = []
    private var _bb: FlatBuffer
    private var isNested = false
    private var _numOfFields = 0
    private var stringOffsetMap: [String: Offset<String>] = [:]
    private var finished = false
    private var serializeDefaults: Bool
    private var objectStart = 0
    
    var size: UOffset { return _bb.size }
    var _minAlignment: Int32 = 0 {
        didSet {
            _bb.alignment = Int(_minAlignment)
        }
    }
    
    public var data: Data {
        if !finished { fatalError(FlatbufferError.calledSizedBinaryBeforeFinish.localizedDescription) }
        return Data(bytes: _bb.memory, count: _bb.capacity)
    }
    
    public var sizedArray: [UInt8] {
        let cp = _bb.capacity - _bb.writerIndex
        let ptr = UnsafeBufferPointer(start: _bb.memory.advanced(by: _bb.writerIndex).bindMemory(to: UInt8.self, capacity: cp), count: cp)
        return Array(ptr)
    }
    
    public var buffer: FlatBuffer { return _bb }
    
    // MARK: - Init
    
    ///
    /// - Parameter initialSize:
    public init(initialSize: Int32 = 1024, serializeDefaults force: Bool = false) {
        guard initialSize > 0 else { fatalError( FlatbufferError.sizeIsZeroOrLess.errorDescription ?? "") }
        serializeDefaults = force
        _bb = FlatBuffer(initialSize: Int(initialSize))
    }
    
    ///
    public func clear() {
        _minAlignment = 0
        objectStart = 0
        isNested = false
        _bb.clear()
        stringOffsetMap = [:]
    }
    
    public func clearOffsets() {
        _numOfFields = 0
        objectStart = 0
        _vtable = []
        stringOffsetMap = [:]
    }
}

// MARK: - Create Tables

extension FlatBuffersBuilder {
    
    /// Description
    /// - Parameter offset: offset description
    /// - Parameter prefix: prefix description
    public func finish<T>(offset: Offset<T>, addPrefix prefix: Bool = false) {
        notNested()
        let size = MemoryLayout<UOffset>.size
        preAlign(len: Int32(size + (prefix ? size : 0)), alignment: _minAlignment)
        push(element: refer(to: offset.o))
        if prefix { push(element: _bb.size) }
        clearOffsets()
        finished = true
    }
    
    ///
    public func startTable(with numOfFields: Int) -> UOffset {
        notNested()
        isNested = true
        _vtable = [UInt32](repeating: 0, count: numOfFields)
        return _bb.size
    }
    
    ///
    /// - Parameter offset:
    public func endTable(at startOffset: UOffset)  -> UOffset {
        if !isNested { fatalError( FlatbufferError.serializingWithoutCallingStartVector.errorDescription ?? "") }
        let sizeofVoffset = MemoryLayout<VOffset>.size
        let vTableOffset = push(element: SOffset(0))
        
        let tableObjectSize = vTableOffset - startOffset
        guard tableObjectSize < 0x10000 else { fatalError(FlatbufferError.growBeyondTwoGB.errorDescription ?? "") }
        
        for i in _vtable.lazy.reversed() {
            let off = i == 0 ? 0 : vTableOffset - i
            _bb.push(value: VOffset(off), len: sizeofVoffset)
        }
        
        _bb.push(value: VOffset(tableObjectSize), len: sizeofVoffset)
        _bb.push(value: (UInt16(_vtable.count + 2) * UInt16(sizeofVoffset)), len: sizeofVoffset)
        
        clearOffsets()
        let vt_use = _bb.size
        // FIXME: - check if there is a vtable already added and point to it
        //        var isAlreadyAdded = false
        
        let size = MemoryLayout<Int32>.size
        _bb.write(value: Int32(vt_use) - Int32(vTableOffset),
                  len: size,
                  index: Int(vTableOffset))
        isNested = false
        return vTableOffset
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
    fileprivate func preAlign<T: Scalar>(len: Int32, type: T.Type) {
        preAlign(len: len, alignment: Int32(MemoryLayout<T>.size))
    }
    
    ///
    /// - Parameter off:
    fileprivate func refer(to off: UOffset) -> UOffset {
        let size = Int32(MemoryLayout<UOffset>.size)
        preAlign(len: size, alignment: size)
        return _bb.size - off + UInt32(size)
    }
    
    ///
    /// - Parameter offset:
    /// - Parameter position:
    fileprivate func track(offset: UOffset, at position: VOffset) {
        _vtable[Int(position)] = offset
        _numOfFields += 1
    }
    
    ///
    /// - Parameter fieldId:
    fileprivate func fieldIndex(toOffset fieldId: VOffset) -> VOffset {
        let fixedSize: VOffset = 2
        return (fieldId + fixedSize) * VOffset(MemoryLayout<VOffset>.size)
    }
}

// MARK: - Vectors

extension FlatBuffersBuilder {
    ///
    /// - Parameter len:
    /// - Parameter elementSize:
    public func startVector(_ len: Int32, elementSize: Int) {
        notNested()
        isNested = true
        preAlign(len: len * Int32(elementSize), type: UOffset.self)
        preAlign(len: len * Int32(elementSize), alignment: Int32(elementSize))
    }
    
    ///
    /// - Parameter len:
    public func endVector(len: Int32) -> UOffset {
        if !isNested { fatalError(FlatbufferError.serializingWithoutCallingStartVector.errorDescription ?? "") }
        isNested = false
        return push(element: len)
    }
    
    ///
    /// - Parameter elements:
    /// - Parameter size:
    public func createVector<T: Scalar>(_ elements: [T], size: Int) -> Offset<UOffset> {
        let size = Int32(size)
        startVector(size, elementSize: MemoryLayout<T>.size)
        _bb.push(elements: elements)
        return Offset(offset: endVector(len: size))
    }
    
    ///
    /// - Parameter offsets:
    public func createVector<T>(ofOffsets offsets: [Offset<T>]) -> Offset<UOffset> {
        return createVector(ofOffsets: offsets, len: Int32(offsets.count))
    }
    
    ///
    /// - Parameter offsets:
    /// - Parameter len:
    public func createVector<T>(ofOffsets offsets: [Offset<T>], len: Int32) -> Offset<UOffset> {
        startVector(len, elementSize: MemoryLayout<Offset<T>>.size)
        for o in offsets.lazy.reversed() { push(element: o) }
        return Offset(offset: endVector(len: len))
    }
    
    ///
    /// - Parameter str:
    public func createVector(ofStrings str: [String]) -> Offset<UOffset> {
        var offsets: [Offset<String>] = []
        for s in str { offsets.append(create(string: s)) }
        return createVector(ofOffsets: offsets)
    }
    
    ///
    /// - Parameter structs:
    public func createVector<T: Writeable>(structs: [T]) -> Offset<UOffset> {
        let size = MemoryLayout<T>.size
        startVector(Int32(structs.count * size), elementSize: MemoryLayout<T>.alignment)
        for i in structs.lazy.reversed() { _bb.push(struct: i, len: size) }
        return Offset(offset: endVector(len: Int32(structs.count)))
    }
    
}

// MARK: - Inserting Structs

extension FlatBuffersBuilder {
    
    ///
    /// - Parameter s:
    /// - Parameter index:
    @discardableResult
    public func create<T: Writeable>(struct s: T) -> Offset<UOffset> {
        let size = Int32(MemoryLayout<T>.size)
        preAlign(len: size, alignment: Int32(MemoryLayout<T>.alignment))
        _bb.push(struct: s, len: Int(size))
        return Offset(offset: _bb.size)
    }
    
    ///
    /// - Parameter o:
    public func add(structOffset o: UOffset) {
        guard Int(o) < _vtable.count else { fatalError(FlatbufferError.outOfRange.errorDescription ?? "") }
        _vtable[Int(o)] = _bb.size
    }
}

extension FlatBuffersBuilder {
    
    // MARK: - Inserting Strings
    
    ///
    /// - Parameter str:
    public func create(string str: String) -> Offset<String> {
        let len = str.count
        notNested()
        preAlign(len: Int32(len) + 1, type: UOffset.self)
        _bb.fill(padding: 1)
        _bb.push(string: str, len: len)
        push(element: UOffset(len))
        return Offset(offset: _bb.size)
    }
    
    public func createShared(string str: String) -> Offset<String> {
        if let offset = stringOffsetMap[str] {
            return offset
        }
        let offset = create(string: str)
        stringOffsetMap[str] = offset
        return offset
    }
    
    // MARK: - Inseting offsets
    
    ///
    /// - Parameter offset:
    /// - Parameter position:
    public func add<T>(offset: Offset<T>, at position: VOffset) {
        if offset.isEmpty { track(offset: 0, at: position); return }
        add(element: refer(to: offset.o), def: 0, at: position)
    }
    
    ///
    /// - Parameter o:
    @discardableResult
    public func push<T>(element o: Offset<T>) -> UOffset {
        return push(element: refer(to: o.o))
    }
    
    // MARK: - Inserting Scalars to Buffer
    
    ///
    /// - Parameter e:
    /// - Parameter def:
    /// - Parameter position:
    public func add<T: Scalar>(element: T, def: T, at position: VOffset) {
        if (element == def && !serializeDefaults) { track(offset: 0, at: position); return }
        let off = push(element: element)
        track(offset: off, at: position)
    }
    
    ///
    /// - Parameter element:
    @discardableResult
    public func push<T: Scalar>(element: T) -> UOffset {
        preAlign(len: Int32(MemoryLayout<T>.size),
                 alignment: Int32(MemoryLayout<T>.size))
        _bb.push(value: element, len: MemoryLayout<T>.size)
        return _bb.size
    }
}

#if DEBUG
extension FlatBuffersBuilder {
    public func debug(str: String = "normal memory: ") { _bb.debugMemory(str: str) }
}
#endif
