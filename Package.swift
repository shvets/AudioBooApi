// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "AudioBooApi",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17)
  ],
  products: [
    .library(name: "AudioBooApi", targets: ["AudioBooApi"])
  ],
  dependencies: [
    //.package(name: "SimpleHttpClient", path: "../SimpleHttpClient"),
    .package(url: "https://github.com/shvets/SimpleHttpClient", from: "1.0.10"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.3.2"),
    .package(url: "https://github.com/JohnSundell/Codextended", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "AudioBooApi",
      dependencies: [
        "SimpleHttpClient",
        "SwiftSoup",
        "Codextended"
      ]),
    .testTarget(
      name: "AudioBooApiTests",
      dependencies: [
        "AudioBooApi"
      ]),
  ]
)
