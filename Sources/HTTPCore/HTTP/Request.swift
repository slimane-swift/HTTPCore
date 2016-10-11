import Foundation

public struct Request: Message {
    public var method: Method
    public var url: URL
    public var version: Version
    public var headers: Headers
    public var body: Body
    public var storage: [String: Any]
    
    public init(method: Method, url: URL, version: Version, headers: Headers, body: Body) {
        self.method = method
        self.url = url
        self.version = version
        self.headers = headers
        self.body = body
        self.storage = [:]
    }
}

public protocol RequestInitializable {
    init(request: Request)
}

public protocol RequestRepresentable {
    var request: Request { get }
}

public protocol RequestConvertible: RequestInitializable, RequestRepresentable {}


extension Request {
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: Body) {
        self.init(
            method: method,
            url: url,
            version: Version(major: 1, minor: 1),
            headers: headers,
            body: body
        )
        
        switch body {
        case let .buffer(body):
            self.headers["Content-Length"] = body.count.description
        default:
            self.headers["Transfer-Encoding"] = "chunked"
        }
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: Data = []) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .buffer(body)
        )
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: ReadableStream) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .reader(body)
        )
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: @escaping (WritableStream, @escaping (Result<Void>) -> Void) -> Void) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .writer(body)
        )
    }
}

extension Request {
    public var path: String? {
        return url.path
    }
    
    public var queryItems: [URLQueryItem] {
        return url.queryItems
    }
}

extension Request {
    public typealias UpgradeConnection = (Request, DuplexStream) -> Void
    
    public var upgradeConnection: UpgradeConnection? {
        get {
            return storage["request-connection-upgrade"] as? UpgradeConnection
        }
        
        set(upgradeConnection) {
            storage["request-connection-upgrade"] = upgradeConnection
        }
    }
}

extension Request {
    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []
            
            if let acceptString = headers["Accept"] {
                let acceptedTypesString = acceptString.split(separator: ",")
                
                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.split(separator: ";")
                    
                    if acceptedTypeTokens.count >= 1 {
                        let mediaTypeString = acceptedTypeTokens[0].trim()
                        if let acceptedMediaType = try? MediaType(string: mediaTypeString) {
                            acceptedMediaTypes.append(acceptedMediaType)
                        }
                    }
                }
            }
            
            return acceptedMediaTypes
        }
        
        set(accept) {
            headers["Accept"] = accept.map({"\($0.type)/\($0.subtype)"}).joined(separator: ", ")
        }
    }
    
    public var cookies: Set<Cookie> {
        get {
            return headers["Cookie"].flatMap({Set<Cookie>(cookieHeader: $0)}) ?? []
        }
        
        set(cookies) {
            headers["Cookie"] = cookies.map({$0.description}).joined(separator: ", ")
        }
    }
    
    public var authorization: String? {
        get {
            return headers["Authorization"]
        }
        
        set(authorization) {
            headers["Authorization"] = authorization
        }
    }
    
    public var host: String? {
        get {
            return headers["Host"]
        }
        
        set(host) {
            headers["Host"] = host
        }
    }
    
    public var userAgent: String? {
        get {
            return headers["User-Agent"]
        }
        
        set(userAgent) {
            headers["User-Agent"] = userAgent
        }
    }
}


