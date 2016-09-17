import Quick
import Nimble
@testable import KeyedMapper

fileprivate struct Model: Mappable, ReverseMappable {
    fileprivate enum Key: String, JSONKey {
        case stringProperty
    }
    
    fileprivate let stringProperty: String
    
    //MARK: Mappable
    fileprivate init(map: KeyedMapper<Model>) throws {
        try self.stringProperty = map.from(.stringProperty)
    }
    
    //MARK: ReverseMappable
    fileprivate func toKeyedJSON() -> [Key : Any?] {
        return [.stringProperty : stringProperty]
    }
}

extension Model: Equatable {
    fileprivate static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs.stringProperty == rhs.stringProperty
    }
}

class ReverseMappableSpec: QuickSpec {
    override func spec() {
        describe("ReverseMappable") {
            describe("toJSON") {
                it("should return an NSDictionary that is identical to the one that was passed in originally") {
                    let expectedDict: NSDictionary = ["stringProperty" : ""]
                    let actualDict = try! Model.from(JSON: expectedDict).toJSON()
                    
                    expect(actualDict) == expectedDict
                }
                
                it("should return an NSDictionary that can be used to recreate the same model") {
                    let expectedModel = try! Model.from(JSON: ["stringProperty" : ""])
                    let actualModel = try! Model.from(JSON: expectedModel.toJSON())
                    
                    expect(actualModel) == expectedModel
                }
            }
        }
    }
}