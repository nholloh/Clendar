//
//  EventStore+Extensions.swift
//  Clendar
//
//  Created by Vinh Nguyen on 25/3/19.
//  Copyright © 2019 Vinh Nguyen. All rights reserved.
//

import EventKit
import Foundation

extension EKEventStore {
    func createEvent(title: String, startDate: Date, endDate: Date?, calendar: EKCalendar, span: EKSpan = .thisEvent, completion: VoidHandler? = nil) {
        let event = EKEvent(eventStore: self)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar

        do {
            try self.save(event, span: span, commit: true)
            completion.flatMap { $0() }
        } catch {
            logError(error.localizedDescription)
        }
    }

    func calendarForApp(completion: EventCalendarHandler? = nil) {
        let calendars = self.calendars(for: .event)
        guard let clendar = calendars.first(where: { $0.title == AppName }) else {
            let newClendar = EKCalendar(for: .event, eventStore: self)
            newClendar.title = AppName
            newClendar.source = self.defaultCalendarForNewEvents?.source

            do {
                try self.saveCalendar(newClendar, commit: true)
                completion.flatMap { $0(newClendar) }
            } catch {
                logError(error.localizedDescription)
            }

            return
        }

        completion.flatMap { $0(clendar) }
    }
}
