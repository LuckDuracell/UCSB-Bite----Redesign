//
//  ContentView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/4/23.
//

import SwiftUI
import Erik

struct ContentView: View {
    
    @State var loading = false
    @State var slotSelected: Bool = false
    
    @State var isRotating = 0.0
    
    @State var showIngredients = false
    @State var selectedFood = Food(name: "empty", ingredients: "empty")
    
    @State var foodSlot: FoodSlot
    @State var foodSlotString: String
    
    @State var foodList: [Cafeteria] = []
    
    init(foodSlot: FoodSlot, foodSlotString: String) {
        let time = Calendar.current.component(.hour, from: .now)
        if time >= 15 {
            _foodSlot = State(initialValue: .dinner)
            _foodSlotString = State(initialValue: "Dinner")
        } else if time >= 11 {
            _foodSlot = State(initialValue: .lunch)
            _foodSlotString = State(initialValue: "Lunch")
        } else {
            _foodSlot = State(initialValue: .breakfast)
            _foodSlotString = State(initialValue: "Breakfast")
        }
    }
    
    
    func connectToUSCB() {
        withAnimation {
            slotSelected = false
            loading = true
        }
        if !foodList.isEmpty {
            withAnimation {
                foodList = []
            }
            openNutritionNet()
        } else {
            openNutritionNet()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            selectMealSlot()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            grabFood()
        })
    }
    
    func openNutritionNet() {
        let url = URL(string: "http://nutrition.info.dining.ucsb.edu/NetNutrition/1")!
        Erik.visit(url: url) { obj, error  in
            if let e = error {
                print(e.localizedDescription)
            } else if let doc = obj {
                let buttons = doc.querySelectorAll(".text-muted")
                let deLaGuerra = buttons.first(where: { elem in
                    if let txt = elem.text{
                        return txt.contains("De La Guerra's Daily Menu")
                    } else {
                        return false
                    }
                })
                deLaGuerra?.click()
            }
        }
    }
    
    func selectMealSlot() {
        Erik.currentContent() { obj, error in
            if let doc = obj {
                let cardBlock = doc.querySelector(".card-block")
                let today = cardBlock?.querySelectorAll(".list-group-item") ?? []
                if today.count > 0 {
                    switch foodSlot {
                    case .breakfast:
                        today[0].click()
                    case .lunch:
                        today[1].click()
                    case .dinner:
                        today[2].click()
                    }
                    slotSelected = true
                } else {
                    sleep(1)
                    selectMealSlot()
                }
            }
        }
    }
    
    func grabFood() {
        Erik.currentContent() { (obj, error) -> Void in
            if let e = error {
                print(e.localizedDescription)
            }
            else if let doc = obj {
                
                let peanutButton = doc.querySelector("#allergy_-1")
                if !(peanutButton?.className?.contains("active") ?? true) {
                    peanutButton?.click()
                }
                
                let foodTable = doc.querySelectorAll(".table").last
                if foodTable != nil && slotSelected {
                    let menu = foodTable?.querySelectorAll(".cbo_nn_itemGroupRow, .cbo_nn_itemPrimaryRow, .cbo_nn_itemAlternateRow")
                    var currentCafeteria = Cafeteria(title: "", food: [])
                    for object in menu! {
                        if object.className! == "cbo_nn_itemGroupRow bg-faded" {
                            if currentCafeteria != Cafeteria(title: "", food: []) {
                                foodList.append(currentCafeteria)
                                currentCafeteria = Cafeteria(title: "", food: [])
                            }
                            currentCafeteria.title = object.text!
                        } else {
                            if let food = object.querySelector(".cbo_nn_itemHover")?.text {
                                withAnimation {
                                    currentCafeteria.food.append(food)
                                }
                            }
                        }
                    }
                    foodList.append(currentCafeteria)
                    withAnimation {
                        loading = false
                    }
                } else {
                    sleep(1)
                    grabFood()
                }
            }
        }
    }
    
    func grabIngredients() {
        Erik.currentContent() { obj, error in
            if let e = error {
                print(e.localizedDescription)
            } else if let doc = obj {
                let ingredients = doc.querySelector(".cbo_nn_LabelIngredients")
                if let ing = ingredients?.text {
                    withAnimation {
                        selectedFood.ingredients = ing
                    }
                } else if showIngredients {
                    sleep(1)
                    grabIngredients()
                }
            }
        }
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    ForEach(foodList, id: \.self) { menu in
                        VStack(alignment: .leading, content: {
                            Text(menu.title)
                                .font(.title3.bold())
                                .padding(3)
                            ForEach(menu.food, id: \.self, content: { foodItem in
                                Text("   • " + foodItem)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: UIScreen.width * 0.85, alignment: .leading)
                                    .foregroundStyle(.gray)
                                    .onTapGesture(perform: {
                                        selectedFood.ingredients = ""
                                        selectedFood.name = foodItem
                                        Erik.visit(url: URL(string: "https://nutrition.info.dining.ucsb.edu/NetNutrition/1")!) { obj, error in
                                            if let e = error {
                                                print(e.localizedDescription)
                                            } else if let doc = obj {
                                                let foodButtons = doc.querySelectorAll(".cbo_nn_itemHover")
                                                let foodButton = foodButtons.first(where: { food in
                                                    food.text?.contains(foodItem) ?? false
                                                })
                                                foodButton?.click()
                                            }
                                        }
                                        grabIngredients()
                                        withAnimation {
                                            showIngredients = true
                                        }
                                    })
                            })
                        })
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(15)
                    }
                } .navigationTitle("UCSB Bite")
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading, content: {
                            Picker("Meal", selection: $foodSlotString, content: {
                                ForEach(["Breakfast", "Lunch", "Dinner"], id: \.self, content: { slot in
                                    Text(slot)
                                })
                            })
                            .foregroundColor(Color("seaBlue"))
                            .padding(3)
                            .cornerRadius(5)
                            .onChange(of: foodSlotString, perform: { slot in
                                switch slot {
                                case "Breakfast":
                                    foodSlot = .breakfast
                                case "Lunch":
                                    foodSlot = .lunch
                                default:
                                    foodSlot = .dinner
                                }
                                connectToUSCB()
                            })
                        })
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Image(systemName: "fork.knife.circle.fill")
                                .rotation3DEffect(.degrees(isRotating), axis: (x: 1, y: 1, z: 1))
                                .onAppear(perform: {
                                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false), {
                                        isRotating += 360.0
                                    })
                                })
                                .opacity(loading ? 1 : 0)
                                .foregroundColor(Color("seaBlue"))
                        })
                    })
            }
        }
        .onAppear(perform: {
            connectToUSCB()
        })
        .overlay {
            ZStack {
                Rectangle()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture(perform: {
                        withAnimation {
                            showIngredients = false
                        }
                    })
                    .background(.ultraThinMaterial)
                    .opacity(0.8)
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(selectedFood.name)
                            .bold()
                        Divider()
                        Text(selectedFood.ingredients)
                    }
                } .frame(maxHeight: UIScreen.height * 0.5)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(15)
                .padding()
            } .opacity(showIngredients ? 1 : 0)
                .disabled(!showIngredients)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(foodSlot: .breakfast, foodSlotString: "Breakfast")
    }
}

enum FoodSlot {
    case breakfast
    case lunch
    case dinner
}

struct Cafeteria: Hashable {
    var title: String
    var food: [String]
}

extension UIScreen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

struct Food {
    var name: String
    var ingredients: String
}
