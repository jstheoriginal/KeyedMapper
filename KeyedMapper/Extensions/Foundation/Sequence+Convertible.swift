import Foundation

public extension Sequence where Self.Iterator.Element: Convertible, Self.Iterator.Element.ConvertedType == Self.Iterator.Element {
    public static func fromMap(_ values: [Any]) throws -> [Self.Iterator.Element.ConvertedType] {
        return try values.map(Self.Iterator.Element.fromMap)
    }
}

public extension Sequence where Self.Iterator.Element: Sequence,
                                Self.Iterator.Element.Iterator.Element: Convertible,
                                Self.Iterator.Element.Iterator.Element.ConvertedType == Self.Iterator.Element.Iterator.Element {
    public static func fromMap(_ values: [[Any]]) throws -> [[Self.Iterator.Element.Iterator.Element.ConvertedType]] {
        return try values.map([Self.Iterator.Element.Iterator.Element.ConvertedType].fromMap)
    }
}
