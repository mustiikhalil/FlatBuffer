import Foundation

extension Int {
    var convertToPowerofTwo: Int {
        guard self > 0 else { return 1 }
        var n = UOffset(self)
        
        #if arch(arm) || arch(i386)
        let max = UInt32(Int.max)
        #else
        let max = UInt32.max
        #endif
        
        n -= 1
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        n |= n >> 8
        n |= n >> 16
        if n != max {
            n += 1
        }

        return Int(n)
    }
}
