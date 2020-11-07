import SwiftUI
import ComposableArchitecture
import DesignSystem
import PufferyKit

struct EmailLoginPage: View {
    var onFinish: () -> Void
    let store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>
    
    var body: some View {
        WithViewStore(self.store) { viewModel in
            Slide(.constant(0), imageNamed: "Welcome", showsPageControls: false) {
                EmailTextField(onFinish: onFinish, viewModel: viewModel)
                
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
        }
    }
}
