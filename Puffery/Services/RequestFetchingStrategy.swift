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

struct FetchingError: Error, Identifiable {
    var id = UUID()

    var reason: Reason
    var request: URLRequest?
    var data: Data?

    init(reason: Reason, request: URLRequest?, data: Data?) {
        self.reason = reason
        self.request = request
        self.data = data
    }

    enum Reason {
        case http(Error)
        case encoding(Error)
        case decoding(Error)
        case statusCode(Int)
    }
}

protocol RequestFetchingStrategy {
    @discardableResult
    func task<R>(_ endpoint: Endpoint<R>, receive: @escaping (Result<R, FetchingError>) -> Void) -> URLSessionDataTask?
    func publisher<R>(_ endpoint: Endpoint<R>) -> AnyPublisher<R, FetchingError>
}
