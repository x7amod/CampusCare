//
//  ManagerAnalytics.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//Malak
//
//

import UIKit
import DGCharts
import FirebaseFirestore


class ManagerAnalytics: UIViewController {
    
    
    let formalBlueColors: [UIColor] = [
        UIColor(red: 0/255, green: 51/255, blue: 102/255, alpha: 1),   // Dark Blue
        UIColor(red: 0/255, green: 102/255, blue: 204/255, alpha: 1),  // Blue
        UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1), // Light Blue
        UIColor(red: 102/255, green: 178/255, blue: 255/255, alpha: 1), // Lighter Blue
        UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 1), // Soft Gray
           UIColor(red: 200/255, green: 230/255, blue: 201/255, alpha: 1), // Pastel Green
           UIColor(red: 255/255, green: 224/255, blue: 178/255, alpha: 1), // Pastel Orange
           UIColor(red: 225/255, green: 190/255, blue: 231/255, alpha: 1), // Pastel Purple
           UIColor(red: 255/255, green: 205/255, blue: 210/255, alpha: 1), // Pastel Red
           UIColor(red: 187/255, green: 222/255, blue: 251/255, alpha: 1), // Pastel Blue
           UIColor(red: 255/255, green: 245/255, blue: 157/255, alpha: 1), // Soft Yellow
           UIColor(red: 220/255, green: 237/255, blue: 200/255, alpha: 1)  // Sage Green
    
    ]

    
    let requestCollection = RequestCollection()
    private var allRequests: [RequestModel] = []
    private var techNameByID: [String: String] = [:]



    // Chart views
    var pieChartView: PieChartView!
    var barChartView: BarChartView!
    var lineChartView: LineChartView!

    // Outlets
    @IBOutlet weak var totalRequestsCardView: UIView!
    @IBOutlet weak var pendingTasksCardView: UIView!
    @IBOutlet weak var completedTasksCardView: UIView!

    @IBOutlet weak var totalNum: UILabel!
    @IBOutlet weak var pendingNum: UILabel!
    @IBOutlet weak var completedNum: UILabel!

    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chartContainerView: UIView!
    
    private func styleCard(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        view.backgroundColor = .white
    }


    @IBAction func chartTypeChanged(_ sender: UISegmentedControl) {
        showChart(index: sender.selectedSegmentIndex)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupCharts()
        chartTypeSegmentedControl.selectedSegmentIndex = 0
        showChart(index: 0)
        fetchAnalyticsData()
        loadTechnicians()

        
        styleCard(totalRequestsCardView)
        styleCard(pendingTasksCardView)
        styleCard(completedTasksCardView)


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure charts resize correctly
        pieChartView.frame = chartContainerView.bounds
        barChartView.frame = chartContainerView.bounds
        lineChartView.frame = chartContainerView.bounds
        
       
    }


    
    private func updateCards() {
        let total = allRequests.count

        let pending = allRequests.filter {
            $0.status.lowercased() == "pending"
        }.count

        let completed = allRequests.filter {
            $0.status.lowercased() == "complete"
        }.count

        totalNum.text = "\(total)"
        pendingNum.text = "\(pending)"
        completedNum.text = "\(completed)"
    }



    private func setupCharts() {
        let containerFrame = chartContainerView.bounds

        pieChartView = PieChartView(frame: containerFrame)
        pieChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        barChartView = BarChartView(frame: containerFrame)
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        lineChartView = LineChartView(frame: containerFrame)
        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    
    
    private func showChart(index: Int) {
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }
        switch index {
        case 0:
            chartContainerView.addSubview(pieChartView)
            chartTitle.text = "Tasks Per Technician"
        case 1:
            chartContainerView.addSubview(barChartView)
            chartTitle.text = "Average Resolution Time"
        case 2:
            chartContainerView.addSubview(lineChartView)
            chartTitle.text = "Weekly Resolution Trend"
        default: break
        }
    }
    
    func loadTechnicians() {
        requestCollection.fetchTechnicians { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let techMap):
                    self?.techNameByID = techMap
                    self?.updateAllCharts()

                case .failure(let error):
                    print("Failed to fetch technicians:", error)
                }
            }
        }
    }



    
    
    func fetchAnalyticsData() {
        requestCollection.fetchAllRequests { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    self?.allRequests = requests
                    self?.updateCards()
                    self?.updateAllCharts()

                case .failure(let error):
                    print("Analytics fetch error:", error)
                }
            }
        }
    }

    
    func updatePieChart() {
        let completedRequests = allRequests.filter {
            $0.status.lowercased() == "complete"
        }

        let grouped = Dictionary(grouping: completedRequests, by: { $0.assignTechID })

        let entries = grouped.map { (techID, requests) in
            let techName = techNameByID[techID] ?? "Unknown Technician"

            return PieChartDataEntry(
                value: Double(requests.count),
                label: techName
            )
        }

        let dataSet = PieChartDataSet(entries: entries, label: "Tasks per Technician")
        dataSet.colors = formalBlueColors

        pieChartView.data = PieChartData(dataSet: dataSet)
    }

    
    
    func updateBarChart() {
        let completed = allRequests.compactMap { request -> (String, Double)? in
            guard
                let completedDate = request.completedDate
            else { return nil }

            let hours = completedDate
                .dateValue()
                .timeIntervalSince(request.releaseDate.dateValue()) / 3600

            return (request.assignTechID, hours)
        }

        let grouped = Dictionary(grouping: completed, by: { $0.0 })

        var entries: [BarChartDataEntry] = []
        var index = 0.0

        for (_, values) in grouped {
            let avg = values.map { $0.1 }.reduce(0, +) / Double(values.count)
            entries.append(BarChartDataEntry(x: index, y: avg))
            index += 1
        }

        let dataSet = BarChartDataSet(entries: entries, label: "Avg Resolution Time (hrs)")
        dataSet.colors = formalBlueColors

        barChartView.data = BarChartData(dataSet: dataSet)
        
        let techNames = grouped.keys.map {
            techNameByID[$0] ?? "Unknown"
        }

        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: techNames)
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelPosition = .bottom

    }
    
    
    func updateLineChart() {
        
        let completedDates = allRequests.compactMap {
            $0.completedDate?.dateValue()
        }

        let grouped = Dictionary(grouping: completedDates) {
            Calendar.current.component(.weekOfYear, from: $0)
        }

        let entries = grouped
            .sorted { $0.key < $1.key }
            .map {
                ChartDataEntry(
                    x: Double($0.key),
                    y: Double($0.value.count)
                )
            }

        let dataSet = LineChartDataSet(entries: entries, label: "Weekly Completed Tasks")
        dataSet.colors = [formalBlueColors[1]]       
        dataSet.circleColors = [formalBlueColors[0]]
        dataSet.circleHoleColor = .white


        lineChartView.data = LineChartData(dataSet: dataSet)
    }
    
    
    func updateAllCharts() {
        updatePieChart()
        updateBarChart()
        updateLineChart()

        showChart(index: chartTypeSegmentedControl.selectedSegmentIndex)
    }


}

