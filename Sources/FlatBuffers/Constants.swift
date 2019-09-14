//
//  Constants.swift

import Foundation

protocol Scaler: Equatable {}

extension String: Scaler {}
extension Bool: Scaler {}
extension Double: Scaler {}
extension Float: Scaler {}

extension Int: Scaler {}

extension Int8: Scaler {}
extension Int16: Scaler {}
extension Int32: Scaler {}
extension Int64: Scaler {}

extension UInt8: Scaler {}
extension UInt16: Scaler {}
extension UInt32: Scaler {}
extension UInt64: Scaler {}

public typealias UOffset = UInt32
public typealias SOffset = Int32
public typealias VOffset = UInt16
public typealias LargestScalar = uintmax_t
public typealias Byte = UInt8
public let FlatBufferMaxSize = UInt32.max << ((MemoryLayout<SOffset>.size * 8 - 1) - 1)
