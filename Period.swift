//
//  Period.swift
//  Learning1
//
//  Created by Bharath Patil on 18/11/20.
//

import Foundation

struct Period
{
    var start:Date!;
    var end:Date!;
    func getDayMinutes(d:Date) -> Int
    {
        var cal=Calendar.current;
        cal.timeZone=TimeZone(identifier: "UTC")!
        let hours = cal.component(.hour, from: d)
        let minutes = cal.component(.minute, from: d)
        //print("\(hours),\(minutes)")
        return hours*60+minutes
    }
    func getStartMinute() -> Int
    {
        return getDayMinutes(d: start)
    }
    func getEndMinute() -> Int
    {
        return getDayMinutes(d: end)
    }
}
