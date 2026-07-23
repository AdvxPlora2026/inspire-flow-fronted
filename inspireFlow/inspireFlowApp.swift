//
//  inspireFlowApp.swift
//  inspireFlow
//
//  Created by 叶文峰 on 2026/7/23.
//

import SwiftUI

@main
struct inspireFlowApp: App {
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .transition(.opacity)
                } else {
                    StartView(
                        hasCompletedOnboarding: $hasCompletedOnboarding
                    )
                    .transition(.opacity)
                }
            }
        }
    }
}

#Preview("Main Content") {
    StartView(
        hasCompletedOnboarding: .constant(true)
    )
}
