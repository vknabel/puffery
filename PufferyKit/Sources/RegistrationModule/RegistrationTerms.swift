import SwiftUI
import PrivacyPolicyModule

struct RegistrationTerms: View {
    @State var displaysTermsAndConditions = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button("GettingStarted.Registration.TermsAndConditions") {
                self.displaysTermsAndConditions.toggle()
            }.sheet(isPresented: self.$displaysTermsAndConditions) {
                NavigationView {
                    TermsAndConditions()
                }.navigationViewStyle(StackNavigationViewStyle())
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(0.5)
            .font(.footnote)
        }
    }
}
