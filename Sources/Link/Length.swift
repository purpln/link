struct Length {
    var scheme: Int = 0
    var login: Int = 0
    var password: Int = 0
    var host: Int = 0
    var port: Int = 0
    var path: Int = 0
    var query: Int = 0
    var fragment: Int = 0
}

extension Length {
    var valid: Bool {
        scheme != 0 || host != 0 || path != 0 || query != 0
    }
}
