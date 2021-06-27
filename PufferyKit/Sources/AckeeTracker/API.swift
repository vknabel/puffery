// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct CreateActionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - key: Key that will be used to group similar actions in the UI.
  ///   - value: Numerical value that is added to all other numerical values of the key, grouped by day, month or year.
  /// Use '1' to count how many times an event occurred or a price (e.g. '1.99') to
  /// see the sum of successful checkouts in a shop.
  ///   - details: Details allow you to store more data along with the associated action.
  public init(key: String, value: Swift.Optional<String?> = nil, details: Swift.Optional<String?> = nil) {
    graphQLMap = ["key": key, "value": value, "details": details]
  }

  /// Key that will be used to group similar actions in the UI.
  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  /// Numerical value that is added to all other numerical values of the key, grouped by day, month or year.
  /// Use '1' to count how many times an event occurred or a price (e.g. '1.99') to
  /// see the sum of successful checkouts in a shop.
  public var value: Swift.Optional<String?> {
    get {
      return graphQLMap["value"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }

  /// Details allow you to store more data along with the associated action.
  public var details: Swift.Optional<String?> {
    get {
      return graphQLMap["details"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }
}

public struct CreateRecordInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - siteLocation: URL of the page.
  ///   - siteReferrer: Where the user came from. Either unknown, a specific page or just the domain. This depends on the browser of the user.
  ///   - source: Where the user came from. Specified using the source query parameter.
  ///   - siteLanguage: Preferred language of the user. ISO 639-1 formatted.
  ///   - screenWidth: Width of the screen used by the user to visit the site.
  ///   - screenHeight: Height of the screen used by the user to visit the site.
  ///   - screenColorDepth: Color depth of the screen used by the user to visit the site.
  ///   - deviceName: Device used by the user to visit the site.
  ///   - deviceManufacturer: Manufacturer of the device used by the user to visit the site.
  ///   - osName: Operating system used by the user to visit the site.
  ///   - osVersion: Operating system version used by the user to visit the site.
  ///   - browserName: Browser used by the user to visit the site.
  ///   - browserVersion: Version of the browser used by the user to visit the site.
  ///   - browserWidth: Width of the browser used by the user to visit the site.
  ///   - browserHeight: Height of the browser used by the user to visit the site.
  public init(siteLocation: String, siteReferrer: Swift.Optional<String?> = nil, source: Swift.Optional<String?> = nil, siteLanguage: Swift.Optional<String?> = nil, screenWidth: Swift.Optional<String?> = nil, screenHeight: Swift.Optional<String?> = nil, screenColorDepth: Swift.Optional<String?> = nil, deviceName: Swift.Optional<String?> = nil, deviceManufacturer: Swift.Optional<String?> = nil, osName: Swift.Optional<String?> = nil, osVersion: Swift.Optional<String?> = nil, browserName: Swift.Optional<String?> = nil, browserVersion: Swift.Optional<String?> = nil, browserWidth: Swift.Optional<String?> = nil, browserHeight: Swift.Optional<String?> = nil) {
    graphQLMap = ["siteLocation": siteLocation, "siteReferrer": siteReferrer, "source": source, "siteLanguage": siteLanguage, "screenWidth": screenWidth, "screenHeight": screenHeight, "screenColorDepth": screenColorDepth, "deviceName": deviceName, "deviceManufacturer": deviceManufacturer, "osName": osName, "osVersion": osVersion, "browserName": browserName, "browserVersion": browserVersion, "browserWidth": browserWidth, "browserHeight": browserHeight]
  }

  /// URL of the page.
  public var siteLocation: String {
    get {
      return graphQLMap["siteLocation"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "siteLocation")
    }
  }

  /// Where the user came from. Either unknown, a specific page or just the domain. This depends on the browser of the user.
  public var siteReferrer: Swift.Optional<String?> {
    get {
      return graphQLMap["siteReferrer"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "siteReferrer")
    }
  }

  /// Where the user came from. Specified using the source query parameter.
  public var source: Swift.Optional<String?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  /// Preferred language of the user. ISO 639-1 formatted.
  public var siteLanguage: Swift.Optional<String?> {
    get {
      return graphQLMap["siteLanguage"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "siteLanguage")
    }
  }

  /// Width of the screen used by the user to visit the site.
  public var screenWidth: Swift.Optional<String?> {
    get {
      return graphQLMap["screenWidth"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenWidth")
    }
  }

  /// Height of the screen used by the user to visit the site.
  public var screenHeight: Swift.Optional<String?> {
    get {
      return graphQLMap["screenHeight"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenHeight")
    }
  }

  /// Color depth of the screen used by the user to visit the site.
  public var screenColorDepth: Swift.Optional<String?> {
    get {
      return graphQLMap["screenColorDepth"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenColorDepth")
    }
  }

  /// Device used by the user to visit the site.
  public var deviceName: Swift.Optional<String?> {
    get {
      return graphQLMap["deviceName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceName")
    }
  }

  /// Manufacturer of the device used by the user to visit the site.
  public var deviceManufacturer: Swift.Optional<String?> {
    get {
      return graphQLMap["deviceManufacturer"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceManufacturer")
    }
  }

  /// Operating system used by the user to visit the site.
  public var osName: Swift.Optional<String?> {
    get {
      return graphQLMap["osName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "osName")
    }
  }

  /// Operating system version used by the user to visit the site.
  public var osVersion: Swift.Optional<String?> {
    get {
      return graphQLMap["osVersion"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "osVersion")
    }
  }

  /// Browser used by the user to visit the site.
  public var browserName: Swift.Optional<String?> {
    get {
      return graphQLMap["browserName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "browserName")
    }
  }

  /// Version of the browser used by the user to visit the site.
  public var browserVersion: Swift.Optional<String?> {
    get {
      return graphQLMap["browserVersion"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "browserVersion")
    }
  }

  /// Width of the browser used by the user to visit the site.
  public var browserWidth: Swift.Optional<String?> {
    get {
      return graphQLMap["browserWidth"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "browserWidth")
    }
  }

  /// Height of the browser used by the user to visit the site.
  public var browserHeight: Swift.Optional<String?> {
    get {
      return graphQLMap["browserHeight"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "browserHeight")
    }
  }
}

public struct UpdateActionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - key: Key that will be used to group similar actions in the UI.
  ///   - value: Numerical value that is added to all other numerical values of the key, grouped by day, month or year.
  /// Use '1' to count how many times an event occurred or a price (e.g. '1.99') to
  /// see the sum of successful checkouts in a shop.
  /// Reset an existing value using 'null'.
  ///   - details: Details allow you to store more data along with the associated action.
  public init(key: String, value: Swift.Optional<String?> = nil, details: Swift.Optional<String?> = nil) {
    graphQLMap = ["key": key, "value": value, "details": details]
  }

  /// Key that will be used to group similar actions in the UI.
  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  /// Numerical value that is added to all other numerical values of the key, grouped by day, month or year.
  /// Use '1' to count how many times an event occurred or a price (e.g. '1.99') to
  /// see the sum of successful checkouts in a shop.
  /// Reset an existing value using 'null'.
  public var value: Swift.Optional<String?> {
    get {
      return graphQLMap["value"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }

  /// Details allow you to store more data along with the associated action.
  public var details: Swift.Optional<String?> {
    get {
      return graphQLMap["details"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "details")
    }
  }
}

public final class CreateActionMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation createAction($eventId: ID!, $input: CreateActionInput!) {
      createAction(eventId: $eventId, input: $input) {
        __typename
        payload {
          __typename
          id
        }
      }
    }
    """

  public let operationName: String = "createAction"

  public var eventId: GraphQLID
  public var input: CreateActionInput

  public init(eventId: GraphQLID, input: CreateActionInput) {
    self.eventId = eventId
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["eventId": eventId, "input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createAction", arguments: ["eventId": GraphQLVariable("eventId"), "input": GraphQLVariable("input")], type: .nonNull(.object(CreateAction.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createAction: CreateAction) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createAction": createAction.resultMap])
    }

    /// Create a new action to track an event.
    public var createAction: CreateAction {
      get {
        return CreateAction(unsafeResultMap: resultMap["createAction"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "createAction")
      }
    }

    public struct CreateAction: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CreateActionPayload"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("payload", type: .object(Payload.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(payload: Payload? = nil) {
        self.init(unsafeResultMap: ["__typename": "CreateActionPayload", "payload": payload.flatMap { (value: Payload) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The newly created action.
      public var payload: Payload? {
        get {
          return (resultMap["payload"] as? ResultMap).flatMap { Payload(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "payload")
        }
      }

      public struct Payload: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Action"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "Action", "id": id])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Action identifier.
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }
    }
  }
}

public final class CreateRecordMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation createRecord($domainId: ID!, $input: CreateRecordInput!) {
      createRecord(domainId: $domainId, input: $input) {
        __typename
        payload {
          __typename
          id
        }
      }
    }
    """

  public let operationName: String = "createRecord"

  public var domainId: GraphQLID
  public var input: CreateRecordInput

  public init(domainId: GraphQLID, input: CreateRecordInput) {
    self.domainId = domainId
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["domainId": domainId, "input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createRecord", arguments: ["domainId": GraphQLVariable("domainId"), "input": GraphQLVariable("input")], type: .nonNull(.object(CreateRecord.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createRecord: CreateRecord) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createRecord": createRecord.resultMap])
    }

    /// Create a new record to track a page visit.
    public var createRecord: CreateRecord {
      get {
        return CreateRecord(unsafeResultMap: resultMap["createRecord"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "createRecord")
      }
    }

    public struct CreateRecord: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CreateRecordPayload"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("payload", type: .object(Payload.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(payload: Payload? = nil) {
        self.init(unsafeResultMap: ["__typename": "CreateRecordPayload", "payload": payload.flatMap { (value: Payload) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The newly created record.
      public var payload: Payload? {
        get {
          return (resultMap["payload"] as? ResultMap).flatMap { Payload(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "payload")
        }
      }

      public struct Payload: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Record"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "Record", "id": id])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Record identifier.
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }
    }
  }
}

public final class UpdateActionMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation updateAction($actionId: ID!, $input: UpdateActionInput!) {
      updateAction(id: $actionId, input: $input) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "updateAction"

  public var actionId: GraphQLID
  public var input: UpdateActionInput

  public init(actionId: GraphQLID, input: UpdateActionInput) {
    self.actionId = actionId
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["actionId": actionId, "input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateAction", arguments: ["id": GraphQLVariable("actionId"), "input": GraphQLVariable("input")], type: .nonNull(.object(UpdateAction.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateAction: UpdateAction) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateAction": updateAction.resultMap])
    }

    /// Update an existing action.
    public var updateAction: UpdateAction {
      get {
        return UpdateAction(unsafeResultMap: resultMap["updateAction"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateAction")
      }
    }

    public struct UpdateAction: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["UpdateActionPayload"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "UpdateActionPayload", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Indicates that the action update was successful. Might be 'null' otherwise.
      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

public final class UpdateRecordMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation updateRecord($recordId: ID!) {
      updateRecord(id: $recordId) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "updateRecord"

  public var recordId: GraphQLID

  public init(recordId: GraphQLID) {
    self.recordId = recordId
  }

  public var variables: GraphQLMap? {
    return ["recordId": recordId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateRecord", arguments: ["id": GraphQLVariable("recordId")], type: .nonNull(.object(UpdateRecord.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateRecord: UpdateRecord) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateRecord": updateRecord.resultMap])
    }

    /// Update an existing record to track the duration of a visit.
    public var updateRecord: UpdateRecord {
      get {
        return UpdateRecord(unsafeResultMap: resultMap["updateRecord"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateRecord")
      }
    }

    public struct UpdateRecord: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["UpdateRecordPayload"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "UpdateRecordPayload", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Indicates that the record update was successful. Might be 'null' otherwise.
      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}
