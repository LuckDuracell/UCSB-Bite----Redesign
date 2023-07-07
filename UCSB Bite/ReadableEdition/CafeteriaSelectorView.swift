//
//  CafeteriaSelectorView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct CafeteriaSelectorView: View {
    
    @ObservedObject var cafeVM: CafeteriaViewModel
    
    @Binding var showCafeteria: Bool
    
    var body: some View {
        VStack {
            Text("Cafeterias")
                .font(.largeTitle.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(cafeVM.allCafeterias, id: \.self) { caf in
                    if caf.name != .none {
                        CafeteriaButton(caf)
                    }
                }
            } .padding(.horizontal, 15)
        }
        .frame(maxWidth: 350)
        .padding(.vertical, 30)
        .foregroundColor(.white)
        .glassify()
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func CafeteriaButton(_ cafeteria: Cafeteria) -> some View {
        Button {
            if cafeteria.status != .unavailable {
                withAnimation(.bouncy(duration: 1)) {
                    cafeVM.currentCafeteria = cafeteria
                    showCafeteria = true
                }
                DispatchQueue.main.async {
//                    selectMealSlot()
                    cafeVM.openMenus()
                }
            }
        } label: {
            VStack {
                Text(cafeteria.name.rawValue)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                HStack {
                    Text("Status:")
                    Text(cafeteria.status.rawValue)
                        .foregroundStyle(cafeteria.status == .open ? .green : .red)
                }
            }
            .frame(width: 150, height: 80)
            .foregroundStyle(.secondary)
            .bold()
            .brightness(0.3)
        }
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(.rect(cornerRadius: 10))
    }
    
}

#Preview {
    CafeteriaSelectorView(cafeVM: CafeteriaViewModel(restVM: RestrictionsViewModel()), showCafeteria: .constant(false))
}
