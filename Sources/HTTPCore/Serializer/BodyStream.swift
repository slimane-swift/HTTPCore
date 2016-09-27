public enum BodyStreamError: Error {
    case readUnsupported
}
        
final class BodyStream: DuplexStream {
    var closed = false
    
    let transport: DuplexStream
    
    init(_ transport: DuplexStream) {
        self.transport = transport
    }
    
    func read(upTo byteCount: Int, deadline: Double = .never, completion: @escaping (Result<Data>) -> Void = { _ in }) {
        completion(.failure(BodyStreamError.readUnsupported))
    }
    
    func write(_ data: Data, deadline: Double = .never, completion: @escaping (Result<Void>) -> Void = { _ in }) {
        if closed {
            completion(.failure(StreamError.closedStream))
        }
        
        let newLine: Data = [13, 10]
        transport.write(String(data.count, radix: 16).data+newLine+data+newLine, completion: completion)
    }
    
    func close() {
        closed = true
    }
}
