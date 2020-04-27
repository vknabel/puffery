import Fluent

extension Model {
    public static func find<Relation>(_: Self.IDValue?, on database: FluentKit.Database, with relationKey: KeyPath<Self, Relation>) -> NIO.EventLoopFuture<Self?> where Relation: EagerLoadable, Relation.From == Self {
        query(on: database)
            .with(relationKey)
            .first()
    }
}
