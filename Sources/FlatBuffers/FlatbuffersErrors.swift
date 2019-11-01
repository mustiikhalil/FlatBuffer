import Foundation

public enum FlatbufferError: Error {
    case sizeIsZeroOrLess,
    nestedSerializationNotAllowed,
    serializingWithoutCallingStartVector,
    growBeyondTwoGB,
    invalidFieldNumber,
    endTableCalledBeforeStart,
    calledSizedBinaryBeforeFinish,
    endianCheck,
    outOfRange
}

extension FlatbufferError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .nestedSerializationNotAllowed:
            return "Object serialization must not be nested"
            
        case .serializingWithoutCallingStartVector:
            return "Calling endVector without calling startVector"
            
        case .sizeIsZeroOrLess:
            return "Size should be greater than zero!"
            
        case .growBeyondTwoGB:
            return "Buffer can't grow beyond 2 Gigabytes"
            
        case .invalidFieldNumber:
            return "Invalid field numbers!"
            
        case .endTableCalledBeforeStart:
            return "End table was called before calling start table"
            
        case .calledSizedBinaryBeforeFinish:
            return "Data shouldn't be called before finish()"
            
        case .endianCheck:
            return "Reading/Writing a buffer in big endian machine is not supported on swift"
            
        case .outOfRange:
            return "Out of the table range"
        }
    }
}
