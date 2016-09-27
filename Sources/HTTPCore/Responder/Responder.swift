//
//  Responder.swift
//  MySlimaneApp
//
//  Created by Yuki Takei on 2016/10/11.
//
//

public typealias Respond = (Request, Response, (Chainer) -> Void) -> Void

public protocol Responder {
    func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void)
}
