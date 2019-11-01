//
//  Constants.swift

import Foundation

let isLitteEndian = CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue)

public typealias Byte = UInt8
public typealias UOffset = UInt32
public typealias SOffset = Int32
public typealias VOffset = UInt16
public let FlatBufferMaxSize = UInt32.max << ((MemoryLayout<SOffset>.size * 8 - 1) - 1)

public protocol Scalar: Equatable {
    associatedtype NumericValue
    var convertedEndian: NumericValue { get }
}

extension Scalar where Self: FixedWidthInteger {
    public var convertedEndian: NumericValue {
        if isLitteEndian { return self as! Self.NumericValue }
        return self.littleEndian as! Self.NumericValue
    }
}

extension Double: Scalar {
    public typealias NumericValue = UInt64
    
    public var convertedEndian: UInt64 {
        if isLitteEndian { return self.bitPattern }
        return self.bitPattern.littleEndian
    }
}
extension Float: Scalar {
    public typealias NumericValue = UInt32
    
    public var convertedEndian: UInt32 {
        if isLitteEndian { return self.bitPattern }
        return self.bitPattern.littleEndian
    }
}

extension Int: Scalar {
    public typealias NumericValue = Int
}

extension Int8: Scalar {
    public typealias NumericValue = Int8
}

extension Int16: Scalar {
    public typealias NumericValue = Int16
}

extension Int32: Scalar {
    public typealias NumericValue = Int32
}

extension Int64: Scalar {
    public typealias NumericValue = Int64
}

extension UInt8: Scalar {
    public typealias NumericValue = UInt8
}

extension UInt16: Scalar {
    public typealias NumericValue = UInt16
}

extension UInt32: Scalar {
    public typealias NumericValue = UInt32
}

extension UInt64: Scalar {
    public typealias NumericValue = UInt64
}
