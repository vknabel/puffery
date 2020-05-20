import Foundation

/// Internally used dependencies for the Ackee Tracker.
public struct AckeeDependencies {
  internal let report: (Error) -> Void
  internal let fetch: (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> Void

  /// Sets up Ackee for production use.
  /// - Parameters:
  ///     - urlSession: The internally used `URLSession`. Default: `URLSession.shared`
  public static func prod(
    urlSession: URLSession = URLSession.shared
  ) -> AckeeDependencies {
    return .init(
      report: { print("Ackee.error:", $0) },
      fetch: {
        let task = urlSession.dataTask(with: $0, completionHandler: $1)
        task.priority = URLSessionTask.lowPriority
        task.resume()
      }
    )
  }
}

extension AckeeDependencies {
  func fetch<Response: Decodable>(
    _ request: URLRequest,
    of responseType: Response.Type,
    receive: @escaping (Response) -> Void
  ) {
    fetch(request) { data, response, error in
      do {
        if let error = error {
          self.report(error)
        }
        guard let response = response as? HTTPURLResponse, let data = data,
          response.statusCode == 200 || response.statusCode == 201
        else {
          return
        }
        receive(try AckeeDependencies.apiDecoder.decode(responseType, from: data))
      } catch {
        self.report(error)
      }
    }
  }

  private static var apiDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return formatter
  }

  internal static var apiEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(apiDateFormatter)
    return encoder
  }

  internal static var apiDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(apiDateFormatter)
    return decoder
  }
}
