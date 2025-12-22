//
//  Schedule.swift
//  CampusCare
//
//  Created by Malak on 29/11/2025.
//

import UIKit
import FSCalendar

class Schedule: UIViewController,
                FSCalendarDelegate,
                FSCalendarDataSource,
                UITableViewDelegate,
                UITableViewDataSource {

    // MARK: - Data
    let assignTechID = "123" // temporary (replace with logged-in user ID)
    let requestCollection = RequestCollection()
    var tasksForSelectedDate: [RequestModel] = []

    // MARK: - Outlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tasks: UITableView!
    

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Calendar setup
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .month
        calendar.headerHeight = 50
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
        calendar.appearance.headerTitleColor = .black

        // TableView setup
        tasks.delegate = self
        tasks.dataSource = self

        // Header
        let headerView = Bundle.main
            .loadNibNamed("CampusCareHeader", owner: nil, options: nil)?
            .first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        headerView.setTitle("My Schedule")
        view.addSubview(headerView)
    }

    // MARK: - Calendar Delegate
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        fetchTasks(for: date)
    }

    // MARK: - Fetch Tasks
    func fetchTasks(for date: Date) {
        tasksForSelectedDate.removeAll()

        requestCollection.fetchRequests(assignTechID: assignTechID, date: date) { [weak self] requests in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.tasksForSelectedDate = requests
                self.tasks.reloadData()
            }
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tasksForSelectedDate.isEmpty ? 1 : tasksForSelectedDate.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        if tasksForSelectedDate.isEmpty {
            cell.textLabel?.text = "No tasks for this day"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
        } else {
            let task = tasksForSelectedDate[indexPath.row]
            cell.textLabel?.text = "\(task.title) • \(task.status)"
            cell.textLabel?.textAlignment = .left
            cell.selectionStyle = .default
        }

        return cell
    }
}
