//
//  Fetching.swift
//  Puffery
//
//  Created by Valentin Knabel on 22.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct Fetching<V, E: Error, LoadingView: View, ErrorView: View, DataView: View>: View {
    typealias Retry = () -> Void

    var fetch: AnyPublisher<V, E>
    var loading: () -> LoadingView
    var error: (E, @escaping Retry) -> ErrorView
    var data: (V) -> DataView

    @State var latestResult: Result<V, E>?
    @State var operation: AnyCancellable?

    init<P: Publisher>(
        _ fetch: P,
        @ViewBuilder loading: @escaping () -> LoadingView,
        @ViewBuilder error: @escaping (E, @escaping Retry) -> ErrorView,
        @ViewBuilder data: @escaping (V) -> DataView
    ) where P.Output == V, P.Failure == E {
        self.fetch = fetch.eraseToAnyPublisher()
        self.loading = loading
        self.error = error
        self.data = data
    }

    var body: some View {
        Group {
            operation.map { _ in loading() }
            latestResult?.failure.map {
                self.error($0, self.retry)
            }
            latestResult?.success.map(data)
        }.onAppear(perform: reloadData)
            .onDisappear(perform: cancel)
    }

    private func reloadData() {
        operation = fetch.sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.latestResult = .failure(error)
                }
                self.operation = nil
            },
            receiveValue: { self.latestResult = .success($0) }
        )
    }

    private func retry() {
        latestResult = nil
        reloadData()
    }

    private func cancel() {
        operation = nil
    }
}

private extension Result {
    var success: Success? {
        if case let .success(value) = self {
            return value
        } else {
            return nil
        }
    }

    var failure: Failure? {
        if case let .failure(error) = self {
            return error
        } else {
            return nil
        }
    }
}

extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView {
    init<P: Publisher>(
        _ fetch: P,
        @ViewBuilder data: @escaping (V) -> DataView
    ) where P.Output == V, P.Failure == E {
        self.fetch = fetch.eraseToAnyPublisher()
        self.data = data
        loading = { ActivityIndicator(isAnimating: true) }
        error = { error, retry in
            AnyView(VStack {
                Text(error.localizedDescription)
                Button(action: retry) {
                    Text("Retry")
                }
                Image("Errorfish").opacity(0.3)
            })
        }
    }
}

extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView, DataView == AnyView, V: Collection {
    init<P: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        @ViewBuilder empty: @escaping () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E {
        self.init(fetch, data: { collection in
            collection.isEmpty ? AnyView(empty()) : AnyView(data(collection))
        })
    }
}

extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView, DataView == AnyView, V: Collection {
    init<P: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        empty: @escaping @autoclosure () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E {
        self.init(fetch, empty: empty, data: data)
    }
}
