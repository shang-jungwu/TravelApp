//
//  UserSchedules.swift
//  Travel
//
//  Created by 吳宗祐 on 2024/1/26.
//

import Foundation

struct UserSchedules: Codable, Equatable {
    static func == (lhs: UserSchedules, rhs: UserSchedules) -> Bool {
        return lhs.numberOfDays == rhs.numberOfDays && lhs.departureDate == rhs.departureDate && lhs.scheduleTitle == rhs.scheduleTitle && lhs.destination == rhs.destination
    }
    
    var createrID: String
    var journeyID: String
    var scheduleTitle: String
    var destination: String
    var departureDate: TimeInterval//Date
    var numberOfDays: Int
    var dayByDaySchedule: [DayByDaySchedule]

    init(createrID: String, journeyID: String, scheduleTitle: String, destination: String, departureDate: TimeInterval, numberOfDays: Int, dayByDaySchedule: [DayByDaySchedule]) {
        self.createrID = createrID
        self.journeyID = journeyID
        self.scheduleTitle = scheduleTitle
        self.destination = destination
        self.departureDate = departureDate
        self.numberOfDays = numberOfDays
        self.dayByDaySchedule = dayByDaySchedule
    }

}

struct DayByDaySchedule: Codable {
    
    var date: TimeInterval//Date
    var places: [DayByDayPlace]
    init(date: TimeInterval, places: [DayByDayPlace] = [DayByDayPlace]()) {
        self.date = date
        self.places = places
    }
}
