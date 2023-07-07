//
//  RestrictionsViewModel.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import Foundation
import SwiftUI

class RestrictionsViewModel: ObservableObject {
    
    @Published var restrictions: [Restriction] = [
        Restriction(name: "Egg", restrictionID: "allergy_-4", enabled: false, section: .protiens),
        Restriction(name: "Milk", restrictionID: "allergy_-3", enabled: false, section: .protiens),
        Restriction(name: "Pork", restrictionID: "allergy_86", enabled: false, section: .protiens),

        Restriction(name: "Fish", restrictionID: "allergy_-5", enabled: false, section: .oceanic),
        Restriction(name: "Shellfish", restrictionID: "allergy_-6", enabled: false, section: .oceanic),

        Restriction(name: "Oat", restrictionID: "allergy_29", enabled: false, section: .grains),
        Restriction(name: "Sesame", restrictionID: "allergy_69", enabled: false, section: .grains),
        Restriction(name: "Wheat", restrictionID: "allergy_-8", enabled: false, section: .grains, addedTerms: ["flour"]),

        Restriction(name: "Soy", restrictionID: "allergy_-7", enabled: false, section: .plants, addedTerms: ["soybean"]),
        Restriction(name: "Peanut", restrictionID: "allergy_-1", enabled: false, section: .plants, addedTerms: ["lentil"]),
        Restriction(name: "Tree Nut", restrictionID: "allergy_-2", enabled: false, section: .plants, addedTerms: ["almond", "brazil nut", "cashew", "hazelnut", "macadamia", "pecan", "pine nut", "pistachio", "walnut", "peanut"]),

        Restriction(name: "Gaucho Bright Bite", restrictionID: "pref_50", enabled: false, section: .choices),
        Restriction(name: "Halal", restrictionID: "pref_105", enabled: false, section: .choices),
        Restriction(name: "Kosher", restrictionID: "pref_106", enabled: false, section: .choices),
        Restriction(name: "Gluten", restrictionID: "pref_26", enabled: false, section: .choices),
        Restriction(name: "Vegan", restrictionID: "pref_8", enabled: false, section: .choices),
        Restriction(name: "Vegetarian", restrictionID: "pref_7", enabled: false, section: .choices)
    ]
    
    init() {
        loadRestrictions()
    }
    
    func loadRestrictions() {
        if let data = UserDefaults.standard.data(forKey: "RestrictionsArray"),
           let restrictionsFile = try? JSONDecoder().decode([Restriction].self, from: data) {
            restrictions = restrictionsFile
        }
    }
    
    func saveRestrictions() {
        if let data = try? JSONEncoder().encode(restrictions) {
            UserDefaults.standard.set(data, forKey: "RestrictionsArray")
        }
    }
    
}
