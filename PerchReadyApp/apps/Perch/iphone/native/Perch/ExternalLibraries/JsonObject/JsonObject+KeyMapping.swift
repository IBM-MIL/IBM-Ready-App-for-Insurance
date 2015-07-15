//
//  JsonObject+KeyMapping.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// MARK: JsonObject+KeyMapping

extension JsonObject {
    
    func propertyKeyForDictionaryKey(var key: String) -> String? {
        if self is MapsUnderscoreCaseToCamelCase {
            key = camelCaseStringFromUnderscoreString(key)
        }
        if self.respondsToSelector(NSSelectorFromString(key)) {
            return key
        } else {
            return nil
        }
    }
    
    func dictionaryKeyForPropertyKey(key: String) -> String {
        if self is MapsUnderscoreCaseToCamelCase {
            return underscoreStringFromCamelCaseString(key)
        } else {
            return key
        }
    }
    
    private func camelCaseStringFromUnderscoreString(underscoreString: String) -> String {
        var camelCaseString = ""
        var makeNextCharacterUppercase = false
        underscoreString.enumerateSubstringsInRange(rangeForString(underscoreString), options: enumerationOptions) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if substring == "_" {
                makeNextCharacterUppercase = true
            } else if makeNextCharacterUppercase {
                camelCaseString += substring.uppercaseString
                makeNextCharacterUppercase = false
            } else {
                camelCaseString += substring
            }
        }
        return camelCaseString
    }
    
    private func underscoreStringFromCamelCaseString(camelCaseString: String) -> String {
        var underscoreString = ""
        camelCaseString.enumerateSubstringsInRange(rangeForString(camelCaseString), options: enumerationOptions) { (substring, substringRange, enclosingRange, shouldContinue) -> () in
            if substring.lowercaseString != substring {
                underscoreString += "_" + substring.lowercaseString
            } else {
                underscoreString += substring
            }
        }
        return underscoreString
    }
    
    private func rangeForString(string: String) -> Range<String.Index> {
        return Range<String.Index>(start: string.startIndex, end: string.endIndex)
    }
    
}

private let enumerationOptions = NSStringEnumerationOptions.ByComposedCharacterSequences