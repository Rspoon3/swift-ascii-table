# swift-ascii-table

A lightweight, plug-and-play Swift package for rendering ASCII tables in CLI applications. Based on Python's [prettytable](https://github.com/prettytable/prettytable) library, focused exclusively on ASCII output with a Swift-idiomatic API.

## Features

- ✅ Simple, fluent API with method chaining
- ✅ Sorting support with custom transforms (numeric, case-insensitive, etc.)
- ✅ Unicode support (proper handling of CJK characters, emoji, combining marks)
- ✅ Flexible alignment (left, center, right) per column or globally
- ✅ Configurable borders and rules (horizontal and vertical)
- ✅ Customizable padding
- ✅ Zero external dependencies
- ✅ Comprehensive test coverage

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/swift-ascii-table.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ASCIITable"]
)
```

## Usage

### Basic Table

```swift
import ASCIITable

let table = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Alice", "30", "New York"])
    .addRow(["Bob", "25", "San Francisco"])

print(table.render())
```

Output:
```
+-------+-----+---------------+
| Name  | Age | City          |
+-------+-----+---------------+
| Alice | 30  | New York      |
| Bob   | 25  | San Francisco |
+-------+-----+---------------+
```

### Custom Alignment

```swift
let table = ASCIITable(columns: ["Product", "Price", "Stock"])
    .addRow(["Laptop", "$1,299", "15"])
    .addRow(["Mouse", "$29", "150"])
    .alignment(.left, for: "Product")
    .alignment(.right, for: "Price")
    .alignment(.center, for: "Stock")

print(table.render())
```

Output:
```
+---------+--------+-------+
| Product | Price  | Stock |
+---------+--------+-------+
| Laptop  | $1,299 |  15   |
| Mouse   |    $29 |  150  |
+---------+--------+-------+
```

### Unicode Support

```swift
let table = ASCIITable(columns: ["Emoji", "中文", "Description"])
    .addRow(["😀", "开心", "Happy"])
    .addRow(["😢", "伤心", "Sad"])

print(table.render())
```

Output:
```
+-------+------+-------------+
| Emoji | 中文 | Description |
+-------+------+-------------+
| 😀    | 开心 | Happy       |
| 😢    | 伤心 | Sad         |
+-------+------+-------------+
```

### Custom Borders and Rules

```swift
// No borders
let table = ASCIITable(columns: ["A", "B"])
    .addRow(["1", "2"])
    .border(false)
    .horizontalRules(.none)
    .verticalRules(.none)

print(table.render())
```

Output:
```
 A   B
 1   2
```

```swift
// All horizontal rules
let table = ASCIITable(columns: ["ID", "Status"])
    .addRow(["1", "Active"])
    .addRow(["2", "Pending"])
    .horizontalRules(.all)

print(table.render())
```

Output:
```
+----+---------+
| ID | Status  |
+----+---------+
| 1  | Active  |
+----+---------+
| 2  | Pending |
+----+---------+
```

### Custom Padding

```swift
let table = ASCIITable(columns: ["A", "B"])
    .addRow(["X", "Y"])
    .padding(3)

print(table.render())
```

Output:
```
+---------+---------+
|   A     |   B     |
+---------+---------+
|   X     |   Y     |
+---------+---------+
```

### Sorting

```swift
// Basic alphabetical sorting
let table = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Charlie", "35", "NYC"])
    .addRow(["Alice", "30", "SF"])
    .addRow(["Bob", "25", "LA"])
    .sort(.by(column: "Name"))

print(table.render())
```

Output:
```
+---------+-----+------+
| Name    | Age | City |
+---------+-----+------+
| Alice   | 30  | SF   |
| Bob     | 25  | LA   |
| Charlie | 35  | NYC  |
+---------+-----+------+
```

```swift
// Numeric sorting with transform
let table = ASCIITable(columns: ["Name", "Age"])
    .addRow(["Alice", "30"])
    .addRow(["Bob", "5"])
    .addRow(["Charlie", "100"])
    .sort(.by(column: "Age", transform: { str in
        if let num = Int(str) {
            return String(format: "%05d", num)
        }
        return str
    }))

print(table.render())
```

Output:
```
+---------+-----+
| Name    | Age |
+---------+-----+
| Bob     | 5   |
| Alice   | 30  |
| Charlie | 100 |
+---------+-----+
```

```swift
// Descending sort
let table = ASCIITable(columns: ["Name", "Score"])
    .addRow(["Alice", "95"])
    .addRow(["Bob", "87"])
    .addRow(["Charlie", "92"])
    .sort(.by(column: "Score", order: .descending))

print(table.render())
```

Output:
```
+---------+-------+
| Name    | Score |
+---------+-------+
| Alice   | 95    |
| Charlie | 92    |
| Bob     | 87    |
+---------+-------+
```

## API Reference

### Initialization

```swift
ASCIITable(columns: [String])
```

### Configuration Methods

All methods return `Self` for method chaining.

- `addRow(_ row: [String]) -> Self` - Add a single row of data
- `columns(_ columns: [String]) -> Self` - Set column headers
- `border(_ enabled: Bool) -> Self` - Enable/disable table borders
- `horizontalRules(_ hrules: HorizontalRule) -> Self` - Set horizontal rule placement
- `verticalRules(_ vrules: VerticalRule) -> Self` - Set vertical rule placement
- `padding(_ width: Int) -> Self` - Set cell padding width
- `header(_ show: Bool) -> Self` - Show/hide header row
- `alignment(_ align: Alignment, for column: String?) -> Self` - Set alignment
- `sort(_ option: SortOption) -> Self` - Sort table rows by column

### Enums

#### HorizontalRule
- `.none` - No horizontal lines
- `.frame` - Only at top and bottom
- `.header` - Only after header
- `.all` - Between all rows

#### VerticalRule
- `.none` - No vertical lines
- `.frame` - Only at left and right edges
- `.all` - Between all columns

#### Alignment
- `.left` - Left-aligned text
- `.center` - Centered text
- `.right` - Right-aligned text

#### SortOrder
- `.ascending` - Sort in ascending order (default)
- `.descending` - Sort in descending order

#### SortOption
- `.by(column: String, order: SortOrder = .ascending, transform: ((String) -> String)? = nil)` - Sort by column with optional order and transform function

### Rendering

```swift
func render() -> String
```

Returns the formatted ASCII table as a string.

## Examples

The package includes several example scripts demonstrating different features:

```bash
# Run the examples
swift run SortingExamples          # Sorting with various options
swift run ANSIColorExample         # ANSI color support
swift Examples/BasicExamples.swift      # Basic tables and common patterns
swift Examples/AlignmentExamples.swift  # Left, center, right alignment
swift Examples/UnicodeExamples.swift    # Emoji, CJK, and international text
swift Examples/BorderExamples.swift     # Border and rule configurations
```

See [Examples/README.md](Examples/README.md) for more details.

## Known Limitations

### Emoji Width Inconsistency

**Emoji widths are renderer-dependent** and will vary across terminals, fonts, and platforms. While this library attempts to calculate display widths for common emoji (counting most as 2 cells), the actual rendering is controlled by your terminal emulator and font.

**Problem characters:**
- ⚠️ (U+26A0 + U+FE0F) - Warning with emoji presentation
- Other Miscellaneous Symbols (U+2600-U+26FF) with variation selectors

**For reliable alignment in CLI tables**, prefer text symbols over emoji:
- ✓ (U+2713) instead of ✅
- ! or ⚠ (U+26A0 without U+FE0F) instead of ⚠️
- → instead of ➡️

**Why?** Emoji glyphs are ~1em × 1em squares that don't follow monospace rules, even in monospace fonts. Width calculation is an approximation.

## Requirements

- Swift 6.2+
- macOS 13+ (or equivalent platform versions)

## Testing

Run the test suite:

```bash
swift test
```

The package includes comprehensive tests covering:
- Basic rendering
- Unicode handling (emoji, CJK characters)
- Alignment options
- Border and rule configurations
- Edge cases

## License

[Your chosen license]

## Credits

Based on the Python [prettytable](https://github.com/prettytable/prettytable) library by Luke Maurits.
