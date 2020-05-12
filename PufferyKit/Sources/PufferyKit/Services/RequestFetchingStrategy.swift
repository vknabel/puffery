//
//  EndpointStrategy.swift
//  Puffery
//
//  Created by Valentin Knabel on 21.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation
import Overture

public struct FetchingError: Error, Identifiable, Equatable {
    public var id = UUID()

    public var reason: Reason
    public var request: URLRequest?
    public var data: Data?

    public init(reason: Reason, request: URLRequest?, data: Data?) {
        self.reason = reason
        self.request = request
        self.data = data
    }

    public enum Reason {
        case http(Error)
        case encoding(Error)
        case decoding(Error)
        case statusCode(Int)

        public func statusCode(_ statuses: Int...) -> Bool {
            if case let .statusCode(code) = self {
                return statuses.contains(code)
            } else {
                return false
            }
        }
    }

    public static func == (lhs: FetchingError, rhs: FetchingError) -> Bool {
        lhs.id == rhs.id
    }
}

public protocol RequestFetchingStrategy {
    @discardableResult
    func task<R>(_ endpoint: Endpoint<R>, receive: @escaping (Result<R, FetchingError>) -> Void) -> URLSessionDataTask?
    func publisher<R>(_ endpoint: Endpoint<R>) -> AnyPublisher<R, FetchingError>
}
