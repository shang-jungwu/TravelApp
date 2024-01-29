//
//  DateUtility.swift
//  Travel
//
//  Created by 吳宗祐 on 2024/1/28.
//

import Foundation

struct DateUtility {
    var dateFormatter = DateFormatter()
    var isoCalendar: Calendar {
        return Calendar(identifier: .iso8601)
    }

    func convertDateToString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func nextSomeDay(startingDate: Date, countOfDays: Int) -> Date {
        if let result = isoCalendar.date(byAdding: .day, value: countOfDays - 1, to: startingDate) {
            return result
        }
        return Date()
    }
    
    func nextDay(startingDate: Date) -> Date {
        if let result = isoCalendar.date(byAdding: .day, value: 1, to: startingDate) {
            return result
        }
        return Date()
    }

}
