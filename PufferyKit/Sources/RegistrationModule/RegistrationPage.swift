import ComposableArchitecture
import SwiftUI
import PlatformSupport
import DesignSystem
import PufferyKit

public struct RegistrationPage: View {
    var onFinish: () -> Void
    
    @ObservedObject private var keyboard = Keyboard()
    let store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>
    
    public init(onFinish: @escaping () -> Void, store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>) {
        self.onFinish = onFinish
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewModel in
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    SlideImage("Privacy")
                        .show(when: !self.keyboard.isActive)
                }
                Text("GettingStarted.Registration.PrivacyOptionalEmail")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .sheet(isPresented: Binding(get: { viewModel.showsWelcomePage }, set: { viewModel.send(.showWelcomePage($0)) })) {
                        NavigationView {
                            WelcomePage()
                        }
                    }

                EmailTextField(onFinish: onFinish, viewModel: viewModel)
                
                Text("GettingStarted.Registration.EmailOptIn")
                    .opacity(0.5)
                
                if viewModel.email.isEmpty || keyboard.isActive {
                    Button(action: { viewModel.send(.shouldRegister(onFinish: self.onFinish)) }) {
                        Text("GettingStarted.Registration.Anonymous")
                    }
                        .buttonStyle(RoundedButtonStyle())
                        .transition(.opacity)
                        .disabled(viewModel.activity.inProgress)
                } else {
                    Button(action: { viewModel.send(.shouldRegister(onFinish: self.onFinish)) }) {
                        Text("GettingStarted.Registration.WithEmail")
                    }
                        .buttonStyle(RoundedButtonStyle())
                        .transition(.opacity)
                        .disabled(viewModel.activity.inProgress || viewModel.email.isEmpty)
                }
                RegistrationTerms()
                    .padding(.vertical)
                                
                HStack {
                    VStack { Divider() }
                    Text("GettingStarted.Registration.RegistrationLoginDelimiter")
                        .italic()
                        .font(.headline)
                    VStack { Divider() }
                }
                .show(when: !self.keyboard.isActive).transition(.opacity)
                
                NavigationLink(
                    "GettingStarted.Registration.LogInWithEmail",
                    destination: EmailLoginPage(onFinish: onFinish, store: store)
                )
                    .buttonStyle(RoundedButtonStyle())
                    .accentColor(Color.gray)
                    .opacity(0.5)
                    .show(when: !self.keyboard.isActive)
            }
            .padding(.horizontal, 20)
            .multilineTextAlignment(.leading)
            .alert(item: Binding.constant(viewModel.activity.failedError)) {
                Alert(
                    title: Text("GettingStarted.Registration.Failed"),
                    message: Text($0.localizedDescription)
                )
            }
        }
    }
}
