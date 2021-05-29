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

public struct Fetching<V, E: Error, LoadingView: View, ErrorView: View, DataView: View>: View {
    typealias Retry = () -> Void

    var fetch: AnyPublisher<V, E>
    var forceReload: AnyPublisher<(), E>
    var loading: () -> LoadingView
    var error: (E, @escaping Retry) -> ErrorView
    var data: (V) -> DataView

    @State var latestResult: Result<V, E>?
    @State var operation: AnyCancellable?
    @State var needsReload = false

    init<P: Publisher, R: Publisher>(
        _ fetch: P,
        forceReload: R,
        @ViewBuilder loading: @escaping () -> LoadingView,
        @ViewBuilder error: @escaping (E, @escaping Retry) -> ErrorView,
        @ViewBuilder data: @escaping (V) -> DataView
    ) where P.Output == V, P.Failure == E, R.Output == Void, R.Failure == E {
        self.fetch = forceReload
            .prepend(())
            .flatMap({ _ in fetch })
            .eraseToAnyPublisher()
        self.forceReload = forceReload.eraseToAnyPublisher()
        self.loading = loading
        self.error = error
        self.data = data
    }

    public var body: some View {
        Group {
            if latestResult == nil {
                loading()
                    .onAppear(perform: reloadData)
            }
            latestResult?.failure.map {
                self.error($0, self.retry)
                    .onAppear(perform: reloadData)
            }
            latestResult?.success.map(data)
                .onDisappear(perform: markForReload)
                .onAppear(perform: reloadIfNeeded)
        }
    }

    private func markForReload() {
        needsReload = true
    }

    private func reloadIfNeeded() {
        guard needsReload else { return }
        reloadData()
    }

    private func reloadData() {
        operation = fetch.sink(
            receiveCompletion: { completion in
                dispatchPrecondition(condition: .onQueue(.main))
                if case let .failure(error) = completion {
                    self.latestResult = .failure(error)
                }
                self.operation = nil
            },
            receiveValue: {
                dispatchPrecondition(condition: .onQueue(.main))
                self.latestResult = .success($0)
            }
        )
    }

    private func retry() {
        dispatchPrecondition(condition: .onQueue(.main))
        latestResult = nil
        reloadData()
    }

    private func cancel() {
        dispatchPrecondition(condition: .onQueue(.main))
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

public extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView {
    init<P: Publisher, R: Publisher>(
        _ fetch: P,
        forceReload: R,
        @ViewBuilder data: @escaping (V) -> DataView
    ) where P.Output == V, P.Failure == E, R.Output == Void, R.Failure == E {
        self.fetch  = forceReload
            .prepend(())
            .flatMap({ _ in fetch })
            .eraseToAnyPublisher()
        self.forceReload = forceReload.eraseToAnyPublisher()
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
    
    init<P: Publisher>(
        _ fetch: P,
        @ViewBuilder data: @escaping (V) -> DataView
    ) where P.Output == V, P.Failure == E {
        self.init(fetch, forceReload: Empty(), data: data)
    }
}

public extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView, DataView == AnyView, V: Collection {
    init<P: Publisher, R: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        forceReload: R,
        @ViewBuilder empty: @escaping () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E, R.Output == Void, R.Failure == E {
        self.init(fetch, forceReload: forceReload, data: { collection in
            collection.isEmpty ? AnyView(empty()) : AnyView(data(collection))
        })
    }

    init<P: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        @ViewBuilder empty: @escaping () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E {
        self.init(fetch, forceReload: Empty(), empty: empty, data: data)
    }
}

public extension Fetching where LoadingView == ActivityIndicator, ErrorView == AnyView, DataView == AnyView, V: Collection {
    init<P: Publisher, R: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        forceReload: R,
        empty: @escaping @autoclosure () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E, R.Output == Void, R.Failure == E {
        self.init(fetch, forceReload: forceReload, empty: empty, data: data)
    }

    init<P: Publisher, EmptyView: View, NonEmptyView: View>(
        _ fetch: P,
        empty: @escaping @autoclosure () -> EmptyView,
        @ViewBuilder data: @escaping (V) -> NonEmptyView
    ) where P.Output == V, P.Failure == E {
        self.init(fetch, forceReload: Empty(), empty: empty, data: data)
    }
}
