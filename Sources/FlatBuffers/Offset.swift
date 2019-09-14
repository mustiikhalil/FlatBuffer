import Foundation

struct Offset<T> {
    var o: UOffset
    var isNull: Bool { return o == nil }
    init(offset: UOffset) { o = offset }
    init() { o = 0 }
}
