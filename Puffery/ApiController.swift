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
    }

    func subscribeChannel(deviceId: String, channelId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("channel/subscribe"))
        request.httpMethod = "POST"

        // Headers

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // JSON Body

        let bodyObject: [String: Any] = [
            "channelId": channelId,
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
    }

    func channels(deviceToken: String, completion: @escaping (Result<[Channel], Error>) -> Void) {
        publicChannels(deviceToken: deviceToken) { publicResult in
            self.privateChannels(deviceToken: deviceToken) { privateResult in
                var channels = (try? publicResult.get()) ?? []
                channels.append(contentsOf: (try? privateResult.get()) ?? [])
                completion(.success(channels))
            }
        }
    }

    func publicChannels(deviceToken: String, completion: @escaping (Result<[Channel], Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("channels").appendingPathComponent(deviceToken).appendingPathComponent("public"))
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                do {
                    let channels = try JSONDecoder().decode([Channel].self, from: data ?? Data())
                    completion(.success(channels))
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
    }

    func privateChannels(deviceToken: String, completion: @escaping (Result<[Channel], Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("channels").appendingPathComponent(deviceToken).appendingPathComponent("private"))
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                do {
                    let channels = try JSONDecoder().decode([Channel].self, from: data ?? Data())
                    completion(.success(channels))
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
    }

    func channelMessages(channel: Channel, completion: @escaping (Result<[Message], Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("channel").appendingPathComponent(channel.publicId).appendingPathComponent("notifications"))
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                do {
                    let channels = try JSONDecoder().decode([ApplePushNotification].self, from: data ?? Data())
                    completion(.success(channels.map(\.message)))
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
    }

    func deviceMessages(deviceToken: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("notifications").appendingPathComponent(deviceToken))
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                do {
                    let channels = try JSONDecoder().decode([ApplePushNotification].self, from: data ?? Data())
                    completion(.success(channels.map(\.message)))
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
    }
}

// private struct JSONString<Value: Codable>: Codable {
//    let value: Value
// }
//
// extension JSONString {
//    init(from decoder: Decoder) throws {
//        let stringContainer = try decoder.singleValueContainer()
//        let rawStringValue = try stringContainer.decode(String.self)
//
//        value = try JSONDecoder().decode(Value.self, from: rawStringValue.data(using: .utf8) ?? Data())
//    }
//
//    func encode(to encoder: Encoder) throws {
//        let rawValue = try JSONEncoder().encode(value)
//        var stringContainer = encoder.singleValueContainer()
//        try stringContainer.encode(String(data: rawValue, encoding: .utf8) ?? "null")
//    }
// }

private struct ApplePushNotification: Codable {
    let aps: ApplePushService

    struct ApplePushService: Codable {
        let alert: Alert

        struct Alert: Codable {
            let title: String
            let body: String
        }
    }

    var message: Message {
        Message(title: aps.alert.title, body: aps.alert.body, color: .unspecified)
    }
}
