//
//  AckeeTracker.swift
//
//
//  Created by Valentin Knabel on 27.06.21.
//

import Apollo
import Foundation

public var ackeeTracker = AckeeTracker()

public struct Record {
    public var id: String
}
public struct Action {
    public var id: String
}

public class AckeeTracker {
    internal var options: AckeeOptions?
    private var client: ApolloClient?
    
    public init() {
        if let serverUrlString = Bundle.main.infoDictionary?["AckeeServerUrl"] as? String,
           let serverUrl = URL(string: serverUrlString),
           let appUrlString = Bundle.main.infoDictionary?["AckeeAppUrl"] as? String,
           let appUrl = URL(string: appUrlString),
           let domainId = Bundle.main.infoDictionary?["AckeeDomainId"] as? String {
            let detailed = Bundle.main.infoDictionary?["AckeeDetailed"] as? Bool ?? false
            prepare(AckeeOptions(domainId: domainId, serverUrl: serverUrl, appUrl: appUrl, detailed: detailed))
        }
    }
    
    public func prepare(_ options: AckeeOptions) {
        self.options = options
        client = ApolloClient(url: options.serverUrl)
    }
    
    private var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    private var isEnabled: Bool {
        if let options = options {
            return !options.disabled && options.ignoreDebug == true && !isDebug
        } else {
            return false
        }
    }
    
    @discardableResult
    public func record(_ record: CreateRecordInput, onSuccess: ((Record) -> Void)? = nil) -> Cancellable {
        guard let options = options, let client = client, isEnabled else {
            return EmptyCancellable()
        }
        return client.perform(mutation: CreateRecordMutation(domainId: options.domainId, input: updatedAttributes(record))) { result in
            self.log(record.siteLocation, result)
            if let recordId = try? result.get().data?.createRecord.payload?.id {
                onSuccess?(Record(id: recordId))
            }
        }
    }
    
    @discardableResult
    public func record(siteLocation: String, onSuccess: ((Record) -> Void)? = nil) -> Cancellable {
        record(CreateRecordInput(siteLocation: siteLocation), onSuccess: onSuccess)
    }
    
    @discardableResult
    public func updateRecord(_ record: Record, onSuccess: ((Bool) -> Void)? = nil) -> Cancellable {
        guard let client = client, isEnabled else {
            return EmptyCancellable()
        }
        return client.perform(mutation: UpdateRecordMutation(recordId: record.id)) { result in
            self.log(record.id, result)
            if let success = try? result.get().data?.updateRecord.success {
                onSuccess?(success)
            }
        }
    }
    
    @discardableResult
    public func action(_ eventId: String, attributes: CreateActionInput, onSuccess: ((Action) -> Void)? = nil) -> Cancellable {
        guard let client = client, isEnabled else {
            return EmptyCancellable()
        }
        return client.perform(mutation: CreateActionMutation(eventId: eventId, input: attributes)) { result in
            self.log(eventId, result)
            if let actionId = try? result.get().data?.createAction.payload?.id {
                onSuccess?(Action(id: actionId))
            }
        }
    }
    
    @discardableResult
    public func action(_ eventId: String, key: String, value: Decimal = 1.0, details: String? = nil, onSuccess: ((Action) -> Void)? = nil) -> Cancellable {
        action(eventId, attributes: CreateActionInput(key: key, value: "\(value)", details: details), onSuccess: onSuccess)
    }
    
    @discardableResult
    public func updateAction(_ action: Action, attributes: UpdateActionInput, onSuccess: ((Bool) -> Void)? = nil) -> Cancellable {
        guard let client = client, isEnabled else {
            return EmptyCancellable()
        }
        return client.perform(mutation: UpdateActionMutation(actionId: action.id, input: attributes)) { result in
            self.log(action.id, result)
            if let success = try? result.get().data?.updateAction.success {
                onSuccess?(success)
            }
        }
    }
    
    public func recordPresence(_ attributes: CreateRecordInput) -> DurationRecorder {
        let recordSession = DurationRecorder()
        record(attributes) { record in
            recordSession.record = record
        }
        return recordSession
    }

    public func recordPresence(_ siteLocation: String) -> DurationRecorder {
        let recordSession = DurationRecorder()
        record(CreateRecordInput(siteLocation: siteLocation)) { record in
            recordSession.record = record
        }
        return recordSession
    }
    
    private func log<Data>(_ what: String, _ result: Result<GraphQLResult<Data>, Error>, method: StaticString = #function) {
        #if DEBUG
        switch result {
        case let .success(response):
            if  let errors = response.errors, !errors.isEmpty {
                print("[ACKEE] Soft-Failure", method, what, errors)
            } else {
                print("[ACKEE] Success", method, what)
            }
        case let .failure(error):
            print("[ACKEE] Failure", method, what, error)
        }
        #endif
    }
}
