import Foundation

/// A lightweight ASCII table renderer for CLI applications.
///
/// Example usage:
/// ```swift
/// let table = ASCIITable(columns: ["Name", "Age", "City"])
///     .addRow(["Alice", "30", "NYC"])
///     .addRow(["Bob", "25", "SF"])
///     .render()
/// ```
public class ASCIITable {
    private var columns: [String]
    private var rows: [[String]]
    private var config: TableConfiguration

    /// Creates a new ASCII table with the specified column headers.
    ///
    /// - Parameter columns: An array of column header names.
    public init(columns: [String] = []) {
        self.columns = columns
        self.rows = []
        self.config = TableConfiguration()
    }

    /// Adds a single row of data to the table.
    ///
    /// - Parameter row: An array of string values, one for each column.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func addRow(_ row: [String]) -> Self {
        assert(columns.isEmpty || row.count == columns.count,
               "Row must have \(columns.count) values to match columns")
        rows.append(row)
        return self
    }

    /// Sets the column headers for the table.
    ///
    /// - Parameter columns: An array of column header names.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func columns(_ columns: [String]) -> Self {
        self.columns = columns
        return self
    }

    /// Sets whether the table should display borders.
    ///
    /// - Parameter enabled: True to show borders, false to hide them.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func border(_ enabled: Bool) -> Self {
        config.border = enabled
        return self
    }

    /// Sets the horizontal rule placement for the table.
    ///
    /// - Parameter hrules: The horizontal rule style.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func horizontalRules(_ hrules: HorizontalRule) -> Self {
        config.hrules = hrules
        return self
    }

    /// Sets the vertical rule placement for the table.
    ///
    /// - Parameter vrules: The vertical rule style.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func verticalRules(_ vrules: VerticalRule) -> Self {
        config.vrules = vrules
        return self
    }

    /// Sets the padding width for table cells.
    ///
    /// - Parameter width: The number of spaces to pad on each side of cell content.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func padding(_ width: Int) -> Self {
        config.padding = max(0, width)
        return self
    }

    /// Sets whether to display the header row.
    ///
    /// - Parameter show: True to show the header, false to hide it.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func header(_ show: Bool) -> Self {
        config.header = show
        return self
    }

    /// Sets the alignment for all columns or a specific column.
    ///
    /// - Parameters:
    ///   - align: The alignment style (left, center, or right).
    ///   - column: Optional column name. If nil, sets the default for all columns.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func alignment(_ align: Alignment, for column: String? = nil) -> Self {
        if let column = column {
            config.alignment[column] = align
        } else {
            config.defaultAlignment = align
        }
        return self
    }

    /// Sets the sorting option for table rows.
    ///
    /// - Parameter option: The sort configuration to apply.
    /// - Returns: Self for method chaining.
    ///
    /// Example usage:
    /// ```swift
    /// // Sort by name ascending (default)
    /// .sort(.by(column: "Name"))
    ///
    /// // Sort by age descending
    /// .sort(.by(column: "Age", order: .descending))
    ///
    /// // Sort numerically
    /// .sort(.by(column: "Age", order: .ascending, transform: { str in
    ///     if let num = Int(str) { return String(format: "%05d", num) }
    ///     return str
    /// }))
    /// ```
    @discardableResult
    public func sort(_ option: SortOption) -> Self {
        config.sortOption = option
        return self
    }

    /// Renders the table as an ASCII string.
    ///
    /// - Returns: The formatted ASCII table.
    public func render() -> String {
        let renderer = TableRenderer(
            columns: columns,
            rows: rows,
            config: config
        )
        return renderer.render()
    }
}

// MARK: - CustomStringConvertible

extension ASCIITable: CustomStringConvertible {
    public var description: String {
        render()
    }
}
