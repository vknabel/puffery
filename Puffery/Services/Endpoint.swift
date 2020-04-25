//
//  ApiService.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation
import Overture

typealias RequestModifier = (inout URLRequest) throws -> Void
typealias ResponseDecoder<Response> = (Data?) throws -> Response

struct Endpoint<Response> {
    var strategy: RequestFetchingStrategy
    var encode: RequestModifier
    var decode: ResponseDecoder<Response>
    var report: (FetchingError) -> Void

    @discardableResult
    func task(_ receive: @escaping (Result<Response, FetchingError>) -> Void) -> URLSessionDataTask? {
        strategy.task(self, receive: receive)
    }

    func publisher() -> AnyPublisher<Response, FetchingError> {
        strategy.publisher(self)
    }
}

extension Endpoint where Response == Data? {
    init(strategy: RequestFetchingStrategy) {
        self.strategy = strategy
        encode = { _ in }
        decode = { $0 }
        report = { _ in }
    }

    func decoding<Resp: Decodable>(_ strategy: @escaping (Resp.Type, Data) throws -> Resp, _: Resp.Type = Resp.self) -> Endpoint<Resp> {
        map { try strategy(Resp.self, $0 ?? Data()) }
    }

    func compactMap<Resp>(_ transform: @escaping (Data) throws -> Resp?) -> Endpoint<Resp?> {
        Endpoint<Resp?>(strategy: strategy, encode: encode, decode: {
            try self.decode($0).flatMap(transform)
        }, report: report)
    }
}

extension Endpoint {
    func update(_ mutate: @escaping (inout URLRequest) throws -> Void) -> Endpoint {
        Endpoint(strategy: strategy, encode: concat(encode, mutate), decode: decode, report: report)
    }

    func map<Resp>(_ transform: @escaping (Response) throws -> Resp) -> Endpoint<Resp> {
        Endpoint<Resp>(strategy: strategy, encode: encode, decode: pipe(decode, transform), report: report)
    }
    
    func perform(_ action: @escaping (Response) -> Void) -> Endpoint {
        map { response in
            action(response)
            return response
        }
    }
    
    func handle(_ error: @escaping (FetchingError) -> Void) -> Endpoint {
        Endpoint(strategy: strategy, encode: encode, decode: decode, report: {
            self.report($0)
            error($0)
        })
    }

    func encoding<Body: Encodable>(body: Body, using strategy: @escaping (Body) throws -> Data) -> Endpoint {
        update { request in
            request.httpBody = try strategy(body)
        }
    }

    func ignoreValue() -> Endpoint<Void> {
        map { _ in }
    }
}

extension Endpoint {
    private func append(components: [String]) -> RequestModifier {
        { request in
            for component in components {
                request.url?.appendPathComponent(component)
            }
        }
    }

    func get(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "GET"), append(components: path)))
    }

    func post(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "POST"), append(components: path)))
    }

    func put(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "PUT"), append(components: path)))
    }

    func delete(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "DELETE"), append(components: path)))
    }
}
