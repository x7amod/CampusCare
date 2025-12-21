//
//  ManagerAnalytics.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//Malak
//

import UIKit
import DGCharts

class ManagerAnalytics: UIViewController {

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

    //Actions
    @IBAction func chartTypeChanged(_ sender: UISegmentedControl) {
        print("Segment tapped: \(sender.selectedSegmentIndex)") // Debug print
        showChart(index: sender.selectedSegmentIndex)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add header
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Analytics")
        }
    }

    //Ensure container bounds are set before creating charts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Only setup charts once
        if pieChartView == nil {
            setupCharts()
            chartTypeSegmentedControl.selectedSegmentIndex = 0 // default Pie chart
            showChart(index: 0)
        }
    }

    
    func setupCharts() {
        let containerFrame = chartContainerView.bounds

        // Pie Chart
        pieChartView = PieChartView(frame: containerFrame)
        pieChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let pieEntries = [
            PieChartDataEntry(value: 40, label: "Pending"),
            PieChartDataEntry(value: 60, label: "Completed")
        ]
        let pieDataSet = PieChartDataSet(entries: pieEntries)
        pieDataSet.colors = ChartColorTemplates.material()
        pieChartView.data = PieChartData(dataSet: pieDataSet)

        // Bar Chart
        barChartView = BarChartView(frame: containerFrame)
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let barEntries = [
            BarChartDataEntry(x: 1, y: 40),
            BarChartDataEntry(x: 2, y: 60)
        ]
        let barDataSet = BarChartDataSet(entries: barEntries, label: "Tasks")
        barDataSet.colors = ChartColorTemplates.material()
        barChartView.data = BarChartData(dataSet: barDataSet)

        // Line Chart
        lineChartView = LineChartView(frame: containerFrame)
        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let lineEntries = [
            ChartDataEntry(x: 1, y: 30),
            ChartDataEntry(x: 2, y: 70)
        ]
        let lineDataSet = LineChartDataSet(entries: lineEntries, label: "Tasks")
        lineDataSet.colors = [.systemBlue]
        lineChartView.data = LineChartData(dataSet: lineDataSet)
    }

    // Show selected chart
    func showChart(index: Int) {
        // Remove old chart
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }

        // Add selected chart
        switch index {
        case 0: chartContainerView.addSubview(pieChartView)
        case 1: chartContainerView.addSubview(barChartView)
        case 2: chartContainerView.addSubview(lineChartView)
        default: break
        }
    }
}

