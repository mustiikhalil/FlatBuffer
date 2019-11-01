import Foundation

public struct Struct {
    private var _bb: FlatBuffer
    private var _postion: Int32
    
    public var bb: FlatBuffer { return _bb }
    public var postion: Int32 { return _postion }
    
    public init(bb: FlatBuffer, position: Int32 = 0) {
        _bb = bb
        _postion = position
    }
    
    public func readBuffer<T: Scalar>(of type: T.Type, at o: Int32) -> T {
        let r = _bb.read(def: T.self, position: Int(o + _postion))
        return r
    }
}
