//
//  Middleware.swift
//  HTTPCore
//
//  Created by Yuki Takei on 2016/10/07.
//
//

public enum MiddlewareError: Error {
    case noNextMiddleware
}

public enum Chainer {
    case respond(Response)
    case next(Request, Response)
    case error(Error)
}

public protocol Middleware: Responder {}

extension Collection where Self.Iterator.Element == Middleware {
    public func chain(request: Request, response: Response, completion: @escaping (Chainer) -> Void) {
        if self.count == 0 {
            completion(.next(request, response))
            return
        }
        
        let middlewares = self.map { $0 }
        
        func _chain(_ index: Int, _ request: Request, _ response: Response) {
            if index < middlewares.count {
                let middleware = middlewares[index]
                middleware.respond(request, response) { chainer in
                    switch chainer {
                    case .respond(let response):
                        completion(.respond(response))
                    case .next(let request, let response):
                        _chain(index+1, request, response)
                    case .error(let error):
                        completion(.error(error))
                    }
                }
            } else {
                completion(.next(request, response))
            }
        }
        _chain(0, request, response)
    }
}

public struct BasicMiddleware: Middleware {
    
    let handler: Respond
    
    public init(_ handler: @escaping Respond){
        self.handler = handler
    }
    
    public func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
        self.handler(request, response, responder)
    }
}
