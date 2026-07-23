//
//  inspireFlowApp.swift
//  inspireFlow
//
//  Created by 叶文峰 on 2026/7/23.
//

import SwiftUI

@main
struct inspireFlowApp: App {
    @StateObject private var appStore = AppStore()
    @StateObject private var session = AppSession()

    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            RootView(hasCompletedOnboarding: $hasCompletedOnboarding)
            .environmentObject(appStore)
            .environmentObject(session)
        }
    }
}

#Preview("Main Content") {
    StartView(
        hasCompletedOnboarding: .constant(true)
    )
    .environmentObject(AppStore())
    .environmentObject(AppSession())
}
