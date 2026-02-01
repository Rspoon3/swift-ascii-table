import Foundation
import ASCIITable

/// Example demonstrating ANSI color support in ASCIITable.
///
/// This example shows how to use ANSI escape codes to add colors to table cells.
/// The table library automatically strips ANSI codes when calculating column widths,
/// so colors display correctly without breaking alignment.
///
/// Run this example with:
/// ```bash
/// swift run ANSIColorExample
/// ```

// ANSI Color Codes
enum ANSIColor {
    static let red = "\u{001B}[31m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
    static let magenta = "\u{001B}[35m"
    static let cyan = "\u{001B}[36m"
    static let reset = "\u{001B}[0m"

    /// Wraps text in the specified color
    static func colored(_ text: String, _ color: String) -> String {
        return "\(color)\(text)\(reset)"
    }
}

@main
struct ANSIColorExample {
    static func main() {
        print("\n🎨 ANSI Color Support Example\n")

        // Example 1: Simple colored table
        print("Example 1: Status indicators with colors")
        print(String(repeating: "─", count: 50))
        let statusTable = ASCIITable(columns: ["Task", "Status", "Priority"])
        statusTable.addRow([
            "Build project",
            ANSIColor.colored("✅ Complete", ANSIColor.green),
            ANSIColor.colored("High", ANSIColor.red)
        ])
        statusTable.addRow([
            "Run tests",
            ANSIColor.colored("⚠️  Warning", ANSIColor.yellow),
            ANSIColor.colored("Medium", ANSIColor.yellow)
        ])
        statusTable.addRow([
            "Deploy",
            ANSIColor.colored("❌ Failed", ANSIColor.red),
            ANSIColor.colored("Critical", ANSIColor.red)
        ])
        print(statusTable.render())

        // Example 2: Colored dates (like the use case in spm-audit)
        print("\n\nExample 2: Date aging visualization")
        print(String(repeating: "─", count: 50))
        let dateTable = ASCIITable(columns: ["Package", "Last Commit", "Status"])

        // Simulate different date ages with colors
        dateTable.addRow([
            "swift-algorithms",
            ANSIColor.colored("Jan 15, 2026", ANSIColor.green),  // Recent (green)
            "Active"
        ])
        dateTable.addRow([
            "old-package",
            ANSIColor.colored("Aug 10, 2025", ANSIColor.yellow), // 6 months (yellow)
            "Needs update"
        ])
        dateTable.addRow([
            "abandoned-lib",
            ANSIColor.colored("Mar 5, 2024", ANSIColor.red),     // >1 year (red)
            "Unmaintained"
        ])
        print(dateTable.render())

        // Example 3: Mixed content with emojis and colors
        print("\n\nExample 3: Mixed emojis and colors")
        print(String(repeating: "─", count: 50))
        let mixedTable = ASCIITable(columns: ["Feature", "Implementation", "Tests"])
        mixedTable.addRow([
            "Auth System",
            ANSIColor.colored("✅ Done", ANSIColor.green),
            ANSIColor.colored("✅ Passing", ANSIColor.green)
        ])
        mixedTable.addRow([
            "API Client",
            ANSIColor.colored("🚧 In Progress", ANSIColor.yellow),
            ANSIColor.colored("⏳ Pending", ANSIColor.yellow)
        ])
        mixedTable.addRow([
            "UI Components",
            ANSIColor.colored("📋 Planned", ANSIColor.cyan),
            ANSIColor.colored("❌ Not started", ANSIColor.red)
        ])
        print(mixedTable.render())

        // Example 4: Color legend
        print("\n\nColor Legend:")
        print(String(repeating: "─", count: 50))
        let legendTable = ASCIITable(columns: ["Color", "Meaning"])
        legendTable.addRow([ANSIColor.colored("■ Green", ANSIColor.green), "Good / Recent / Pass"])
        legendTable.addRow([ANSIColor.colored("■ Yellow", ANSIColor.yellow), "Warning / Moderate / Pending"])
        legendTable.addRow([ANSIColor.colored("■ Red", ANSIColor.red), "Error / Old / Fail"])
        legendTable.addRow([ANSIColor.colored("■ Blue", ANSIColor.blue), "Info / Note"])
        legendTable.addRow([ANSIColor.colored("■ Cyan", ANSIColor.cyan), "Planned / Future"])
        print(legendTable.render())

        print("\n✨ ANSI codes are automatically handled!")
        print("   Column widths are calculated correctly,")
        print("   and colors display properly in the terminal.\n")
    }
}
