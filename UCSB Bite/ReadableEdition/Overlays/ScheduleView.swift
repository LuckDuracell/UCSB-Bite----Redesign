//
//  ScheduleView.swift
//  UCSB Bite
//
//  Created by Luke Drushell on 6/29/23.
//

import SwiftUI

struct ScheduleView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial.opacity(1))
                .brightness(-0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSchedule = false
                    }
                }
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Schedule")
                        .font(.title3.bold())
                    Divider()
                        .background(.gray.opacity(0.1))
                    VStack {
                        VStack(alignment: .leading) {
                            Text("De La Guerra, Carrillo, & Portola")
                                .font(.headline)
                            VStack(alignment: .leading) {
                                Text("Monday-Friday")
                                    .font(.body)
                                VStack(alignment: .leading) {
                                    Text("Breakfast  7:15am-10:00am")
                                    Text("Lunch  11:00am-3:00pm")
                                    Text("Dinner  5:00pm-8:30pm")
                                } .padding(.leading)
                                    .foregroundStyle(.white)
                                    .brightness(-0.05)
                                Text("Saturday-Sunday")
                                    .font(.body)
                                VStack(alignment: .leading) {
                                    Text("Brunch  10:00am-2:00pm")
                                    Text("Dinner  5:00pm-8:30pm")
                                } .padding(.leading)
                                    .foregroundStyle(.white)
                                    .brightness(-0.05)
                            }
                        }
                        .font(.subheadline)
                        .frame(maxWidth: 310, alignment: .leading)
                        .padding()
                        .glassify()
                        .padding(5)
                        VStack(alignment: .leading) {
                            Text("Ortega")
                                .frame(maxWidth: 310, alignment: .leading)
                                .font(.headline)
                            VStack(alignment: .leading) {
                                Text("Monday-Friday")
                                    .font(.body)
                                VStack(alignment: .leading) {
                                    Text("Breakfast  7:15am-10:00am")
                                    Text("Lunch  11:00am-3:00pm")
                                    Text("Dinner  5:00pm-8:30pm")
                                } .padding(.leading)
                                    .foregroundStyle(.white)
                                    .brightness(-0.05)
                            }
                        }
                        .font(.subheadline)
                        .frame(maxWidth: 310, alignment: .leading)
                        .padding()
                        .glassify()
                        .padding(5)
                    }
                }
                .padding(20)
            } .frame(minHeight: 100, maxHeight: 600)
            .foregroundStyle(.white)
            .glassify()
            .padding()
        } .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(showSchedule ? 1 : 0)
    }
}

#Preview {
    ScheduleView()
}
