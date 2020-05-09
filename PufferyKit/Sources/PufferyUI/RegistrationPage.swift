//
//  RegistrationPage.swift
//  
//
//  Created by Valentin Knabel on 03.05.20.
//

import SwiftUI

struct RegistrationPage: View {
    var onFinish: () -> Void
    
    @ObservedObject private var keyboard = Keyboard()
    
    @State var email: String = ""
    @State var inProgress = false
    @State var registrationError: FetchingError?
    @State var shouldCheckEmails = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: performRegister) {
                Text("GettingStarted.Registration.Anonymous")
            }.buttonStyle(RichButtonStyle())
                .show(when: !keyboard.isActive)
                .transition(.opacity)
                .disabled(inProgress)

            Spacer()
            
            HStack {
                VStack { Divider() }
                Text("OR")
                    .italic()
                    .font(.headline)
                VStack { Divider() }
            }.show(when: !keyboard.isActive).transition(.opacity)
            
            VStack {
                TextField("GettingStarted.Login.EmailPlaceholder", text: $email, onCommit: performLogin)
                    .multilineTextAlignment(.center)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(inProgress)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("Background").opacity(keyboard.isActive ? 0.75 : 0.25))
                    )

                Button(action: performLogin) {
                    Text("GettingStarted.Login.Perform")
                }
                .disabled(email.isEmpty || inProgress)
                .sheet(isPresented: self.$shouldCheckEmails) {
                    VStack {
                        Image(systemName: "envelope.badge.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .padding()
                        
                        Text("Registration.Email.Title")
                            .font(.headline)
                        Text("Registration.Email.Recepient email:\(self.email)")
                            .font(.subheadline)
                        
                        Button(action: self.openMailApp) {
                            HStack {
                                Text("Registration.Email.OpenApp")
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, keyboard.currentHeight)
            .animation(.default)
            
            Spacer()
        }.buttonStyle(RichButtonStyle())
    }
    
    func performLogin() {
        guard !email.isEmpty else {
            return
        }
        inProgress = true

        PushNotifications.register {
            let createDeviceRequest = Current.store.state.session.latestDeviceToken.map {
                CreateDeviceRequest(token: $0)
            }
            Current.api.login(user: LoginUserRequest(
                email: self.email,
                device: createDeviceRequest
            )).task { result in
                switch result {
                case .success:
                    self.inProgress = false
                    self.shouldCheckEmails = true
                case let .failure(error) where error.reason.statusCode(403, 404):
                    Current.api.register(user: CreateUserRequest(device: createDeviceRequest, email: self.email))
                        .task(self.handleRegister(result:))
                case let .failure(error):
                    self.registrationError = error
                    self.inProgress = false
                }
            }
        }
    }
    
    func performRegister() {
        registrationError = nil
        inProgress = true

        PushNotifications.register {
            let createDeviceRequest = Current.store.state.session.latestDeviceToken.map {
                CreateDeviceRequest(token: $0)
            }
            Current.api.register(user: CreateUserRequest(device: createDeviceRequest))
                .task(self.handleRegister(result:))
        }
    }
    
    func openMailApp() {
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
         }
    }
    
    private func handleRegister(result: Result<TokenResponse, FetchingError>) {
        switch result {
        case .success:
            self.registrationError = nil
            DispatchQueue.main.async {
                self.onFinish()
            }
        case let .failure(error):
            self.inProgress = false
            self.registrationError = error
        }
    }
}


#if DEBUG
    struct RegistrationPage_Previews: PreviewProvider {
        static var previews: some View {
            RegistrationPage(onFinish: {})
        }
    }
#endif
