//
// Created by arslan on 12/27/16.
//

import PackageDescription

let package = Package(
        name: "Sparkle Spec Collector",
        targets: [
                Target(name: "Sparkle Spec Collector", dependencies: [])
        ],
        dependencies: [
                .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 3),
                .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 3),
                .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 1, minor: 9),
                .Package(url: "https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git", majorVersion: 0, minor: 8)
        ],
        exclude: ["Makefile", "Package-Builder"]
)