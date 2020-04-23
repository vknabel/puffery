import Vapor

typealias Future<V> = EventLoopFuture<V>

extension EventLoopFuture {
    @inlinable
    public func flatMap<NewValue>(file _: StaticString = #file, line _: UInt = #line, _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        flatMap { value -> EventLoopFuture<NewValue> in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.future(error: error)
            }
        }
    }
}
