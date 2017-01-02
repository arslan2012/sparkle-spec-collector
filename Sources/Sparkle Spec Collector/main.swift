//
// Created by arslan on 12/27/16.
//

import Foundation
import HeliumLogger
import Foundation
import Kitura
import KituraMarkdown
import LoggerAPI
import SwiftyJSON

// Disable buffering
setbuf(stdout, nil)

// Attach a logger
Log.logger = HeliumLogger()

// setup routes
let router = Router()
router.add(templateEngine: KituraMarkdown())
router.get("/") { _, response, next in
    try response.redirect("https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/appcast.xml")
    response.status(.OK)
    next()
}

router.get("/release/en") { _, response, next in
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes.html")
    try response.render("x.md",context:["URL":myURL])
    response.status(.OK)
    next()
}
router.get("/release/cn") { _, response, next in
    let myURL = URL(string: "https://raw.githubusercontent.com/arslan2012/Lazy-Hackintosh-Image-Generator/master/releasenotes_cn.html")
    try response.render("x.md",context:["URL":myURL])
    response.status(.OK)
    next()
}

// Start server
Log.info("Starting server")
Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()