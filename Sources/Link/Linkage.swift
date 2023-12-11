public struct Linkage {
    private var storage: Storage
    
    public init(string: String) {
        self.storage = Storage(string: string)
    }
    
    public var string: String? {
        guard storage.length.valid else { return nil }
        return storage.value
    }
}

extension Linkage: CustomStringConvertible {
    public var description: String {
        return storage.value
    }
}

public extension Linkage {
    var scheme: String? {
        get { string(\.scheme) }
        set {
            guard var value = newValue else {
                storage.remove(\.scheme)
                storage.length.scheme = 0
                return
            }
            if let index = value.index(value.endIndex, offsetBy: -3, limitedBy: value.startIndex), value[index] == ":", value.last == "/" {
                
            } else if value.last != ":" {
                value.append(":")
            }
            storage.replace(\.scheme, with: value)
            storage.length.scheme = value.count
        }
    }
}

public extension Linkage {
    var login: String? {
        get {
            guard var string = string(\.login) else { return nil }
            if string.last == ":" || string.last == "@" {
                string.removeLast()
            }
            return string
        }
        set {
            guard var value = newValue else {
                storage.remove(\.login)
                storage.length.login = 0
                return
            }
            if storage.length.password != 0 {
                value.append(":")
            } else {
                value.append("@")
            }
            storage.replace(\.login, with: value)
            storage.length.login = value.count
        }
    }
}

public extension Linkage {
    var password: String? {
        get {
            guard var string = string(\.password) else { return nil }
            if string.last == "@" {
                string.removeLast()
            }
            return string
        }
        set {
            guard var value = newValue, storage.length.login != 0 else {
                storage.remove(\.password)
                storage.length.password = 0
                if storage.length.login != 0, var string = string(\.login), string.last == ":" {
                    string.removeLast()
                    string.append("@")
                    storage.replace(\.login, with: string)
                }
                return
            }
            if var string = string(\.login), string.last == "@" {
                string.removeLast()
                string.append(":")
                storage.replace(\.login, with: string)
                
                value.append("@")
                storage.replace(\.password, with: value)
                storage.length.password = value.count
            }
        }
    }
}

public extension Linkage {
    var host: String? {
        get { string(\.host) }
        set {
            guard let value = newValue else {
                storage.remove(\.host)
                storage.length.host = 0
                return
            }
            storage.replace(\.host, with: value)
            storage.length.host = value.count
        }
    }
}

public extension Linkage {
    var port: Int? {
        get {
            guard var string = string(\.port) else { return nil }
            string.removeFirst()
            return Int(string)
        }
        set {
            guard let value = newValue else {
                storage.remove(\.port)
                storage.length.port = 0
                return
            }
            let string = ":" + String(value)
            storage.replace(\.port, with: string)
            storage.length.port = string.count
        }
    }
}

public extension Linkage {
    var path: [String]? {
        get {
            guard let string = string(\.path) else { return nil }
            return string.split(whereSeparator: { $0 == "/" }).map(String.init)
        }
        set {
            guard let value = newValue else {
                storage.remove(\.path)
                storage.length.path = 0
                return
            }
            let string = "/" + value.joined(separator: "/")
            storage.replace(\.path, with: string)
            storage.length.path = string.count
        }
    }
}

public extension Linkage {
    var query: [(String, String)]? {
        get {
            guard var string = string(\.query) else { return nil }
            string.removeFirst()
            return string.split(whereSeparator: { $0 == "&" })
                .reduce(into: [(String, String)]()) { array, element in
                    let values = element.split(whereSeparator: { $0 == "=" })
                        .map(String.init)
                    guard values.count == 2 else { return }
                    array.append((values[0], values[1]))
                }
        }
        set {
            guard let value = newValue else {
                storage.remove(\.query)
                storage.length.query = 0
                return
            }
            let string = "?" + value.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
            storage.replace(\.query, with: string)
            storage.length.query = string.count
        }
    }
}

public extension Linkage {
    var fragment: String? {
        get {
            guard var string = string(\.fragment) else { return nil }
            string.removeFirst()
            return string
        }
        set {
            guard let value = newValue else {
                storage.remove(\.fragment)
                storage.length.fragment = 0
                return
            }
            let string = "#" + String(value)
            storage.replace(\.fragment, with: string)
            storage.length.fragment = string.count
        }
    }
}

public extension Linkage {
    private func string(_ keypath: KeyPath<Storage, Range<Int>>) -> String? {
        let string = String(storage.value[storage.range(keypath)])
        return string == "" ? nil : string
    }
}
