import Quick
import Nimble
@testable import KeyedMapper

fileprivate struct ConvertibleObject: Convertible, Hashable, Equatable {
    fileprivate let stringProperty: String

    //MARK: Convertible
    fileprivate static func fromMap(_ value: Any) throws -> ConvertibleObject {
        guard let string = value as? String else {
            throw MapperError.convertible(value: value, expectedType: String.self)
        }
        
        return ConvertibleObject(stringProperty: string)
    }

    //MARK: Hashable
    fileprivate var hashValue: Int {
        return stringProperty.hashValue
    }

    //MARK: Equatable
    fileprivate static func == (lhs: ConvertibleObject, rhs: ConvertibleObject) -> Bool {
        return lhs.stringProperty == rhs.stringProperty
    }
}

fileprivate struct Model: Mappable {
    fileprivate enum Key: String, JSONKey {
        case convertibleProperty
    }

    fileprivate let convertibleProperty: ConvertibleObject

    fileprivate init(map: KeyedMapper<Model>) throws {
        try self.convertibleProperty = map.from(.convertibleProperty)
    }
}

fileprivate struct ModelWithArrayProperty: Mappable {
    fileprivate enum Key: String, JSONKey {
        case convertibleArrayProperty
    }

    fileprivate let convertibleArrayProperty: [ConvertibleObject]

    fileprivate init(map: KeyedMapper<ModelWithArrayProperty>) throws {
        try self.convertibleArrayProperty = map.from(.convertibleArrayProperty)
    }
}

fileprivate struct ModelWithDictionaryProperty: Mappable {
    fileprivate enum Key: String, JSONKey {
        case convertibleDictionaryProperty
    }

    fileprivate let convertibleDictionaryProperty: [ConvertibleObject : [ConvertibleObject]]

    fileprivate init(map: KeyedMapper<ModelWithDictionaryProperty>) throws {
        try self.convertibleDictionaryProperty = map.from(.convertibleDictionaryProperty)
    }
}

fileprivate struct ModelWithTwoDArrayProperty: Mappable {
    fileprivate enum Key: String, JSONKey {
        case convertibleTwoDArrayProperty
    }

    fileprivate let convertibleTwoDArrayProperty: [[ConvertibleObject]]

    fileprivate init(map: KeyedMapper<ModelWithTwoDArrayProperty>) throws {
        try self.convertibleTwoDArrayProperty = map.from(.convertibleTwoDArrayProperty)
    }
}

class KeyedMapper_ConvertibleSpec: QuickSpec {
    override func spec() {
        describe("from<T: Convertible> -> T") {
            context("when the fromMap implementation throws an error") {
                it("should throw an error") {
                    let expectedValue = 2
                    let dict: NSDictionary = ["convertibleProperty" : expectedValue]
                    let mapper = KeyedMapper(JSON: dict, type: Model.self)
                    
                    do {
                        let _: ConvertibleObject = try mapper.from(.convertibleProperty)
                    } catch let error as MapperError {
                        expect(error) == MapperError.convertible(value: expectedValue, expectedType: String.self)
                    } catch {
                        XCTFail("Error thrown from from<T: Convertible> -> T was not a convertible error")
                    }
                }
            }
            
            context("when the fromMap implementation does not throw an error") {
                it("should correctly map") {
                    let dict: NSDictionary = ["convertibleProperty" : ""]
                    let mapper = KeyedMapper(JSON: dict, type: Model.self)
                    let convertibleThing: ConvertibleObject = try! mapper.from(.convertibleProperty)
                    
                    expect(convertibleThing).toNot(beNil())
                }
            }
        }

        describe("from<T: Convertible> -> [T]") {
            context("when the value cannot be casted to an array of Any") {
                it("should throw a typeMismatch error") {
                    let value: NSDictionary = [:]
                    let dict: NSDictionary = ["convertibleArrayProperty" : value]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithArrayProperty.self)
                    let field = ModelWithArrayProperty.Key.convertibleArrayProperty
                    
                    do {
                        let _: [ConvertibleObject] = try mapper.from(field)
                    } catch let error as MapperError {
                        expect(error) == MapperError.typeMismatch(field: field.stringValue, forType: ModelWithArrayProperty.self, value: value, expectedType: [Any].self)
                    } catch {
                        XCTFail("Error thrown from from<T: Convertible> -> [T] was not a MapperError")
                    }
                }
            }
            
            context("when the value can be casted to an array of Any") {
                it("should map correctly") {
                    let expectedValue = [""]
                    let dict: NSDictionary = ["convertibleArrayProperty" : expectedValue]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithArrayProperty.self)
                    let convertibleArray: [ConvertibleObject] = try! mapper.from(.convertibleArrayProperty)
                    
                    expect(convertibleArray.count) == expectedValue.count
                }
            }
        }

        describe("from<T: Convertible> -> [[T]]") {
            context("when the value cannot be casted to a two dimensional array of Any") {
                it("should throw a typeMismatch error") {
                    let value: NSDictionary = [:]
                    let dict: NSDictionary = ["convertibleTwoDArrayProperty" : value]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithTwoDArrayProperty.self)
                    let field = ModelWithTwoDArrayProperty.Key.convertibleTwoDArrayProperty

                    do {
                        let _: [[ConvertibleObject]] = try mapper.from(field)
                    } catch let error as MapperError {
                        expect(error) == MapperError.typeMismatch(field: field.stringValue, forType: ModelWithTwoDArrayProperty.self, value: value, expectedType: [[Any]].self)
                    } catch {
                        XCTFail("Error thrown from from<T: Convertible> -> [T] was not a MapperError")
                    }
                }
            }

            context("when the value can be casted to an array of Any") {
                it("should map correctly") {
                    let expectedValue = [""]
                    let dict: NSDictionary = ["convertibleTwoDArrayProperty" : [expectedValue]]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithTwoDArrayProperty.self)
                    let convertibleArray: [[ConvertibleObject]] = try! mapper.from(.convertibleTwoDArrayProperty)

                    expect(convertibleArray.count) == expectedValue.count
                }
            }
        }

        describe("from<T: Convertible> -> [U : [T]]") {
            context("when the value cannot be casted to an NSDictionary") {
                it("should return a typeMismatch error") {
                    let value: NSArray = []
                    let dict: NSDictionary = ["convertibleDictionaryProperty" : value]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                    let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty

                    do {
                        let _: [ConvertibleObject : [ConvertibleObject]] = try mapper.from(field)
                    } catch let error as MapperError {
                        expect(error) == MapperError.typeMismatch(field: field.stringValue, forType: ModelWithDictionaryProperty.self, value: value, expectedType: NSDictionary.self)
                    } catch {
                        XCTFail("Error thrown from from<T: Convertible> -> [U : [T]] was not a MapperError")
                    }
                }
            }

            context("when the value can be cast to an NSDictionary") {
                context("when one of the dictionary values cannot be cast to an [Any]") {
                    it("should return a typeMismatch error") {
                        let value: NSDictionary = ["" : [:]]
                        let dict: NSDictionary = ["convertibleDictionaryProperty" : value]
                        let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                        let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty

                        do {
                            let _: [ConvertibleObject : [ConvertibleObject]] = try mapper.from(field)
                        } catch let error as MapperError {
                            expect(error) == MapperError.typeMismatch(field: field.stringValue, forType: ModelWithDictionaryProperty.self, value: value, expectedType: [Any].self)
                        } catch {
                            XCTFail("Error thrown from from<T: Convertible> -> [U : [T]] was not a MapperError")
                        }
                    }
                }

                context("when all of the dictionary values can be cast to NSArrays") {
                    it("should return the correctly converted objects") {
                        let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty
                        let value: NSDictionary = ["" : [""]]
                        let dict: NSDictionary = [field.stringValue : value]
                        let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                        let convertibleDictionary: [ConvertibleObject : [ConvertibleObject]] = try! mapper.from(field)

                        expect(convertibleDictionary.values.count) == value.count
                    }
                }
            }
        }

        describe("optionalFrom<T: Convertible> -> T?") {
            context("when the fromMap implementation throws an error") {
                it("should return nil") {
                    let expectedValue = 2
                    let dict: NSDictionary = ["convertibleProperty" : expectedValue]
                    let mapper = KeyedMapper(JSON: dict, type: Model.self)
                    let convertibleThing: ConvertibleObject? = mapper.optionalFrom(.convertibleProperty)
                    
                    expect(convertibleThing).to(beNil())
                }
            }
            
            context("when the fromMap implementation does not throw an error") {
                it("should correctly map") {
                    let dict: NSDictionary = ["convertibleProperty" : ""]
                    let mapper = KeyedMapper(JSON: dict, type: Model.self)
                    let convertibleThing: ConvertibleObject? = mapper.optionalFrom(.convertibleProperty)
                    
                    expect(convertibleThing).toNot(beNil())
                }
            }
        }
        
        describe("optionalFrom<T: Convertible> -> [T]?") {
            context("when the value cannot be casted to an array of Any") {
                it("should return nil") {
                    let dict: NSDictionary = ["convertibleArrayProperty" : [:]]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithArrayProperty.self)
                    let convertibleArray: [ConvertibleObject]? = mapper.optionalFrom(.convertibleArrayProperty)
                    
                    expect(convertibleArray).to(beNil())
                }
            }
            
            context("when the value can be casted to an array of Any") {
                it("should map correctly") {
                    let expectedValue = [""]
                    let dict: NSDictionary = ["convertibleArrayProperty" : expectedValue]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithArrayProperty.self)
                    let convertibleArray: [ConvertibleObject]? = mapper.optionalFrom(.convertibleArrayProperty)
                    
                    expect(convertibleArray).toNot(beNil())
                    expect(convertibleArray?.count) == expectedValue.count
                }
            }
        }

        describe("optionalFrom<T: Convertible> -> [[T]]?") {
            context("when the value cannot be casted to a two dimensional array of Any") {
                it("should return nil") {
                    let value: NSDictionary = [:]
                    let dict: NSDictionary = ["convertibleTwoDArrayProperty" : value]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithTwoDArrayProperty.self)
                    let field = ModelWithTwoDArrayProperty.Key.convertibleTwoDArrayProperty

                    let models: [[ConvertibleObject]]? = mapper.optionalFrom(field)

                    expect(models).to(beNil())
                }
            }

            context("when the value can be casted to an array of Any") {
                it("should map correctly") {
                    let expectedValue = [""]
                    let dict: NSDictionary = ["convertibleTwoDArrayProperty" : [expectedValue]]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithTwoDArrayProperty.self)
                    let convertibleArray: [[ConvertibleObject]]? = mapper.optionalFrom(.convertibleTwoDArrayProperty)

                    expect(convertibleArray?.count) == expectedValue.count
                }
            }
        }

        describe("optionalFrom<T: Convertible> -> [U : [T]]?") {
            context("when the value cannot be casted to an NSDictionary") {
                it("should return a nil") {
                    let value: NSArray = []
                    let dict: NSDictionary = ["convertibleDictionaryProperty" : value]
                    let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                    let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty
                    let convertibleDictionary: [ConvertibleObject : [ConvertibleObject]]? = mapper.optionalFrom(field)

                    expect(convertibleDictionary).to(beNil())
                }
            }

            context("when the value can be cast to an NSDictionary") {
                context("when one of the dictionary values cannot be cast to an NSArray") {
                    it("should return a typeMismatch error") {
                        let value: NSDictionary = ["" : [:]]
                        let dict: NSDictionary = ["convertibleDictionaryProperty" : value]
                        let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                        let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty
                        let convertibleDictionary: [ConvertibleObject : [ConvertibleObject]]? = mapper.optionalFrom(field)

                        expect(convertibleDictionary).to(beNil())
                    }
                }

                context("when all of the dictionary values can be cast to NSArrays") {
                    it("should return the correctly converted objects") {
                        let field = ModelWithDictionaryProperty.Key.convertibleDictionaryProperty
                        let value: NSDictionary = ["" : [""]]
                        let dict: NSDictionary = [field.stringValue : value]
                        let mapper = KeyedMapper(JSON: dict, type: ModelWithDictionaryProperty.self)
                        let convertibleDictionary: [ConvertibleObject : [ConvertibleObject]]? = mapper.optionalFrom(field)

                        expect(convertibleDictionary?.values.count) == value.count
                    }
                }
            }
        }
    }
}
