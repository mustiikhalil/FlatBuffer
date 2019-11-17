import Foundation

public final class FlatBuffersUtils {
    public static func getSizePrefix(bb: FlatBuffer) -> Int32 {
        return bb.read(def: Int32.self, position: bb.reader)
    }

    public static func removeSizePrefix(bb: FlatBuffer) -> FlatBuffer {
        return bb.duplicate(removing: MemoryLayout<Int32>.size)
    }
}
