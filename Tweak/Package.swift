// swift-tools-version:5.2

import PackageDescription
import Foundation

guard let theosPath = ProcessInfo.processInfo.environment["THEOS"],
      let projectDir = ProcessInfo.processInfo.environment["PWD"]
else {
    fatalError("""
    THEOS env var not set. If you're using Xcode, open this package with `make dev`
    """)
}

let libFlags: [String] = [
    "-F\(theosPath)/vendor/lib", "-F\(theosPath)/lib",
    "-I\(theosPath)/vendor/include", "-I\(theosPath)/include"
]

let cFlags: [String] = libFlags + [
    "-Wno-unused-command-line-argument", "-Qunused-arguments",
]

let cxxFlags: [String] = [
]

let swiftFlags: [String] = libFlags + [
]

let package = Package(
    name: "BatteryBuddy",
    platforms: [.iOS("13.0")],
    products: [
        .library(
            name: "BatteryBuddy",
            targets: ["BatteryBuddy"]
        ),
    ],
    targets: [
        .target(
            name: "BatteryBuddyC",
            cSettings: [.unsafeFlags(cFlags)],
            cxxSettings: [.unsafeFlags(cxxFlags)]
        ),
        .target(
            name: "BatteryBuddy",
            dependencies: ["BatteryBuddyC"],
            swiftSettings: [.unsafeFlags(swiftFlags)]
        ),
    ]
)
