import Foundation

public struct Offset<T> {
    public var o: UOffset
    public var isEmpty: Bool { return o == 0 }
    public init(offset: UOffset) { o = offset }
    public init() { o = 0 }
}
