import SwiftUI
import DesignSystem

public struct WelcomePage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    public init() {}

    public var body: some View {
        VStack {
            SlideImage("Welcome")
            
            VStack(alignment: .leading, spacing: 12) {
                InlineBulletPoint(
                    systemName: "1.circle.fill",
                    title: "GettingStarted.Welcome.CreateChannels"
                )
                InlineBulletPoint(
                    systemName: "2.circle.fill",
                    title: "GettingStarted.Welcome.SendNotification"
                )
                InlineBulletPoint(
                    systemName: "3.circle.fill",
                    title: "GettingStarted.Welcome.ShareChannel"
                )
                InlineBulletPoint(
                    systemName: "4.circle.fill",
                    title: "GettingStarted.Welcome.SubscribeChannels"
                )
            }.padding(.horizontal)
        }
        .navigationBarItems(trailing: Button(action: dismiss) {
            Text("GettingStarted.Welcome.LetsStart").fontWeight(.bold)
        })
        .record("welcome")
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
