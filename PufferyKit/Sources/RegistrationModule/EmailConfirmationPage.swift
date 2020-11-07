//
//  EmailConfirmationPage.swift
//
//
//  Created by Valentin Knabel on 10.05.20.
//

import SwiftUI
import PlatformSupport
import DesignSystem

public struct EmailConfirmationPage: View {
    let email: String
    
    public init(email: String) {
        self.email = email
    }

    public var body: some View {
        VStack {
            SlideImage("MessageSent")
            
            Image(systemName: "envelope.badge.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .padding()

            Text("Registration.Email.Title")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            Text("Registration.Email.Recepient email:\(self.email)")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            #if !canImport(Cocoa)
                Button(action: self.openMailApp) {
                    HStack {
                        Text("Registration.Email.OpenApp")
                        Image(systemName: "chevron.right")
                    }
                }.padding()
            #endif
        }
        .padding()
        .onAppear {
            PushNotifications.register()
        }
    }

    private func openMailApp() {
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
        }
    }
}
