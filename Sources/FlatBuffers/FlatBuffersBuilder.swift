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
    
    public var fullSizedByteArray: [UInt8] {
        let ptr = UnsafeBufferPointer(start: _bb.memory.assumingMemoryBound(to: UInt8.self), count: _bb.capacity)
        return Array(ptr)
    }
    
    public var sizedByteArray: [UInt8] {
        let cp = _bb.capacity - _bb.writerIndex
        let ptr = UnsafeBufferPointer(start: _bb.memory.advanced(by: _bb.writerIndex).bindMemory(to: UInt8.self, capacity: cp), count: cp)
        return Array(ptr)
    }
    
    public var buffer: FlatBuffer { return _bb }
    
    // MARK: - Init
    
    ///
    /// - Parameter initialSize:
    public init(initialSize: Int32 = 1024, serializeDefaults force: Bool = false) {
        guard initialSize > 0 else { fatalError(FlatbufferError.sizeIsZeroOrLess.errorDescription ?? "") }
        guard isLitteEndian else { fatalError(FlatbufferError.endianCheck.errorDescription ?? "") }
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
    
    ///
    /// - Parameters:
    ///   - table:
    ///   - fields:
    public func require(table: Offset<UOffset>, fields: [Int32]) {
        for field in fields {
            let start = _bb.capacity - Int(table.o)
            let startTable = start - Int(_bb.read(def: Int32.self, position: start))
            let isOkay = _bb.read(def: VOffset.self, position: startTable + Int(field)) != 0
            if !isOkay {
                fatalError("\(FlatbufferError.fieldRequired.errorDescription ?? "") \(field)")
            }
        }
    }
    
    ///
    /// - Parameters:
    ///   - offset:
    ///   - fileId:
    ///   - prefix:
    public func finish<T>(offset: Offset<T>, fileId: String, addPrefix prefix: Bool = false) {
        let size = MemoryLayout<UOffset>.size
        preAlign(len: Int32(size + (prefix ? size : 0) + fileIdConstant), alignment: _minAlignment)
        guard fileId.count == fileIdConstant else { fatalError(FlatbufferError.fileIdCount.errorDescription ?? "") }
        _bb.push(string: fileId, len: 4)
        finish(offset: offset, addPrefix: prefix)
    }
    
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
        
        var writeIndex = 0
        for (index,j) in _vtable.lazy.reversed().enumerated() {
            if j != 0 {
                writeIndex = _vtable.count - index
                break
            }
        }
        
        for i in stride(from: writeIndex - 1, to: -1, by: -1) {
            let off = _vtable[i] == 0 ? 0 : vTableOffset - _vtable[i]
            _bb.push(value: VOffset(off), len: sizeofVoffset)
        }
        
        _bb.push(value: VOffset(tableObjectSize), len: sizeofVoffset)
        _bb.push(value: (UInt16(writeIndex + 2) * UInt16(sizeofVoffset)), len: sizeofVoffset)
        
        clearOffsets()
        let vt_use = _bb.size
        
        var isAlreadyAdded: Int?
        
        mainLoop: for table in _vtables {
            let vt1 = _bb.capacity - Int(table)
            let vt2 = _bb.writerIndex
            let len = _bb.read(def: Int16.self, position: vt1)
            guard len == _bb.read(def: Int16.self, position: vt2) else { break }
            for i in stride(from: sizeofVoffset, to: Int(len), by: sizeofVoffset) {
                if _bb.read(def: Int16.self, position: vt1 + i) != _bb.read(def: Int16.self, position: vt2 + i) {
                    break mainLoop
                }
            }
            isAlreadyAdded = Int(table)
        }
        
        if let offset = isAlreadyAdded {
            let vTableOff = Int(vTableOffset)
            let space = _bb.capacity - vTableOff
            _bb.write(value: Int32(offset - vTableOff), index: space, direct: true)
            _bb.resize(_bb.capacity - space)
        } else {
            _bb.write(value: Int32(vt_use) - Int32(vTableOffset), index: Int(vTableOffset))
            _vtables.append(_bb.size)
        }
        isNested = false
        return vTableOffset
    }
}

// MARK: - Builds Buffer

extension FlatBuffersBuilder {
    
    /// Checks if the flag isNested is true to fatalError( an error since nested serialization is not allowed
    fileprivate func notNested()  {
        if isNested {
            fatalError( FlatbufferError.nestedSerializationNotAllowed.errorDescription ?? "")
        }
    }
    
    ///
    /// - Parameter size:
    fileprivate func minAlignment(size: Int32) {
        if size > _minAlignment {
            _minAlignment = size
        }
    }
    
    ///
    fileprivate func padding(bufSize: UInt32, elementSize: UInt32) -> UInt32 {
        ((~bufSize) + 1) & (elementSize - 1)
    }
    
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
        if !isNested {
            fatalError(FlatbufferError.serializingWithoutCallingStartVector.errorDescription ?? "")
        }
        isNested = false
        return push(element: len)
    }
    
    ///
    /// - Parameter elements:
    public func createVector<T: Scalar>(_ elements: [T]) -> Offset<UOffset> {
        return createVector(elements, size: elements.count)
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
        createVector(ofOffsets: offsets, len: Int32(offsets.count))
    }
    
    ///
    /// - Parameter offsets:
    /// - Parameter len:
    public func createVector<T>(ofOffsets offsets: [Offset<T>], len: Int32) -> Offset<UOffset> {
        startVector(len, elementSize: MemoryLayout<Offset<T>>.size)
        for o in offsets.lazy.reversed() {
            push(element: o)
        }
        return Offset(offset: endVector(len: len))
    }
    
    ///
    /// - Parameter str:
    public func createVector(ofStrings str: [String]) -> Offset<UOffset> {
        var offsets: [Offset<String>] = []
        for s in str {
            offsets.append(create(string: s))
        }
        return createVector(ofOffsets: offsets)
    }
    
    ///
    /// - Parameters:
    ///   - structs:
    ///   - size:
    ///   - alignment:
    ///   - type:
    public func createVector<T: Readable>(structs: [UnsafeMutableRawPointer], size: Int, alignment: Int, type: T.Type) -> Offset<UOffset> {
        startVector(Int32(structs.count * size), elementSize: alignment)
        for i in structs.lazy.reversed() {
            create(struct: i, type: T.self)
        }
        return Offset(offset: endVector(len: Int32(structs.count)))
    }
    
}

// MARK: - Inserting Structs

extension FlatBuffersBuilder {
    
    ///
    /// - Parameters:
    ///   - s:
    ///   - type:
    @discardableResult
    public func create<T: Readable>(struct s: UnsafeMutableRawPointer, type: T.Type) -> Offset<UOffset> {
        let size = T.size
        preAlign(len: Int32(size), alignment: Int32(T.alignment))
        _bb.push(struct: s, size: size)
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
        if offset.isEmpty {
            track(offset: 0, at: position)
            return
        }
        add(element: refer(to: offset.o), def: 0, at: position)
    }
    
    ///
    /// - Parameter o:
    @discardableResult
    public func push<T>(element o: Offset<T>) -> UOffset {
        push(element: refer(to: o.o))
    }
    
    // MARK: - Inserting Scalars to Buffer
    
    ///
    /// - Parameter e:
    /// - Parameter def:
    /// - Parameter position:
    public func add<T: Scalar>(element: T, def: T, at position: VOffset) {
        if (element == def && !serializeDefaults) {
            track(offset: 0, at: position)
            return
        }
        let off = push(element: element)
        track(offset: off, at: position)
    }
    
    ///
    /// - Parameter e:
    /// - Parameter def:
    /// - Parameter position:
    public func add(condition: Bool, def: Bool, at position: VOffset) {
        if (condition == def && !serializeDefaults) {
            track(offset: 0, at: position)
            return
        }
        let off = push(element: Byte(condition ? 1 : 0))
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
    
    /// Used to debug the buffer and the implementation
    public func debug(str: String = "normal memory: ") {
        _bb.debugMemory(str: str)
    }
}
#endif
