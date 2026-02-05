import Foundation

@main
struct ScanAssetsMain {
    static func main() {
        // #region agent log
        func debugLog(_ message: String, hypothesisId: String, data: [String: Any], location: String) {
            let payload: [String: Any] = [
                "sessionId": "debug-session",
                "runId": "pre-fix",
                "hypothesisId": hypothesisId,
                "location": location,
                "message": message,
                "data": data,
                "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            ]
            guard let json = try? JSONSerialization.data(withJSONObject: payload),
                  let jsonString = String(data: json, encoding: .utf8),
                  let lineData = (jsonString + "\n").data(using: .utf8)
            else { return }
            let logURL = URL(fileURLWithPath: "/Users/claudianapolitano/Downloads/DyslexiaApp-main/Leggy 2.swiftpm/.cursor/debug.log")
            if !FileManager.default.fileExists(atPath: logURL.path) {
                FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            if let handle = try? FileHandle(forWritingTo: logURL) {
                handle.seekToEndOfFile()
                handle.write(lineData)
                try? handle.close()
            }
        }
        // #endregion
        
        let rootPath = FileManager.default.currentDirectoryPath
        // #region agent log
        debugLog(
            "scan_start",
            hypothesisId: "H1",
            data: ["rootPath": rootPath],
            location: "scan_assets.swift:scan_start"
        )
        // #endregion
        
        var assetPaths: [String] = []
        if let enumerator = FileManager.default.enumerator(atPath: rootPath) {
            for case let path as String in enumerator {
                if path.hasSuffix("Assets.xcassets") {
                    assetPaths.append(path)
                }
            }
        }
        
        // #region agent log
        debugLog(
            "assets_found",
            hypothesisId: "H1",
            data: ["count": assetPaths.count, "paths": assetPaths],
            location: "scan_assets.swift:assets_found"
        )
        // #endregion
        
        let hasDuplicates = assetPaths.count > 1
        // #region agent log
        debugLog(
            "duplicates_check",
            hypothesisId: "H2",
            data: ["hasDuplicates": hasDuplicates],
            location: "scan_assets.swift:duplicates_check"
        )
        // #endregion
    }
}
