import Foundation
import AppKit

final class ShortResetApp: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private var label: NSTextField!
    private let path = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/CodexBar/codex-account-snapshots.json")

    func applicationDidFinishLaunching(_ notification: Notification) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "gpt-quota-countdown"
        item.button?.toolTip = "GPT 5-hour quota · next reset"
        item.button?.title = ""
        label = NSTextField(labelWithString: "")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = NSColor.labelColor
        label.alignment = .left
        label.isBordered = false
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.lineBreakMode = .byClipping
        item.button?.addSubview(label)
        refresh()
        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in self?.refresh() }
    }

    private func updateText(_ value: String) {
        label.stringValue = value
        label.sizeToFit()
        if let button = item.button {
            item.length = ceil(label.fittingSize.width) + 3
            let h = max(18, label.fittingSize.height)
            label.frame = NSRect(x: 0, y: floor((button.bounds.height - h)/2) + 1, width: ceil(label.fittingSize.width) + 2, height: h)
        }
    }

    private func refresh() {
        updateText(remainingTime(reset: readReset(from: path), now: Date()))
    }
}

private func readReset(from url: URL) -> Date? {
    guard let data = try? Data(contentsOf: url),
          let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let records = root["records"] as? [[String: Any]],
          let first = records.first,
          let snapshot = first["snapshot"] as? [String: Any],
          let primary = snapshot["primary"] as? [String: Any],
          let window = primary["windowMinutes"] as? Int, window == 300,
          let timestamp = primary["resetsAt"] as? Double,
          timestamp.isFinite else { return nil }
    // The CodexBar cache serializes Swift Date values relative to 2001.
    return Date(timeIntervalSinceReferenceDate: timestamp)
}

private func remainingTime(reset: Date?, now: Date) -> String {
    guard let reset else { return "—" }
    let remaining = reset.timeIntervalSince(now)
    if remaining <= 0 { return "0m" }
    guard remaining <= 5 * 60 * 60 else { return "—" }
    let minutes = Int(ceil(remaining / 60))
    if minutes >= 60 {
        return "\(minutes / 60)h\(String(format: "%02d", minutes % 60))m"
    }
    return "\(minutes)m"
}

let arguments = CommandLine.arguments
if arguments.count == 4, arguments[1] == "--preview",
   let timestamp = Double(arguments[3]), timestamp.isFinite {
    let snapshot = URL(fileURLWithPath: arguments[2])
    print(remainingTime(reset: readReset(from: snapshot), now: Date(timeIntervalSince1970: timestamp)))
    exit(0)
}
if arguments.count != 1 {
    fputs("Usage: GPTQuotaCountdown [--preview SNAPSHOT_PATH UNIX_TIMESTAMP]\n", stderr)
    exit(2)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = ShortResetApp()
app.delegate = delegate
app.run()
