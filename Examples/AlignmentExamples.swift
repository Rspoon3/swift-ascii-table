#!/usr/bin/env swift

// This file uses the same inline source as BasicExamples.swift
// In production, you'd just: import ASCIITable

import Foundation

// MARK: - Copy of all source code (same as BasicExamples.swift)
public enum Alignment { case left, center, right }
public enum HorizontalRule { case none, frame, header, all }
public enum VerticalRule { case none, frame, all }

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

extension String {
    var displayWidth: Int {
        var width = 0
        for scalar in unicodeScalars {
            let value = scalar.value
            if (0x1100...0x115F).contains(value) || (0x2E80...0x2EFF).contains(value) ||
               (0x3000...0x303F).contains(value) || (0x3040...0x309F).contains(value) ||
               (0x30A0...0x30FF).contains(value) || (0x3100...0x312F).contains(value) ||
               (0x3130...0x318F).contains(value) || (0x3190...0x319F).contains(value) ||
               (0x31A0...0x31BF).contains(value) || (0x31C0...0x31EF).contains(value) ||
               (0x31F0...0x31FF).contains(value) || (0x3200...0x32FF).contains(value) ||
               (0x3300...0x33FF).contains(value) || (0x3400...0x4DBF).contains(value) ||
               (0x4DC0...0x4DFF).contains(value) || (0x4E00...0x9FFF).contains(value) ||
               (0xA000...0xA48F).contains(value) || (0xA490...0xA4CF).contains(value) ||
               (0xAC00...0xD7AF).contains(value) || (0xF900...0xFAFF).contains(value) ||
               (0xFE10...0xFE1F).contains(value) || (0xFE30...0xFE4F).contains(value) ||
               (0xFF00...0xFF60).contains(value) || (0xFFE0...0xFFE6).contains(value) {
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
        case .left: return self + String(repeating: " ", count: padding)
        case .right: return String(repeating: " ", count: padding) + self
        case .center:
            let leftPad = padding / 2
            let rightPad = padding - leftPad
            return String(repeating: " ", count: leftPad) + self + String(repeating: " ", count: rightPad)
        }
    }
}

struct TableRenderer {
    let columns: [String]
    let rows: [[String]]
    let config: TableConfiguration

    func computeColumnWidths() -> [Int] {
        guard !columns.isEmpty else { return [] }
        var widths = columns.map { $0.displayWidth }
        for row in rows {
            for (index, cell) in row.enumerated() where index < widths.count {
                widths[index] = max(widths[index], cell.displayWidth)
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
            parts.append(String(repeating: config.horizontalChar, count: width + config.padding * 2))
            if index < widths.count - 1 {
                parts.append(String(config.vrules == .all ? config.junctionChar : config.horizontalChar))
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
            let align = config.alignment[columns[index]] ?? config.defaultAlignment
            let paddedCell = cell.padded(to: widths[index], alignment: align)
            parts.append(String(repeating: " ", count: config.padding))
            parts.append(paddedCell)
            parts.append(String(repeating: " ", count: config.padding))
            if index < rowData.count - 1 {
                parts.append(String(config.vrules == .all ? config.verticalChar : " "))
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
        if config.hrules != .none { output.append(renderHorizontalRule(widths: widths)) }
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

public class ASCIITable {
    private var columns: [String]
    private var rows: [[String]]
    private var config: TableConfiguration

    public init(columns: [String] = []) {
        self.columns = columns
        self.rows = []
        self.config = TableConfiguration()
    }

    @discardableResult public func addRow(_ row: [String]) -> Self { rows.append(row); return self }
    @discardableResult public func columns(_ columns: [String]) -> Self { self.columns = columns; return self }
    @discardableResult public func border(_ enabled: Bool) -> Self { config.border = enabled; return self }
    @discardableResult public func horizontalRules(_ hrules: HorizontalRule) -> Self { config.hrules = hrules; return self }
    @discardableResult public func verticalRules(_ vrules: VerticalRule) -> Self { config.vrules = vrules; return self }
    @discardableResult public func padding(_ width: Int) -> Self { config.padding = max(0, width); return self }
    @discardableResult public func header(_ show: Bool) -> Self { config.header = show; return self }
    @discardableResult public func alignment(_ align: Alignment, for column: String? = nil) -> Self {
        if let column = column { config.alignment[column] = align }
        else { config.defaultAlignment = align }
        return self
    }
    public func render() -> String {
        TableRenderer(columns: columns, rows: rows, config: config).render()
    }
}

// MARK: - Alignment Examples

print("=============================================")
print("  SWIFT ASCII TABLE - ALIGNMENT EXAMPLES")
print("=============================================\n")

// Example 1: Left Alignment (Default)
print("Example 1: Left Alignment (Default)")
print("------------------------------------")
let table1 = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Alice", "30", "NYC"])
    .addRow(["Bob", "25", "SF"])
    .alignment(.left)
print(table1.render())
print()

// Example 2: Center Alignment
print("Example 2: Center Alignment")
print("---------------------------")
let table2 = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Alice", "30", "NYC"])
    .addRow(["Bob", "25", "SF"])
    .alignment(.center)
print(table2.render())
print()

// Example 3: Right Alignment
print("Example 3: Right Alignment")
print("--------------------------")
let table3 = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Alice", "30", "NYC"])
    .addRow(["Bob", "25", "SF"])
    .alignment(.right)
print(table3.render())
print()

// Example 4: Mixed Alignment - Financial Report
print("Example 4: Mixed Alignment - Financial Report")
print("---------------------------------------------")
let table4 = ASCIITable(columns: ["Item", "Quantity", "Price", "Total"])
    .addRow(["Widget A", "100", "$10.00", "$1,000.00"])
    .addRow(["Gadget B", "50", "$25.50", "$1,275.00"])
    .addRow(["Thing C", "200", "$5.00", "$1,000.00"])
    .addRow(["Total", "", "", "$3,275.00"])
    .alignment(.left, for: "Item")
    .alignment(.center, for: "Quantity")
    .alignment(.right, for: "Price")
    .alignment(.right, for: "Total")
print(table4.render())
print()

// Example 5: Sports Standings
print("Example 5: Sports Standings")
print("---------------------------")
let table5 = ASCIITable(columns: ["Team", "W", "L", "PCT", "GB"])
    .addRow(["Yankees", "95", "67", ".586", "-"])
    .addRow(["Red Sox", "92", "70", ".568", "3.0"])
    .addRow(["Blue Jays", "89", "73", ".549", "6.0"])
    .addRow(["Rays", "80", "82", ".494", "15.0"])
    .addRow(["Orioles", "52", "110", ".321", "43.0"])
    .alignment(.left, for: "Team")
    .alignment(.center, for: "W")
    .alignment(.center, for: "L")
    .alignment(.right, for: "PCT")
    .alignment(.right, for: "GB")
print(table5.render())
print()

// Example 6: Different Column Widths
print("Example 6: Variable Width Columns")
print("----------------------------------")
let table6 = ASCIITable(columns: ["Short", "A Longer Column Name", "X"])
    .addRow(["A", "Some text here", "1"])
    .addRow(["B", "More text", "2"])
    .alignment(.left, for: "Short")
    .alignment(.center, for: "A Longer Column Name")
    .alignment(.right, for: "X")
print(table6.render())
print()

// Example 7: Numbers Table
print("Example 7: Number Alignment")
print("---------------------------")
let table7 = ASCIITable(columns: ["ID", "Value", "Percentage"])
    .addRow(["1", "1234567", "85.5%"])
    .addRow(["2", "89", "12.3%"])
    .addRow(["3", "45678", "99.9%"])
    .addRow(["4", "123", "0.1%"])
    .alignment(.center, for: "ID")
    .alignment(.right, for: "Value")
    .alignment(.right, for: "Percentage")
print(table7.render())
print()

print("=============================================")
print("  Tip: Right-align numbers for easy comparison!")
print("  Tip: Center-align headers with left-align data")
print("=============================================")
