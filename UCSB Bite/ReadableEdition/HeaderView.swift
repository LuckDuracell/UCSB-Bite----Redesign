//
//  HeaderView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct HeaderView: View {
    
    @Binding var showSchedule: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSchedule = true
                }
            } label: {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title2.bold())
                    .padding(10)
                    .glassify()
            }
            Text("UCSB Bite")
                .font(.largeTitle.bold())
                .padding(10)
                .glassify()
                .id(0)
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSettings = true
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.bold())
                    .padding(10)
                    .glassify()
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 30)
    }
}

#Preview {
    HeaderView(showSchedule: .constant(false), showSettings: .constant(false))
}
