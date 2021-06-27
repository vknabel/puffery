//
//  Attributes.swift
//  
//
//  Created by Valentin Knabel on 27.06.21.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#endif

internal extension AckeeTracker {
    func updatedAttributes(_ attributes: CreateRecordInput) -> CreateRecordInput {
        guard let options = options else {
            return attributes
        }
        
        var attributes = attributes
        attributes.siteLocation = options.appUrl.appendingPathComponent(attributes.siteLocation).absoluteString

        guard options.detailed else {
            return attributes
        }
        
        attributes.siteLanguage = Locale.current.languageCode
        
        #if canImport(UIKit)
            attributes.deviceName = UIDevice.current.model
        #endif

        #if os(macOS)
        attributes.osName = "OS X"
        #elseif os(iOS)
        attributes.osName = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #elseif os(watchOS)
        attributes.osName = "watchOS"
        #elseif os(tvOS)
        attributes.osName = "tvOS"
        #elseif os(Linux)
        attributes.osName = "Linux"
        #elseif os(Windows)
        attributes.osName = "Windows"
        #endif

        #if canImport(UIKit)
        attributes.osVersion = UIDevice.current.systemVersion
        #else
            let version = ProcessInfo.processInfo.operatingSystemVersion
        attributes.osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #endif
        
        return attributes
    }
}
