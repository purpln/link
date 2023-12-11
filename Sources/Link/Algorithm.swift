func algorithm(_ string: String, log: (String) -> Void) -> Length {
    var scheme: Int = 0
    var login: Int = 0
    var password: Int = 0
    var host: Int = 0
    var port: Int = 0
    var path: Int = 0
    var query: Int = 0
    var fragment: Int = 0
    
    var start = string.startIndex
    var end = string.endIndex
    
    //fragment at end (#hash)
    if let index = string[start..<end].lastIndex(of: "#") {
        fragment = string.distance(from: index, to: end)
        end = index
    }
    log(String(string[start..<end]))
    
    //basic query (?value=string&int=0)
    if let index = string[start..<end].lastIndex(of: "?") {
        query = string.distance(from: index, to: end)
        end = index
    }
    log(String(string[start..<end]))
    
    //deeplink query (prefs:root=settings)
    if query == 0, string[start..<end].firstIndex(of: "=") != nil,
       let index = string[start..<end].lastIndex(of: ":"),
       let offset = string.index(index, offsetBy: 1, limitedBy: end) {
        query = string.distance(from: offset, to: end) + 1
        end = offset
    }
    log(String(string[start..<end]))
    
    //sheme both :// & : (jdbc:mysql:// & tel:+1-816-555-1212)
    if let index = string[start..<end].firstIndex(of: ":"),
       let offset = string.index(index, offsetBy: 1, limitedBy: end) {
        if let slash = string[start..<end].firstIndex(of: "/"),
           let next = string.index(slash, offsetBy: 1, limitedBy: end), string[next] == "/", let offset = string.index(next, offsetBy: 1, limitedBy: end) {
            scheme = string.distance(from: start, to: offset)
            start = offset
        } else {
            scheme = string.distance(from: start, to: index) + 1
            start = offset
        }
    }
    log(String(string[start..<end]))
    
    //login & password (https://login:password@api.link.org / https://login@api.link.org)
    if let index = string[start..<end].firstIndex(of: "@"),
       let new = string.index(index, offsetBy: 1, limitedBy: end) {
        if let next = string[start..<index].firstIndex(of: ":") {
            login = string.distance(from: start, to: next) + 1
            password = string.distance(from: next, to: index)
            start = new
        } else {
            login = string.distance(from: start, to: index)
            start = new
        }
    }
    log(String(string[start..<end]))
    
    //ipv6 hostname (ldap://[2001:db8::7]:80)
    if let first = string[start..<end].firstIndex(of: "["),
       let last = string[start..<end].lastIndex(of: "]"),
       let index = string.index(last, offsetBy: 1, limitedBy: end) {
        host = string.distance(from: first, to: last) + 1
        start = index
    }
    log(String(string[start..<end]))
    
    //paths (/test/path)
    if let index = string[start..<end].firstIndex(of: "/") {
        path = string.distance(from: index, to: end)
        end = index
    }
    log(String(string[start..<end]))
    
    //port (:443)
    if let index = string[start..<end].lastIndex(of: ":"), let offset = string.index(index, offsetBy: 1, limitedBy: end), Int(String(string[offset])) != nil {
        port = string.distance(from: index, to: end)
        end = index
    }
    log(String(string[start..<end]))
    
    //if all previous variants not suit
    //strange path varinat (urn:example:animal:ferret:nose)
    //all the rest is host name
    if path == 0, string[start..<end].lastIndex(of: ":") != nil {
        path = string.distance(from: start, to: end)
    } else if host == 0 {
        host = string.distance(from: start, to: end)
    }
    log(String(string[start..<end]))
    
    return Length(scheme: scheme, login: login, password: password, host: host, port: port, path: path, query: query, fragment: fragment)
}

//https://login:password@api.link.org:443/test/path?value=string&int=0#fragment
//app-settings:value=string&int=0
//urn:example:animal:ferret:nose
//jdbc:mysql://test_user:ouupppssss@localhost:3306/sakila/
//tel:+1-816-555-1212
//telnet://192.0.2.16:80/
//ldap://[2001:db8::7]/c=GB?objectClass=one&objectClass=two
