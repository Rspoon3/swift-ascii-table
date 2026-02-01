#!/usr/bin/env swift

import Foundation

// Copy the source files inline for standalone execution
// In production, you'd import ASCIITable

// MARK: - Alignment

public enum Alignment {
    case left, center, right
}

// MARK: - HorizontalRule

public enum HorizontalRule {
    case none, frame, header, all
}

// MARK: - VerticalRule

public enum VerticalRule {
    case none, frame, all
}

// MARK: - TableConfiguration

struct TableConfiguration {
    var border: Bool = true
    var hrules: HorizontalRule = .frame
    var vrules: VerticalRule = .all
    var padding: Int = 1
    var header: Bool = true
    var defaultAlignment: Alignment = .left
    var alignment: [String: Alignment] = [:]
    var horizontalChar: Character = "-"
    var verticalChar: Character = "|"
    var junctionChar: Character = "+"
}

// MARK: - UnicodeWidth Extension

extension String {
    var displayWidth: Int {
        var width = 0
        for scalar in unicodeScalars {
            let value = scalar.value
            if (0x1100...0x115F).contains(value) ||
               (0x2E80...0x2EFF).contains(value) ||
               (0x3000...0x303F).contains(value) ||
               (0x3040...0x309F).contains(value) ||
               (0x30A0...0x30FF).contains(value) ||
               (0x3100...0x312F).contains(value) ||
               (0x3130...0x318F).contains(value) ||
               (0x3190...0x319F).contains(value) ||
               (0x31A0...0x31BF).contains(value) ||
               (0x31C0...0x31EF).contains(value) ||
               (0x31F0...0x31FF).contains(value) ||
               (0x3200...0x32FF).contains(value) ||
               (0x3300...0x33FF).contains(value) ||
               (0x3400...0x4DBF).contains(value) ||
               (0x4DC0...0x4DFF).contains(value) ||
               (0x4E00...0x9FFF).contains(value) ||
               (0xA000...0xA48F).contains(value) ||
               (0xA490...0xA4CF).contains(value) ||
               (0xAC00...0xD7AF).contains(value) ||
               (0xF900...0xFAFF).contains(value) ||
               (0xFE10...0xFE1F).contains(value) ||
               (0xFE30...0xFE4F).contains(value) ||
               (0xFF00...0xFF60).contains(value) ||
               (0xFFE0...0xFFE6).contains(value) {
                width += 2
            } else if scalar.properties.isNoncharacterCodePoint {
                width += 0
            } else if (0x1F300...0x1F9FF).contains(value) {
                width += 2
            } else {
                width += 1
            }
        }
        return width
    }

    func padded(to width: Int, alignment: Alignment) -> String {
        let currentWidth = self.displayWidth
        guard currentWidth < width else { return self }
        let padding = width - currentWidth

        switch alignment {
        case .left:
            return self + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + self
        case .center:
            let leftPad = padding / 2
            let rightPad = padding - leftPad
            return String(repeating: " ", count: leftPad) + self + String(repeating: " ", count: rightPad)
        }
    }
}

// MARK: - TableRenderer

struct TableRenderer {
    let columns: [String]
    let rows: [[String]]
    let config: TableConfiguration

    func computeColumnWidths() -> [Int] {
        guard !columns.isEmpty else { return [] }
        var widths = columns.map { $0.displayWidth }
        for row in rows {
            for (index, cell) in row.enumerated() where index < widths.count {
                let cellWidth = cell.displayWidth
                if cellWidth > widths[index] {
                    widths[index] = cellWidth
                }
            }
        }
        return widths
    }

    func renderHorizontalRule(widths: [Int]) -> String {
        guard config.border else { return "" }
        var parts: [String] = []
        if config.vrules == .all || config.vrules == .frame {
            parts.append(String(config.junctionChar))
        }
        for (index, width) in widths.enumerated() {
            let line = String(repeating: config.horizontalChar, count: width + config.padding * 2)
            parts.append(line)
            if index < widths.count - 1 {
                if config.vrules == .all {
                    parts.append(String(config.junctionChar))
                } else {
                    parts.append(String(config.horizontalChar))
                }
            } else if config.vrules == .all || config.vrules == .frame {
                parts.append(String(config.junctionChar))
            }
        }
        return parts.joined()
    }

    func renderRow(_ rowData: [String], widths: [Int]) -> String {
        var parts: [String] = []
        if config.vrules == .all || config.vrules == .frame {
            parts.append(String(config.verticalChar))
        }
        for (index, cell) in rowData.enumerated() where index < widths.count {
            let columnName = columns[index]
            let alignment = config.alignment[columnName] ?? config.defaultAlignment
            let paddedCell = cell.padded(to: widths[index], alignment: alignment)
            parts.append(String(repeating: " ", count: config.padding))
            parts.append(paddedCell)
            parts.append(String(repeating: " ", count: config.padding))
            if index < rowData.count - 1 {
                if config.vrules == .all {
                    parts.append(String(config.verticalChar))
                } else if config.vrules == .frame {
                    parts.append(" ")
                }
            } else if config.vrules == .all || config.vrules == .frame {
                parts.append(String(config.verticalChar))
            }
        }
        return parts.joined()
    }

    func render() -> String {
        guard !columns.isEmpty else { return "" }
        var output: [String] = []
        let widths = computeColumnWidths()
        if config.hrules != .none {
            output.append(renderHorizontalRule(widths: widths))
        }
        if config.header {
            output.append(renderRow(columns, widths: widths))
            if config.hrules == .frame || config.hrules == .header || config.hrules == .all {
                output.append(renderHorizontalRule(widths: widths))
            }
        }
        for (index, row) in rows.enumerated() {
            output.append(renderRow(row, widths: widths))
            if config.hrules == .all && index < rows.count - 1 {
                output.append(renderHorizontalRule(widths: widths))
            }
        }
        if config.hrules == .frame || config.hrules == .all {
            output.append(renderHorizontalRule(widths: widths))
        }
        return output.joined(separator: "\n")
    }
}

// MARK: - ASCIITable

public class ASCIITable {
    private var columns: [String]
    private var rows: [[String]]
    private var config: TableConfiguration

    public init(columns: [String] = []) {
        self.columns = columns
        self.rows = []
        self.config = TableConfiguration()
    }

    @discardableResult
    public func addRow(_ row: [String]) -> Self {
        rows.append(row)
        return self
    }

    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns = columns
        return self
    }

    @discardableResult
    public func border(_ enabled: Bool) -> Self {
        config.border = enabled
        return self
    }

    @discardableResult
    public func horizontalRules(_ hrules: HorizontalRule) -> Self {
        config.hrules = hrules
        return self
    }

    @discardableResult
    public func verticalRules(_ vrules: VerticalRule) -> Self {
        config.vrules = vrules
        return self
    }

    @discardableResult
    public func padding(_ width: Int) -> Self {
        config.padding = max(0, width)
        return self
    }

    @discardableResult
    public func header(_ show: Bool) -> Self {
        config.header = show
        return self
    }

    @discardableResult
    public func alignment(_ align: Alignment, for column: String? = nil) -> Self {
        if let column = column {
            config.alignment[column] = align
        } else {
            config.defaultAlignment = align
        }
        return self
    }

    public func render() -> String {
        let renderer = TableRenderer(columns: columns, rows: rows, config: config)
        return renderer.render()
    }
}

// MARK: - Examples

print("========================================")
print("  SWIFT ASCII TABLE - BASIC EXAMPLES")
print("========================================\n")

// Example 1: Simple Table
print("Example 1: Simple Table")
print("------------------------")
let table1 = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Alice", "30", "New York"])
    .addRow(["Bob", "25", "San Francisco"])
    .addRow(["Charlie", "35", "Los Angeles"])
print(table1.render())
print()

// Example 2: Product Catalog
print("Example 2: Product Catalog")
print("---------------------------")
let table2 = ASCIITable(columns: ["Product", "Price", "Stock"])
    .addRow(["Laptop", "$1,299", "15"])
    .addRow(["Mouse", "$29", "150"])
    .addRow(["Keyboard", "$89", "75"])
    .addRow(["Monitor", "$399", "42"])
print(table2.render())
print()

// Example 3: Server Status
print("Example 3: Server Status")
print("------------------------")
let table3 = ASCIITable(columns: ["Server", "Status", "Uptime", "Load"])
    .addRow(["web-01", "Online", "99.9%", "23%"])
    .addRow(["web-02", "Online", "99.8%", "45%"])
    .addRow(["db-01", "Offline", "0%", "0%"])
    .addRow(["cache-01", "Online", "100%", "12%"])
print(table3.render())
print()

// Example 4: Grades
print("Example 4: Student Grades")
print("-------------------------")
let table4 = ASCIITable(columns: ["Student", "Math", "Science", "English", "Average"])
    .addRow(["Alice", "95", "88", "92", "91.7"])
    .addRow(["Bob", "78", "85", "90", "84.3"])
    .addRow(["Charlie", "92", "95", "87", "91.3"])
print(table4.render())
print()

// Example 5: Empty Table
print("Example 5: Empty Table (Headers Only)")
print("--------------------------------------")
let table5 = ASCIITable(columns: ["Column A", "Column B", "Column C"])
print(table5.render())
print()

// Example 6: Single Column
print("Example 6: Single Column")
print("------------------------")
let table6 = ASCIITable(columns: ["Numbers"])
    .addRow(["1"])
    .addRow(["2"])
    .addRow(["3"])
    .addRow(["4"])
    .addRow(["5"])
print(table6.render())
print()

print("========================================")
print("  Run 'swift Examples/AlignmentExamples.swift' for alignment demos")
print("  Run 'swift Examples/UnicodeExamples.swift' for Unicode demos")
print("========================================")
