//
//  DietaryRestrictionsView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct DietaryRestrictionsView: View {
    
    @ObservedObject var cafeVM: CafeteriaViewModel
    @ObservedObject var restVM: RestrictionsViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial.opacity(1))
                .brightness(-0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSettings = false
                        cafeVM.openMenus()
                    }
                }
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Dietary Restrictions")
                        .font(.title3.bold())
                    Divider()
                        .background(.gray.opacity(0))
                    Text("These toggles will attempt to filter dietary restrictions. We recommend that users also tap foods and read the ingredient list themselves. All allergy data is scrubbed from the UCSB NetNutrition website, which warns that it anything is subject to change and the information may at times be inaccurate. Stay safe!")
                        .font(.caption2)
                        .brightness(-0.1)
                    Divider()
                        .background(.gray.opacity(0))
                    VStack(spacing: 5) {
                        ForEach(RestrictionSection.allCases, id: \.self) { section in
                            VStack {
                                ForEach($restVM.restrictions, id: \.self) { $restriction in
                                    if restriction.section == section {
                                        Toggle(restriction.name, isOn: $restriction.enabled)
                                            .font(.headline)
                                            .onChange(of: restVM.restrictions) { _, _ in
                                                restVM.saveRestrictions()
                                                withAnimation(.bouncy) {
                                                    cafeVM.currentCafeteria.inner_cafs = [InnerCafeteria(name: "Loading...", menu: [])]
                                                }
                                            }
                                            .tint(.yellow)
                                    }
                                }
                            }
                            .padding(10)
                            .glassify()
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(30)
            } .frame(minHeight: 100, maxHeight: 600)
            .foregroundStyle(.white)
            .glassify()
            .padding()
        } .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(showSettings ? 1 : 0)
    }
}

#Preview {
    DietaryRestrictionsView(cafeVM: CafeteriaViewModel(restVM: RestrictionsViewModel()), restVM: RestrictionsViewModel(), showSettings: .constant(true))
}
