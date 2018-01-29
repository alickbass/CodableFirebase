//
//  Encoder.swift
//  CodableFirebase
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import Foundation

class _FirebaseEncoder : Encoder {
    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    struct _Options {
        let dateEncodingStrategy: FirebaseEncoder.DateEncodingStrategy?
        let dataEncodingStrategy: FirebaseEncoder.DataEncodingStrategy?
        let skipFirestoreTypes: Bool
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    fileprivate var storage: _FirebaseEncodingStorage
    fileprivate let options: _Options
    fileprivate(set) public var codingPath: [CodingKey]
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    init(options: _Options, codingPath: [CodingKey] = []) {
        self.storage = _FirebaseEncodingStorage()
        self.codingPath = codingPath
        self.options = options
    }
    
    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    fileprivate var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }
    
    // MARK: - Encoder Methods
    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: NSMutableDictionary
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = _FirebaseKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: NSMutableArray
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        return _FirebaseUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

fileprivate struct _FirebaseEncodingStorage {
    // MARK: Properties
    /// The container stack.
    /// Elements may be any one of the plist types (NSNumber, NSString, NSDate, NSArray, NSDictionary).
    private(set) fileprivate var containers: [NSObject] = []
    
    // MARK: - Initialization
    /// Initializes `self` with no containers.
    fileprivate init() {}
    
    // MARK: - Modifying the Stack
    fileprivate var count: Int {
        return containers.count
    }
    
    fileprivate mutating func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        containers.append(dictionary)
        return dictionary
    }
    
    fileprivate mutating func pushUnkeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        containers.append(array)
        return array
    }
    
    fileprivate mutating func push(container: NSObject) {
        containers.append(container)
    }
    
    fileprivate mutating func popContainer() -> NSObject {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}

fileprivate struct _FirebaseKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    /// A reference to the encoder we're writing to.
    private let encoder: _FirebaseEncoder
    
    /// A reference to the container we're writing to.
    private let container: NSMutableDictionary
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _FirebaseEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods
    public mutating func encodeNil(forKey key: Key)               throws { container[key.stringValue] = NSNull() }
    public mutating func encode(_ value: Bool, forKey key: Key)   throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int, forKey key: Key)    throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int8, forKey key: Key)   throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int16, forKey key: Key)  throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int32, forKey key: Key)  throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int64, forKey key: Key)  throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt, forKey key: Key)   throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt8, forKey key: Key)  throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt16, forKey key: Key) throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt32, forKey key: Key) throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt64, forKey key: Key) throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: String, forKey key: Key) throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Float, forKey key: Key)  throws { container[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Double, forKey key: Key) throws { container[key.stringValue] = encoder.box(value) }
    
    public mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        container[key.stringValue] = try encoder.box(value)
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = NSMutableDictionary()
        self.container[key.stringValue] = dictionary
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        let container = _FirebaseKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = NSMutableArray()
        container[key.stringValue] = array
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        return _FirebaseUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _FirebaseReferencingEncoder(referencing: encoder, at: _FirebaseKey.super, wrapping: container)
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _FirebaseReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }
}

fileprivate struct _FirebaseUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    // MARK: Properties
    /// A reference to the encoder we're writing to.
    private let encoder: _FirebaseEncoder
    
    /// A reference to the container we're writing to.
    private let container: NSMutableArray
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The number of elements encoded into the container.
    public var count: Int {
        return container.count
    }
    
    // MARK: - Initialization
    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _FirebaseEncoder, codingPath: [CodingKey], wrapping container: NSMutableArray) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - UnkeyedEncodingContainer Methods
    public mutating func encodeNil()             throws { container.add(NSNull()) }
    public mutating func encode(_ value: Bool)   throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Int)    throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Int8)   throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Int16)  throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Int32)  throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Int64)  throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: UInt)   throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: UInt8)  throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Float)  throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: Double) throws { container.add(self.encoder.box(value)) }
    public mutating func encode(_ value: String) throws { container.add(self.encoder.box(value)) }
    
    public mutating func encode<T : Encodable>(_ value: T) throws {
        encoder.codingPath.append(_FirebaseKey(index: count))
        defer { encoder.codingPath.removeLast() }
        container.add(try encoder.box(value))
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(_FirebaseKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let dictionary = NSMutableDictionary()
        self.container.add(dictionary)
        
        let container = _FirebaseKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_FirebaseKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let array = NSMutableArray()
        self.container.add(array)
        return _FirebaseUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _FirebaseReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }
}

struct _FirebaseKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    static let `super` = _FirebaseKey(stringValue: "super")!
}

extension _FirebaseEncoder {
    
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool)   -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int)    -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int8)   -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int16)  -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int32)  -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int64)  -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt)   -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt8)  -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt16) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt32) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt64) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Float)  -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Double) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: String) -> NSObject { return NSString(string: value) }
    
    fileprivate func box<T : Encodable>(_ value: T) throws -> NSObject {
        return try self.box_(value) ?? NSDictionary()
    }
    
    fileprivate func box(_ date: Date) throws -> NSObject {
        guard let options = options.dateEncodingStrategy else { return date as NSDate }
        
        switch options {
        case .deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            try date.encode(to: self)
            return self.storage.popContainer()
            
        case .secondsSince1970:
            return NSNumber(value: date.timeIntervalSince1970)
            
        case .millisecondsSince1970:
            return NSNumber(value: 1000.0 * date.timeIntervalSince1970)
            
        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return NSString(string: _iso8601Formatter.string(from: date))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            return NSString(string: formatter.string(from: date))
            
        case .custom(let closure):
            let depth = self.storage.count
            try closure(date, self)
            
            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return NSDictionary()
            }
            
            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        }
    }
    
    fileprivate func box(_ data: Data) throws -> NSObject {
        guard let options = options.dataEncodingStrategy else { return data as NSData }
        
        switch options {
        case .deferredToData:
            // Must be called with a surrounding with(pushedKey:) call.
            try data.encode(to: self)
            return self.storage.popContainer()
            
        case .base64:
            return NSString(string: data.base64EncodedString())
            
        case .custom(let closure):
            let depth = self.storage.count
            try closure(data, self)
            
            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return NSDictionary()
            }
            
            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        }
    }
    
    func box_<T : Encodable>(_ value: T) throws -> NSObject? {
        if T.self == Date.self || T.self == NSDate.self {
            return try self.box((value as! Date))
        } else if T.self == Data.self || T.self == NSData.self {
            return try self.box((value as! Data))
        } else if T.self == URL.self || T.self == NSURL.self {
            return self.box((value as! URL).absoluteString)
        } else if options.skipFirestoreTypes && (value is FirestoreEncodable) {
            guard let value = value as? NSObject else {
                throw DocumentReferenceError.typeIsNotNSObject
            }
            return value
        }
        
        // The value should request a container from the _FirebaseEncoder.
        let depth = storage.count
        try value.encode(to: self)
        
        // The top container should be a new container.
        guard storage.count > depth else {
            return nil
        }
        
        return storage.popContainer()
    }
}

extension _FirebaseEncoder : SingleValueEncodingContainer {
    // MARK: - SingleValueEncodingContainer Methods
    private func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    public func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.push(container: NSNull())
    }
    
    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
}

fileprivate class _FirebaseReferencingEncoder : _FirebaseEncoder {
    // MARK: Reference types.
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(NSMutableArray, Int)
        
        /// Referencing a specific key in a dictionary container.
        case dictionary(NSMutableDictionary, String)
    }
    
    // MARK: - Properties
    /// The encoder we're referencing.
    private let encoder: _FirebaseEncoder
    
    /// The container reference itself.
    private let reference: Reference
    
    // MARK: - Initialization
    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: _FirebaseEncoder, at index: Int, wrapping array: NSMutableArray) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        
        self.codingPath.append(_FirebaseKey(index: index))
    }
    
    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: _FirebaseEncoder, at key: CodingKey, wrapping dictionary: NSMutableDictionary) {
        self.encoder = encoder
        reference = .dictionary(dictionary, key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        codingPath.append(key)
    }
    
    // MARK: - Coding Path Operations
    fileprivate override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }
    
    // MARK: - Deinitialization
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: Any
        switch storage.count {
        case 0: value = NSDictionary()
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        switch self.reference {
        case .array(let array, let index):
            array.insert(value, at: index)
            
        case .dictionary(let dictionary, let key):
            dictionary[NSString(string: key)] = value
        }
    }
}

internal extension DecodingError {
    internal static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(_typeDescription(of: reality)) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }
    
    fileprivate static func _typeDescription(of value: Any) -> String {
        if value is NSNull {
            return "a null value"
        } else if value is NSNumber /* FIXME: If swift-corelibs-foundation isn't updated to use NSNumber, this check will be necessary: || value is Int || value is Double */ {
            return "a number"
        } else if value is String {
            return "a string/data"
        } else if value is [Any] {
            return "an array"
        } else if value is [String : Any] {
            return "a dictionary"
        } else {
            return "\(type(of: value))"
        }
    }
}
