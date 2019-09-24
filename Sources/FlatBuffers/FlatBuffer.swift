import Foundation

///
public final class FlatBuffer {
    
    private var _memory: UnsafeMutableRawPointer
    private var _writerSize: Int = 0
    private var _capacity: Int
    
    var alignment = 1
    
    public var writerIndex: Int { return _capacity - _writerSize }
    public var size: UOffset { return UOffset(_writerSize) }
    public var memory: UnsafeMutableRawPointer { return _memory }
    public var capacity: Int { return _capacity }
    
    ///
    /// - Parameter size:
    init(initialSize size: Int) {
        _memory = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        _memory.initializeMemory(as: UInt8.self, repeating: 0, count: size)
        _capacity = size
    }
    
    public init(bytes: [UInt8]) {
        let ptr = UnsafePointer(bytes)
        _memory = UnsafeMutableRawPointer.allocate(byteCount: bytes.count, alignment: alignment)
        _memory.copyMemory(from: ptr, byteCount: bytes.count)
        _capacity = bytes.count
    }
    
    deinit { _memory.deallocate() }
    
    ///
    /// - Parameter padding:
    func fill(padding: UInt32) {
        ensureSpace(size: UInt8(padding))
        _writerSize += (MemoryLayout<UInt8>.size * Int(padding))
    }

    ///
    /// - Parameter value:
    /// - Parameter len:
    func push<T: Scalar>(value: T, len: Int) {
        ensureSpace(size: UInt8(len))
        _memory.storeBytes(of: value, toByteOffset: writerIndex - len, as: T.self)
        _writerSize += len
    }
    
    ///
    /// - Parameter str:
    /// - Parameter len:
    func push(string str: String, len: Int) {
        ensureSpace(size: UInt8(len))
        let utf8View = str.utf8
        for c in utf8View.lazy.reversed() {
            push(value: c, len: 1)
        }
    }
    
    ///
    /// - Parameter pointer:
    /// - Parameter len:
    func write<T>(value: T, len: Int, index: Int) {
        _memory.storeBytes(of: value, toByteOffset: _capacity - index, as: T.self)
    }
    
    ///
    /// - Parameter size:
    @discardableResult
    func ensureSpace(size: UInt8) -> UInt8 {
        if Int(size) + _writerSize > _capacity { reallocate(size) }
        assert(size < FlatBufferMaxSize, FlatbufferError.growBeyondTwoGB.errorDescription ?? "FB doesn't support more than 2GB")
        return size
    }
    
    ///
    /// - Parameter size:
    fileprivate func reallocate(_ size: UInt8) {
        let currentWritingIndex = writerIndex
        while _capacity <= _writerSize + Int(size) {
            _capacity = _capacity << 1
        }
        let newData = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
        newData.initializeMemory(as: UInt8.self, repeating: 0, count: _capacity)
        newData.advanced(by: writerIndex).copyMemory(from: _memory.advanced(by: currentWritingIndex), byteCount: _writerSize)
        _memory.deallocate()
        _memory = newData
    }
    
    public func clearSize() {
        _writerSize = _capacity
    }
    
    ///
    public func clear() {
        _writerSize = 0
        _memory.deallocate()
        _memory = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
    }
    
    public func read<T: Scalar>(def: T.Type, position: Int, with off: Int) -> T {
        let r = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: off)
        r.copyMemory(from: _memory.advanced(by: position), byteCount: off)
        return r.load(as: T.self)
    }
    
    #if DEBUG
    func debugMemory(str: String) {
        let bufprt = UnsafeBufferPointer(start: _memory.assumingMemoryBound(to: UInt8.self), count: _capacity)
        let a = Array(bufprt)
        print(str, a, " \nwith buffer size: \(a.count) and writer size: \(_writerSize)")
    }
    #endif
}
