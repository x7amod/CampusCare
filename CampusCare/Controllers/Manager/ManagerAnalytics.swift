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

class ManagerAnalytics: UIViewController {

    
    let requestCollection = RequestCollection()
    private var allRequests: [RequestModel] = []


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
        
        styleCard(totalRequestsCardView)
        styleCard(pendingTasksCardView)
        styleCard(completedTasksCardView)
        
//        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
//            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
//            view.addSubview(headerView)
//            headerView.setTitle("Analytics")
//        }

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
            $0.status.lowercased() == "completed"
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
        case 0: chartContainerView.addSubview(pieChartView)
        case 1: chartContainerView.addSubview(barChartView)
        case 2: chartContainerView.addSubview(lineChartView)
        default: break
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
            $0.status.lowercased() == "completed"
        }

        let grouped = Dictionary(grouping: completedRequests, by: { $0.assignTechID })

        let entries = grouped.map {
            PieChartDataEntry(
                value: Double($0.value.count),
                label: "Tech \($0.key)"
            )
        }

        let dataSet = PieChartDataSet(entries: entries, label: "Tasks per Technician")
        dataSet.colors = ChartColorTemplates.material()

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
        dataSet.colors = ChartColorTemplates.material()

        barChartView.data = BarChartData(dataSet: dataSet)
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
        dataSet.colors = [.systemBlue]

        lineChartView.data = LineChartData(dataSet: dataSet)
    }
    
    
    func updateAllCharts() {
        updatePieChart()
        updateBarChart()
        updateLineChart()

        showChart(index: chartTypeSegmentedControl.selectedSegmentIndex)
    }


}

