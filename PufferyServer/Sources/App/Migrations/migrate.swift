import Fluent
import Vapor

func migrate(_ app: Application) throws {
    let migrations: [Migration] = [
        CreateUserMigration(),
        CreateChannelMigration(),
        CreateDeviceMigration(),
        CreateMessageMigration(),
        CreateSubscriptionMigration(),
        CreateUserTokenMigration(),
        _2020_04_23_UniqueEmailsOptionalUserMigration(),
        _2020_04_26_UniqueSubscriptionMigration(),
        _2020_04_27_AddUserPasswordMigration(),
        _2020_04_27_UniqueUserEmailsAndDeletionRulesMigration(),
        _2020_04_28_CreateConfirmationMigration(),
        _2020_04_28_ReplaceUserPasswordWithVerifiedFlagMigration(),
    ]
    migrations.forEach {
        app.migrations.add($0)
    }
}
