//
//  GlassModifier.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thickMaterial.opacity(0.2))
            .clipShape(.rect(cornerRadius: 10))
            .shadow(color: .black.opacity(0.15), radius: 4)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            }
    }
}
extension View {
    func glassify() -> some View {
        self
            .modifier(GlassBackground())
    }
}

struct GlassTestView: View {
    var body: some View {
        VStack {
            Label("Large Title", systemImage: "mug.fill")
                .foregroundStyle(.white)
                .font(.largeTitle.bold())
                .shadow(color: .black.opacity(0.3), radius: 1)
                .padding()
                .glassify()
            Text("Headline")
                .foregroundStyle(.white)
                .font(.headline)
                .shadow(color: .black.opacity(0.3), radius: 1)
                .padding()
                .glassify()
            Button {
                
            } label: {
                Text("Button")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .shadow(color: .black.opacity(0.3), radius: 1)
                    .padding()
                    .glassify()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(.sandbg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    GlassTestView()
}
