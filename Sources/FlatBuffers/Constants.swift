//
//  Constants.swift

import Foundation

private let isLitteEndian = CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue)

protocol Scaler: Equatable {
    associatedtype NumaricValue
    var convertedEndian: NumaricValue { get }
}

extension Scaler where Self: FixedWidthInteger {
    var convertedEndian: NumaricValue {
        if isLitteEndian { return self as! Self.NumaricValue }
        return self.littleEndian as! Self.NumaricValue
    }
}

extension Double: Scaler {
    typealias NumaricValue = UInt64
    
    var convertedEndian: UInt64 {
        if isLitteEndian { return self.bitPattern }
        return self.bitPattern.littleEndian
    }
}
extension Float: Scaler {
    typealias NumaricValue = UInt32
    
    var convertedEndian: UInt32 {
        if isLitteEndian { return self.bitPattern }
        return self.bitPattern.littleEndian
    }
}

extension Int: Scaler { typealias NumaricValue = Int }

extension Int8: Scaler { typealias NumaricValue = Int8 }
extension Int16: Scaler { typealias NumaricValue = Int16 }
extension Int32: Scaler { typealias NumaricValue = Int32 }
extension Int64: Scaler { typealias NumaricValue = Int64 }

extension UInt8: Scaler { typealias NumaricValue = UInt8 }
extension UInt16: Scaler { typealias NumaricValue = UInt16 }

extension UInt32: Scaler { typealias NumaricValue = UInt32 }
extension UInt64: Scaler { typealias NumaricValue = UInt64 }

public typealias UOffset = UInt32
public typealias SOffset = Int32
public typealias VOffset = UInt16
public let FlatBufferMaxSize = UInt32.max << ((MemoryLayout<SOffset>.size * 8 - 1) - 1)
