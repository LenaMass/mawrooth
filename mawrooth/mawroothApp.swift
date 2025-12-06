import SwiftUI
import UIKit   // 👈 add this

@main
struct MawroothApp: App {
    
    init() {
        // Configure a transparent navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        // 👇 Make all bar button items use "plain" style (no circle / pill)
        let plainButtons = UIBarButtonItemAppearance(style: .plain)
        appearance.buttonAppearance = plainButtons
        appearance.doneButtonAppearance = plainButtons
        appearance.backButtonAppearance = plainButtons
        
        // Apply to all navigation bars in the app
        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

