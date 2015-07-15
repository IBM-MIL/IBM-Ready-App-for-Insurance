//
//  JsonValue.swift
//  JsonObject
//
//  Created by Bradley Hilton on 3/17/15.
//
//

import Foundation

// An enum that represents a JSON dictionary value
// Call value() to get associated value

public enum JsonValue {
    
    case String(NSString)
    case Number(NSNumber)
    case Array(NSArray)
    case Dictionary(NSDictionary)
    case Null(NSNull)
    
    init?(value: AnyObject?) {
        switch value {
        case let value as NSString:
            self = .String(value)
        case let value as NSNumber:
            self = .Number(value)
        case let value as NSArray:
            self = .Array(value)
        case let value as NSDictionary:
            self = .Dictionary(value)
        case let value as NSNull:
            self = .Null(value)
        default:
            return nil
        }
    }
    
    func value() -> AnyObject {
        switch self {
        case .String(let value): return value
        case .Number(let value): return value
        case .Array(let value): return value
        case .Dictionary(let value): return value
        case .Null(let value): return value
        }
    }
    
}