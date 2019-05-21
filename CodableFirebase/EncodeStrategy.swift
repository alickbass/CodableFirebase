//
//  EncodeStrategy.swift
//  CodableFirebase
//
//  Created by Zitao Xiong on 11/3/18.
//  Copyright © 2018 ViolentOctopus. All rights reserved.
//

import Foundation

/// The strategy to use for encoding `Date` values.
public enum DateEncodingStrategy {
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate

    case deferredToTimestamp((Date) -> TimestampType)

    /// Encode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601

    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)

    /// Encode the `Date` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    case custom((Date, Encoder) throws -> Void)
}

/// The strategy to use for encoding `Data` values.
public enum DataEncodingStrategy {
    /// Defer to `Data` for choosing an encoding.
    case deferredToData

    /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
    case base64

    /// Encode the `Data` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    case custom((Data, Encoder) throws -> Void)
}

public enum FirestoreTypeEncodingStrategy {
    case deferredToPtotocol
    case custom((_ value: Any) throws -> Any)
}

extension CodingUserInfoKey {
    public static let dateEncodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "dateEncodingStrategy")!

    public static let dataEncodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "dataEncodingStrategy")!

    public static let skipFirestoreTypes: CodingUserInfoKey = CodingUserInfoKey(rawValue: "skipFirestoreTypes")!

    public static let firestoreTypeEncodingStrategy: CodingUserInfoKey = CodingUserInfoKey(rawValue: "firestoreTypeEncodingStrategy")!
}

extension Dictionary where Key == CodingUserInfoKey, Value == Any {
    var dateEncodingStrategy: DateEncodingStrategy? {
        return self[.dateEncodingStrategy] as? DateEncodingStrategy
    }

    var dataEncodingStrategy: DataEncodingStrategy? {
        return self[.dataEncodingStrategy] as? DataEncodingStrategy
    }

    var skipFirestoreTypes: Bool {
        if let skip = self[.skipFirestoreTypes] as? Bool {
            return skip
        }
        return false
    }

    var firestoreTypeEncodingStrategy: FirestoreTypeEncodingStrategy {
        if let strategy = self[.firestoreTypeEncodingStrategy] as? FirestoreTypeEncodingStrategy {
            return strategy
        }

        return FirestoreTypeEncodingStrategy.deferredToPtotocol
    }
}
