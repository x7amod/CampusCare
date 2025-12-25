import UIKit
import FSCalendar
import FirebaseFirestore

class Schedule: UIViewController,
                FSCalendarDelegate,
                FSCalendarDataSource,
                UITableViewDelegate,
                UITableViewDataSource {

    // MARK: - Data
    var assignTechID: String = ""
    let requestCollection = RequestCollection()
    var tasksForSelectedDate: [RequestModel] = []

    // MARK: - Outlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tasks: UITableView!
    
    func testTimezoneConversion() {
        print("\nTESTING TIMEZONE CONVERSION")
        
        // Test date: November 27, 2025
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 27
        components.hour = 0
        components.minute = 0
        
        guard let testDate = Calendar.current.date(from: components) else { return }
        
        let calendar = Calendar.current
        let startOfDayLocal = calendar.startOfDay(for: testDate)
        
        print("Test Date: \(testDate.toStringLocal())")
        print("Start of Day (Local): \(startOfDayLocal.toStringLocal())")
        print("Start of Day (UTC): \(startOfDayLocal.utcString())")
        
        // Convert to Timestamp and back
        let timestamp = Timestamp(date: startOfDayLocal)
        let timestampDate = timestamp.dateValue()
        
        print("Timestamp seconds: \(timestamp.seconds)")
        print("Timestamp back to Date: \(timestampDate.toStringLocal())")
        print("Timestamp back to Date (UTC): \(timestampDate.utcString())")
        
        // Test what Firestore actually sees
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Local
        formatter.timeZone = TimeZone.current
        print("Local representation: \(formatter.string(from: startOfDayLocal))")
        
        // UTC
        formatter.timeZone = TimeZone(identifier: "UTC")
        print("UTC representation: \(formatter.string(from: startOfDayLocal))")
    }
    
    // View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        testTimezoneConversion()
        // Debug date comparison first
        //debugDateComparison()
        
          // Create test document
         // createTestDocument()
        
        
        // Fix NaN errors in FSCalendar
        calendar.placeholderType = .none  // Hide dates from other months
        calendar.appearance.eventDefaultColor = .systemBlue
        calendar.appearance.eventSelectionColor = .systemBlue
      
        
        guard let techID = UserStore.shared.currentTechID else {
            showAlert(title: "Error", message: "Technician not logged in")
            return
        }
        
        assignTechID = techID
        print("Current Tech ID: \(assignTechID)")

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
        tasks.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        // Header
        let headerView = Bundle.main
            .loadNibNamed("CampusCareHeader", owner: nil, options: nil)?
            .first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        headerView.setTitle("My Schedule")
        view.addSubview(headerView)
        
        // Debug existing data
        debugFirestoreData()
        
        // Select today by default
        DispatchQueue.main.async {
            let today = Date()
            self.calendar.select(today)
            self.fetchTasks(for: today)
        }
    }
    
    // Debug Functions
    func debugDateComparison() {
        print("\nDEBUG DATE COMPARISON")
        
        // Create test dates
        let now = Date()
        let normalizedNow = now.normalized()
        
        print("Current Date: \(now.formattedString)")
        print("Normalized Current Date: \(normalizedNow.formattedString)")
        
        // Test with your test date (Nov 26, 2025)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.year = 2025
        components.month = 11
        components.day = 26
        components.hour = 10
        components.minute = 0
        
        if let testDate = Calendar.current.date(from: components) {
            let normalizedTest = testDate.normalized()
            let startOfTestDay = Calendar.current.startOfDay(for: testDate)
            let endOfTestDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfTestDay)
            
            print("\nTest Date (Nov 26, 2025 10:00 AM):")
            print("  Raw: \(testDate.formattedString)")
            print("  Normalized: \(normalizedTest.formattedString)")
            print("  Start of Day: \(startOfTestDay.formattedString)")
            print("  End of Day: \(endOfTestDay?.formattedString ?? "N/A")")
            
            // Check if dates are in the same day
            let calendar = Calendar.current
            let isSameDay = calendar.isDate(testDate, inSameDayAs: normalizedTest)
            print("  Is same day? \(isSameDay)")
            
            // Check what Firestore query would use
            print("\nFirestore Query would use:")
            print("  selectedDate: \(testDate.formattedString)")
            print("  startOfDay: \(startOfTestDay.formattedString)")
            print("  endOfDay: \(endOfTestDay?.formattedString ?? "N/A")")
        }
    }
    
    // Test Functions
    func createTestDocument() {
        let db = Firestore.firestore()
        
        // Create a date for November 26, 2025
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.year = 2025
        components.month = 11
        components.day = 26
        components.hour = 10
        components.minute = 0
        
        guard let testDate = Calendar.current.date(from: components) else {
            print("Could not create test date")
            return
        }
        
        print("\n Creating test document with date:")
        print("   Raw date: \(testDate.formattedString)")
        print("   Normalized: \(testDate.normalized().formattedString)")
        
        // Create a clean dictionary without nil values
        let testData: [String: Any] = [
            "category": "Test",
            "description": "Test task for debugging",
            "imageURL": "",
            "location": "Test Location",
            "priority": "Medium",
            "title": "DEBUG TEST TASK",
            "status": "Assigned",
            "releaseDate": Timestamp(date: Date()),
            "creatorID": "debug_user",
            "creatorRole": "Admin",
            "assignTechID": "L9MGa8esCfQNcLOKed3VjrXHvio2",
            "assignedDate": Timestamp(date: testDate),
            "lastUpdateDate": Timestamp(date: Date())
        ]
        
        db.collection("Requests").addDocument(data: testData) { error in
            if let error = error {
                print(" Failed to add test: \(error.localizedDescription)")
            } else {
                print("Test document created!")
                print("   Tech ID: L9MGa8esCfQNcLOKed3VjrXHvio2")
                print("   Date: November 26, 2025 (\(testDate.formattedString))")
                print("   Normalized Date: \(testDate.normalized().formattedString)")
                
                // Test the query immediately
                self.testQuery()
            }
        }
    }
    
    func testQuery() {
        print("\n TESTING QUERY...")
        
        let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 26))!
        let normalizedTestDate = testDate.normalized()
        
        print("   Query Date: \(testDate.formattedString)")
        print("   Normalized Query Date: \(normalizedTestDate.formattedString)")
        
        requestCollection.getRequestsForDate(
            assignTechID: "L9MGa8esCfQNcLOKed3VjrXHvio2",
            selectedDate: testDate
        ) { requests in
            print("🧪 Query result: \(requests.count) tasks")
            for request in requests {
                if let assignedDate = request.assignedDate {
                    let taskDate = assignedDate.dateValue()
                    let normalizedTaskDate = taskDate.normalized()
                    print("   • \(request.title)")
                    print("     Task Date: \(taskDate.formattedString)")
                    print("     Normalized: \(normalizedTaskDate.formattedString)")
                    print("     Matches query date? \(normalizedTaskDate == normalizedTestDate)")
                } else {
                    print("   • \(request.title) - NO DATE")
                }
            }
        }
    }
    
    // Calendar Delegate
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        print("\n Calendar selected date: \(date.formattedString)")
        print("   Normalized selected date: \(date.normalized().formattedString)")
        fetchTasks(for: date)
    }
    
    // MARK:- Fetch Tasks
    func fetchTasks(for date: Date) {
        print("\n Fetching tasks for date: \(date.formattedString)")
        print("   Tech ID being used: \(assignTechID)")
        print("   Normalized date: \(date.normalized().formattedString)")
        
        tasksForSelectedDate.removeAll()
        tasks.reloadData()
        
        requestCollection.getRequestsForDate(
            assignTechID: assignTechID,
            selectedDate: date
        ) { [weak self] requests in
            guard let self = self else { return }
            
            print("\n Received \(requests.count) tasks")
            
            if requests.isEmpty {
                print("No tasks received! Possible issues:")
                print("   1. No documents match the query")
                print("   2. Tech ID mismatch: \(self.assignTechID)")
                print("   3. Date range issue for: \(date.formattedString)")
                print("   4. Firestore query returning empty")
            }
            
            // Debug each task
            for (index, task) in requests.enumerated() {
                print("   \(index + 1). \(task.title)")
                print("      Tech ID: \(task.assignTechID)")
                print("      Status: \(task.status)")
                print("      Priority: \(task.priority)")
                if let assignedDate = task.assignedDate {
                    let assignedDateNormalized = assignedDate.dateValue().normalized()
                    print("      Assigned Date: \(assignedDate.dateValue().formattedString)")
                    print("      Normalized: \(assignedDateNormalized.formattedString)")
                    print("      Matches selected date? \(assignedDateNormalized == date.normalized())")
                } else {
                    print("      Assigned Date: nil")
                }
                print("      Location: \(task.location)")
            }
            
            self.tasksForSelectedDate = requests
            
            DispatchQueue.main.async {
                self.tasks.reloadData()
                self.updateCalendarDots()
            }
        }
    }
    
    func debugFirestoreData() {
        let db = Firestore.firestore()
        
        print("\n === DEBUGGING FIRESTORE DATA ===")
        
        // Test 1: Query ALL documents to see what's there
        db.collection("Requests").getDocuments { snapshot, error in
            if let error = error {
                print(" Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("📭 No documents at all in Requests collection")
                return
            }
            
            print(" Total documents in Requests: \(documents.count)")
            
            for document in documents {
                let data = document.data()
                print("\n Document ID: \(document.documentID)")
                print("   assignTechID: \(data["assignTechID"] as? String ?? "MISSING")")
                print("   title: \(data["title"] as? String ?? "No title")")
                print("   status: \(data["status"] as? String ?? "No status")")
                
                if let assignedDate = data["assignedDate"] as? Timestamp {
                    let dateValue = assignedDate.dateValue()
                    print("   assignedDate: \(dateValue.formattedString)")
                    print("   assignedDate normalized: \(dateValue.normalized().formattedString)")
                } else {
                    print("   assignedDate: nil")
                }
                
                // Check for our test technician
                if let techID = data["assignTechID"] as? String,
                   techID == "L9MGa8esCfQNcLOKed3VjrXHvio2" {
                    print("    THIS IS OUR TEST DOCUMENT!")
                }
            }
            
            print("🔍 === END DEBUG ===")
            
            // Now check specifically for our technician
            self.checkTechnicianTasks()
        }
    }
    
    func checkTechnicianTasks() {
        let db = Firestore.firestore()
        print("\nChecking tasks for technician: \(assignTechID)")
        
        db.collection("Requests")
            .whereField("assignTechID", isEqualTo: assignTechID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print(" No tasks assigned to this technician")
                    return
                }
                
                print(" Technician has \(documents.count) tasks:")
                for (index, document) in documents.enumerated() {
                    let data = document.data()
                    print("   \(index + 1). \(data["title"] as? String ?? "Untitled")")
                    if let date = data["assignedDate"] as? Timestamp {
                        print("     Date: \(date.dateValue().formattedString)")
                        print("     Normalized: \(date.dateValue().normalized().formattedString)")
                    } else {
                        print("     Date: Not assigned")
                    }
                }
            }
    }
    
    // MARK:- Update Calendar Dots
    func updateCalendarDots() {
        print("\n Updating calendar dots...")
        print("   Total tasks: \(tasksForSelectedDate.count)")
        
        // Collect dates that have tasks
        let datesWithTasks = tasksForSelectedDate.compactMap { request -> Date? in
            guard let assignedDate = request.assignedDate else {
                print("   Skipping task '\(request.title)' - no assigned date")
                return nil
            }
            
            let normalized = assignedDate.dateValue().normalized()
            print("   Task '\(request.title)' date: \(assignedDate.dateValue().formattedString) -> normalized: \(normalized.formattedString)")
            return normalized
        }
        
        // Remove duplicates
        let uniqueDates = Array(Set(datesWithTasks))
        print("   Unique dates with tasks: \(uniqueDates.count)")
        for date in uniqueDates.sorted() {
            print("   - \(date.formattedString)")
        }
        
        // Update calendar appearance
        calendar.reloadData()
        
        // Force calendar to refresh dots immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.calendar.reloadData()
        }
    }
    
    //  Calendar Data Source for Dots
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let normalizedDate = date.normalized()
        
        // Count tasks for this date
        let matchingTasks = tasksForSelectedDate.filter { request in
            guard let assignedDate = request.assignedDate else { return false }
            let taskDateNormalized = assignedDate.dateValue().normalized()
            let matches = taskDateNormalized == normalizedDate
            
            if matches {
                print("Calendar dot match for \(normalizedDate.formattedString): \(request.title)")
            }
            
            return matches
        }
        
        let count = matchingTasks.count
        
        if count > 0 {
            print(" Calendar shows dot for \(normalizedDate.formattedString): \(count) tasks")
        }
        
        return count > 0 ? 1 : 0
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let count = tasksForSelectedDate.isEmpty ? 1 : tasksForSelectedDate.count
        print("TableView rows: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.backgroundColor = .white
        
        if tasksForSelectedDate.isEmpty {
            cell.textLabel?.text = "No tasks for this day"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            cell.selectionStyle = .none
            print("Creating 'No tasks' cell")
        } else {
            let task = tasksForSelectedDate[indexPath.row]
            
            // Format assigned date if available
            let dateString: String
            if let assignedDate = task.assignedDate {
                dateString = assignedDate.dateValue().toStringLocal(format: "h:mm a")
                print("📋 Creating cell for task: \(task.title) at \(dateString)")
            } else {
                dateString = "No time set"
                print("📋 Creating cell for task: \(task.title) (no time)")
            }
            
            cell.textLabel?.text = "\(task.title) • \(task.status) • \(dateString)"
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .default
            
            // Color code by priority
            switch task.priority.lowercased() {
            case "high":
                cell.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
            case "medium":
                cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
            case "low":
                cell.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
            default:
                cell.backgroundColor = .white
            }
        }
        
        return cell
    }
    
    //  TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !tasksForSelectedDate.isEmpty else { return }
        
        let task = tasksForSelectedDate[indexPath.row]
        showTaskDetails(task: task)
    }
    
    private func showTaskDetails(task: RequestModel) {
        var details = """
        Title: \(task.title)
        Category: \(task.category)
        Priority: \(task.priority)
        Status: \(task.status)
        Location: \(task.location)
        
        Description:
        \(task.description)
        
        Dates:
        Created: \(task.releaseDate.toReadableString())
        """
        
        if let assignedDate = task.assignedDate {
            details += "\nAssigned: \(assignedDate.toReadableString())"
        }
        
        if let inProgressDate = task.inProgressDate {
            details += "\nStarted: \(inProgressDate.toReadableString())"
        }
        
        if let completedDate = task.completedDate {
            details += "\nCompleted: \(completedDate.toReadableString())"
        }
        
        let alert = UIAlertController(
            title: "Task Details",
            message: details,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

