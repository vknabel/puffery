struct SubscriptionMessage: Comparable {
    var message: Message
    var subscription: Subscription

    static func == (lhs: SubscriptionMessage, rhs: SubscriptionMessage) -> Bool {
        lhs.message.id == rhs.message.id
            && lhs.subscription.id == rhs.subscription.id
    }

    static func < (lhs: SubscriptionMessage, rhs: SubscriptionMessage) -> Bool {
        (lhs.message.createdAt ?? .distantFuture) < (rhs.message.createdAt ?? .distantFuture)
    }
}
