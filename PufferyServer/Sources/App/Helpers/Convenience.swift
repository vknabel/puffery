import Fluent

public extension Model {
    static func find<Relation>(_ id: Self.IDValue?, on database: FluentKit.Database, with relationKey: KeyPath<Self, Relation>) async throws -> Self? where Relation: EagerLoadable, Relation.From == Self {
        guard let id = id else {
            return nil
        }
        return try await query(on: database)
            .filter(\._$id == id)
            .with(relationKey)
            .first()
    }

    func saving(on db: Database) async throws -> Self {
        try await save(on: db)
        return self
    }
}
