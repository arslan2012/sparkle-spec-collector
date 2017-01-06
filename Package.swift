//
// Created by arslan on 12/27/16.
//

import PackageDescription

let package = Package(
        name: "Sparkle Spec Collector",
        targets: [
                Target(name: "Sparkle Spec Collector", dependencies: ["KituraMarkdown","SwiftKueryPostgreSQL"]),
                Target(name: "KituraMarkdown", dependencies: ["Ccmark"]),
                Target(name: "Ccmark", dependencies: []),
                Target(name: "SwiftKueryPostgreSQL", dependencies: [])
        ],
        dependencies: [
                .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1),
                .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1),
                .Package(url: "https://github.com/IBM-Swift/CLibpq.git", majorVersion: 0, minor: 1),
                .Package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", majorVersion: 0, minor: 5),
                .Package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", majorVersion: 1)
        ]
)