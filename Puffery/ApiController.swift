import Foundation

class ApiController {
    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    let baseURL = URL(string: "https://api.puffery.app/")!

    func docs(completion: @escaping (Result<String?, Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                let contents = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.success(contents ?? ""))
            } else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(.failure(error!))
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    func createChannel(deviceId: String, title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("channel/create"))
        request.httpMethod = "POST"

        // Headers

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // JSON Body

        let bodyObject: [String: Any] = [
            "title": title,
            "deviceId": deviceId,
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (_: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                completion(.success(()))
            } else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(.failure(error!))
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    func notify(title: String, body: String, channelToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("notify"))
        request.httpMethod = "POST"

        // Headers

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // JSON Body

        let bodyObject: [String: Any] = [
            "title": title,
            "body": body,
            "channelToken": channelToken,
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (_: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                completion(.success(()))
            } else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(.failure(error!))
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    func channels(deviceToken: String, completion: @escaping (Result<[Channel], Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("subscriptions").appendingPathComponent(deviceToken))
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                do {
                    let channels = try JSONDecoder().decode([JSONString<Channel>].self, from: data ?? Data())
                    completion(.success(channels.map(\.value)))
                } catch {
                    completion(.failure(error))
                }
            } else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(.failure(error!))
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

private struct JSONString<Value: Codable>: Codable {
    let value: Value
}

extension JSONString {
    init(from decoder: Decoder) throws {
        let stringContainer = try decoder.singleValueContainer()
        let rawStringValue = try stringContainer.decode(String.self)

        value = try JSONDecoder().decode(Value.self, from: rawStringValue.data(using: .utf8) ?? Data())
    }

    func encode(to encoder: Encoder) throws {
        let rawValue = try JSONEncoder().encode(value)
        var stringContainer = encoder.singleValueContainer()
        try stringContainer.encode(String(data: rawValue, encoding: .utf8) ?? "null")
    }
}
