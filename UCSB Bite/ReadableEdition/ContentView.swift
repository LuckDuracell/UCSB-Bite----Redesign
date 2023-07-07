//
//  ContentView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI
import Erik

struct ContentView: View {
    
    @State private var showCafeteria: Bool = false
    
    @State private var ingredientsOverlay: (name: String, text: NSAttributedString, show: Bool) = (name: "", text: NSAttributedString(string: ""), show: false)
    
    @State private var showSettings = false
    @State private var showSchedule = false
    
    @ObservedObject var restVM: RestrictionsViewModel
    @StateObject var cafeVM: CafeteriaViewModel
    
    @State private var drag: CGFloat = 0
    
    init(restVM: RestrictionsViewModel) {
        self.restVM = restVM
        _cafeVM = StateObject(wrappedValue: CafeteriaViewModel(restVM: restVM))
    }
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                HeaderView(showSchedule: $showSchedule, showSettings: $showSettings)
                ZStack(alignment: .top) {
                    CafeteriaSelectorView(cafeVM: cafeVM, showCafeteria: $showCafeteria)
                        .offset(x: showCafeteria ? -UIScreen.width * 0.92 + (drag.safeWidth() * 0.1) : drag.safeWidth() * 0.1)
                        .padding(.top, 50)
                    CafeteriaView(cafeVM: cafeVM, ingredientsOverlay: $ingredientsOverlay)
                        .offset(x: !showCafeteria ? UIScreen.width * 0.92 + (drag.safeWidth() * 0.1) : drag.safeWidth() * 0.1)
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            drag = gesture.translation.width
                        }
                        .onEnded { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                                if drag > 25 {
                                    withAnimation(.bouncy(duration: 1)) {
                                        reader.scrollTo(0)
                                        showCafeteria = false
                                    }
                                }
                                if drag < -25 && cafeVM.currentCafeteria.status == .open {
                                    withAnimation(.bouncy(duration: 1)) {
                                        reader.scrollTo(0)
                                        showCafeteria = true
                                    }
                                }
                                withAnimation(.bouncy(duration: 1)) {
                                    drag = 0
                                }
                            })
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image(.sandbg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .offset(y: showCafeteria ? 20 : -120)
            }
            .overlay (
                IngredientsView(ingredientsOverlay: $ingredientsOverlay)
            )
            .overlay (
                ScheduleView(showSchedule: $showSchedule)
            )
            .overlay (
                DietaryRestrictionsView(cafeVM: cafeVM, restVM: restVM, showSettings: $showSettings)
            )
        }
        .saturation(1.2)
    }
}

#Preview {
    ContentView(restVM: RestrictionsViewModel())
}
