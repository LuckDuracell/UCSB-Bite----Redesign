//
//  UCSB_BiteApp.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/4/23.
//

import SwiftUI

@main
struct UCSB_BiteApp: App {
    
    @StateObject var restVM = RestrictionsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(restVM: restVM)
                .preferredColorScheme(.light)
        }
    }
}

extension CGFloat {
    func safeWidth() -> CGFloat {
        if self > 600 {
            return 600
        }
        if self < -600 {
            return -600
        }
        return self
    }
}

extension UIScreen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}
