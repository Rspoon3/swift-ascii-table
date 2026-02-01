import Foundation

/// Specifies where horizontal rules (lines) should be rendered in the table.
public enum HorizontalRule {
    /// No horizontal lines
    case none
    /// Only at the top and bottom of the table (frame)
    case frame
    /// Only after the header
    case header
    /// Between all rows
    case all
}

/// Specifies where vertical rules (lines) should be rendered in the table.
public enum VerticalRule {
    /// No vertical lines
    case none
    /// Only at the left and right edges of the table (frame)
    case frame
    /// Between all columns
    case all
}

/// Specifies horizontal text alignment within table cells.
public enum Alignment {
    case left
    case center
    case right
}

/// Configuration options for table rendering.
struct TableConfiguration {
    /// Whether to display table borders
    var border: Bool = true

    /// Horizontal rule placement
    var hrules: HorizontalRule = .frame

    /// Vertical rule placement
    var vrules: VerticalRule = .all

    /// Padding width on both sides of cell content
    var padding: Int = 1

    /// Whether to display the header row
    var header: Bool = true

    /// Default alignment for all columns
    var defaultAlignment: Alignment = .left

    /// Per-column alignment overrides (key is column name)
    var alignment: [String: Alignment] = [:]

    /// Characters used for drawing borders
    var horizontalChar: Character = "-"
    var verticalChar: Character = "|"
    var junctionChar: Character = "+"
}
