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
        calendarView.layer.cornerRadius = 20.0
        calendarView.allowsMultipleSelection = true
        configureStandardViewDesignWithShadow(view: calendarInnerContainer, shadowSize: 1.0, widthAdj: 55, heightAdj: 0, xOffset: 0, yOffset: 0)
        
        //Display the initial dates on the calendar from and to date buttons
        resetCalendarToDate()
        resetCalendarFromDate()
        updateMainDateButtonDateLabels()
        
        calendarView.register(UINib(nibName: "CalendarSectionHeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CalendarSectionHeaderView")

    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        currentCell.dateLabel.text = cellState.text
        configureTextColorFor(cell: currentCell, cellState: cellState)
        configureSelectedStateFor(cell: currentCell, cellState: cellState)
        let cellHidden = cellState.date < hideDate
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
        
        if !cellState.isSelected{
            currentCell.selectedView.isHidden = true
            currentCell.selectedMiddleView.isHidden = true
        }
        
        //Set the cell style based on where it is in the range selected
        if #available(iOS 11.0, *) {
            switch cellState.selectedPosition() {
            case .left:
                currentCell.selectedView.isHidden = false
                currentCell.selectedMiddleView.isHidden = false
                currentCell.selectedView.layer.cornerRadius = 22
                currentCell.dateLabel.textColor = UIColor.white
                //currentCell.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            case .middle:
                currentCell.selectedView.isHidden = true
                currentCell.selectedMiddleView.isHidden = false
                currentCell.dateLabel.textColor = themeTextColor
                //currentCell.selectedView.layer.cornerRadius = 0
                //currentCell.selectedView.layer.maskedCorners = []
            case .right:
                currentCell.selectedView.isHidden = false
                currentCell.selectedMiddleView.isHidden = false
                currentCell.selectedView.layer.cornerRadius = 22
                currentCell.dateLabel.textColor = UIColor.white
                //currentCell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            case .full:
                currentCell.selectedView.isHidden = false
                currentCell.selectedMiddleView.isHidden = false
                currentCell.selectedView.layer.cornerRadius = 22
                currentCell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
                currentCell.dateLabel.textColor = themeTextColor
            default: break
            }
            
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
        calendar.scrollDirection = .vertical
        var startDate = Date()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var endDate = cal!.date(byAdding: NSCalendar.Unit.year, value: 3, to: startDate, options: NSCalendar.Options.matchLast)
        if endDate == nil { endDate = startDate}
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        
        return parameters
 
     
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if date <= fromDate {
            fromDate = date
        } else {
            toDate = date
        }
        
        calendarView.selectDates(from: fromDate, to: toDate, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        configureCell(cell: cell, cellState: cellState)
        calendar.reloadData()
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        //If date is closer to fromDate, deselect all dates before fromDate and make date = fromDate
        //If date is closer to toDate, deselect all dates after date and make date = toDate
        
        if date.isWithin24HoursOf(date: fromDate){
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
             calendarView.selectDates([fromDate], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            fromDate = date
            toDate = date
        } else if date.isWithin24HoursOf(date: toDate){
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
             calendarView.selectDates([toDate], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            fromDate = date
            toDate = date
        } else if (date.timeIntervalSince1970 - fromDate.timeIntervalSince1970) < (toDate.timeIntervalSince1970 - date.timeIntervalSince1970){
            fromDate = date
            calendarView.deselectDates(from: Date().addingTimeInterval(-ONE_DAY), to: fromDate.addingTimeInterval(-ONE_DAY), triggerSelectionDelegate: false)
            calendarView.selectDates([fromDate], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        } else {
        calendarView.deselectDates(from: date.addingTimeInterval(ONE_DAY), to: toDate.addingTimeInterval(ONE_DAY), triggerSelectionDelegate: false)
        calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            toDate = date
        }
        
        configureCell(cell: cell, cellState: cellState)
        calendar.reloadData()
        
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
    
    func resetCalendarFromDate(){
        fromDate = Date()
        
    }
    
    func resetCalendarToDate(){
        toDate = fromDate.addingTimeInterval(ONE_WEEK)
    }
    
    func updateMainDateButtonDateLabels(){
        
        //Display selected date in button text
        let df = DateFormatter()
        df.dateFormat = "MM/dd/YY"
        let fromDateString = df.string(from: fromDate)
        let toDateString = df.string(from: toDate)
        mainDateButton.setTitle(fromDateString + " \n- " + toDateString, for: .normal)
        
        
    }
    
    func hideCalendarView(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        }){ success in
            self.calendarContainer.isHidden = true
        }
    }
    
    func showCalendarView(){
        self.calendarContainer.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.transform = .identity
        })
    }

}
