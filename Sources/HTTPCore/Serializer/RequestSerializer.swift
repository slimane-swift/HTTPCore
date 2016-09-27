public struct RequestSerializer {
    
    let transport: DuplexStream
    
    public init(stream: DuplexStream) {
        self.transport = stream
    }
    
    public func serialize(_ request: Request, completion: @escaping (Result<Void>) -> Void) {
        let newLine: Data = [13, 10]
        
        transport.write("\(request.method) \(request.url.absoluteString) HTTP/\(request.version.major).\(request.version.minor)".data)
        transport.write(newLine)
        
        for (name, value) in request.headers.headers {
            transport.write("\(name): \(value)".data)
            transport.write(newLine)
        }
        
        transport.write(newLine)
        
        switch request.body {
        case .buffer(let buffer):
            transport.write(buffer)
            completion(.success())
        case .reader(let reader):
            reader.read(upTo: 2014) { result in
                switch result {
                case .success(let data):
                    self.transport.write(String(data.count, radix: 16).data)
                    self.transport.write(newLine)
                    self.transport.write(data)
                    self.transport.write(newLine)
                    if reader.closed {
                        self.transport.write("0".data)
                        self.transport.write(newLine)
                        self.transport.write(newLine)
                        completion(.success())
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .writer(let writer):
            let body = BodyStream(transport)
            writer(body) { result in
                switch result {
                case .success(_):
                    self.transport.write("0".data)
                    self.transport.write(newLine)
                    self.transport.write(newLine)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
