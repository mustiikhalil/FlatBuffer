import Foundation

///
struct FlatBuffer {
    
    private let alignment = 1
    private var _memory: UnsafeMutableRawPointer
    private var _writerSize: Int = 0
    private var _capacity: Int
    var writerIndex: Int { return _capacity - _writerSize }
    
    var size: UOffset { return UOffset(_writerSize) }
    var memory: UnsafeMutableRawPointer { return _memory }
    var capacity: Int { return _capacity }
    
    ///
    /// - Parameter size:
    init(initialSize size: Int) {
        _memory = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: alignment)
        _memory.initializeMemory(as: UInt8.self, repeating: 0, count: size)
        _capacity = size
    }
    
    init(bytes: [UInt8]) {
        let ptr = UnsafePointer(bytes)
        _memory = UnsafeMutableRawPointer.allocate(byteCount: bytes.count, alignment: alignment)
        _memory.copyMemory(from: ptr, byteCount: bytes.count)
        _capacity = bytes.count
    }
    
    ///
    /// - Parameter padding:
    @inlinable mutating func fill(padding: UInt32) {
        ensureSpace(size: UInt8(padding))
        for _ in 0..<padding {
            _writerSize += MemoryLayout<UInt8>.size
            _memory.advanced(by: writerIndex).storeBytes(of: 0, as: UInt8.self)
        }
    }

    ///
    /// - Parameter value:
    /// - Parameter len:
    @inlinable mutating func push<T: Scaler>(value: T, len: Int) {
        ensureSpace(size: UInt8(len))
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: len)
        pointer.initialize(to: value)
        write(pointer: pointer, len: len, index: writerIndex)
    }
    
    ///
    /// - Parameter str:
    /// - Parameter len:
    @inlinable mutating func push(string str: String, len: Int) {
        ensureSpace(size: UInt8(len))
        let pointer = UnsafeMutablePointer<String>.allocate(capacity: len)
        pointer.initialize(to: str)
        write(pointer: pointer, len: len, index: writerIndex)
    }
    
    ///
    /// - Parameter pointer:
    /// - Parameter len:
    @inlinable mutating func write<T>(pointer: UnsafeMutablePointer<T>, len: Int, index: Int) {
        _memory.advanced(by: index - len).copyMemory(from: pointer, byteCount: len)
        _writerSize += len
    }
    
    ///
    /// - Parameter size:
    @discardableResult
    @inlinable mutating func ensureSpace(size: UInt8) -> UInt8 {
        if Int(size) + _writerSize > _capacity { rellocate(size) }
        assert(size < FlatBufferMaxSize, FlatbufferError.growBeyondTwoGB.errorDescription ?? "FB doesn't support more than 2GB")
        return size
    }
    
    ///
    /// - Parameter size:
    @inlinable mutating func rellocate(_ size: UInt8) {
        let currentWritingIndex = writerIndex
        _capacity += Int(size)
        // FIXME: - remove in case not needed :D!
//        while _capacity <= Int(size) + _writerSize {
//            _capacity = _capacity << 1
//        }
        let newData = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
        newData.initializeMemory(as: UInt8.self, repeating: 0, count: _capacity)
        newData.advanced(by: writerIndex).copyMemory(from: _memory.advanced(by: currentWritingIndex), byteCount: _writerSize)
        _memory.deallocate()
        _memory = newData
    }
    
    /// 
    @inlinable mutating func clear() {
        _writerSize = 0
        _memory.deallocate()
        _memory = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
    }
    
    @inlinable mutating func smallScratch<T>(value: T) {
        ensureSpace(size: UInt8(MemoryLayout<T>.size))
    }
    
    @inlinable func read<T: Scaler>(def: T.Type, position: Int, with off: Int) -> T {
        let r = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: off)
        r.copyMemory(from: _memory.advanced(by: position), byteCount: off)
        return r.load(as: T.self)
    }
    
    #if DEBUG
    func debugMemory(str: String) {
        let bufprt = UnsafeBufferPointer(start: _memory.assumingMemoryBound(to: UInt8.self), count: _capacity)
        let a = Array(bufprt)
        print(str, a, " \nwith buffer size: \(a.count)")
    }
    #endif
}

func pointer<T>(c: T) -> UnsafeMutablePointer<T> {
    let p = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
    p.initialize(to: c)
    return p
}
