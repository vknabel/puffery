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

public typealias RequestModifier = (inout URLRequest) throws -> Void
public typealias ResponseDecoder<Response> = (Data?) throws -> Response

public struct Endpoint<Response> {
    public var strategy: RequestFetchingStrategy
    public var encode: RequestModifier
    public var decode: ResponseDecoder<Response>
    public var report: (FetchingError) -> Void

    @discardableResult
    public func task(_ receive: @escaping (Result<Response, FetchingError>) -> Void) -> URLSessionDataTask? {
        strategy.task(self, receive: receive)
    }

    public func publisher() -> AnyPublisher<Response, FetchingError> {
        strategy.publisher(self)
    }
}

extension Endpoint where Response == Data? {
    public init(strategy: RequestFetchingStrategy) {
        self.strategy = strategy
        encode = { _ in }
        decode = { $0 }
        report = { _ in }
    }

    public func decoding<Resp: Decodable>(_ strategy: @escaping (Resp.Type, Data) throws -> Resp, _: Resp.Type = Resp.self) -> Endpoint<Resp> {
        map { try strategy(Resp.self, $0 ?? Data()) }
    }

    public func compactMap<Resp>(_ transform: @escaping (Data) throws -> Resp?) -> Endpoint<Resp?> {
        Endpoint<Resp?>(strategy: strategy, encode: encode, decode: {
            try self.decode($0).flatMap(transform)
        }, report: report)
    }
}

extension Endpoint {
    public func update(_ mutate: @escaping (inout URLRequest) throws -> Void) -> Endpoint {
        Endpoint(strategy: strategy, encode: concat(encode, mutate), decode: decode, report: report)
    }

    public func map<Resp>(_ transform: @escaping (Response) throws -> Resp) -> Endpoint<Resp> {
        Endpoint<Resp>(strategy: strategy, encode: encode, decode: pipe(decode, transform), report: report)
    }

    public func perform(_ action: @escaping (Response) -> Void) -> Endpoint {
        map { response in
            action(response)
            return response
        }
    }

    public func handle(_ error: @escaping (FetchingError) -> Void) -> Endpoint {
        Endpoint(strategy: strategy, encode: encode, decode: decode, report: {
            self.report($0)
            error($0)
        })
    }

    public func encoding<Body: Encodable>(body: Body, using strategy: @escaping (Body) throws -> Data) -> Endpoint {
        update { request in
            request.httpBody = try strategy(body)
        }
    }

    public func query(_ params: [String: String?]) -> Endpoint {
        update { request in
            guard let requestUrl = request.url,
                  var components = URLComponents(string: requestUrl.absoluteString) else {
                return
            }
            var queryItems = components.queryItems ?? []
            queryItems.append(contentsOf: params.map({ key, value in
                URLQueryItem(name: key, value: value)
            }))
            components.queryItems = queryItems
            request.url = components.url ?? requestUrl
        }
    }

    public func ignoreValue() -> Endpoint<Void> {
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

    public func get(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "GET"), append(components: path)))
    }

    public func post(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "POST"), append(components: path)))
    }

    public func put(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "PUT"), append(components: path)))
    }

    public func delete(_ path: String...) -> Endpoint {
        update(concat(mut(\.httpMethod, "DELETE"), append(components: path)))
    }
}
