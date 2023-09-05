// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-scru64",
  products: [.library(name: "Scru64", targets: ["Scru64"])],
  dependencies: [],
  targets: [
    .target(name: "Scru64", dependencies: []),
    .testTarget(name: "Scru64Tests", dependencies: ["Scru64"]),
  ]
)
