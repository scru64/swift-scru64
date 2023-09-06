/// The total size in bits of the `nodeId` and `counter` fields.
let nodeCtrSize: UInt8 = 24

/// Generates a new SCRU64 ID object using the global generator.
///
/// By default, the global generator reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable when a generator method is first called, and it causes a fatal error if it
/// fails to do so. The node configuration is encoded in a node spec string consisting of `nodeId`
/// and `nodeIdSize` integers separated by a slash (e.g., "42/8", "0xb00/12"; see ``Scru64NodeSpec``
/// for details). You can configure the global generator differently by calling
/// ``Scru64GlobalGenerator/initialize(nodeSpec:)`` before the default initializer is triggered.
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
/// By default, the global generator reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable when a generator method is first called, and it causes a fatal error if it
/// fails to do so. The node configuration is encoded in a node spec string consisting of `nodeId`
/// and `nodeIdSize` integers separated by a slash (e.g., "42/8", "0xb00/12"; see ``Scru64NodeSpec``
/// for details). You can configure the global generator differently by calling
/// ``Scru64GlobalGenerator/initialize(nodeSpec:)`` before the default initializer is triggered.
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
/// By default, the global generator reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable when a generator method is first called, and it causes a fatal error if it
/// fails to do so. The node configuration is encoded in a node spec string consisting of `nodeId`
/// and `nodeIdSize` integers separated by a slash (e.g., "42/8", "0xb00/12"; see ``Scru64NodeSpec``
/// for details). You can configure the global generator differently by calling
/// ``Scru64GlobalGenerator/initialize(nodeSpec:)`` before the default initializer is triggered.
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
/// By default, the global generator reads the node configuration from the `SCRU64_NODE_SPEC`
/// environment variable when a generator method is first called, and it causes a fatal error if it
/// fails to do so. The node configuration is encoded in a node spec string consisting of `nodeId`
/// and `nodeIdSize` integers separated by a slash (e.g., "42/8", "0xb00/12"; see ``Scru64NodeSpec``
/// for details). You can configure the global generator differently by calling
/// ``Scru64GlobalGenerator/initialize(nodeSpec:)`` before the default initializer is triggered.
///
/// This function usually returns a value immediately, but if not possible, it sleeps and waits for
/// the next timestamp tick.
///
/// This function is thread-safe; multiple threads can call it concurrently.
///
/// - Precondition: The global generator must have been properly configured.
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
public func scru64String() async -> String { await scru64().description }
