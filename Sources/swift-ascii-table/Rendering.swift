import Foundation

/// Handles the rendering logic for ASCII tables.
struct TableRenderer {
    let columns: [String]
    let rows: [[String]]
    let config: TableConfiguration

    /// Computes the display width for each column based on headers and row data.
    func computeColumnWidths() -> [Int] {
        guard !columns.isEmpty else { return [] }

        var widths = columns.map { $0.displayWidth }

        // Check all rows and update widths if needed
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

    /// Renders a horizontal rule (border line) for the table.
    func renderHorizontalRule(widths: [Int]) -> String {
        guard config.border else { return "" }

        var parts: [String] = []

        // Left edge
        if config.vrules == .all || config.vrules == .frame {
            parts.append(String(config.junctionChar))
        }

        // Column separators
        for (index, width) in widths.enumerated() {
            let line = String(repeating: config.horizontalChar, count: width + config.padding * 2)
            parts.append(line)

            // Add junction between columns or at right edge
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

    /// Renders a single row (header or data) with proper alignment and padding.
    func renderRow(_ rowData: [String], widths: [Int]) -> String {
        var parts: [String] = []

        // Left border
        if config.vrules == .all || config.vrules == .frame {
            parts.append(String(config.verticalChar))
        }

        // Render each cell
        for (index, cell) in rowData.enumerated() where index < widths.count {
            let columnName = columns[index]
            let alignment = config.alignment[columnName] ?? config.defaultAlignment
            let paddedCell = cell.padded(to: widths[index], alignment: alignment)

            // Add left padding
            parts.append(String(repeating: " ", count: config.padding))
            parts.append(paddedCell)
            parts.append(String(repeating: " ", count: config.padding))

            // Add column separator or right border
            if index < rowData.count - 1 {
                if config.vrules == .all {
                    parts.append(String(config.verticalChar))
                } else if config.vrules == .frame {
                    // No separator between columns, just padding
                    parts.append(" ")
                }
            } else if config.vrules == .all || config.vrules == .frame {
                parts.append(String(config.verticalChar))
            }
        }

        return parts.joined()
    }

    /// Renders the complete table as a string.
    func render() -> String {
        guard !columns.isEmpty else { return "" }

        var output: [String] = []
        let widths = computeColumnWidths()

        // Top border
        if config.hrules != .none {
            output.append(renderHorizontalRule(widths: widths))
        }

        // Header
        if config.header {
            output.append(renderRow(columns, widths: widths))

            // Header separator - render after header for frame, header, and all
            if config.hrules == .frame || config.hrules == .header || config.hrules == .all {
                output.append(renderHorizontalRule(widths: widths))
            }
        }

        // Data rows
        for (index, row) in rows.enumerated() {
            output.append(renderRow(row, widths: widths))

            // Row separator (only if hrules is .all and not the last row)
            if config.hrules == .all && index < rows.count - 1 {
                output.append(renderHorizontalRule(widths: widths))
            }
        }

        // Bottom border
        if config.hrules == .frame || config.hrules == .all {
            output.append(renderHorizontalRule(widths: widths))
        }

        return output.joined(separator: "\n")
    }
}
