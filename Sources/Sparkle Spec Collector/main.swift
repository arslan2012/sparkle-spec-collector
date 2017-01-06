//
// Created by arslan on 12/27/16.
//

import Foundation
import HeliumLogger
import Foundation
import Kitura
import KituraMarkdown
import KituraStencil
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
    if let queryError = result.asError {
        Log.error(String(describing: queryError))
    } else {
        Log.info("init table succeed")
    }
}
// Disable buffering
setbuf(stdout, nil)

// setup routes
let router = Router()
router.add(templateEngine: KituraMarkdown())
router.add(templateEngine: StencilTemplateEngine())
router.get("/") { _, response, next in
    defer {
        next()
    }
    var sumOfAll = 0, sumOfEmptyAppName = 0
    var Lang:[String: Int] = [:]
    connection.execute("SELECT * from specs where time >  CURRENT_TIMESTAMP - INTERVAL '1 months'") { result in
        if let rows = result.asRows {
            Log.info("get result success")
            for row in rows {
                for (title, value) in row {
                    if (title == "appname"){
                        sumOfAll += 1
                        if value as! String == "" {
                            sumOfEmptyAppName += 1
                        }
                    }
                    if (title == "lang"){
                        if Lang[value as! String] == nil {
                            Lang[value as! String] = 1
                        } else {
                            Lang[value as! String]! += 1
                        }
                    }
                }
            }
        } else if let queryError = result.asError {
            Log.error(String(describing: queryError))
        }
    }
    struct language {
        let name: String
        let frequency: Int
    }
    var LangList:[language] = []
    for (key,value) in Lang {
        if key != "" {
            LangList.append(language(name: key, frequency: value))
        }
    }
    LangList.sort(by:{ $0.frequency > $1.frequency })
    var context:[String : Any] = [
            "sumOfAll":sumOfAll,
            "sumOfEmptyAppName":sumOfEmptyAppName,
            "percent":Double(sumOfEmptyAppName) / Double(sumOfAll) * 100,
            "LangList":LangList
    ]
    try response.render("index.stencil", context: context).end()
}
router.get("/api/specs") { request, response, next in
    defer {
        next()
    }
    try response.redirect("https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/appcast.xml").end()
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
}

router.get("/release/en") { _, response, next in
    defer {
        next()
    }
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes.md")
    try response.render("x.md", context: ["URL": myURL ?? ""]).end()
}
router.get("/release/cn") { _, response, next in
    defer {
        next()
    }
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes_cn.md")
    try response.render("x.md", context: ["URL": myURL ?? ""]).end()
}

// Start server
Log.info("Starting server")
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
