public enum Body {
    case buffer(Data)
    case reader(ReadableStream)
    case writer((WritableStream, @escaping (Result<Void>) -> Void) -> Void)
}

public enum BodyError: Error {
    case inconvertibleType
}

extension Body {
    public var isBuffer: Bool {
        switch self {
        case .buffer: return true
        default: return false
        }
    }

    public var isReader: Bool {
        switch self {
        case .reader: return true
        default: return false
        }
    }

    public var isWriter: Bool {
        switch self {
        case .writer: return true
        default: return false
        }
    }
}
