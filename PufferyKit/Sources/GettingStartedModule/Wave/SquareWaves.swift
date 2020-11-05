import SwiftUI

 struct SquareWaves: View {
    let amplitude = 10.0
    
    var body: some View {
        Image("GettingStartedAppIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 128)
            .padding()
//        Image("KugelfischAppTour")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(height: 80)
//            .transition(.slide)
//            .modifier(SwimAnimation(duration: 3, offset: 5))
//            .padding(30)
//            .background(
//                Color("Background")
////                LinearGradient(
////                    gradient: Gradient(colors: [
////                        Color("LagoonGreen"),
////                        Color("LogoonDeepBlue"),
////                    ]),
////                    startPoint: UnitPoint.bottomLeading,
////                    endPoint: .topTrailing
////                )
//                .cornerRadius(25)
//                .aspectRatio(contentMode: .fit)
//            )
//            .padding()
    }
 }
