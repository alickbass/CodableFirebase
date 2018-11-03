//
//  DecodeStrategy.swift
//  CodableFirebase
//
//  Created by Zitao Xiong on 11/3/18.
//  Copyright © 2018 ViolentOctopus. All rights reserved.
//

import Foundation

/// The strategy to use for decoding `Date` values.
public enum DateDecodingStrategy {
    /// Defer to `Date` for decoding. This is the default strategy.
    case deferredToDate

    case deferredToTimestamp
    
    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    case secondsSince1970

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    case millisecondsSince1970

    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601

    /// Decode the `Date` as a string parsed by the given formatter.
    case formatted(DateFormatter)

    /// Decode the `Date` as a custom value decoded by the given closure.
    case custom((_ decoder: Decoder) throws -> Date)
}

/// The strategy to use for decoding `Data` values.
public enum DataDecodingStrategy {
    /// Defer to `Data` for decoding.
    case deferredToData

    /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
    case base64

    /// Decode the `Data` as a custom value decoded by the given closure.
    case custom((_ decoder: Decoder) throws -> Data)
}

public enum FirestoreTypeDecodingStrategy {
    case deferredToPtotocol
    case custom((_ value: Any) throws -> Any)
}


extension CodingUserInfoKey {
    public static let dateDecodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "dateDecodingStrategy")!
    
    public static let dataDecodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "dataDecodingStrategy")!

    public static let firestoreTypeDecodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "firestoreTypeDecodingStrategy")!
}

extension Dictionary where Key == CodingUserInfoKey, Value == Any {
    var dateDecodingStrategy: DateDecodingStrategy? {
        return self[.dateDecodingStrategy] as? DateDecodingStrategy
    }

    var dataDecodingStrategy: DataDecodingStrategy? {
        return self[.dataDecodingStrategy] as? DataDecodingStrategy
    }

    var firestoreTypeDecodingStrategy: FirestoreTypeDecodingStrategy {
        if let strategy = self[.firestoreTypeDecodingStrategy] as? FirestoreTypeDecodingStrategy {
            return strategy
        }

        return FirestoreTypeDecodingStrategy.deferredToPtotocol
    }
}
