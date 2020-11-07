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

    var registrationStore: ComposableArchitecture.Store<RegistrationState, RegistrationAction>
    
    public init(store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>, onFinish: @escaping () -> Void) {
        registrationStore = store
        self.onFinish = onFinish
    }

    public var body: some View {
        NavigationView {
            ZStack {
                Pages(currentPage: $currentPageIndex) {
                    Slide($currentPageIndex, imageNamed: "Logo") {
                        Text("GettingStarted.Splash.WelcomeToPuffery")
                            .font(.headline)
                    }
                    
                    Slide($currentPageIndex, imageNamed: "Lost") {
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
                    
                    Slide($currentPageIndex, imageNamed: "Arrived") {
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
                    
                    Slide($currentPageIndex, imageNamed: "Privacy", showsPageControls: false) {
                        RegistrationPage(onFinish: self.onFinish, store: self.registrationStore)
                    }
                }.edgesIgnoringSafeArea(.all)
            }
            .trackAppearence("getting-started", using: Current.tracker)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
    struct GettingStarted_Previews: PreviewProvider {
        static var previews: some View {
            GettingStartedPage(
                store: ComposableArchitecture.Store<RegistrationState, RegistrationAction>(
                    initialState: RegistrationState(),
                    reducer: registrationReducer,
                    environment: RegistrationEnvironment.live()
                ),
                onFinish: {}
            )
        }
    }
#endif
