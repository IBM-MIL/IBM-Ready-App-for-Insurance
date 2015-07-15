//
//  JsonObject.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/16/15.
//
//

import Foundation

public protocol MapsUnderscoreCaseToCamelCase {}

public class JsonObject: NSObject {
    
    // Convenience initializer that assumes you'd like to validate your object
    public convenience init?(dictionary: NSDictionary) {
        self.init(dictionary: dictionary, shouldValidate: true)
    }
    
    // Required initializer that takes a json dictionary to load into your 
    // properties and a flag indicating whether your object should be validated
    public required init?(dictionary: NSDictionary, shouldValidate: Bool) {
        super.init()
        loadDictionary(dictionary)
        if shouldValidate {
            if self.missingKeys().count > 0 {
                println("Invalid JSON data. Required JSON keys are missing from the input: \(self.missingKeys())")
                return nil
            }
        }
    }
    
    // Generated variable that returns a json dictionary representation of your object
    public var dictionary: NSDictionary {
        get {
            return serializedDictionary()
        }
    }
    
    // Call this method to register a custom JsonMapper
    public static func registerMapper(mapper: JsonMapper) {
        registerJsonMapper(mapper)
    }
    
}
