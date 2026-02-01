# swift-ascii-table

A lightweight, plug-and-play Swift package for rendering ASCII tables in CLI applications. Based on Python's [prettytable](https://github.com/prettytable/prettytable) library, focused exclusively on ASCII output with a Swift-idiomatic API.

## Features

- ✅ Simple, fluent API with method chaining
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

### Rendering

```swift
func render() -> String
```

Returns the formatted ASCII table as a string.

## Examples

The package includes several example scripts demonstrating different features:

```bash
# Run the examples
swift Examples/BasicExamples.swift      # Basic tables and common patterns
swift Examples/AlignmentExamples.swift  # Left, center, right alignment
swift Examples/UnicodeExamples.swift    # Emoji, CJK, and international text
swift Examples/BorderExamples.swift     # Border and rule configurations
```

See [Examples/README.md](Examples/README.md) for more details.

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
