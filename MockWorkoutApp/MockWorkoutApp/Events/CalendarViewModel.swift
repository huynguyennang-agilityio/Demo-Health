//
//  CalendarViewModel.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 21/11/25.
//
import EventKit

class CalendarViewModel: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    
    func requestAccessAndFetchEvents() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .authorized {
            self.fetchEventsForNextTwoWeeks()
        } else {
            print(status.rawValue)
            eventStore.requestFullAccessToEvents { success, error in
                if success && error == nil {
                    print("Access has been granted.")
                } else {
                    print("Access request failed with error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved!")
        } catch {
            print("Failed to save event: \(error)")
        }
    }

    private func fetchEventsForNextTwoWeeks() {
        let calendars = eventStore.calendars(for: .event)
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 2, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let fetchedEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = fetchedEvents.sorted(by: { $0.startDate < $1.startDate })
        }
    }
}
