//
//  AdminViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore
import DGCharts

class AdminAnalytics: UIViewController {
    
    //Outlit
    @IBOutlet weak var techNum: UILabel!
    @IBOutlet weak var reqNum: UILabel!
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak  var OpenRequestView: UIView!
    @IBOutlet weak var AvTechView: UIView!
    
    //collection
    let requestCollection = RequestCollection()
    private let usersCollection = UsersCollection()
    
    
    //charts
    var barChartView: BarChartView!
    var lineChartView: LineChartView!
    
    //var
    private var requests: [RequestModel] = []
    var HighPriorityRequests: [RequestModel] = []
    var LowPriorityRequests: [RequestModel] = []
    var MidPriorityRequests: [RequestModel] = []
    
    var numRequest : Int = 0
    var openRequest : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupHeader()
        fetchTechnicians()
        FetchRequests()
        setupChart()
        setupShadow()
        
    }
    
    private func setupShadow() {

        // AvTechView shadow
        AvTechView.layer.shadowColor = UIColor.black.cgColor
        AvTechView.layer.shadowOpacity = 0.25
        AvTechView.layer.shadowOffset = CGSize(width: 0, height: 4)
        AvTechView.layer.shadowRadius = 3
        AvTechView.layer.masksToBounds = false

        // OpenRequestView shadow
        OpenRequestView.layer.shadowColor = UIColor.black.cgColor
        OpenRequestView.layer.shadowOpacity = 0.25
        OpenRequestView.layer.shadowOffset = CGSize(width: 0, height: 4)
        OpenRequestView.layer.shadowRadius = 3
        OpenRequestView.layer.masksToBounds = false
    }

    
    private func setupChart(){
        let containerFrame = chartContainer.bounds
        
        barChartView = BarChartView(frame: containerFrame)
        barChartView.isHidden = false
        chartContainer.addSubview(barChartView)
        
        lineChartView = LineChartView(frame: containerFrame)
        lineChartView.isHidden = true
        chartContainer.addSubview(lineChartView)
    }
    
    @IBAction func chartChange(_ sender: UISegmentedControl) {
        print("Segment tapped: \(sender.selectedSegmentIndex)") // Debug print
        showChart(index: sender.selectedSegmentIndex)
    }
    
    private func showChart(index: Int) {
        switch index {
        case 0:
            barChartView.isHidden = false
            lineChartView.isHidden = true
        case 1:
            barChartView.isHidden = true
            lineChartView.isHidden = false
        default:
            print("not exist")
        }
    }

    private func setupHeader() {
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
        headerView.setTitle("Analytics")  // Change this for each screen
    }
    
    private func fetchTechnicians() {
        usersCollection.fetchTechnicians { users in
            let techUsers = users.filter { $0.Role == "Technician" }
            
            DispatchQueue.main.async {
                self.techNum.text = "\(techUsers.count)" // update the label with Tech count
            }
        }
    }
    
    
    private func FetchRequests() {
        requestCollection.fetchAllRequests { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let list):
                    
                    self.requests = list
                    self.numRequest = list.count
                    self.openRequest = list.filter { $0.status != "Completed" }.count
                    
                    self.reqNum.text = "\(self.numRequest)"
                    
                    self.prepareAnalyticsData()
                    
                case .failure(let error):
                    print("Error fetching requests: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    private func prepareAnalyticsData() {
        preparePriorityData()
        prepareRequestsOverTime()
    }
    
    private func preparePriorityData() {
        
        HighPriorityRequests = requests.filter { $0.priority == "High" }
        MidPriorityRequests  = requests.filter { $0.priority == "Medium" }
        LowPriorityRequests  = requests.filter { $0.priority == "Low" }
        
        let highCount = HighPriorityRequests.count
        let midCount  = MidPriorityRequests.count
        let lowCount  = LowPriorityRequests.count
        
        let entries = [
            BarChartDataEntry(x: 0, y: Double(lowCount)),
            BarChartDataEntry(x: 1, y: Double(midCount)),
            BarChartDataEntry(x: 2, y: Double(highCount))
        ]
        
        let dataSet = BarChartDataSet(entries: entries, label: "Requests by Priority")
        
        dataSet.colors = [
            UIColor(red: 254/255, green: 247/255, blue: 94/255, alpha: 1),  // Low
            UIColor(red: 255/255, green: 160/255, blue: 105/255, alpha: 1), // Medium
            UIColor(red: 242/255, green: 109/255, blue: 109/255, alpha: 1)  // High
        ]
        
        // Values above bars as integers
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 12)
        
        let data = BarChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(decimals: 0))
        data.barWidth = 0.5
        barChartView.data = data
        
        
        // X Axis
        let xAxis = barChartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Low", "Medium", "High"])
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        
        // Left Axis
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = Double(self.numRequest)
        leftAxis.granularity = 1
        // Force integers on axis
        leftAxis.valueFormatter = DefaultAxisValueFormatter { (value, _) -> String in
            return "\(Int(value))"
        }
        
        barChartView.rightAxis.enabled = false
        barChartView.animate(yAxisDuration: 1.0)
        barChartView.legend.enabled = false
        barChartView.chartDescription.enabled = false
    }
    
    private func prepareRequestsOverTime() {
        
        let groupedByMonth = Dictionary(grouping: requests) { request -> Int in
            let date = request.releaseDate.dateValue()
            let components = Calendar.current.dateComponents([.month], from: date)
            return components.month ?? 1
        }
        
        let monthIndices = Array(1...12)
        let monthLabels = ["Jan","Feb","Mar","Apr","May","Jun",
                           "Jul","Aug","Sep","Oct","Nov","Dec"]
        
        var entries: [ChartDataEntry] = []
        for (i, month) in monthIndices.enumerated() {
            let count = groupedByMonth[month]?.count ?? 0
            entries.append(ChartDataEntry(x: Double(i), y: Double(count)))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Requests per Month")
        let lineColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        dataSet.colors = [lineColor]
        dataSet.circleColors = [lineColor]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = lineColor.withAlphaComponent(0.2)
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 11)
        
        // Values above points as integers
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        data.setValueFormatter(DefaultValueFormatter(decimals: 0))

        // X-axis
        let xAxis = lineChartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: monthLabels)
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.labelRotationAngle = -30
        xAxis.axisMinimum = -0.5
        xAxis.axisMaximum = 11.5
        lineChartView.extraLeftOffset = 30
        lineChartView.extraRightOffset = 30
        lineChartView.extraBottomOffset = 30
        lineChartView.extraTopOffset = 10
        
        // Y-axis
        let maxY = entries.map { Int($0.y) }.max() ?? 0
        let leftAxis = lineChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = Double(maxY + 1)
        leftAxis.granularity = 1
        leftAxis.valueFormatter = DefaultAxisValueFormatter { (value, _) -> String in
            return "\(Int(value))"
        }
        
        lineChartView.rightAxis.enabled = false
        lineChartView.animate(xAxisDuration: 1.0)
        lineChartView.chartDescription.enabled = false
    }
    
    @IBAction func genReport(_ sender: Any) {
        let pdfMetaData = [
            kCGPDFContextCreator: "CampusCare",
            kCGPDFContextAuthor: "Admin",
            kCGPDFContextTitle: "Analytics Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        barChartView.isHidden = false
        lineChartView.isHidden = false
        
        let data = renderer.pdfData { context in
            
            func drawHeader(yPosition: CGFloat) -> CGFloat {
                var y = yPosition
                let title = "CampusCare Analytics Report"
                let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: (pageWidth - titleSize.width)/2, y: y), withAttributes: titleAttributes)
                y += titleSize.height + 20
                
                let infoText = "Total Requests: \(numRequest)\nOpen Requests: \(openRequest)"
                let infoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
                infoText.draw(at: CGPoint(x: 40, y: y), withAttributes: infoAttributes)
                y += 50
                return y
            }
            
            // Bar Chart
            context.beginPage()
            var yPos: CGFloat = 20
            yPos = drawHeader(yPosition: yPos)
            
            if let barImage = barChartView.getChartImage(transparent: false) {
                let aspectRatio = barImage.size.width / barImage.size.height
                let chartWidth = pageWidth - 80
                let chartHeight = chartWidth / aspectRatio
                barImage.draw(in: CGRect(x: 40, y: yPos, width: chartWidth, height: chartHeight))
            }
            
            //  Line Chart
            context.beginPage()
            yPos = 20
            yPos = drawHeader(yPosition: yPos)
            
            if let lineImage = lineChartView.getChartImage(transparent: false) {
                let aspectRatio = lineImage.size.width / lineImage.size.height
                let chartWidth = pageWidth - 80
                let chartHeight = chartWidth / aspectRatio
                lineImage.draw(in: CGRect(x: 40, y: yPos, width: chartWidth, height: chartHeight))
            }
        }
        
        // restore previous chart visibility
        lineChartView.isHidden = true
        
        // Save / share PDF
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("AnalyticsReport.pdf")
        do {
            try data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            present(activityVC, animated: true)
        } catch {
            print("Could not save PDF: \(error.localizedDescription)")
        }
    }


    
}
