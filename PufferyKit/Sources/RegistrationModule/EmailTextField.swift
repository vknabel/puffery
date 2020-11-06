import SwiftUI
import DesignSystem
import ComposableArchitecture

struct EmailTextField: View {
    var onFinish: () -> Void
    let viewModel: ComposableArchitecture.ViewStore<RegistrationState, RegistrationAction>

    var body: some View {
        TextField("GettingStarted.Login.EmailPlaceholder", text: Binding(get: { viewModel.email }, set: { viewModel.send(.updateEmail($0)) }), onCommit: { viewModel.send(.shouldLogin(onFinish: self.onFinish)) })
            .textFieldStyle(RoundedTextFieldStyle())
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .disabled(viewModel.activity.inProgress)
    }
}
