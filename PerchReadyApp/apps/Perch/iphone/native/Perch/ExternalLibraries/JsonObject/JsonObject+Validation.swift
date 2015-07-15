//
//  JsonObject+Validation.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// MARK: JsonObject+Validation

extension JsonObject {
    
    func missingKeys() -> [String] {
        var missingKeys = [String]()
        for (name, mirrorType) in properties() {
            if respondsToSelector(NSSelectorFromString(name)) && mirrorType.summary == "nil" {
                if let mapper = mapperForType(mirrorType.valueType),
                    let optionalMapper = mapper as? OptionalMapper,
                    let sampleInstance: AnyObject = optionalMapper.sampleInstance as? AnyObject {
                        setValue(sampleInstance, forKey: name)
                        if valueForKey(name) != nil && isLeafProperty(name: name) {
                            missingKeys.append(name)
                        }
                        setValue(nil, forKey: name)
                }
            }
        }
        return missingKeys
    }
    
    private func isLeafProperty(#name: String) -> Bool {
        for (propertyName, mirrorType) in properties() {
            if propertyName == name {
                return "\(mirrorType)".rangeOfString("Swift._OptionalMirror", options: nil, range: nil, locale: nil) == nil
            }
        }
        return false
    }
    
}