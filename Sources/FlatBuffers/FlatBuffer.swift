import Foundation

///
struct FlatBuffer {
    
    private let alignment = 1
    private var _memory: UnsafeMutableRawPointer
    private var _writerSize: Int = 0
    private var _capacity: Int
    private var writerIndex: Int { return _capacity - _writerSize }
    var size: Int32 { return Int32(_writerSize) }
    
    ///
    /// - Parameter size:
    init(initialSize size: Int) {
        _memory = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        _capacity = size
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
        let len = UInt8(len)
        ensureSpace(size: len)
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: Int(len))
        pointer.initialize(to: value)
        _memory.advanced(by: writerIndex - Int(len)).copyMemory(from: pointer, byteCount: Int(len))
        _writerSize += Int(len)
    }

    
    ///
    /// - Parameter size:
    @discardableResult
    @inlinable mutating func ensureSpace(size: UInt8) -> UInt8 {
        if Int(size) + _writerSize > _capacity { rellocate(size) }
        return size
    }
    
    ///
    /// - Parameter size:
    @inlinable mutating func rellocate(_ size: UInt8) {
        let currentWritingIndex = writerIndex

        while _capacity <= Int(size) + _writerSize {
            _capacity = _capacity << 1
        }
        let newData = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
        newData.advanced(by: writerIndex).copyMemory(from: _memory.advanced(by: currentWritingIndex), byteCount: _writerSize)
        _memory.deallocate()
        _memory = newData
    }
    
    @inlinable mutating func clear() {
        _writerSize = 0
        _memory.deallocate()
        _memory = UnsafeMutableRawPointer.allocate(byteCount: _capacity, alignment: alignment)
    }
    
    #if DEBUG
    func debugMemory(str: String = "normal memory: ") {
        let bufprt = UnsafeBufferPointer(start: _memory.assumingMemoryBound(to: UInt8.self), count: _capacity)
        print(str, Array(bufprt))
    }
    #endif
}
