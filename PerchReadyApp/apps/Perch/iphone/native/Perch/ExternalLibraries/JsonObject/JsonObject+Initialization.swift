//
//  JsonObject+Initialization.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// MARK: JsonObject+Initialization

extension JsonObject {
    
    func loadDictionary(dictionary: NSDictionary) {
        for (key, value) in dictionary {
            if let key = key as? String,
                let mappedKey = propertyKeyForDictionaryKey(key),
                let mappedValue: AnyObject = valueForValue(value, key: mappedKey) {
                    self.setValue(mappedValue, forKey: mappedKey)
            }
        }
    }
    
    private func valueForValue(value: AnyObject, key: String) -> AnyObject? {
        for (propertyName, mirrorType) in properties() {
            if propertyName == key {
                if let mapper = mapperForType(mirrorType.valueType), let jsonValue = JsonValue(value: value) {
                    return mapper.propertyValueFromJsonValue(jsonValue)
                }
            }
        }
        return nil
    }
    
    func properties() -> [(String, MirrorType)] {
        var properties = [(String, MirrorType)]()
        for i in 1..<reflect(self).count {
            properties.append(reflect(self)[i])
        }
        return properties
    }
    
}
