//
//  JsonMapper.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

public protocol JsonMapper {
    
    // Required method that returns an instance of this object given a JsonValue input
    func propertyValueFromJsonValue(value: JsonValue) -> AnyObject?
    
    // Required method that returns a JsonValue given an instance of this object
    func jsonValueFromPropertyValue(value: AnyObject) -> JsonValue?
    
}
