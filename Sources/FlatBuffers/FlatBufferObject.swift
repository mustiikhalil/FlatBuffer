import Foundation

public protocol FlatBufferObject {
    init(_ bb: FlatBuffer, o: Int32)
}

public protocol Writeable {}
public protocol Readable: FlatBufferObject {}
