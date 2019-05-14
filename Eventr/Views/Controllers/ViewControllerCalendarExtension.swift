//
//  ViewControllerCalendarExtension.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/8/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import JTAppleCalendar

//Extension for calendar code
extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Display the initial dates on the calendar from and to date buttons
        resetCalendarToDate()
        resetCalendarFromDate()
        
        
        calendarView.register(UINib(nibName: "CalendarSectionHeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CalendarSectionHeaderView")

    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        currentCell.dateLabel.text = cellState.text
        configureSelectedStateFor(cell: currentCell, cellState: cellState)
        configureTextColorFor(cell: currentCell, cellState: cellState)
        let cellHidden = cellState.date < hideDate
        currentCell.isHidden = cellHidden
        
    }
    
    func configureTextColorFor(cell: JTAppleCell?, cellState: CellState){
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        if cellState.isSelected{
            currentCell.dateLabel.textColor = UIColor.black
        } else {
            if cellState.dateBelongsTo == .thisMonth && cellState.date > Date() {
                currentCell.dateLabel.textColor = UIColor.blue
            } else {
                currentCell.dateLabel.textColor = UIColor.purple
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
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarSearchCell", for: indexPath)
        configureCell(cell: cell, cellState: cellState)
 
    
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarSearchCell", for: indexPath) as! CalendarCell
        configureCell(cell: cell, cellState: cellState)
        return cell
 
      
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        
        
        calendar.scrollingMode = .stopAtEachSection
        calendar.scrollDirection = .horizontal
        var startDate = Date()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var endDate = cal!.date(byAdding: NSCalendar.Unit.year, value: 3, to: startDate, options: NSCalendar.Options.matchLast)
        if endDate == nil { endDate = startDate}
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        
        return parameters
 
     
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        //When calendar date is selected, set the appropriate date ('from date' or 'to date') depending on whether user is selecting from date or to date
        //Set the date text on the appropriate button
        
        configureCell(cell: cell, cellState: cellState)
        if fromDateWasSelected {
            fromDate = date
        } else {
            toDate = date
        }
        
        //Display selected date in button text
        if !calendarContainer.isHidden {
            let df = DateFormatter()
            df.dateFormat = "MMM dd YYYY"
            let dateString = df.string(from: date)
            if fromDateWasSelected{
               selectFromDate.setTitle(dateString, for: .normal)
            } else {
                selectToDate.setTitle(dateString, for: .normal)
            }
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
        return MonthSize(defaultSize: 40)
    }
    
    func resetCalendarFromDate(){
        let df = DateFormatter()
        df.dateFormat = "MMM dd YYYY"
        fromDate = Date()
        let fromDateString = df.string(from: fromDate)
        selectFromDate.setTitle(fromDateString, for: .normal)
        
    }
    
    func resetCalendarToDate(){
        let df = DateFormatter()
        df.dateFormat = "MMM dd YYYY"
        toDate = fromDate.addingTimeInterval(ONE_WEEK)
        let toDateString = df.string(from: toDate)
        selectToDate.setTitle(toDateString, for: .normal)
        
    }
    

}
