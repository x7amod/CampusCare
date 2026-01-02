//
//  RoleTabBarController.swift
//  CampusCare
//
//  Created by m1 on 02/01/2026.
//

import UIKit

class RoleTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        replaceMoreTab()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // Apply to all states
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        
        // Ensure the tab bar is always white
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }

    private func replaceMoreTab() {
        guard var tabs = viewControllers else { return }
        let moreIndex = 2

        let moreNav = UIStoryboard(name: "More", bundle: nil)
            .instantiateInitialViewController() as! UINavigationController

        moreNav.tabBarItem = tabs[moreIndex].tabBarItem
        tabs[moreIndex] = moreNav
        viewControllers = tabs
    }
}
