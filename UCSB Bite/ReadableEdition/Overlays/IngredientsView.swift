//
//  IngredientsView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct IngredientsView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial.opacity(1))
                .brightness(-0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        ingredientsOverlay.show = false
                    }
                }
            ScrollView(showsIndicators: false) {
                VStack {
                    Text(ingredientsOverlay.name)
                        .font(.title3.bold())
                    Divider()
                        .background(.gray.opacity(0.1))
                    Text(AttributedString(ingredientsOverlay.text))
                }
                .padding(30)
            } .frame(minHeight: 100, maxHeight: 600)
            .foregroundStyle(.white)
            .glassify()
            .padding()
        } .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(ingredientsOverlay.show ? 1 : 0)
    }
}

#Preview {
    IngredientsView()
}
