//
//  ListNotesTableViewController.swift
//  MakeSchoolNotes
//
//  Created by Chris Orcutt on 1/10/16.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit

protocol ListToDoTableViewControllerDelegate {
    func updatetoDos()
}

class ListToDoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListToDoTableViewControllerDelegate, skipViewControllerDelegate {
    
    let emptyBox = UIImage(named: "Empty_Box")
    let checkedBox = UIImage(named: "Checked_Box")
    let searchIcon = UIImage(named: "SearchIcon")
    
    var currentweekday = Calendar.current.component(.weekday,from: Date())
    var currentday = Calendar.current.component(.day, from: Date()) //date
    var currentmonth = Calendar.current.component(.month, from: Date())
    var currentyear = Calendar.current.component(.year, from: Date())
    let weekdayCal = Calendar.current.component(.weekday, from: Date())
    let dayCal = Calendar.current.component(.day, from: Date())
    let monthCal = Calendar.current.component(.month, from: Date())
    let yearCal = Calendar.current.component(.year, from: Date())
    
    
    
    
    @IBOutlet weak var listToDo: UIView!
    @IBOutlet weak var table: UITableView?
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    
    var toDos = [ToDo] () {
        didSet {
            table?.reloadData()
        }
    }
    
    func updatetoDos() {
        toDos = CoreDataHelper.retrievetoDos()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.setImage(searchIcon, for: UIControlState.normal)
        let left = UISwipeGestureRecognizer(target : self, action : #selector(ListToDoTableViewController.leftSwipe))
        left.direction = .left
        self.listToDo.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(ListToDoTableViewController.rightSwipe))
        right.direction = .right
        self.listToDo.addGestureRecognizer(right)
        
        calculateDate(weekday: weekdayCal, month: monthCal, day: dayCal, year: yearCal, operation: "none")
        toDos = CoreDataHelper.retrievetoDos()
        
    } // view loaded: recognizes swipe gesture than calculates which date is today, then retrieves the data
    
    override func viewWillAppear(_ animated: Bool) {
       
        table?.reloadData()
    } //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let initFilteredtoDo = toDos.filter{ $0.month == currentmonth}
        let filteredtoDo = initFilteredtoDo.filter{ $0.date == currentday}
        return filteredtoDo.count
    } // Filters for tasks with current month, then filters for tasks with current date, then returns the value of the number of tasks for "today"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listToDoTableViewCell", for: indexPath) as! ListToDoTableViewCell
        let initFilteredtoDo = toDos.filter{ $0.month == currentmonth}
        let filteredtoDo = initFilteredtoDo.filter{ $0.date == currentday}
        let toDo = filteredtoDo[indexPath.row]
        // Filters out for current date, then assigns each cell to toDo
        
        cell.toDo = toDo
        cell.toDoLabel.text = toDo.goal
        cell.punishmentLabel.text = toDo.punishment
        cell.deadlineLabel.text = toDo.deadline
        if toDo.checkBox == false {
            cell.checkBox.setImage(emptyBox, for: UIControlState.normal)
        } else if toDo.checkBox == true {
            cell.checkBox.setImage(checkedBox, for: UIControlState.normal)
        }
        
        return cell
        // changes each cell according to the data in toDo
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let initFilteredtoDo = toDos.filter{ $0.month == currentmonth}
            let filteredtoDo = initFilteredtoDo.filter{ $0.date == currentday}
            let toDoToDelete = filteredtoDo[indexPath.row]
            CoreDataHelper.delete(toDo: toDoToDelete)
            // filters out the current date and the task to delete and deletes it
            toDos = CoreDataHelper.retrievetoDos()
        } // updates the list
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        
        switch identifier {
        case "displayToDo":
            guard let indexPath = table?.indexPathForSelectedRow else { return }
            
            let toDo = toDos[indexPath.row]
            
            let destination = segue.destination as! DisplayToDoViewController
            
            destination.toDo = toDo
            destination.listToDoDelegate = self
            
        case "addToDo":
            let destination = segue.destination as! DisplayToDoViewController
            destination.day = currentday
            destination.month = currentmonth
            destination.year = currentyear
            destination.listToDoDelegate = self
        case "displaySkip":
            if let destination = segue.destination as? SkipViewController {
                let calendar = Calendar.current
                let sendDate = calendar.date(from: DateComponents(year: currentyear, month: currentmonth, day: currentday, hour: 00, minute: 00, second: 00)) //convert int to date
                destination.currentDate = sendDate!
                destination.skipDelegate = self
            }
        default:
            print("Something unexpected was pressed")
            
        }
    }
    
    func acceptDate(acceptDate: Date) {
        let acceptWeekday = Calendar.current.component(.weekday, from:acceptDate)
        let acceptMonth = Calendar.current.component(.month, from: acceptDate)
        let acceptDay = Calendar.current.component(.day, from: acceptDate)
        let acceptYear = Calendar.current.component(.year, from: acceptDate)
        
        calculateDate(weekday: acceptWeekday, month: acceptMonth, day: acceptDay, year: acceptYear, operation: "none")
        currentday = acceptDay
        currentweekday = acceptWeekday
        currentmonth = acceptMonth
        currentyear = acceptYear
        updatetoDos()
        
    }
    
    @objc
    func leftSwipe() {
       
        calculateDate(weekday: currentweekday, month: currentmonth, day: currentday, year: currentyear, operation: "add")
        currentday += 1
        currentweekday += 1
        
        updatetoDos()
    }
    
    @objc
    func rightSwipe() {
        
        calculateDate(weekday: currentweekday, month: currentmonth, day: currentday, year: currentyear, operation: "subtract")
        currentday -= 1
        currentweekday -= 1
        
        updatetoDos()
    }
    
    func calculateDate(weekday: Int, month: Int, day: Int, year: Int, operation: String) {
        var weekday2 = ""
        var month2 = ""
        
        var weekdayCal = weekday
        var dayCal = day
        var yearCal = year
        
        
        if operation == "add" {
            weekdayCal += 1
            dayCal += 1
        } else if operation == "subtract" {
            weekdayCal -= 1
            dayCal -= 1
        } else if operation == "none" {
            
        }
        
        if month % 12 == 1 {
            month2 = "January"
            if operation == "add" {
                if day == 31 {
                    month2 = "February"
                    dayCal = 1
                    currentday = 1
                    currentmonth = 2
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "December"
                    dayCal = 31
                    yearCal -= 1
                    currentday = 31
                    currentmonth = 12
                    currentyear -= 1
                }
            }
        } else if month % 12 == 2 {
            month2 = "February"
            if operation == "add" {
                if day == 28 {
                    month2 = "March"
                    dayCal = 1
                    currentmonth = 3
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "January"
                    dayCal = 31
                    currentmonth = 1
                    currentday = 31
                }
            }
        } else if month % 12 == 3 {
            month2 = "March"
            if operation == "add" {
                if day == 31 {
                    month2 = "April"
                    dayCal = 1
                    currentmonth = 4
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "February"
                    dayCal = 28
                    currentmonth = 2
                    currentday = 28
                }
            }
        } else if month % 12 == 4 {
            month2 = "April"
            if operation == "add" {
                if day == 30 {
                    month2 = "May"
                    dayCal = 1
                    currentmonth = 5
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "March"
                    dayCal = 31
                    currentmonth = 3
                    currentday = 31
                }
            }
        } else if month % 12 == 5 {
            month2 = "May"
            if operation == "add" {
                if day == 31 {
                    month2 = "June"
                    dayCal = 1
                    currentmonth = 6
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "April"
                    dayCal = 30
                    currentmonth = 4
                    currentday = 30
                }
            }
        } else if month % 12 == 6 {
            month2 = "June"
            if operation == "add" {
                if day == 30 {
                    month2 = "July"
                    dayCal = 1
                    currentmonth = 7
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "May"
                    dayCal = 31
                    currentmonth = 5
                    currentday = 31
                }
            }
        } else if month % 12 == 7 {
            month2  = "July"
            if operation == "add" {
                if day == 31 {
                    month2 = "August"
                    dayCal = 1
                    currentmonth = 8
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "June"
                    dayCal = 30
                    currentmonth = 6
                    currentday = 30
                }
            }
        } else if month % 12 == 8 {
            month2 = "August"
            if operation == "add" {
                if day == 31 {
                    month2 = "September"
                    dayCal = 1
                    currentmonth = 9
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "July"
                    dayCal = 31
                    currentmonth = 7
                    currentday = 31
                }
            }
        } else if month % 12 == 9 {
            month2 = "September"
            if operation == "add" {
                if day == 30 {
                    month2 = "October"
                    dayCal = 1
                    currentmonth = 10
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "August"
                    dayCal = 31
                    currentmonth = 8
                    currentday = 31
                }
            }
        } else if month % 12 == 10 {
            month2 = "October"
            if operation == "add" {
                if day == 31 {
                    month2 = "November"
                    dayCal = 1
                    currentmonth = 1
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "September"
                    dayCal = 30
                    currentmonth = 9
                    currentday = 30
                }
            }
        } else if month % 12 == 11 {
            month2 = "November"
            if operation == "add" {
                if day == 30 {
                    month2 = "December"
                    dayCal = 1
                    currentmonth = 12
                    currentday = 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "October"
                    dayCal = 31
                    currentmonth = 10
                    currentday = 31
                }
            }
        } else if month % 12 == 0 {
            month2 = "December"
            if operation == "add" {
                if day == 31 {
                    month2 = "January"
                    dayCal = 1
                    yearCal += 1
                    currentmonth = 1
                    currentday = 1
                    currentyear += 1
                }
            } else if operation == "subtract" {
                if day == 1 {
                    month2 = "November"
                    dayCal = 30
                    currentmonth = 11
                    currentday = 30
                }
            }
        }
        
        if weekdayCal % 7 == 1 || weekdayCal % 7 == -6 {
            weekday2 = "Sunday"
        } else if weekdayCal % 7 == 2 || weekdayCal % 7 == -5 {
            weekday2 = "Monday"
        } else if weekdayCal % 7 == 3 || weekdayCal % 7 == -4 {
            weekday2 = "Tuesday"
        } else if weekdayCal % 7 == 4 || weekdayCal % 7 == -3 {
            weekday2 = "Wednesday"
        } else if weekdayCal % 7 == 5 || weekdayCal % 7 == -2 {
            weekday2 = "Thursday"
        } else if weekdayCal % 7 == 6 || weekdayCal % 7 == -1 {
            weekday2 = "Friday"
        } else if weekdayCal % 7 == 0 {
            weekday2 = "Saturday"
        }
        
        
        
        
        checkDate(weekday2: weekday2, month2: month2, day: dayCal, year2: yearCal)
        
    }
    
    func checkDate(weekday2: String, month2: String, day: Int, year2: Int){
        if day == 1 {
            todayDateLabel.text = "\(weekday2), \(month2) \(day)st, \(year2)"
        } else if day == 2 {
            todayDateLabel.text = "\(weekday2), \(month2) \(day)nd, \(year2)"
        } else if day == 3 {
            todayDateLabel.text = "\(weekday2), \(month2) \(day)rd, \(year2)"
        } else {
            todayDateLabel.text = "\(weekday2), \(month2) \(day)th, \(year2)"
        }
    }
    
    
    
}
