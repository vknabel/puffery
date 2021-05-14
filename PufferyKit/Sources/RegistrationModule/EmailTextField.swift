import SwiftUI
import DesignSystem
import ComposableArchitecture

struct EmailTextField: View {
    @Binding var email: String
    let onFinish: () -> Void
    let viewModel: ComposableArchitecture.ViewStore<RegistrationState, RegistrationAction>

    var body: some View {
        TextField("GettingStarted.Login.EmailPlaceholder", text: $email, onCommit: { viewModel.send(.shouldLogin(onFinish: self.onFinish)) })
            .textFieldStyle(RoundedTextFieldStyle())
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .disabled(viewModel.activity.inProgress)
    }
}
