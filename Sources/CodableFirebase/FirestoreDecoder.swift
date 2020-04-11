//
//  FirestoreDecoder.swift
//  Slap
//
//  Created by Oleksii on 21/10/2017.
//  Copyright © 2017 Slap. All rights reserved.
//

import Foundation

public protocol FirestoreDecodable: Decodable {}
public protocol FirestoreEncodable: Encodable {}

public typealias DocumentReferenceType = FirestoreDecodable & FirestoreEncodable
public typealias FieldValueType = FirestoreEncodable

public protocol GeoPointType: FirestoreDecodable, FirestoreEncodable {
    var latitude: Double { get }
    var longitude: Double { get }
    init(latitude: Double, longitude: Double)
}

public protocol TimestampType: FirestoreDecodable, FirestoreEncodable {
    init(date: Date)
    func dateValue() -> Date
}

open class FirestoreDecoder {
    public init() {}
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    open func decode<T : Decodable>(_ type: T.Type, from container: [String: Any]) throws -> T {
        let options = _FirebaseDecoder._Options(
            dateDecodingStrategy: nil,
            dataDecodingStrategy: nil,
            skipFirestoreTypes: true,
            userInfo: userInfo
        )
        let decoder = _FirebaseDecoder(referencing: container, options: options)
        guard let value = try decoder.unbox(container, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
        }
        
        return value
    }
}

enum GeoPointKeys: CodingKey {
    case latitude, longitude
}

extension GeoPointType {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoPointKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoPointKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

enum DocumentReferenceError: Error {
    case typeIsNotSupported
    case typeIsNotNSObject
}

extension FirestoreDecodable {
    public init(from decoder: Decoder) throws {
        throw DocumentReferenceError.typeIsNotSupported
    }
}

extension FirestoreEncodable {
    public func encode(to encoder: Encoder) throws {
        throw DocumentReferenceError.typeIsNotSupported
    }
}

extension TimestampType {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(date: try container.decode(Date.self))
    }
  
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dateValue())
    }
}
