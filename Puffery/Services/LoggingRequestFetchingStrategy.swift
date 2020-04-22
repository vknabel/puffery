//
//  LoggingRequestFetchingStrategy.swift
//  Puffery
//
//  Created by Valentin Knabel on 22.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation

final class LoggingRequestFetchingStrategy: RequestFetchingStrategy {
    private let strategy: RequestFetchingStrategy
    private let log: (Result<Any, FetchingError>) -> Void

    init(_ strategy: RequestFetchingStrategy, log: @escaping (Result<Any, FetchingError>) -> Void) {
        self.strategy = strategy
        self.log = log
    }

    func task<R>(_ endpoint: Endpoint<R>, receive: @escaping (Result<R, FetchingError>) -> Void) -> URLSessionDataTask? {
        strategy.task(endpoint) { result in
            defer { receive(result) }

            switch result {
            case let .success(value):
                self.log(.success(value as Any))
            case let .failure(error):
                self.log(.failure(error))
            }
        }
    }

    func publisher<R>(_ endpoint: Endpoint<R>) -> AnyPublisher<R, FetchingError> {
        strategy.publisher(endpoint).handleEvents(
            receiveOutput: { self.log(.success($0 as Any)) },
            receiveCompletion: {
                guard case let .failure(error) = $0 else {
                    return
                }
                self.log(.failure(error))
            }
        ).eraseToAnyPublisher()
    }
}
