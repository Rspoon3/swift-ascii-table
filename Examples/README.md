# Swift ASCII Table Examples

This directory contains executable Swift scripts demonstrating various features of the swift-ascii-table package.

## Running the Examples

Each script can be run directly from the command line:

```bash
# Basic examples - simple tables and common use cases
swift Examples/BasicExamples.swift

# Alignment examples - left, center, right, and per-column alignment
swift Examples/AlignmentExamples.swift

# Unicode examples - emoji, CJK characters, and international text
swift Examples/UnicodeExamples.swift

# Border examples - various border and rule configurations
swift Examples/BorderExamples.swift
```

Or make them executable and run directly:

```bash
chmod +x Examples/*.swift
./Examples/BasicExamples.swift
./Examples/AlignmentExamples.swift
./Examples/UnicodeExamples.swift
./Examples/BorderExamples.swift
```

## What Each Example Demonstrates

### BasicExamples.swift
- Simple table creation
- Product catalogs
- Server status tables
- Student grades
- Empty tables
- Single column tables

**Featured API:**
- `ASCIITable(columns:)`
- `.addRow()`
- `.render()`

### AlignmentExamples.swift
- Left alignment (default)
- Center alignment
- Right alignment
- Per-column alignment
- Financial reports
- Sports standings
- Number formatting

**Featured API:**
- `.alignment(.left)`
- `.alignment(.center)`
- `.alignment(.right)`
- `.alignment(.right, for: "ColumnName")`

### UnicodeExamples.swift
- Emoji characters
- Chinese characters (中文)
- Japanese characters (日本語)
- Korean characters (한글)
- Arabic script
- Russian Cyrillic
- Mathematical symbols
- Currency symbols
- Multi-language tables

**Featured API:**
- Unicode support built-in
- Proper display width calculation
- CJK character handling

### BorderExamples.swift
- Default borders
- No borders
- Header rule only
- All horizontal rules
- Frame only
- No vertical rules
- Custom padding
- Grid style
- Markdown-like style

**Featured API:**
- `.border(true/false)`
- `.horizontalRules(.none/.frame/.header/.all)`
- `.verticalRules(.none/.frame/.all)`
- `.padding(0...n)`
- `.header(true/false)`

## Quick Start

Want to see everything at once? Run all examples:

```bash
for script in Examples/*.swift; do
    echo "Running $script..."
    swift "$script"
    echo ""
    echo "Press Enter to continue..."
    read
done
```

## Note About Standalone Scripts

These example scripts include the ASCIITable source code inline so they can run standalone without importing the package. In your own projects, you would simply:

```swift
import ASCIITable

let table = ASCIITable(columns: ["A", "B", "C"])
    .addRow(["1", "2", "3"])
print(table.render())
```

## Creating Your Own Tables

Mix and match the features you see in these examples:

```swift
let myTable = ASCIITable(columns: ["Name", "Score", "Rank"])
    .addRow(["Alice", "95", "1"])
    .addRow(["Bob", "87", "2"])
    .alignment(.left, for: "Name")
    .alignment(.right, for: "Score")
    .alignment(.center, for: "Rank")
    .padding(2)
    .horizontalRules(.header)

print(myTable.render())
```

## Tips

- **Right-align numbers** for easy visual comparison
- **Center-align** short values like status indicators
- **Use header-only rules** for cleaner markdown-style tables
- **Increase padding** for more spacious, readable tables
- **Remove borders** for minimal, clean output
- **Unicode just works** - no special configuration needed

Enjoy building beautiful CLI tables! 📊
