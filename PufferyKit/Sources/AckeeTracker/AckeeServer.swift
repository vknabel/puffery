import Apollo

internal struct AckeeServer {
    private let configuration: AckeeConfiguration
    private let dependencies: AckeeDependencies
    internal let client: ApolloClient

    init(
        configuration: AckeeConfiguration,
        dependencies: AckeeDependencies
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
        client = ApolloClient(url: configuration.serverUrl)
    }
}
