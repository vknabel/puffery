import Foundation

internal struct AckeeServer {
    private let configuration: AckeeConfiguration
    private let dependencies: AckeeDependencies

    init(
        configuration: AckeeConfiguration,
        dependencies: AckeeDependencies
    ) {
        self.configuration = configuration
        self.dependencies = dependencies
    }
}

extension AckeeServer {
    func post(attributes: Attributes, receive: @escaping (Record) -> Void) {
        guard
            let request = createRequest(
                "POST", ["domains", configuration.domainId, "records"], attributes: attributes
            )
        else { return }
        dependencies.fetch(
            request,
            of: RecordResponse.self,
            receive: { receive($0.data) }
        )
    }

    func update(record: Record) {
        dependencies.fetch(
            createRequest("POST", ["domains", configuration.domainId, "records", record.id])
        ) { _, _, _ in }
    }

    private func createRequest(
        _ method: String,
        _ components: [String],
        body: Data? = nil
    ) -> URLRequest {
        let endpointURL = components.reduce(configuration.serverUrl) { $0.appendingPathComponent($1) }
        var request = URLRequest(url: endpointURL)
        request.httpMethod = method
        if let body = body {
            request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }

    private func createRequest<Attr: Encodable>(
        _ method: String,
        _ components: [String],
        attributes: Attr
    ) -> URLRequest? {
        do {
            return createRequest(
                method, components, body: try AckeeDependencies.apiEncoder.encode(attributes)
            )
        } catch {
            dependencies.report(error)
            return nil
        }
    }
}
