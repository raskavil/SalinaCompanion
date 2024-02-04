//
//  SalinaCompanionApp.swift
//  SalinaCompanion
//
//  Created by Vilém Raška on 01.02.2024.
//

import SwiftUI
import SwiftData

@main
struct SalinaCompanionApp: App {
    
    private let dataManager: DataManager = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Stop.self, Timestamp.self, LineAlias.self]) { result in
            if case .success(let container) = result {
                Task.detached(priority: .userInitiated) {
                    self.dataManager.set(container)
                }
            }
        }
    }
    
    init() {
        Font.registerDesignFonts()
        UINavigationBar.appearance().largeTitleTextAttributes = UIFont(name: "SourceSans3-Bold", size: 34).map { [.font: $0]}
        UITabBarItem.appearance().setTitleTextAttributes(UIFont(name: "SourceSans3-Medium", size: 12).map { [.font: $0] }, for: [])
    }
}
