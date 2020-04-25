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
}
