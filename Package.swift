// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Link",
    products: [
        .library(name: "Link", targets: ["Link"]),
    ],
    targets: [
        .target(name: "Link"),
    ]
)
#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
package.platforms = [.iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13)]
#endif
