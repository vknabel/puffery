//
//  GettingStartedPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import APIDefinition
import ComposableArchitecture
import SwiftUI
import UserNotifications
import RegistrationModule
import PufferyKit
import Pages
import DesignSystem

public struct GettingStartedPage: View {
    var onFinish: () -> Void

    @State var currentPageIndex = 0
    @State var registrationInProgress = false
    @State var registrationError: FetchingError?

    @State var registrationStore = ComposableArchitecture.Store<RegistrationState, RegistrationAction>(
        initialState: RegistrationState(),
        reducer: registrationReducer,
        environment: RegistrationEnvironment.live()
    )
    
    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    public var body: some View {
        NavigationView {
            ZStack {
                Pages(currentPage: $currentPageIndex) {
                    Slide($currentPageIndex) {
                        SlideImage("Logo")
                        
                        Text("GettingStarted.Splash.WelcomeToPuffery")
                            .font(.headline)
                    }
                    
                    Slide($currentPageIndex) {
                        SlideImage("Lost")
                        
                        MultilineBulletPoint(
                            systemName: "questionmark.circle.fill",
                            title: "GettingStarted.Splash.FirstQuestion"
                        )
                        MultilineBulletPoint(
                            systemName: "questionmark.circle.fill",
                            title: "GettingStarted.Splash.SecondQuestion"
                        )
                    }
                    .multilineTextAlignment(.center)
                    
                    Slide($currentPageIndex) {
                        SlideImage("Arrived")

                        VStack(spacing: 12) {
                            InlineBulletPoint(
                                systemName: "checkmark.seal.fill",
                                title: "GettingStarted.Benefits.First"
                            )
                            InlineBulletPoint(
                                systemName: "checkmark.seal.fill",
                                title: "GettingStarted.Benefits.Second"
                            )
                            InlineBulletPoint(
                                systemName: "checkmark.seal.fill",
                                title: "GettingStarted.Benefits.Third"
                            )
                            InlineBulletPoint(
                                systemName: "checkmark.seal.fill",
                                title: "GettingStarted.Benefits.Fourth"
                            )
                            InlineBulletPoint(
                                systemName: "checkmark.seal.fill",
                                title: "GettingStarted.Benefits.Fifth"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        RegistrationPage(onFinish: self.onFinish, store: self.registrationStore)
                    }
                }.edgesIgnoringSafeArea(.all)
            }
            .trackAppearence("getting-started", using: Current.tracker)
        }
    }
}

#if DEBUG
    struct GettingStarted_Previews: PreviewProvider {
        static var previews: some View {
            GettingStartedPage(onFinish: {})
        }
    }
#endif
