import PDFKit

override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
        name: "scanwise.native.merge",
        binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
        if call.method == "mergePdfs" {

            guard let args = call.arguments as? [String: Any],
                  let inputPaths = args["inputPaths"] as? [String],
                  let outputPath = args["outputPath"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
                return
            }

            let mergedDocument = PDFDocument()

            for path in inputPaths {
                if let doc = PDFDocument(url: URL(fileURLWithPath: path)) {
                    for i in 0..<doc.pageCount {
                        if let page = doc.page(at: i) {
                            mergedDocument.insert(page, at: mergedDocument.pageCount)
                        }
                    }
                }
            }

            mergedDocument.write(to: URL(fileURLWithPath: outputPath))
            result(outputPath)
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}