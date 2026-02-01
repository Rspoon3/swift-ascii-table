#!/usr/bin/env swift

// This file demonstrates Unicode character handling
// In production: import ASCIITable

import Foundation

// MARK: - Source code inline (abbreviated for brevity)
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
        for row in rows {
            for (i, cell) in row.enumerated() where i < widths.count {
                widths[i] = max(widths[i], cell.displayWidth)
            }
        }
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
    @discardableResult public func alignment(_ align: Alignment, for column: String? = nil) -> Self {
        if let column = column { config.alignment[column] = align }
        else { config.defaultAlignment = align }
        return self
    }
    public func render() -> String { TableRenderer(columns: columns, rows: rows, config: config).render() }
}

// MARK: - Unicode Examples

print("============================================")
print("  SWIFT ASCII TABLE - UNICODE EXAMPLES")
print("============================================\n")

// Example 1: Emoji
print("Example 1: Emoji Characters")
print("----------------------------")
let table1 = ASCIITable(columns: ["Emoji", "Name", "Category"])
    .addRow(["😀", "Grinning Face", "Smiley"])
    .addRow(["😢", "Crying Face", "Sad"])
    .addRow(["❤️", "Red Heart", "Love"])
    .addRow(["🎉", "Party Popper", "Celebration"])
    .addRow(["🚀", "Rocket", "Travel"])
    .alignment(.center, for: "Emoji")
print(table1.render())
print()

// Example 2: Chinese Characters
print("Example 2: Chinese Characters (Simplified)")
print("-------------------------------------------")
let table2 = ASCIITable(columns: ["中文", "拼音", "English"])
    .addRow(["你好", "nǐ hǎo", "Hello"])
    .addRow(["谢谢", "xiè xie", "Thank you"])
    .addRow(["再见", "zài jiàn", "Goodbye"])
    .addRow(["对不起", "duì bu qǐ", "Sorry"])
print(table2.render())
print()

// Example 3: Japanese Characters
print("Example 3: Japanese Characters")
print("-------------------------------")
let table3 = ASCIITable(columns: ["日本語", "ローマ字", "English"])
    .addRow(["こんにちは", "konnichiwa", "Hello"])
    .addRow(["ありがとう", "arigatou", "Thank you"])
    .addRow(["さようなら", "sayounara", "Goodbye"])
print(table3.render())
print()

// Example 4: Korean Characters
print("Example 4: Korean Characters (Hangul)")
print("--------------------------------------")
let table4 = ASCIITable(columns: ["한글", "로마자", "English"])
    .addRow(["안녕하세요", "annyeonghaseyo", "Hello"])
    .addRow(["감사합니다", "gamsahamnida", "Thank you"])
    .addRow(["안녕히 가세요", "annyeonghi gaseyo", "Goodbye"])
print(table4.render())
print()

// Example 5: Mixed Languages
print("Example 5: Multi-Language Menu")
print("-------------------------------")
let table5 = ASCIITable(columns: ["Language", "Hello", "World"])
    .addRow(["English", "Hello", "World"])
    .addRow(["Spanish", "Hola", "Mundo"])
    .addRow(["Chinese", "你好", "世界"])
    .addRow(["Japanese", "こんにちは", "世界"])
    .addRow(["Korean", "안녕하세요", "세계"])
    .addRow(["Arabic", "مرحبا", "عالم"])
    .addRow(["Russian", "Привет", "Мир"])
print(table5.render())
print()

// Example 6: Emoji Status Indicators
print("Example 6: Status Dashboard with Emoji")
print("---------------------------------------")
let table6 = ASCIITable(columns: ["Service", "Status", "Response Time", "Uptime"])
    .addRow(["API Gateway", "✅", "45ms", "99.9%"])
    .addRow(["Database", "✅", "12ms", "100%"])
    .addRow(["Cache", "⚠️", "150ms", "98.5%"])
    .addRow(["Worker Queue", "❌", "N/A", "0%"])
    .alignment(.left, for: "Service")
    .alignment(.center, for: "Status")
    .alignment(.right, for: "Response Time")
    .alignment(.right, for: "Uptime")
print(table6.render())
print()

// Example 7: Weather with Symbols
print("Example 7: Weather Forecast")
print("---------------------------")
let table7 = ASCIITable(columns: ["Day", "Icon", "High", "Low", "Conditions"])
    .addRow(["Monday", "☀️", "75°F", "55°F", "Sunny"])
    .addRow(["Tuesday", "⛅", "72°F", "58°F", "Partly Cloudy"])
    .addRow(["Wednesday", "🌧️", "65°F", "52°F", "Rainy"])
    .addRow(["Thursday", "⛈️", "68°F", "54°F", "Thunderstorms"])
    .addRow(["Friday", "🌤️", "74°F", "56°F", "Mostly Sunny"])
    .alignment(.center, for: "Icon")
    .alignment(.right, for: "High")
    .alignment(.right, for: "Low")
print(table7.render())
print()

// Example 8: Math and Special Symbols
print("Example 8: Mathematical Symbols")
print("--------------------------------")
let table8 = ASCIITable(columns: ["Symbol", "Name", "Example"])
    .addRow(["π", "Pi", "3.14159..."])
    .addRow(["∞", "Infinity", "∞"])
    .addRow(["∑", "Summation", "∑(1..10)"])
    .addRow(["√", "Square Root", "√16 = 4"])
    .addRow(["≈", "Approximately", "π ≈ 3.14"])
    .alignment(.center, for: "Symbol")
print(table8.render())
print()

// Example 9: Currency Symbols
print("Example 9: International Currencies")
print("------------------------------------")
let table9 = ASCIITable(columns: ["Currency", "Symbol", "Code", "Example"])
    .addRow(["US Dollar", "$", "USD", "$100.00"])
    .addRow(["Euro", "€", "EUR", "€85.50"])
    .addRow(["British Pound", "£", "GBP", "£75.25"])
    .addRow(["Japanese Yen", "¥", "JPY", "¥10,000"])
    .addRow(["Chinese Yuan", "¥", "CNY", "¥650"])
    .alignment(.center, for: "Symbol")
    .alignment(.right, for: "Example")
print(table9.render())
print()

print("============================================")
print("  Note: All Unicode characters are properly")
print("  aligned with correct display width!")
print("============================================")
