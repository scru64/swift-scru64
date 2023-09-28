/// The maximum valid value (i.e., `zzzzzzzzzzzz`).
let maxScru64Int: UInt64 = 4_738_381_338_321_616_895

/// The maximum valid value of the `timestamp` field.
let maxTimestamp: UInt64 = maxScru64Int >> nodeCtrSize

/// The maximum valid value of the combined `nodeCtr` field.
let maxNodeCtr: UInt32 = (1 << nodeCtrSize) - 1

/// Digit characters used in the Base36 notation.
let digits = [UInt8]("0123456789abcdefghijklmnopqrstuvwxyz".utf8)

/// An O(1) map from ASCII code points to Base36 digit values.
let decodeMap: [UInt8] = [
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
  0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
  0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
]

/// Represents a SCRU64 ID.
public struct Scru64Id: Sendable {
  /// The minimum valid value (i.e., `000000000000`).
  public static let min: Self = try! Self(0)

  /// The maximum valid value (i.e., `zzzzzzzzzzzz`).
  public static let max: Self = try! Self(maxScru64Int)

  /// Returns the integer representation.
  public let num: UInt64

  /// Creates a value from a 64-bit integer.
  ///
  /// - Throws: An error if the argument is larger than `36^12 - 1`.
  public init(_ num: UInt64) throws {
    if num > maxScru64Int {
      throw RangeError(value: num)
    }
    self.num = num
  }

  /// Creates a value from a 64-bit integer.
  ///
  /// - Throws: An error if the argument is negative or larger than `36^12 - 1`.
  init(signed num: Int64) throws {
    if num < 0 || num > maxScru64Int {
      throw RangeError(value: num)
    }
    self.num = UInt64(num)
  }

  /// Creates a value from the `timestamp` and the combined `nodeCtr` field value.
  ///
  /// - Throws: An error if any argument is larger than their respective maximum value
  /// (`36^12 / 2^24 - 1` and `2^24 - 1`, respectively).
  public init(timestamp: UInt64, nodeCtr: UInt32) throws {
    if timestamp > maxTimestamp || nodeCtr > maxNodeCtr {
      throw PartsError(timestamp: timestamp, nodeCtr: nodeCtr)
    }
    // no further check is necessary because `MAX_SCRU64_INT` happens to equal
    // `MAX_TIMESTAMP << 24 | MAX_NODE_CTR`
    num = timestamp << nodeCtrSize | UInt64(nodeCtr)
  }

  /// Returns the `timestamp` field value.
  public var timestamp: UInt64 { num >> nodeCtrSize }

  /// Returns the `nodeId` and `counter` field values combined as a single 24-bit integer.
  public var nodeCtr: UInt32 { UInt32(truncatingIfNeeded: num) & maxNodeCtr }

  /// An error converting an integer into a SCRU64 ID.
  struct RangeError<T>: Error, CustomStringConvertible {
    let value: T
    var description: String {
      "could not convert integer to SCRU64 ID: `\(T.self)` out of range: \(value)"
    }
  }

  /// An error passing invalid arguments to ``init(timestamp:nodeCtr:)``.
  struct PartsError: Error, CustomStringConvertible {
    let timestamp: UInt64
    let nodeCtr: UInt32
    var description: String {
      let head = "could not create SCRU64 ID from parts: "
      switch (timestamp <= maxTimestamp, nodeCtr <= maxNodeCtr) {
      case (false, false): return head + "`timestamp` and `nodeCtr` out of range"
      case (false, true): return head + "`timestamp` out of range"
      case (true, false): return head + "`nodeCtr` out of range"
      case (true, true): fatalError("unreachable")
      }
    }
  }
}

extension Scru64Id: LosslessStringConvertible {
  /// An `Optional`-returning equivalent to ``init(parsing:)``.
  public init?(_ description: String) {
    try? self.init(parsing: description)
  }

  /// Creates a value from a 12-digit string representation.
  ///
  /// - Throws: An error if the argument is not a valid string representation.
  public init(parsing: String) throws {
    var desc = parsing
    num = try desc.withUTF8 {
      if $0.count != 12 {
        throw ParseError(message: "invalid length: \($0.count) bytes (expected 12)")
      }

      var n: UInt64 = 0
      for (i, e) in $0.enumerated() {
        if decodeMap[Int(e)] < 36 {
          n = n * 36 + UInt64(decodeMap[Int(e)])
        } else if e < 0x80 {
          throw ParseError(message: "invalid digit \(Character(Unicode.Scalar(e))) at \(i)")
        } else {
          throw ParseError(message: "non-ASCII digit at \(i)")
        }
      }
      return n
    }
  }

  /// Returns the 12-digit canonical string representation.
  public var description: String {
    func buildUtf8Bytes(_ dst: UnsafeMutableBufferPointer<UInt8>) -> Int {
      var n = num
      for i in (0..<12).reversed() {
        dst[i] = digits[Int(n % 36)]
        n /= 36
      }
      return 12
    }

    if #available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, *) {
      return String(unsafeUninitializedCapacity: 12, initializingUTF8With: buildUtf8Bytes)
    } else {
      return String(
        cString: [UInt8](unsafeUninitializedCapacity: 13) {
          $0.initialize(repeating: 0)
          $1 = buildUtf8Bytes($0) + 1
        })
    }
  }

  /// An error parsing an invalid string representation of SCRU64 ID.
  struct ParseError: Error, CustomStringConvertible {
    let message: String
    var description: String { "could not parse string as SCRU64 ID: \(message)" }
  }
}

extension Scru64Id: Comparable, Hashable {
  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.num < rhs.num }
}

extension Scru64Id: Codable {
  /// Encodes the object as a 12-digit canonical string representation.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

  /// Decodes the object from a 12-digit canonical string representation or a 64-bit integer.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    do {
      if let value = try? container.decode(String.self) {
        try self.init(parsing: value)
      } else if let value = try? container.decode(UInt64.self) {
        try self.init(value)
      } else if let value = try? container.decode(Int64.self) {
        try self.init(signed: value)
      } else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "expected string or integer but found neither")
      }
    } catch let err as ParseError {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: err.description)
    } catch let err as RangeError<UInt64> {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: err.description)
    } catch let err as RangeError<Int64> {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: err.description)
    }
  }
}
