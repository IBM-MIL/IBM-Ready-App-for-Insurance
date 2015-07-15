//
//  JsonObject+Mappers.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// MARK: JsonObject+Mappers

extension JsonObject {
    
    // MARK: Public Methods
    
    func mapperForType(type: Any.Type) -> JsonMapper? {
        return mapperFromCompleteDescription(completeDescription(type))
    }
    
    static func registerJsonMapper(mapper: JsonMapper) {
        for (index, existingMapper) in enumerate(mappers) {
            if let existingMapper = existingMapper as? JsonInternalMapper where "\(existingMapper.type)" == "\(reflect(mapper).valueType)" {
                mappers.removeAtIndex(index)
            } else if "\(reflect(existingMapper).valueType)" == "\(reflect(mapper).valueType)" {
                mappers.removeAtIndex(index)
            }
        }
        mappers.append(mapper)
    }
    
    // MARK: Mapper Methods
    
    static var mappers: [JsonMapper] = [NSStringMapper(), NSNumberMapper(), NSArrayMapper(), NSDictionaryMapper(), JsonObjectMapper(), OptionalMapper(), DictionaryMapper(), ArrayMapper(), StringMapper(), IntMapper(), FloatMapper(), DoubleMapper(), BoolMapper()]
    
    private func mapperFromCompleteDescription(completeDescription: String) -> JsonMapper? {
        var typeDescription = self.typeDescription(completeDescription)
        if let JsonMapper = mapperFromTypeDescription(typeDescription) {
            if let JsonMapper = JsonMapper as? JSONGenericMapper,
                let genericMappers = genericMappersFromGenericsDescription(genericsDescription(completeDescription))  {
                    JsonMapper.submappers = genericMappers
            }
            if let JsonMapper = JsonMapper as? JsonObjectMapper,
                let modelType = NSClassFromString(completeDescription) as? JsonObject.Type {
                    JsonMapper.modelType = modelType
            }
            return JsonMapper
        }
        return nil
    }
    
    private func mapperFromTypeDescription(typeDescription: String) -> JsonMapper? {
        for mapper in JsonObject.mappers {
            if self.typeDescription(typeForMapper(mapper)) == typeDescription {
                return mapper
            }
        }
        if let someClass: AnyClass = NSClassFromString(typeDescription) {
            return mapperFromSuperClass(someClass)
        }
        return nil
    }
    
    private func mapperFromSuperClass(someClass: AnyClass) -> JsonMapper? {
        if let superclass: AnyClass = someClass.superclass() {
            for mapper in JsonObject.mappers {
                if typeDescription(someClass as! Any.Type) == typeDescription(typeForMapper(mapper)) {
                    return mapper
                }
            }
            return mapperFromSuperClass(superclass)
        } else {
            return nil
        }
    }
    
    private func genericMappersFromGenericsDescription(genericsDescription: String) -> [JsonMapper]? {
        var generics = [JsonMapper]()
        for genericTypeDescription in componentsFromString(genericsDescription) {
            if let genericMapper = mapperFromCompleteDescription(genericTypeDescription) {
                generics.append(genericMapper)
            }
        }
        return generics
    }
    
    // MARK: String Functions
    
    private func componentsFromString(string: String) -> [String] {
        var component = ""
        var components = [String]()
        var range = Range<String.Index>(start: string.startIndex, end: string.endIndex)
        var options = NSStringEnumerationOptions.ByComposedCharacterSequences
        var openings = 0
        var closings = 0
        string.enumerateSubstringsInRange(range, options: options) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if openings == closings && substring == "," {
                components.append(component)
                component = ""
            } else {
                if substring == ">" {
                    closings++
                }
                if substring == "<" {
                    openings++
                }
                component += substring
            }
        }
        components.append(component)
        return components
    }
    
    private func completeDescription(type: Any.Type) -> String {
        return "\(type)".stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
    }
    
    private func typeDescription(type: Any.Type) -> String {
        return typeDescription(completeDescription(type))
    }
    
    private func typeDescription(description: String) -> String {
        if let openingRange = description.rangeOfString("<", options: nil, range: nil, locale: nil) where description[count(description) - 1] == ">" {
            return description.substringWithRange(Range<String.Index>(start: description.startIndex, end: openingRange.startIndex))
        } else {
            return description
        }
    }
    
    private func genericsDescription(type: Any.Type) -> String {
        return genericsDescription(completeDescription(type))
    }
    
    private func genericsDescription(description: String) -> String {
        if let openingRange = description.rangeOfString("<", options: nil, range: nil, locale: nil) where description[count(description) - 1] == ">" {
            return description.substringWithRange(Range<String.Index>(start: openingRange.endIndex, end: description.endIndex.predecessor()))
        } else {
            return ""
        }
    }
    
}

// MARK: Helper Functions

private func typeForMapper(mapper: JsonMapper) -> Any.Type {
    if let internalMapper = mapper as? JsonInternalMapper {
        return internalMapper.type
    } else {
        return reflect(mapper).valueType
    }
}

private func sampleInstanceForMapper(mapper: JsonMapper) -> Any? {
    if let internalMapper = mapper as? JsonInternalMapper {
        return internalMapper.sampleInstance
    } else {
        return mapper
    }
}

// MARK: Internal Mappers

protocol JsonInternalMapper: JsonMapper {
    
    var type: Any.Type { get }
    
    var sampleInstance: Any? { get }
    
}

// MARK: Foundation Mappers

class NSStringMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return NSString.self } }
    
    var sampleInstance: Any? { get { return "Hello World" as NSString } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .String(let nsstring): return nsstring
        case .Number(let nsnumber): return nsnumber.stringValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
}

class NSNumberMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return NSNumber.self } }
    
    var sampleInstance: Any? { get { return NSNumber(integer: 42) } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber
        case .String(let nsstring): return nsstring
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class NSArrayMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return NSArray.self } }
    
    var sampleInstance: Any? { get { return NSArray() } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Array(let nsarray): return nsarray
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class NSDictionaryMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return NSDictionary.self } }
    
    var sampleInstance: Any? { get { return NSDictionary() } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary): return nsdictionary
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

// MARK: Model Mapper

class JsonObjectMapper: JsonInternalMapper {
    
    var modelType: JsonObject.Type = JsonObject.self
    
    var type: Any.Type { get { return JsonObject.self } }
    
    var sampleInstance: Any? { get { return modelType(dictionary: NSDictionary(), shouldValidate: false) } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary): return modelType(dictionary: nsdictionary, shouldValidate: true)
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let model = value as? JsonObject {
            return JsonValue(value: model.dictionary)
        } else {
            return nil
        }
    }
    
}

// MARK: Generic Mappers

class JSONGenericMapper: JsonInternalMapper {
    
    var submappers = [JsonMapper]()
    
    var type: Any.Type { get { return JSONGenericMapper.self } }
    
    var sampleInstance: Any? { get { return JSONGenericMapper() } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? { return nil }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: nil) }
    
}

class OptionalMapper: JSONGenericMapper {
    
    override var type: Any.Type { get { return Optional<AnyObject>.self } }
    
    override var sampleInstance: Any? {
        get {
            if submappers.count > 0 {
                return sampleInstanceForMapper(submappers[0])
            } else {
                return nil
            }
        }
    }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        if submappers.count > 0 {
            return submappers[0].propertyValueFromJsonValue(value)
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if submappers.count > 0 {
            return submappers[0].jsonValueFromPropertyValue(value)
        } else {
            return nil
        }
    }
    
}

class DictionaryMapper: JSONGenericMapper {
    
    override var type: Any.Type { get { return Dictionary<String, AnyObject>.self } }
    
    override var sampleInstance: Any? { get { return NSDictionary() } }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Dictionary(let nsdictionary): return propertyValueFromDictionary(nsdictionary)
        default: return nil
        }
    }
    
    private func propertyValueFromDictionary(nsdictionary: NSDictionary) -> AnyObject? {
        if submappers.count > 1 {
            let keyMapper = submappers[0]
            let valueMapper = submappers[1]
            var dictionary = NSMutableDictionary()
            for (key, value) in nsdictionary {
                if let keyJsonValue = JsonValue(value: key),
                    let valueJsonValue = JsonValue(value: value),
                    let key: NSCopying = keyMapper.propertyValueFromJsonValue(keyJsonValue) as? NSCopying,
                    let value: AnyObject = valueMapper.propertyValueFromJsonValue(valueJsonValue) {
                        dictionary.setObject(value, forKey: key)
                }
            }
            return dictionary
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let valueDictionary = value as? NSDictionary where submappers.count > 1 {
            let keyMapper = submappers[0]
            let valueMapper = submappers[1]
            var dictionary = NSMutableDictionary()
            for (key, value) in valueDictionary {
                if let keyJsonObject = keyMapper.jsonValueFromPropertyValue(key),
                    let key = keyJsonObject.value() as? NSCopying,
                    let valueJsonValue = valueMapper.jsonValueFromPropertyValue(value) {
                        dictionary.setObject(valueJsonValue.value(), forKey: key)
                }
            }
            return JsonValue(value: dictionary)
        } else {
            return nil
        }
    }
}

class ArrayMapper: JSONGenericMapper {
    
    override var type: Any.Type { get { return Array<AnyObject>.self } }
    
    override var sampleInstance: Any? { get { return NSArray() } }
    
    override func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Array(let nsarray): return propertyValueFromArray(nsarray)
        default: return nil
        }
    }
    
    private func propertyValueFromArray(nsarray: NSArray) -> AnyObject? {
        if submappers.count > 0 {
            let submapper = submappers[0]
            var array = NSMutableArray()
            for value in nsarray {
                if let jsonValue = JsonValue(value: value),
                    let object: AnyObject = submapper.propertyValueFromJsonValue(jsonValue) {
                        array.addObject(object)
                }
            }
            return array
        } else {
            return nil
        }
    }
    
    override func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let valueArray = value as? NSArray where submappers.count > 0 {
            let submapper = submappers[0]
            var array = NSMutableArray()
            for value in valueArray {
                if let jsonObject = submapper.jsonValueFromPropertyValue(value) {
                    array.addObject(jsonObject.value())
                }
            }
            return JsonValue(value: array)
        } else {
            return nil
        }
    }
}

// MARK: Swift Mappers

class StringMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return String.self } }
    
    var sampleInstance: Any? { get { return "Hello World" as String } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .String(let nsstring): return nsstring
        case .Number(let nsnumber): return nsnumber.stringValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? { return JsonValue(value: value) }
    
}

class IntMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return Int.self } }
    
    var sampleInstance: Any? { get { return 42 as Int } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.integerValue
        case .String(let nsstring): return nsstring.integerValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Int {
            return JsonValue(value: NSNumber(integer: value))
        } else {
            return nil
        }
    }
    
}

class FloatMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return Float.self } }
    
    var sampleInstance: Any? { get { return 42.00 as Float } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.floatValue
        case .String(let nsstring): return nsstring.floatValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Float {
            return JsonValue(value: NSNumber(float: value))
        } else {
            return nil
        }
    }
    
}

class DoubleMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return Double.self } }
    
    var sampleInstance: Any? { get { return 42.00 as Double } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.doubleValue
        case .String(let nsstring): return nsstring.doubleValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Double {
            return JsonValue(value: NSNumber(double: value))
        } else {
            return nil
        }
    }
    
}

class BoolMapper: JsonInternalMapper {
    
    var type: Any.Type { get { return Bool.self } }
    
    var sampleInstance: Any? { get { return true as Bool } }
    
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject? {
        switch value {
        case .Number(let nsnumber): return nsnumber.boolValue
        case .String(let nsstring): return nsstring.boolValue
        default: return nil
        }
    }
    
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue? {
        if let value = value as? Bool {
            return JsonValue(value: NSNumber(bool: value))
        } else {
            return nil
        }
    }
    
}


