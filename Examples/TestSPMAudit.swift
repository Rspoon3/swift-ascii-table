#!/usr/bin/env swift

// Test script to reproduce spm-audit table output

import Foundation

// MARK: - Source code inline (same as other examples)
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
            } else if scalar.properties.isNoncharacterCodePoint ||
                    (0xFE00...0xFE0F).contains(value) ||
                    (0x200B...0x200D).contains(value) {
                width += 0
            } else if (0x1F300...0x1F9FF).contains(value) ||
                    (0x2600...0x26FF).contains(value) ||
                    (0x2700...0x27BF).contains(value) ||
                    (0x1F000...0x1F02F).contains(value) ||
                    (0x1F0A0...0x1F0FF).contains(value) ||
                    (0x1FA00...0x1FAFF).contains(value) {
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

// MARK: - Test spm-audit data

print("Testing spm-audit table output")
print("================================\n")

print("📋 Package.resolved")
print(String(repeating: "─", count: 80))

let table = ASCIITable(columns: ["Package", "Type", "Current", "Swift", "Latest", "Status",
                                  "README", "License", "CLAUDE.md", "AGENTS.md"])

// Add exact data from spm-audit output
table.addRow(["GRDB.swift", "Unknown", "7.9.0", "6.1", "7.9.0", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["SFSymbols", "Unknown", "3.1.0", "6.0", "3.1", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["SwiftTools", "Unknown", "2.3.1", "6.0", "2.3.1", "✅ Up to date", "✅", "Missing", "❌", "❌"])
table.addRow(["combine-schedulers", "Unknown", "1.1.0", "6.1", "1.1.0", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["sqlite-data", "Unknown", "1.5.1", "6.1", "1.5.1", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-clocks", "Unknown", "1.0.6", "5.9", "1.0.6", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-collections", "Unknown", "1.3.0", "6.2", "1.3.0", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-concurrency-extras", "Unknown", "1.3.2", "5.9", "1.3.2", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-custom-dump", "Unknown", "1.3.4", "6.0", "1.4.1", "⚠️  Update available", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-dependencies", "Unknown", "1.10.1", "6.0", "1.10.1", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-identified-collections", "Unknown", "1.1.1", "5.9", "1.1.1", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-perception", "Unknown", "2.0.9", "6.0", "2.0.9", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-sharing", "Unknown", "2.7.4", "5.9", "2.7.4", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-snapshot-testing", "Unknown", "1.18.7", "6.0", "1.18.9", "⚠️  Update available", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-structured-queries", "Unknown", "0.30.0", "6.1", "0.30.0", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["swift-syntax", "Unknown", "602.0.0", "5.9", "602.0.0", "✅ Up to date", "✅", "MIT", "❌", "❌"])
table.addRow(["xctest-dynamic-overlay", "Unknown", "1.8.1", "6.0", "1.8.1", "✅ Up to date", "✅", "MIT", "❌", "❌"])

print(table.render())

print("\n📊 Summary: 2 update(s) available")
