import Foundation

public struct Offset<T> {
    public var o: UOffset
    public var isNull: Bool { return o == nil }
    public init(offset: UOffset) { o = offset }
    public init() { o = 0 }
}
