import Foundation

//// TODO: - add docs

class FlatBuffersBuilder {

    private var _bb: FlatBuffer

    private var _minAlignment: Int32 = 0

    private var isNested = false

    ///
    /// - Parameter initialSize:
    init(initialSize: Int32 = 1024) throws {
        guard initialSize > 0 else { throw FlatbufferError.sizeIsZeroOrLess }
        _bb = FlatBuffer(initialSize: Int(initialSize))
    }

    /// Checks if the flag isNested is true to throw an error since nested serialization is not allowed
    fileprivate func notNested() throws { if isNested { throw FlatbufferError.nestedSerializationNotAllowed } }

    ///
    /// - Parameter size:
    fileprivate func minAlignment(size: Int32) { if size > _minAlignment { _minAlignment = size } }

    ///
    fileprivate func padding(bufSize: UInt32, elementSize: UInt32) -> UInt32 { ((~bufSize) + 1) & (elementSize - 1) }

    ///
    /// - Parameter len:
    fileprivate func preAlign(len: Int32, alignment: Int32) {
        minAlignment(size: alignment)
        _bb.fill(padding: padding(bufSize: UOffset(_bb.size + len), elementSize: UOffset(alignment)))
    }

    ///
    /// - Parameter len:
    /// - Parameter type:
    func preAlign<T: Scaler>(len: Int32, type: T.Type) {
        preAlign(len: len, alignment: Int32(MemoryLayout<T>.size))
    }

    ///
    /// - Parameter str:
    func create(string str: String) throws -> Int32 {
        let len = str.count
        try notNested()
        preAlign(len: Int32(len) + 1, type: UOffset.self)
        _bb.fill(padding: 1)
        _bb.push(value: str, len: len)
        _bb.push(value: UOffset(len), len: MemoryLayout.size(ofValue: UOffset(len)))
        _bb.debugMemory()
        return _bb.size
    }
    
    func clear() {
        _minAlignment = 0
        isNested = false
        _bb.clear()
        _bb.debugMemory(str: "deallocating memory: ")
    }
}

protocol Scaler {}

extension Int: Scaler {}
extension UInt32: Scaler {}
extension String: Scaler {}
extension Int32: Scaler {}
