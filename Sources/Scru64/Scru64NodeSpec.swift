/// Represents a node configuration specifier used to build a ``Scru64Generator``.
///
/// A `NodeSpec` is usually expressed as a node spec string, which starts with a decimal `nodeId`, a
/// hexadecimal `nodeId` prefixed with `"0x"`, or a 12-digit `nodePrev` SCRU64 ID value, followed by
/// a slash and a decimal `nodeIdSize` value ranging from 1 to 23 (e.g., `"42/8"`, `"0xb00/12"`,
/// `"0u2r85hm2pt3/16"`). The first and second forms create a fresh new generator with the given
/// `nodeId`, while the third form constructs one that generates subsequent SCRU64 IDs to the
/// `nodePrev`.
public struct Scru64NodeSpec: Equatable, Sendable {
  let nodePrevRaw: Scru64Id

  /// Returns the `nodeIdSize` value.
  public let nodeIdSize: UInt8

  /// Creates an instance with `nodePrev` and `nodeIdSize` values.
  ///
  /// - Throws: An error if the `nodeIdSize` is zero or greater than 23.
  public init(nodePrev: Scru64Id, nodeIdSize: UInt8) throws {
    if 0 < nodeIdSize && nodeIdSize < nodeCtrSize {
      self.nodePrevRaw = nodePrev
      self.nodeIdSize = nodeIdSize
    } else {
      throw NodeSpecError.nodeIdSize(nodeIdSize: nodeIdSize)
    }
  }

  /// Returns the `nodePrev` value if the `NodeSpec` is constructed with one or `nil` otherwise.
  public var nodePrev: Scru64Id? {
    if nodePrevRaw.timestamp > 0 {
      return nodePrevRaw
    } else {
      return nil
    }
  }

  /// Creates an instance with `nodeId` and `nodeIdSize` values.
  ///
  /// - Throws: An error if the `nodeIdSize` is zero or greater than 23 or if the `nodeId` does not
  /// fit in `nodeIdSize` bits.
  public init(nodeId: UInt32, nodeIdSize: UInt8) throws {
    if 0 < nodeIdSize && nodeIdSize < nodeCtrSize {
      if nodeId < (1 << nodeIdSize) {
        let nodeCtr = nodeId << (nodeCtrSize - nodeIdSize)
        self.nodePrevRaw = try! Scru64Id(timestamp: 0, nodeCtr: nodeCtr)
        self.nodeIdSize = nodeIdSize
      } else {
        throw NodeSpecError.nodeIdRange(nodeId: nodeId, nodeIdSize: nodeIdSize)
      }
    } else {
      throw NodeSpecError.nodeIdSize(nodeIdSize: nodeIdSize)
    }
  }

  /// Returns the `nodeId` value given at instance creation or encoded in the `nodePrev` value.
  public var nodeId: UInt32 {
    let counterSize = nodeCtrSize - nodeIdSize
    return nodePrevRaw.nodeCtr >> counterSize
  }

  /// An error representing an invalid pair of `nodeId` and `nodeIdSize` to construct a
  /// ``Scru64NodeSpec`` instance.
  enum NodeSpecError: Error, CustomStringConvertible {
    case nodeIdSize(nodeIdSize: UInt8)
    case nodeIdRange(nodeId: UInt32, nodeIdSize: UInt8)
    var description: String {
      switch self {
      case .nodeIdSize(let nodeIdSize):
        return "`nodeIdSize` (\(nodeIdSize)) must range from 1 to 23"
      case .nodeIdRange(let nodeId, let nodeIdSize):
        return "`nodeId` (\(nodeId)) must fit in `nodeIdSize` (\(nodeIdSize)) bits"
      }
    }
  }
}

extension Scru64NodeSpec: LosslessStringConvertible {
  /// An `Optional`-returning equivalent to ``init(parsing:)``.
  public init?(_ description: String) {
    try? self.init(parsing: description)
  }

  /// Creates an instance from a node spec string.
  ///
  /// - Throws: An error if if an invalid node spec string is passed.
  public init(parsing: String) throws {
    let xs = parsing.split(separator: "/", omittingEmptySubsequences: false)
    if xs.count != 2 || xs[0].isEmpty || xs[1].isEmpty {
      throw ParseError(
        message: #"syntax error (expected: e.g., "42/8", "0xb00/12", "0u2r85hm2pt3/16")"#)
    }

    if xs[1].utf8.count > 3 || xs[1].hasPrefix("+") {
      throw ParseError(message: "could not parse string as `nodeIdSize`")
    }
    guard let nodeIdSize = UInt8(xs[1], radix: 10) else {
      throw ParseError(message: "could not parse string as `nodeIdSize`")
    }

    let len = xs[0].utf8.count
    do {
      if len == 12 {
        let nodePrev = try Scru64Id(parsing: String(xs[0]))
        try self.init(nodePrev: nodePrev, nodeIdSize: nodeIdSize)
      } else {
        var value = xs[0]
        var radix = 10
        var limit = 8
        if xs[0].hasPrefix("0x") || xs[0].hasPrefix("0X") {
          value = xs[0].dropFirst(2)
          radix = 16
          limit = 6
        }
        if value.utf8.count > limit || value.hasPrefix("+") {
          throw ParseError(message: "could not parse string as `nodeId`")
        }
        guard let nodeId = UInt32(value, radix: radix) else {
          throw ParseError(message: "could not parse string as `nodeId`")
        }
        try self.init(nodeId: nodeId, nodeIdSize: nodeIdSize)
      }
    } catch let err as Scru64Id.ParseError {
      throw ParseError(message: err.description)
    } catch let err as NodeSpecError {
      throw ParseError(message: err.description)
    }
  }

  /// Returns the node spec string representation.
  public var description: String {
    if let p = nodePrev {
      return "\(p)/\(nodeIdSize)"
    } else {
      return "\(nodeId)/\(nodeIdSize)"
    }
  }

  /// An error parsing an invalid node spec string representation.
  struct ParseError: Error, CustomStringConvertible {
    let message: String
    var description: String { "could not parse string as node spec: \(message)" }
  }
}

extension Scru64NodeSpec: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let value = try? container.decode(String.self) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "expected string")
    }
    do {
      try self.init(parsing: value)
    } catch let err as ParseError {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: err.description)
    }
  }
}
