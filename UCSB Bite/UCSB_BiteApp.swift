//
//  UCSB_BiteApp.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/4/23.
//

import SwiftUI

@main
struct UCSB_BiteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(foodSlot: .breakfast, foodSlotString: "Breakfast")
        }
    }
}
