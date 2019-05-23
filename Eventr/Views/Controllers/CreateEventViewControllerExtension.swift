//
//  CreateEventViewControllerExtension.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/7/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import JTAppleCalendar

extension CreateEventViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureTimePicker(){
        timePicker.setValue(themeDarkGray, forKeyPath: "textColor")
    }
    
    func configureCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.layer.cornerRadius = 20.0
        eventDate = Date() //Reset the date of the event
        
        let df = DateFormatter()
        df.dateFormat = "MMM dd YYYY"
        let dateString = df.string(from: Date())
        selectEventDateButton.setTitle(dateString, for: .normal)
        
        calendarView.register(UINib(nibName: "CalendarSectionHeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CalendarSectionHeaderView")
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        currentCell.dateLabel.text = cellState.text
        configureSelectedStateFor(cell: currentCell, cellState: cellState)
        configureTextColorFor(cell: currentCell, cellState: cellState)
        let cellHidden = cellState.dateBelongsTo != .thisMonth || cellState.date < Date().addingTimeInterval(-ONE_DAY)
        currentCell.isHidden = cellHidden
        
    }
    
    func configureTextColorFor(cell: JTAppleCell?, cellState: CellState){
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        if cellState.isSelected{
            currentCell.dateLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth && cellState.date > Date() {
                currentCell.dateLabel.textColor = themeTextColor
            } else {
                currentCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func configureSelectedStateFor(cell: JTAppleCell?, cellState: CellState){
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        if cellState.isSelected{
            currentCell.selectedView.isHidden = false
        } else {
            currentCell.selectedView.isHidden = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath)
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        configureCell(cell: cell, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        calendar.scrollingMode = .stopAtEachSection
        calendar.scrollDirection = .vertical
        

        let today = Date()
        let startDate = today
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var endDate = cal!.date(byAdding: NSCalendar.Unit.year, value: 3, to: today, options: NSCalendar.Options.matchLast)
        if endDate == nil { endDate = today}
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        
        return parameters
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        eventDate = date
        
        //Display selected date in button text
        if !calendarContainer.isHidden {
            let df = DateFormatter()
            df.dateFormat = "MMM dd YYYY"
            let dateString = df.string(from: date)
            selectEventDateButton.setTitle(dateString, for: .normal)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "CalendarSectionHeaderView", for: indexPath)
        let date = range.start
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        (header as! CalendarSectionHeaderView).title.text = formatter.string(from: date)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    func displayDateErrorNotification(){
        let getDateFailAlert = UIAlertController(title: "Unable to retrieve Event Date. Ensure date and time are entered correctly.", message: nil, preferredStyle: .alert)
        getDateFailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
        }))
        self.present(getDateFailAlert, animated: true)
    }
    
    func getFirebaseGMTDate(date: Date, time: Date) -> Date? {
        //Return the event date in firebase format (GMT)
        //Create the firebase date by adding together the selected date and selected time and converting the date to (GMT)
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: time)
            let hour = comp.hour
            let minute = comp.minute
            let firebaseDate = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: date)!
            let convertedFirebaseDate = firebaseDate.convertToTimeZone(initTimeZone: Calendar.current.timeZone, timeZone: TimeZone(secondsFromGMT: 0)!)
            let printFormatter = DateFormatter()
            printFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            printFormatter.timeZone = Calendar.current.timeZone
            printFormatter.locale = Calendar.current.locale
            print("fbdate:" + printFormatter.string(from: firebaseDate))
            print("convertedfbdate:" + printFormatter.string(from: convertedFirebaseDate))
            return convertedFirebaseDate
       
    }
    
    func getFirebaseGMTDate(date: Date) -> Date? {
        //Return the event date in firebase format (GMT)
        //Create the firebase date by adding together the selected date and selected time and converting the date to (GMT)
        let convertedFirebaseDate = date.convertToTimeZone(initTimeZone: Calendar.current.timeZone, timeZone: TimeZone(secondsFromGMT: 0)!)
        let printFormatter = DateFormatter()
        printFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        printFormatter.timeZone = Calendar.current.timeZone
        printFormatter.locale = Calendar.current.locale
        print("fbdate:" + printFormatter.string(from: date))
        print("convertedfbdate:" + printFormatter.string(from: convertedFirebaseDate))
        return convertedFirebaseDate
        
    }
    
    
    func setCalendarButtonTitleToBeSelectedTime(){
        //Format and set time to be title of the "Event Time:" button
        let df = DateFormatter()
        df.timeStyle = .short
        let timeString = df.string(from: eventTime)
        selectEventTimeButton.setTitle(timeString, for: .normal)
    }
    
    //Display alert if required fields are missing data
    func requiredFieldsAreMissingData() -> Bool {
        guard let categoryString = selectCategoryButton.titleLabel?.text else {
            return false
        }
        if eventName.text.isEmpty || eventDescription.text.isEmpty || eventLocation.text.isEmpty || eventPhoneNumber.text.isEmpty ||  categoryString.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    //Check if phone number is properly formatted
    //Phone number is properly formatted if it only contains numbers or is empty
    func phoneNumberIsNotProperlyFormatted() -> Bool {
          let phoneNumberString = eventPhoneNumber.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !eventPhoneNumber.text.isEmpty && phoneNumberString != "" {
            let onlyContainsNumbers = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: phoneNumberString))
            return !onlyContainsNumbers
        }
        return false
    }
    
    func displayAlertWithOKButton(text: String){
        let emptyFieldsAlert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        emptyFieldsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(emptyFieldsAlert, animated: true)
    }
    
    //Increment user daily allotted max # of events
    func incrementUserDefaultsDailyEventCount(){
        
        let prefs = UserDefaults.standard
        if let date = prefs.object(forKey: dailyMaximumDateKey) as? Date {
            if  Double(date.timeIntervalSinceNow) < -ONE_DAY {
                prefs.set(Date(), forKey: dailyMaximumDateKey)
                prefs.set(1, forKey: dailyMaximumNumberKey)
            } else {
                var dailyEventCount = prefs.object(forKey: dailyMaximumNumberKey) as? Int
                if dailyEventCount != nil {
                    dailyEventCount! += 1
                    prefs.set(dailyEventCount, forKey: dailyMaximumNumberKey)
                }
            }
            
        } else {
            prefs.set(Date(), forKey: dailyMaximumDateKey)
            prefs.set(1, forKey: dailyMaximumNumberKey)
        }
        
    }
    
    //Check if user surpassed daily allotted max # of events
    func checkIfUserDefaultsDailyEventMaximumReached() -> Bool {
        let prefs = UserDefaults.standard
        guard let date = prefs.object(forKey: dailyMaximumDateKey) as? Date else {
            return false
        }
        
        if Double(date.timeIntervalSinceNow) > -ONE_DAY {
            let dailyCount = prefs.object(forKey: dailyMaximumNumberKey) as? Int
            if dailyCount != nil && dailyCount! >= 50 {
                return true
            }
        }
        return false
    }
    
    //If user surpassed daily allotted max # of events, display alert
    func displayMaxDailyEventsReachedAlert(){
        let maxDailyEventsAlert = UIAlertController(title: "Daily Event Maximum Reached (5 Events in 24 Hours)", message: nil, preferredStyle: .alert)
        maxDailyEventsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        
        self.present(maxDailyEventsAlert, animated: true)
    }
    
    func configureCreateEventScreen(){
        
        //Update create event button text
        createEventButton.setTitle("Create Event", for: .normal)

    }
    
    func configureEditEventScreen(){
        
        //Update create event button text
        createEventButton.setTitle("Update Event", for: .normal)
        
        //If editing an event, autopopulate the entry field values with current event values
        guard let selectedEventDate = selectedEvent.date else {
            return
        }
        eventName.text = selectedEvent.name
        selectCategoryButton.setTitle(selectedEvent.category.text(), for: .normal)
        previousDate = selectedEventDate.addingTimeInterval(0)
        eventDate = selectedEventDate
        let df = DateFormatter()
        df.dateFormat = "MMM dd YYYY"
        let dateString = df.string(from: selectedEventDate)
        selectEventDateButton.setTitle(dateString, for: .normal)
        eventLocation.text = selectedEvent.location
        eventDescription.text = selectedEvent.details
        eventContactInfo.text = selectedEvent.contact
        eventTicketURL.text = selectedEvent.ticketURL
        eventURL.text = selectedEvent.eventURL
        eventTag1.text = selectedEvent.tag1
        eventTag2.text = selectedEvent.tag2
        eventTag3.text = selectedEvent.tag3
        paidSwitch.isOn = selectedEvent.paid
        eventTime = eventDate.addingTimeInterval(0) //The time is the same as the date... when an event is created they are combined to the same date value.  Create a new Date() so that when the time is edited, the date isn't adjusted
        setCalendarButtonTitleToBeSelectedTime()
    }
    
    func displayCreateEventFailAlert(){
        let createEventFailAlert = UIAlertController(title: "Event unable to be created. Ensure network connection is established or retry later", message: nil, preferredStyle: .alert)
        createEventFailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
        }))
        self.present(createEventFailAlert, animated: true)
    }
}
