import Foundation

public protocol FlatBufferObject {
    init(_ bb: FlatBuffer, o: Int32)
}

public protocol Readable: FlatBufferObject {
    static var size: Int { get }
    static var alignment: Int { get }
}

public protocol Mutable {
    var bb: FlatBuffer { get }
    var postion: Int32 { get }
}

extension Mutable {
    func mutate<T: Scalar>(value: T, o: Int32) -> Bool {
        guard o != 0 else { return false }
        bb.write(value: value, index: Int(o), direct: true)
        return true
    }
}

extension Mutable where Self == Table {
    
    /// Mutates the value with respect to the position
    /// - Parameters:
    ///   - value: New value to be inserted to the buffer
    ///   - index: index of the Element
    func mutate<T: Scalar>(_ value: T, index: Int32) -> Bool {
        guard index != 0 else { return false }
        return mutate(value: value, o: index + postion)
    }
    
    /// Directly mutates the element at the index passed to it, this will ignore the position
    /// - Parameters:
    ///   - value: New value to be inserted to the buffer
    ///   - index: index of the Element
    func directMutate<T: Scalar>(_ value: T, index: Int32) -> Bool {
        return mutate(value: value, o: index)
    }
}

extension Mutable where Self == Struct {
    
    /// Mutates the value with respect to the position
    /// - Parameters:
    ///   - value: New value to be inserted to the buffer
    ///   - index: index of the Element
    func mutate<T: Scalar>(_ value: T, index: Int32) -> Bool {
        return mutate(value: value, o: index + postion)
    }
    
    /// Directly mutates the element at the index passed to it, this will ignore the position
    /// - Parameters:
    ///   - value: New value to be inserted to the buffer
    ///   - index: index of the Element
    func directMutate<T: Scalar>(_ value: T, index: Int32) -> Bool {
        return mutate(value: value, o: index)
    }
}
extension Struct: Mutable {}
extension Table: Mutable {}
