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

struct GettingStartedPage: View {
    var onFinish: () -> Void

    @State var registrationInProgress = false
    @State var registrationError: FetchingError?

    @State var registrationStore = ComposableArchitecture.Store<RegistrationState, RegistrationAction>(
        initialState: RegistrationState(),
        reducer: registrationReducer,
        environment: RegistrationEnvironment.live()
    )

    var body: some View {
        Waves {
            RegistrationPage(onFinish: self.onFinish, store: self.registrationStore)
        }.trackAppearence("getting-started", using: Current.tracker)
    }
}

#if DEBUG
    struct GettingStarted_Previews: PreviewProvider {
        static var previews: some View {
            GettingStartedPage(onFinish: {})
        }
    }
#endif
