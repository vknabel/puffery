import Vapor

@available(*, deprecated, message: "Use EventLoopFuture<V> instead")
typealias Future<V> = EventLoopFuture<V>

extension EventLoopFuture {
    @inlinable
    @available(*, deprecated)
    public func flatMap<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        flatMap(file: file, line: line) { value -> EventLoopFuture<NewValue> in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.future(error: error)
            }
        }
    }

    @inlinable
    public static func zip<Second, Third>(
        _ first: EventLoopFuture<Value>,
        _ second: EventLoopFuture<Second>,
        _ third: EventLoopFuture<Third>
    ) -> EventLoopFuture<(Value, Second, Third)> {
        first.and(second).and(third)
            .map { (prefix, third) in
                (prefix.0, prefix.1, third)
            }
    }

    @inlinable
    public func and<Second, Third>(
        _ second: EventLoopFuture<Second>,
        _ third: EventLoopFuture<Third>
    ) -> EventLoopFuture<(Value, Second, Third)> {
        and(second).and(third)
            .map { (prefix, third) in
                (prefix.0, prefix.1, third)
            }
    }
}
