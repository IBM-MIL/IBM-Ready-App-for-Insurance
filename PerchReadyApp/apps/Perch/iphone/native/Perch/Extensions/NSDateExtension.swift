/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

extension NSDate{
    func daysInBetweenDate(date: NSDate) -> Double
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/86400)
        return diff
    }
    
    func hoursInBetweenDate(date: NSDate) -> Double
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/3600)
        return diff
    }
    
    func minutesInBetweenDate(date: NSDate) -> Double
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/60)
        return diff
    }
    
    func secondsInBetweenDate(date: NSDate) -> Double
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff)
        return diff
    }
    
    /**
    NSDate formatting method to display date and time, but insert TODAY if date is today
    
    :returns: the formatted date string
    */
    func perchTableCellStringFormat() -> String {
        
        // create dates without time for comparison
        var cal = NSCalendar.currentCalendar()
        var components = cal.components((NSCalendarUnit.CalendarUnitEra|NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay) , fromDate: NSDate())
        var today = cal.dateFromComponents(components)
        components = cal.components((NSCalendarUnit.CalendarUnitEra|NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay) , fromDate: self)
        var formattedDate = cal.dateFromComponents(components)
        
        // determine if date represents today
        var chosenFormat = ""
        if today!.isEqualToDate(formattedDate!) {
            chosenFormat = "'TODAY', h:mm a"
        } else {
            chosenFormat = "MM/dd/yyyy, h:mm a"
        }
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = chosenFormat
        var converted = dateFormatter.stringFromDate(self)
        
        return converted
    }
}