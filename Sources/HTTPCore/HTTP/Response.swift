import Foundation

public struct Response: Message {
    public var version: Version
    public var status: Status
    public var headers: Headers
    public var cookieHeaders: Set<String>
    public var body: Body
    public var storage: [String: Any] = [:]
    
    public init(version: Version, status: Status, headers: Headers, cookieHeaders: Set<String>, body: Body) {
        self.version = version
        self.status = status
        self.headers = headers
        self.cookieHeaders = cookieHeaders
        self.body = body
    }
}

public protocol ResponseInitializable {
    init(response: Response)
}

public protocol ResponseRepresentable {
    var response: Response { get }
}

public protocol ResponseConvertible: ResponseInitializable, ResponseRepresentable {}

extension Response {
    public typealias UpgradeConnection = (Request, DuplexStream) -> Void
    
    public var upgradeConnection: UpgradeConnection? {
        get {
            return storage["response-connection-upgrade"] as? UpgradeConnection
        }
        
        set(upgradeConnection) {
            storage["response-connection-upgrade"] = upgradeConnection
        }
    }
}

extension Response {
    
    public init(status: Status = .ok, headers: Headers = [:], body: Body) {
        self.init(
            version: Version(major: 1, minor: 1),
            status: status,
            headers: headers,
            cookieHeaders: [],
            body: body
        )
        
        switch body {
        case let .buffer(body):
            self.headers["Content-Length"] = body.count.description
        default:
            self.headers["Transfer-Encoding"] = "chunked"
        }
    }
    
    public init(status: Status = .ok, headers: Headers = [:], body: Data = []) {
        self.init(
            status: status,
            headers: headers,
            body: .buffer(body)
        )
    }
    
    public init(status: Status = .ok, headers: Headers = [:], body: ReadableStream) {
        self.init(
            status: status,
            headers: headers,
            body: .reader(body)
        )
    }
    
    public init(status: Status = .ok, headers: Headers = [:], body: @escaping (WritableStream, @escaping (Result<Void>) -> Void) -> Void) {
        self.init(
            status: status,
            headers: headers,
            body: .writer(body)
        )
    }
}

extension Response {
    public var statusCode: Int {
        return status.statusCode
    }
    
    public var isError: Bool {
        return status.isError
    }
    
    public var isClientError: Bool {
        return status.isClientError
    }
    
    public var isServerError: Bool {
        return status.isServerError
    }
    
    public var reasonPhrase: String {
        return status.reasonPhrase
    }
}

extension Response {
    public var cookies: Set<AttributedCookie> {
        get {
            var cookies = Set<AttributedCookie>()
            
            for header in cookieHeaders {
                if let cookie = AttributedCookie(header) {
                    cookies.insert(cookie)
                }
            }
            
            return cookies
        }
        
        set(cookies) {
            var headers = Set<String>()
            
            for cookie in cookies {
                let header = String(describing: cookie)
                headers.insert(header)
            }
            
            cookieHeaders = headers
        }
    }
}

extension Response: CustomStringConvertible {
    public var statusLineDescription: String {
        return "HTTP/" + String(version.major) + "." + String(version.minor) + " " + String(statusCode) + " " + reasonPhrase + "\n"
    }
    
    public var description: String {
        return statusLineDescription +
            headers.description
    }
}

extension Response: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n" + storageDescription
    }
}

private let storageKey = "__slimane__.internal.customeResponder"

extension Response {
    public var customResponder: Responder? {
        get {
            return self.storage[storageKey] as? Responder
        }
        set {
            self.storage[storageKey] = newValue
        }
    }
}
