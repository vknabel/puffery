import Fluent

extension Model {
    public static func find<Relation>(_ id: Self.IDValue?, on database: FluentKit.Database, with relationKey: KeyPath<Self, Relation>) -> NIO.EventLoopFuture<Self?> where Relation: EagerLoadable, Relation.From == Self {
        guard let id = id else {
            return database.eventLoop.makeSucceededFuture(nil)
        }
        return query(on: database)
            .filter(\._$id == id)
            .with(relationKey)
            .first()
    }

    public func saving(on db: Database) -> EventLoopFuture<Self> {
        save(on: db).map { _ in self }
    }
}
