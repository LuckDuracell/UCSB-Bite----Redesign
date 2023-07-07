//
//  CafeteriaView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct CafeteriaView: View {
    
    @ObservedObject var cafeVM: CafeteriaViewModel
    @Binding var ingredientsOverlay: (name: String, text: NSAttributedString, show: Bool)
    
    var body: some View {
        VStack {
            HStack {
                ForEach(cafeVM.currentCafeteria.mealTimes, id: \.self) { mealTimeOption in
                    Button {
                        withAnimation(.bouncy) {
                            cafeVM.currentMealTime = mealTimeOption
                            cafeVM.currentCafeteria.inner_cafs = [InnerCafeteria(name: "Loading...", menu: [])]
                        }
                        cafeVM.openMenus()
                    } label: {
                        Text(mealTimeOption.rawValue)
                            .padding(12)
                            .glassify()
                            .shadow(color: cafeVM.currentMealTime == mealTimeOption ? .yellow.opacity(0.4) : .clear, radius: 3)
                            .scaleEffect(cafeVM.currentMealTime == mealTimeOption ? 1.05 : 1)
                    }
                }
            }
            .frame(maxWidth: 350, alignment: .top)
            .frame(height: 41)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .glassify()
            .padding(.horizontal)
            .padding(.top, -25)
            VStack {
                Text("Cafeteria Menu")
                    .font(.largeTitle.bold())
                Text(cafeVM.currentCafeteria.name != .none ? "" : cafeVM.currentCafeteria.name.rawValue)
                    .foregroundStyle(.white.opacity(0.8))
                //                .animation(.easeInOut(duration: 0.35).delay(0.85), value: currentCafeteria)
                    .font(.headline)
                VStack(spacing: 20) {
                    ForEach($cafeVM.currentCafeteria.inner_cafs, id: \.self) { $innerCaf in
                        VStack {
                            Text(innerCaf.name)
                                .frame(maxWidth: 330, alignment: .leading)
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                ForEach($innerCaf.menu, id: \.self) { $menuItem in
                                    Button {
                                        cafeVM.parseCurrentDocument(0, newCompletionHandler: { doc in
                                            let foods = doc.querySelectorAll(cafeVM.innerFoodClass)
                                            
                                            let object = foods.first(where: { elem in
                                                elem.text == menuItem.name
                                            })
                                            object?.click()
                                            cafeVM.parseCurrentDocument(0.5, newCompletionHandler: { doc in
                                                if let ingredients = doc.querySelector(".cbo_nn_LabelIngredients")?.text {
                                                    if let contains = doc.querySelector(".cbo_nn_LabelAllergens")?.text {
                                                        menuItem.ingredients = """
                                                Contains: \(contains)
                                                Ingredients: \(ingredients)
                                                """
                                                    } else {
                                                        menuItem.ingredients = "Ingredients: \(ingredients)"
                                                    }
                                                    ingredientsOverlay.text = cafeVM.restrictionsHighlighted(menuItem.ingredients)
                                                    ingredientsOverlay.name = menuItem.name
                                                    withAnimation(.easeInOut(duration: 0.4)) {
                                                        ingredientsOverlay.show = true
                                                    }
                                                }
                                            })
                                        })
                                    } label: {
                                        Text(menuItem.name)
                                            .padding(4)
                                            .frame(width: 150, height: 80)
                                            .foregroundStyle(.secondary)
                                            .bold()
                                            .brightness(0.4)
                                            .background(.ultraThinMaterial.opacity(0.6))
                                            .clipShape(.rect(cornerRadius: 10))
                                    }
                                }
                            } .padding(.horizontal)
                        }
                    }
                } .padding(.top)
            }
            .frame(maxWidth: 350, minHeight: 450, alignment: .top)
            .padding(.vertical, 30)
            .foregroundColor(.white)
            .glassify()
            .padding(.horizontal)
        }
    }
}

#Preview {
    CafeteriaView(cafeVM: CafeteriaViewModel(restVM: RestrictionsViewModel()), ingredientsOverlay: .constant((name: "", text: NSAttributedString(string: ""), show: false)))
}
