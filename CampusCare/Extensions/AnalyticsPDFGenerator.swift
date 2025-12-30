import UIKit
import DGCharts

final class AnalyticsPDFGenerator {

    //for genreate report
    static func generateReport(
        title: String,
        total: Int,
        open: Int? = nil,
        pending: Int? = nil,
        completed: Int? = nil,
        charts: [(String, ChartViewBase)],
        completion: @escaping (Data) -> Void
    ) {

        let pdfMetaData = [
            kCGPDFContextCreator: "CampusCare",
            kCGPDFContextAuthor: "System",
            kCGPDFContextTitle: title
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in

            func drawHeader(y: CGFloat) -> CGFloat {
                var yPos = y

                let titleAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ]
                let titleSize = title.size(withAttributes: titleAttr)
                title.draw(
                    at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPos),
                    withAttributes: titleAttr
                )

                yPos += titleSize.height + 20

                var infoLines: [String] = [
                    "Total Requests: \(total)"
                ]
                if let open = open { infoLines.append("Open Requests: \(open)") }
                if let pending = pending { infoLines.append("Pending Requests: \(pending)") }
                if let completed = completed { infoLines.append("Completed Requests: \(completed)") }

                let infoText = infoLines.joined(separator: "\n")
                infoText.draw(
                    at: CGPoint(x: 40, y: yPos),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 16)]
                )

                return yPos + CGFloat(infoLines.count * 22) + 20
            }

            for (chartTitle, chart) in charts {
                context.beginPage()
                var yPos: CGFloat = 20
                yPos = drawHeader(y: yPos)

                chartTitle.draw(
                    at: CGPoint(x: 40, y: yPos),
                    withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
                )

                yPos += 30

                if let image = chart.getChartImage(transparent: false) {
                    let ratio = image.size.width / image.size.height
                    let width = pageRect.width - 80
                    let height = width / ratio

                    image.draw(
                        in: CGRect(x: 40, y: yPos, width: width, height: height)
                    )
                }
            }
        }

        completion(data)
    }


    static func uploadSaveAndShare(
        from viewController: UIViewController,
        data: Data,
        filePrefix: String
    ) {

        let fileName = "\(filePrefix)_\(Int(Date().timeIntervalSince1970))"

        // upload to Cloudinary
        CloudinaryManager.shared.uploadPDF(data, fileName: fileName) { pdfURL in
            guard let pdfURL = pdfURL else {
                print(" Failed to upload PDF")
                return
            }

            // Save URL to Firestore
            let reportCollection = ReportCollection()
            reportCollection.createReport(url: pdfURL.absoluteString) { error in
                if let error = error {
                    print(" Firestore save error:", error.localizedDescription)
                } else {
                    print(" PDF URL saved to Firestore")
                }
            }

            // Save locally and share
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(fileName).pdf")

            do {
                try data.write(to: tempURL)

                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(
                        activityItems: [tempURL],
                        applicationActivities: nil
                    )
                    viewController.present(activityVC, animated: true)
                }

            } catch {
                print(" Could not save PDF locally:", error.localizedDescription)
            }
        }
    }
}

