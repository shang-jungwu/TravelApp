//
//  DateUtility.swift
//  Travel
//
//  Created by 吳宗祐 on 2024/1/28.
//

import Foundation

struct DateUtility {
    var dateFormatter = DateFormatter()

    func convertDateToString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

}
