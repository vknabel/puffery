import Foundation

internal struct Attributes: Codable, Equatable {
  var siteLocation: String
  var siteReferrer: String?

  var siteLanguage: String?
  var deviceName: String?
  var osName: String?
  var osVersion: String?
}

internal struct RecordResponse: Codable, Equatable {
  var type: RecordResponseType
  var data: Record

  enum RecordResponseType: String, Codable, Equatable {
    case record
  }
}

internal struct Record: Codable, Equatable {
  var id: String
  var domainId: String
  var siteLocation: String
  var created: Date
  var updated: Date
}
