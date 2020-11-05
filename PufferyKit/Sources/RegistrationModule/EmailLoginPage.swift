import SwiftUI
import ComposableArchitecture
import DesignSystem
import PufferyKit

struct EmailLoginPage: View {
    var onFinish: () -> Void
    let store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>
    @ObservedObject var globalStore = Current.store
    
    var body: some View {
        WithViewStore(self.store) { viewModel in
            VStack(alignment: .center) {
                SlideImage("Welcome")
                
                EmailTextField(onFinish: onFinish, store: store)
                
                Button(action: { viewModel.send(.shouldLogin(onFinish: self.onFinish)) }) {
                    Text("GettingStarted.Login.Perform")
                }
                    .buttonStyle(RoundedButtonStyle(animation: nil))
                    .transition(.opacity)
                    .disabled(viewModel.activity.inProgress)
                
                HStack {
                    RegistrationTerms()
                        .padding(.vertical)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .multilineTextAlignment(.leading)
            .sheet(isPresented: viewModel.binding(
                get: { $0.shouldCheckEmails && self.globalStore.state.session.sessionToken != nil },
                send: RegistrationAction.showCheckEmails
            )) {
                EmailConfirmationPage(email: viewModel.email)
            }
        }
    }
}

private struct LoginButtonId: Identifiable, Hashable {
    var id = #filePath
}
