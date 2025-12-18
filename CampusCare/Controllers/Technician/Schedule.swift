//
//  Schedule.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FSCalendar

class Schedule: UIViewController , FSCalendarDelegate, FSCalendarDataSource,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tasks: UITableView!
    
    
    var tasksForSelectedDate: [String] = []
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tasksForSelectedDate.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = tasksForSelectedDate[indexPath.row]
        return cell
    }
    
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: date)

        // TEST DATA
        if selectedDate.hasSuffix("-10") {
            tasksForSelectedDate = [
                "Fix AC",
                "Replace Light"
            ]
        } else if selectedDate.hasSuffix("-15") {
            tasksForSelectedDate = [
                "Repair Door"
            ]
        } else {
            tasksForSelectedDate = []
        }

        tasks.reloadData()
    }



   
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.headerHeight = 50
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleAlignment = .center
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.scope = .month
        
        tasks.delegate = self
        tasks.dataSource = self


    
        
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
           headerView.setTitle("My Schedule")  // Change this for each screen
    }
    
    
    
    
    

    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
