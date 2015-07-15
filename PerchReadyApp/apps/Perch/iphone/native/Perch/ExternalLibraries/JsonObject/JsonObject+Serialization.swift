//
//  JsonObject+Serialization.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// MARK: JsonObject+Serialization

extension JsonObject {
    
    func serializedDictionary() -> NSDictionary {
        var dictionary = NSMutableDictionary()
        for (name, mirrorType) in properties() {
            if let mapper = mapperForType(mirrorType.valueType),
                let value: AnyObject = valueForProperty(name, mirrorType: mirrorType) {
                    if let jsonValue = mapper.jsonValueFromPropertyValue(value) {
                        dictionary.setObject(jsonValue.value(), forKey: dictionaryKeyForPropertyKey(name))
                    }
            }
        }
        return dictionary
    }
    
    private func valueForProperty(name: String, mirrorType: MirrorType) -> AnyObject? {
        if let value: AnyObject = mirrorType.value as? AnyObject {
            return value
        } else if respondsToSelector(NSSelectorFromString(name)) {
            if let value: AnyObject = valueForKey(name) {
                return value
            }
        }
        return nil
    }
    
}