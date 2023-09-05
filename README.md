# SCRU64: Sortable, Clock-based, Realm-specifically Unique identifier

[![GitHub tag](https://img.shields.io/github/v/tag/scru64/swift-scru64)](https://github.com/scru64/swift-scru64)
[![License](https://img.shields.io/github/license/scru64/swift-scru64)](https://github.com/scru64/swift-scru64/blob/main/LICENSE)
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fscru64%2Fswift-scru64%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/scru64/swift-scru64)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fscru64%2Fswift-scru64%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/scru64/swift-scru64)

SCRU64 ID offers compact, time-ordered unique identifiers generated by
distributed nodes. SCRU64 has the following features:

- ~62-bit non-negative integer storable as signed/unsigned 64-bit integer
- Sortable by generation time (as integer and as text)
- 12-digit case-insensitive textual representation (Base36)
- ~38-bit Unix epoch-based timestamp that ensures useful life until year 4261
- Variable-length node/machine ID and counter fields that share 24 bits

```swift
import Darwin  // import `setenv()`
import Scru64

// pass node ID through environment variable
setenv("SCRU64_NODE_SPEC", "42/8", 1)

// generate a new identifier object
let x = scru64Sync()
print(x)  // e.g., "0u2r85hm2pt3"
print(x.num)  // as a 64-bit unsigned integer

// generate a textual representation directly
print(scru64StringSync())  // e.g., "0u2r85hm2pt4"
```

See [SCRU64 Specification] for details.

SCRU64's uniqueness is realm-specific, i.e., dependent on the centralized
assignment of node ID to each generator. If you need decentralized, globally
unique time-ordered identifiers, consider [SCRU128].

[SCRU64 Specification]: https://github.com/scru64/spec
[SCRU128]: https://github.com/scru128/spec

## Add swift-scru64 as a package dependency

To add this library to your Xcode project as a dependency, select **File** >
**Add Packages** and enter the package URL:
https://github.com/scru64/swift-scru64

To use this library in a SwiftPM project, add the following line to the
dependencies in your Package.swift file:

```swift
.package(url: "https://github.com/scru64/swift-scru64", from: "<version>"),
```

And, include `Scru64` as a dependency for your target:

```swift
.target(
  name: "<target>",
  dependencies: [.product(name: "Scru64", package: "swift-scru64")]
)
```

## License

Licensed under the Apache License, Version 2.0.

## See also

- [swift-scru64 - Swift Package Index](https://swiftpackageindex.com/scru64/swift-scru64)
