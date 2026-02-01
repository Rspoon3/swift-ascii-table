#!/usr/bin/env swift

// This file demonstrates border and rule configurations
// In production: import ASCIITable

import Foundation

// MARK: - Source code (same as other examples)
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
            return String(repeating: " ", count: leftPad) + self + String(repeating: " ", count: padding - leftPad)
        }
    }
}

struct TableRenderer {
    let columns: [String]; let rows: [[String]]; let config: TableConfiguration
    func computeColumnWidths() -> [Int] {
        guard !columns.isEmpty else { return [] }
        var widths = columns.map { $0.displayWidth }
        for row in rows { for (i, cell) in row.enumerated() where i < widths.count {
            widths[i] = max(widths[i], cell.displayWidth) } }
        return widths
    }
    func renderHorizontalRule(widths: [Int]) -> String {
        guard config.border else { return "" }
        var parts: [String] = []
        if config.vrules == .all || config.vrules == .frame { parts.append(String(config.junctionChar)) }
        for (i, w) in widths.enumerated() {
            parts.append(String(repeating: config.horizontalChar, count: w + config.padding * 2))
            if i < widths.count - 1 {
                parts.append(String(config.vrules == .all ? config.junctionChar : config.horizontalChar))
            } else if config.vrules == .all || config.vrules == .frame { parts.append(String(config.junctionChar)) }
        }
        return parts.joined()
    }
    func renderRow(_ rowData: [String], widths: [Int]) -> String {
        var parts: [String] = []
        if config.vrules == .all || config.vrules == .frame { parts.append(String(config.verticalChar)) }
        for (i, cell) in rowData.enumerated() where i < widths.count {
            let align = config.alignment[columns[i]] ?? config.defaultAlignment
            parts.append(String(repeating: " ", count: config.padding))
            parts.append(cell.padded(to: widths[i], alignment: align))
            parts.append(String(repeating: " ", count: config.padding))
            if i < rowData.count - 1 {
                parts.append(String(config.vrules == .all ? config.verticalChar : " "))
            } else if config.vrules == .all || config.vrules == .frame { parts.append(String(config.verticalChar)) }
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
        for (i, row) in rows.enumerated() {
            output.append(renderRow(row, widths: widths))
            if config.hrules == .all && i < rows.count - 1 { output.append(renderHorizontalRule(widths: widths)) }
        }
        if config.hrules == .frame || config.hrules == .all { output.append(renderHorizontalRule(widths: widths)) }
        return output.joined(separator: "\n")
    }
}

public class ASCIITable {
    private var columns: [String]; private var rows: [[String]]; private var config: TableConfiguration
    public init(columns: [String] = []) { self.columns = columns; self.rows = []; self.config = TableConfiguration() }
    @discardableResult public func addRow(_ row: [String]) -> Self { rows.append(row); return self }
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
    public func render() -> String { TableRenderer(columns: columns, rows: rows, config: config).render() }
}

// MARK: - Border Examples

print("==============================================")
print("  SWIFT ASCII TABLE - BORDER & RULE EXAMPLES")
print("==============================================\n")

let sampleData = [
    ["Alice", "30", "NYC"],
    ["Bob", "25", "SF"],
    ["Charlie", "35", "LA"]
]

// Example 1: Default (Frame + All Vertical)
print("Example 1: Default Style (Frame + All Vertical Rules)")
print("------------------------------------------------------")
let table1 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table1.addRow(row) }
print(table1.render())
print()

// Example 2: No Borders
print("Example 2: No Borders or Rules")
print("-------------------------------")
let table2 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table2.addRow(row) }
table2.border(false).horizontalRules(.none).verticalRules(.none)
print(table2.render())
print()

// Example 3: Header Rule Only
print("Example 3: Header Rule Only")
print("----------------------------")
let table3 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table3.addRow(row) }
table3.horizontalRules(.header)
print(table3.render())
print()

// Example 4: All Horizontal Rules
print("Example 4: All Horizontal Rules")
print("--------------------------------")
let table4 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table4.addRow(row) }
table4.horizontalRules(.all)
print(table4.render())
print()

// Example 5: Frame Only (No Internal Lines)
print("Example 5: Frame Only (No Internal Vertical Rules)")
print("---------------------------------------------------")
let table5 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table5.addRow(row) }
table5.verticalRules(.frame)
print(table5.render())
print()

// Example 6: No Horizontal Rules
print("Example 6: No Horizontal Rules")
print("-------------------------------")
let table6 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table6.addRow(row) }
table6.horizontalRules(.none)
print(table6.render())
print()

// Example 7: Minimal (No Header)
print("Example 7: No Header Row")
print("------------------------")
let table7 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table7.addRow(row) }
table7.header(false)
print(table7.render())
print()

// Example 8: Custom Padding
print("Example 8: Padding = 0 (Tight)")
print("------------------------------")
let table8 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table8.addRow(row) }
table8.padding(0)
print(table8.render())
print()

print("Example 9: Padding = 3 (Spacious)")
print("---------------------------------")
let table9 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table9.addRow(row) }
table9.padding(3)
print(table9.render())
print()

// Example 10: Markdown-like (Header Rule + All Vertical)
print("Example 10: Markdown-like Style")
print("--------------------------------")
let table10 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table10.addRow(row) }
table10.horizontalRules(.header)
print(table10.render())
print()

// Example 11: Plain Columns (No Rules)
print("Example 11: Plain Columns (Spacious, No Rules)")
print("-----------------------------------------------")
let table11 = ASCIITable(columns: ["Name", "Age", "City"])
for row in sampleData { table11.addRow(row) }
table11.border(false).horizontalRules(.none).verticalRules(.none).padding(2)
print(table11.render())
print()

// Example 12: Grid Style (All Rules)
print("Example 12: Full Grid (All Rules)")
print("----------------------------------")
let table12 = ASCIITable(columns: ["A", "B", "C", "D"])
    .addRow(["1", "2", "3", "4"])
    .addRow(["5", "6", "7", "8"])
    .addRow(["9", "10", "11", "12"])
    .horizontalRules(.all)
    .verticalRules(.all)
print(table12.render())
print()

print("==============================================")
print("  Mix and match settings to create your own style!")
print("==============================================")
