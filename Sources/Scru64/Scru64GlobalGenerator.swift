import Foundation

/// The gateway class that forwards supported method and property calls to the process-wide global
/// generator.
///
/// The global generator reads the node configuration from the `SCRU64_NODE_SPEC` environment
/// variable by default, and it causes a fatal error if it fails to read a well-formed node spec
/// string (e.g., `"42/8"`, `"0xb00/12"`, `"0u2r85hm2pt3/16"`) when a generator method is first
/// called. See also ``Scru64NodeSpec`` for the node spec string format.
public final class Scru64GlobalGenerator {
  private static let lock = NSLock()
  private static var instanceRaw: Scru64Generator<Scru64CounterModeDefault>? = nil

  static var instance: Scru64Generator<Scru64CounterModeDefault> {
    // double-checked locking pattern
    if Self.instanceRaw == nil {
      Self.lock.lock()
      defer { Self.lock.unlock() }
      if Self.instanceRaw == nil {
        guard let nodeSpec = ProcessInfo.processInfo.environment["SCRU64_NODE_SPEC"] else {
          fatalError(
            "scru64: could not read config from SCRU64_NODE_SPEC env var: env var not present")
        }
        do {
          Self.instanceRaw = Scru64Generator(try Scru64NodeSpec(parsing: nodeSpec))
        } catch let err as Scru64NodeSpec.ParseError {
          fatalError(
            "scru64: could not read config from SCRU64_NODE_SPEC env var: \(err.description)")
        } catch {
          fatalError("unreachable")
        }
      }
    }
    return Self.instanceRaw!
  }

  /// Initializes the global generator, if not initialized, with the node spec passed.
  ///
  /// This method configures the global generator with the argument only when the global generator
  /// is not yet initialized. Otherwise, it preserves the existing configuration.
  ///
  /// This method return `true` if this method configures the global generator or `false` if it
  /// preserves the existing configuration.
  public static func initialize(nodeSpec: Scru64NodeSpec) -> Bool {
    // double-checked locking pattern
    if Self.instanceRaw == nil {
      Self.lock.lock()
      defer { Self.lock.unlock() }
      if Self.instanceRaw == nil {
        Self.instanceRaw = Scru64Generator(nodeSpec)
        return true
      }
    }
    return false
  }

  /// Calls ``Scru64Generator/generate()`` of the global generator.
  public static func generate() -> Scru64Id? { Self.instance.generate() }

  /// Calls ``Scru64Generator/generateOrSleep()`` of the global generator.
  public static func generateOrSleep() -> Scru64Id { Self.instance.generateOrSleep() }

  /// Calls ``Scru64Generator/generateOrAwait()`` of the global generator.
  @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
  public static func generateOrAwait() async -> Scru64Id { await Self.instance.generateOrAwait() }

  /// Calls ``Scru64Generator/nodeId`` of the global generator.
  public static var nodeId: UInt32 { Self.instance.nodeId }

  /// Calls ``Scru64Generator/nodeIdSize`` of the global generator.
  public static var nodeIdSize: UInt8 { Self.instance.nodeIdSize }

  /// Calls ``Scru64Generator/nodeSpec`` of the global generator.
  public static var nodeSpec: Scru64NodeSpec { Self.instance.nodeSpec }
}
