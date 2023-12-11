struct Storage {
    var value: String
    var length: Length
    
    init(string: String) {
        self.value = string
        self.length = algorithm(string) { _ in }
    }
}

extension Storage {
    mutating func remove(_ keypath: KeyPath<Storage, Range<Int>>) {
        replace(keypath, with: "")
    }
    mutating func replace(_ keypath: KeyPath<Storage, Range<Int>>, with: String) {
        value.replaceSubrange(range(keypath), with: with)
    }
}

extension Storage {
    var scheme: Range<Int>   { range(previous: 0..<0,    length: \.scheme) }
    var login: Range<Int>    { range(previous: scheme,   length: \.login) }
    var password: Range<Int> { range(previous: login,    length: \.password) }
    var host: Range<Int>     { range(previous: password, length: \.host) }
    var port: Range<Int>     { range(previous: host,     length: \.port) }
    var path: Range<Int>     { range(previous: port,     length: \.path) }
    var query: Range<Int>    { range(previous: path,     length: \.query) }
    var fragment: Range<Int> { range(previous: query,    length: \.fragment) }
    
    func range(previous: Range<Int>, length keypath: KeyPath<Length, Int>) -> Range<Int> {
        previous.upperBound..<(previous.upperBound + length[keyPath: keypath])
    }
    
    func range(_ keypath: KeyPath<Storage, Range<Int>>) -> Range<String.Index> {
        let range = self[keyPath: keypath]
        let start = value.index(value.startIndex, offsetBy: range.lowerBound)
        let end = value.index(value.startIndex, offsetBy: range.upperBound)
        return start..<end
    }
    //let end = value.index(value.startIndex, offsetBy: range.upperBound, limitedBy: value.endIndex) ?? value.endIndex
}
