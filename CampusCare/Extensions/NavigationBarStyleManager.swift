//
//  NavigationBarStyleManager.swift
//  CampusCare
//
//  Created on 12/26/25.
//

import UIKit

/// Manages global navigation bar styling across the app
class NavigationBarStyleManager {
    
    static let shared = NavigationBarStyleManager()
    
    /// CampusCare brand color: RGB(15, 43, 89)
    let campusCareBlue = UIColor(red: 15/255, green: 43/255, blue: 89/255, alpha: 1.0)
    
    private init() {}
    
    /// Applies global navigation bar styling to all navigation bars in the app
    func applyGlobalNavigationBarStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = campusCareBlue
        
        // Title text attributes
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        // Large title text attributes
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // Button items color
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance = barButtonItemAppearance
        appearance.doneButtonAppearance = barButtonItemAppearance
        
        // Back button color
        UINavigationBar.appearance().tintColor = .white
        
        // Apply to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }
    
    /// Applies navigation bar styling to a specific navigation bar
    /// - Parameter navigationBar: The navigation bar to style
    func applyNavigationBarStyle(to navigationBar: UINavigationBar?) {
        guard let navBar = navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = campusCareBlue
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance = barButtonItemAppearance
        appearance.doneButtonAppearance = barButtonItemAppearance
        
        navBar.tintColor = .white
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
    }
}
