//
//  CafeteriaViewModel.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import Foundation
import SwiftUI
import Erik


class CafeteriaViewModel: ObservableObject {
    
    @Published var allCafeterias: [Cafeteria]
    @Published var currentCafeteria: Cafeteria = Cafeteria(name: .none, status: .unavailable, mealTimes: [])
    @Published var restVM: RestrictionsViewModel
    @Published var currentMealTime: MealTime?
    
    @Published var erik = Erik()
    
    let innerTitleClass = "cbo_nn_itemGroupRow bg-faded"
    let innerFoodClass = ".cbo_nn_itemHover"
    let urlString = "http://nutrition.info.dining.ucsb.edu/NetNutrition/1"
    
    init(restVM: RestrictionsViewModel) {
        
        self.restVM = restVM
        
        var cafs: [Cafeteria] = []
        for caf in SelectedCafeteria.allCases {
            cafs.append(Cafeteria(name: caf, status: .closed, mealTimes: caf == .ortega ? [.constant] : []))
        }
        self.allCafeterias = cafs
        
        let hour = Calendar.current.component(.hour, from: .now)
        let minutes = (hour * 60) + Calendar.current.component(.minute, from: .now)
        if minutes < 600 {
            self.currentMealTime = .breakfast
        } else if minutes < 900 {
            self.currentMealTime = .lunch
        } else {
            self.currentMealTime = .dinner
        }
    }
    
    func restrictionsHighlighted(_ ing: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: ing)
     
        for rest in restVM.restrictions {
            let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            var searchRange = ing.startIndex..<ing.endIndex
             
            while let range = ing.range(of: rest.name, options: options, range: searchRange) {
                attributedString.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSRange(range, in: ing))
                searchRange = range.upperBound..<ing.endIndex
            }
     
            for term in rest.addedTerms {
                searchRange = ing.startIndex..<ing.endIndex
                while let range = ing.range(of: term, options: options, range: searchRange) {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.yellow, range: NSRange(range, in: ing))
                    searchRange = range.upperBound..<ing.endIndex
                }
            }
        }
     
        return attributedString
    }


    func setCafeteriaSchedule(caf: Cafeteria) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: .now)
        let hour = Calendar.current.component(.hour, from: .now)
        let minutes = (hour * 60) + Calendar.current.component(.minute, from: .now)
        switch caf.name {
        case .dlg, .carillo, .portola:
            if weekday != 1 && weekday != 7 {
                //weekdays
                if minutes >= 435 && minutes < 600 {
                    return true
                }
                if minutes >= 660 && minutes < 900 {
                    return true
                }
                if minutes >= 1020 && minutes < 1230 {
                    return true
                }
            } else {
                //weekends
                if minutes >= 600 && minutes < 840 {
                    return true
                }
                if minutes >= 1020 && minutes < 1230 {
                    return true
                }
            }
        default:
            if minutes >= 600 && minutes <= 1140 {
                return true
            }
        }
        return false
    }


    func parseCurrentDocument(_ delay: Double, newCompletionHandler: @escaping (Document) -> Void ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.erik.currentContent { obj, error in
                if let e = error {
                    print(e.localizedDescription)
                } else if let doc = obj {
                    newCompletionHandler(doc)
                }
            }
        })
    }
    func restrictionClick(_ restrictionButton: Element?, restriction: Restriction) {
        if restriction.enabled {
            if !restrictionButton!.className!.contains("active") {
                restrictionButton?.click()
            }
        } else {
            if restrictionButton!.className!.contains("active") {
                restrictionButton?.click()
            }
        }
    }


    func checkCafeterias() {
        erik.visit(urlString: urlString) { obj, error  in
            if let e = error {
                print("checkCafeterias + " + e.localizedDescription)
            } else if let doc = obj {
                let buttons = doc.querySelectorAll(".text-muted")
                for i in self.allCafeterias.indices {
                    let cafeteriaDailyMenu = buttons.first(where: { elem in
                        if let txt = elem.text {
                            return txt.contains("\(self.allCafeterias[i].name.rawValue)'s Daily Menu")
                        } else {
                            return false
                        }
                    })
                    if self.setCafeteriaSchedule(caf: self.allCafeterias[i]) {
                        if cafeteriaDailyMenu != nil {
                            withAnimation(.easeIn) {
                                self.allCafeterias[i].status = .open
                            }
                        } else {
                            withAnimation(.easeIn) {
                                self.allCafeterias[i].status = .unavailable
                            }
                        }
                    }
                }
            }
        }
    }
    func openMenus() {
        parseCurrentDocument(0, newCompletionHandler: { doc in
            let buttons = doc.querySelectorAll(".text-muted")
            
            if let cafeteriaDailyMenu = buttons.first(where: { elem in
                if let txt = elem.text {
                    return txt.contains("\(self.currentCafeteria.name.rawValue)'s Daily Menu")
                } else {
                    return false
                }
            }) {
                cafeteriaDailyMenu.click()
                self.parseCurrentDocument(0.5, newCompletionHandler: { _ in
                    if self.currentCafeteria.name == .ortega {
                        self.parseSpecificMenu()
                    } else {
                        self.selectMealSlot()
                    }
                })
            }
        })
    }
    func selectMealSlot() {
        parseCurrentDocument(0.5, newCompletionHandler: { doc in
            let cardBlock = doc.querySelector(".card-block")
            let today = cardBlock?.querySelectorAll(".list-group-item") ?? []
            self.currentCafeteria.mealTimes = []
            var newMealTimes: [MealTime] = []
            var lastMealTime: MealTime = .constant
            if today.count > 0 {
                for mealTime in today {
                    let text = mealTime.text ?? ""
                    let mealTimeText = text.split(separator: "-").last?.description ?? ""
                    for i in MealTime.allCases {
                        if i.rawValue == mealTimeText {
                            withAnimation(.bouncy) {
                                newMealTimes.append(i)
                                lastMealTime = i
                            }
                        }
                    }
                }
                if newMealTimes != self.currentCafeteria.mealTimes {
                    withAnimation(.bouncy) {
                        self.currentCafeteria.mealTimes = newMealTimes
                    }
                }
                if self.currentMealTime != nil {
                    if !self.currentCafeteria.mealTimes.contains(self.currentMealTime!) {
                        self.currentMealTime = lastMealTime
                    }
                } else {
                    self.currentMealTime = lastMealTime
                }
                let selectedMealButton = today.first(where: { elem in
                    let text = elem.text ?? ""
                    let mealTimeText = text.split(separator: "-").last?.description ?? ""
                    return (mealTimeText == self.currentMealTime?.rawValue ?? "")
                })
                selectedMealButton?.click()
                self.parseSpecificMenu()
            } else {
                print("Error: Today Does Not Exist")
            }
        })
    }
    func parseSpecificMenu() {
        parseCurrentDocument(0.5, newCompletionHandler: { doc in
            for rest in self.restVM.restrictions {
                let restButton = doc.querySelector("#\(rest.restrictionID)")
                self.restrictionClick(restButton, restriction: rest)
                usleep(10000)
            }
        })
        parseCurrentDocument(1.5, newCompletionHandler: { doc in
            let foodTable = doc.querySelectorAll(".table").last
            if foodTable != nil {
                withAnimation(.spring(duration: 0.5)) {
                    //removes "Loading" from the cafeteria page
                    self.currentCafeteria.inner_cafs.removeAll()
                }
                let menu = foodTable?.querySelectorAll(".cbo_nn_itemGroupRow, .cbo_nn_itemPrimaryRow, .cbo_nn_itemAlternateRow")
                var innerCaf = InnerCafeteria(name: "", menu: [])
                
                for object in menu ?? [] {
                    if object.className == self.innerTitleClass {
                        if !innerCaf.menu.isEmpty {
                            //every time a new inner cafeteria appears, check if there was one before it being generated and append it to display if so
                            withAnimation(.spring(duration: 1)) {
                                self.currentCafeteria.inner_cafs.append(innerCaf)
                            }
                            innerCaf.menu = []
                        }
                        innerCaf.name = object.text ?? "Error"
                    } else {
                        if let food = object.querySelector(self.innerFoodClass)?.text {
                            innerCaf.menu.append(FoodItem(name: food, ingredients: ""))
                        }
                    }
                }
                //appends the final inner cafeteria, since the appending process happens at the start of every new one, I include this to catch that last silly little guy
                withAnimation(.spring(duration: 1)) {
                    self.currentCafeteria.inner_cafs.append(innerCaf)
                }
            }
        })
    }
}
