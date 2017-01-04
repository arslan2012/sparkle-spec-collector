//
// Created by arslan on 12/27/16.
//

import Foundation
import HeliumLogger
import Foundation
import Kitura
import KituraMarkdown
import SwiftKuery
import SwiftKueryPostgreSQL
import LoggerAPI
import SwiftyJSON

// Attach a logger
Log.logger = HeliumLogger()

// get the environment values
let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080
var dbURL = ProcessInfo.processInfo.environment["DATABASE_URL"] ?? "postgresql://postgres:postgres@localhost:5432/test"
dbURL += "?sslmode=require"

//connect to database
let connection = PostgreSQLConnection(url: dbURL)
connection.connect() { error in
    if let error = error {
        Log.error(String(describing: error))
    } else {
        // Build and execute your query here.
    }
}
let appcastKeys = ["appName", "appVersion", "cpuFreqMHz", "cpu64bit", "cpusubtype", "cputype", "lang", "model", "ncpu", "osVersion", "ramMB"];
var InitQuery = "CREATE TABLE IF NOT EXISTS specs (";
for key in appcastKeys {
    InitQuery += key
    InitQuery += " varchar(255) NOT NULL default '',"
}
InitQuery += "time timestamp NOT NULL default CURRENT_TIMESTAMP);"
connection.execute(InitQuery) { result in
    if let resultSet = result.asResultSet {
        Log.info("init success")
    } else if let queryError = result.asError {
        Log.error(String(describing: queryError))
    }
}
// Disable buffering
setbuf(stdout, nil)

// setup routes
let router = Router()
router.add(templateEngine: KituraMarkdown())
router.get("/api/specs") { request, response, next in
    var insertQuery = "INSERT INTO specs VALUES ("
    for key in appcastKeys {
        insertQuery += "'"
        insertQuery += request.queryParameters[key] ?? ""
        insertQuery += "',"
    }
    insertQuery += "DEFAULT);"
    connection.execute(insertQuery) { result in
        if let resultSet = result.asResultSet {
            Log.info("new spec saved")
        } else if let queryError = result.asError {
            Log.error(String(describing: queryError))
        }
    }
    try response.redirect("https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/appcast.xml")
    response.status(.OK)
    next()
}

router.get("/release/en") { _, response, next in
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes.html")
    try response.render("x.md", context: ["URL": myURL ?? ""])
//	try response.render("releasenotes.md", context: [:])
    response.status(.OK)
    next()
}
router.get("/release/cn") { _, response, next in
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes_cn.html")
    try response.render("x.md", context: ["URL": myURL ?? ""])
//	try response.render("releasenotes_cn.md", context: [:])
    response.status(.OK)
    next()
}

// Start server
Log.info("Starting server")
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
