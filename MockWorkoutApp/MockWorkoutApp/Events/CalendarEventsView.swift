//
//  CalendarEventsView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 21/11/25.
//
import SwiftUI
import EventKit

struct CalendarEventsView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.events, id: \.eventIdentifier) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text("\(event.startDate.formatted()) - \(event.endDate.formatted())")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Next 2 Weeks Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Tạo sự kiện mẫu
                        let startDate = Date()
                        let endDate = Date().addingTimeInterval(3600) // +1 giờ
                        viewModel.createEvent(title: "New Event", startDate: startDate, endDate: endDate)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.requestAccessAndFetchEvents()
            }
        }
    }
}
