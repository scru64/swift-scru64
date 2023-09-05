/// The total size in bits of the `nodeId` and `counter` fields.
let nodeCtrSize: UInt8 = 24

/// Generates a new SCRU64 ID object using the global generator.
///
/// The ``Scru64GlobalGenerator`` reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable by default, and it causes a fatal error if it fails to read a well-formed
/// node spec string (e.g., `"42/8"`, `"0xb00/12"`, `"0u2r85hm2pt3/16"`) when a generator method is
/// first called. See also ``Scru64NodeSpec`` for the node spec string format.
///
/// This function usually returns a value immediately, but if not possible, it sleeps and waits for
/// the next timestamp tick. It employs blocking sleep to wait; see ``scru64()`` for the
/// non-blocking equivalent.
///
/// This function is thread-safe; multiple threads can call it concurrently.
///
/// - Precondition: The global generator must have been properly configured.
public func scru64Sync() -> Scru64Id { Scru64GlobalGenerator.generateOrSleep() }

/// Generates a new SCRU64 ID encoded in the 12-digit canonical string representation using the
/// global generator.
///
/// The ``Scru64GlobalGenerator`` reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable by default, and it causes a fatal error if it fails to read a well-formed
/// node spec string (e.g., `"42/8"`, `"0xb00/12"`, `"0u2r85hm2pt3/16"`) when a generator method is
/// first called. See also ``Scru64NodeSpec`` for the node spec string format.
///
/// This function usually returns a value immediately, but if not possible, it sleeps and waits for
/// the next timestamp tick. It employs blocking sleep to wait; see ``scru64String()`` for the
/// non-blocking equivalent.
///
/// This function is thread-safe; multiple threads can call it concurrently.
///
/// - Precondition: The global generator must have been properly configured.
public func scru64StringSync() -> String { scru64Sync().description }

/// Generates a new SCRU64 ID object using the global generator.
///
/// The ``Scru64GlobalGenerator`` reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable by default, and it causes a fatal error if it fails to read a well-formed
/// node spec string (e.g., `"42/8"`, `"0xb00/12"`, `"0u2r85hm2pt3/16"`) when a generator method is
/// first called. See also ``Scru64NodeSpec`` for the node spec string format.
///
/// This function usually returns a value immediately, but if not possible, it sleeps and waits for
/// the next timestamp tick.
///
/// This function is thread-safe; multiple threads can call it concurrently.
///
/// - Precondition: The global generator must have been properly configured.
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
public func scru64() async -> Scru64Id { await Scru64GlobalGenerator.generateOrAwait() }

/// Generates a new SCRU64 ID encoded in the 12-digit canonical string representation using the
/// global generator.
///
/// The ``Scru64GlobalGenerator`` reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable by default, and it causes a fatal error if it fails to read a well-formed
/// node spec string (e.g., `"42/8"`, `"0xb00/12"`, `"0u2r85hm2pt3/16"`) when a generator method is
/// first called. See also ``Scru64NodeSpec`` for the node spec string format.
///
/// This function usually returns a value immediately, but if not possible, it sleeps and waits for
/// the next timestamp tick.
///
/// This function is thread-safe; multiple threads can call it concurrently.
///
/// - Precondition: The global generator must have been properly configured.
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
public func scru64String() async -> String { await scru64().description }
