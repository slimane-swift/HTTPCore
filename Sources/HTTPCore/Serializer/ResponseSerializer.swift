public struct ResponseSerializer {
    
    let transport: DuplexStream
    
    public init(stream: DuplexStream) {
        self.transport = stream
    }
    
    public func serialize(_ response: Response, completion: @escaping (Result<Void>) -> Void = { _ in }){
        let newLine: Data = [13, 10]
        
        transport.write("HTTP/\(response.version.major).\(response.version.minor) \(response.status.statusCode) \(response.status.reasonPhrase)".data)
        transport.write(newLine)
        
        for (name, value) in response.headers.headers {
            transport.write("\(name): \(value)".data)
            transport.write(newLine)
        }
        
        for cookie in response.cookies {
            transport.write("Set-Cookie: \(cookie)".data)
            transport.write(newLine)
        }
        
        transport.write(newLine)
        
        switch response.body {
        case .buffer(let buffer):
            self.transport.write(buffer)
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
