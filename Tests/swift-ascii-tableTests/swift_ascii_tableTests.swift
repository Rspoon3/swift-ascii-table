import Testing
@testable import ASCIITable

@Suite("ASCII Table Tests")
struct ASCIITableTests {

    @Test("Basic table rendering")
    func basicTableRendering() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "25"])

        let output = table.render()
        let expectedLines = [
            "+-------+-----+",
            "| Name  | Age |",
            "+-------+-----+",
            "| Alice | 30  |",
            "| Bob   | 25  |",
            "+-------+-----+"
        ]
        let expected = expectedLines.joined(separator: "\n")

        #expect(output == expected)
    }

    @Test("Empty table")
    func emptyTable() {
        let table = ASCIITable(columns: ["A", "B"])
        let output = table.render()

        let expectedLines = [
            "+---+---+",
            "| A | B |",
            "+---+---+",
            "+---+---+"
        ]
        let expected = expectedLines.joined(separator: "\n")

        #expect(output == expected)
    }

    @Test("Table without border")
    func tableWithoutBorder() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .border(false)

        let output = table.render()

        // Without borders, there should be no +, -, | characters at edges
        #expect(!output.contains("+"))
        #expect(!output.contains("-"))
    }

    @Test("Table without header")
    func tableWithoutHeader() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "25"])
            .header(false)

        let output = table.render()

        // Header should not appear in output
        #expect(!output.contains("Name"))
        #expect(!output.contains("Age"))
        // But data should still appear
        #expect(output.contains("Alice"))
        #expect(output.contains("Bob"))
    }

    @Test("Center alignment")
    func centerAlignment() {
        let table = ASCIITable(columns: ["A"])
            .addRow(["X"])
            .alignment(.center)

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // The header and data should be centered (equal padding on both sides)
        // Line 0: +---+
        // Line 1: | A |
        // Line 2: +---+
        // Line 3: | X |
        // Line 4: +---+
        #expect(lines[1].contains("| A |"))
        #expect(lines[3].contains("| X |"))
    }

    @Test("Right alignment")
    func rightAlignment() {
        let table = ASCIITable(columns: ["Number"])
            .addRow(["42"])
            .alignment(.right)

        let output = table.render()

        // Number should be right-aligned with space on the left
        #expect(output.contains("Number"))
        #expect(output.contains("42"))
    }

    @Test("Per-column alignment")
    func perColumnAlignment() {
        let table = ASCIITable(columns: ["Left", "Right"])
            .addRow(["A", "1"])
            .alignment(.left, for: "Left")
            .alignment(.right, for: "Right")

        let output = table.render()

        #expect(output.contains("Left"))
        #expect(output.contains("Right"))
        #expect(output.contains("A"))
        #expect(output.contains("1"))
    }

    @Test("Custom padding")
    func customPadding() {
        let table = ASCIITable(columns: ["A"])
            .addRow(["X"])
            .padding(3)

        let output = table.render()

        // With padding of 3, there should be 3 spaces on each side
        #expect(output.contains("|   A   |"))
        #expect(output.contains("|   X   |"))
    }

    @Test("Horizontal rules - all")
    func horizontalRulesAll() {
        let table = ASCIITable(columns: ["A", "B"])
            .addRow(["1", "2"])
            .addRow(["3", "4"])
            .horizontalRules(.all)

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // Should have rules between every row
        // Count the number of lines with + and -
        let ruleLines = lines.filter { $0.contains("+") && $0.contains("-") }
        #expect(ruleLines.count == 4) // Top, after header, between rows, bottom
    }

    @Test("Horizontal rules - none")
    func horizontalRulesNone() {
        let table = ASCIITable(columns: ["A"])
            .addRow(["1"])
            .horizontalRules(.none)

        let output = table.render()

        // Should have no horizontal rule characters
        #expect(!output.contains("-"))
        #expect(!output.contains("+"))
    }

    @Test("Vertical rules - none")
    func verticalRulesNone() {
        let table = ASCIITable(columns: ["A", "B"])
            .addRow(["1", "2"])
            .verticalRules(.none)

        let output = table.render()

        // Should have no vertical rule characters (except in horizontal rules)
        let lines = output.components(separatedBy: "\n")
        let dataLines = lines.filter { !$0.contains("-") }
        for line in dataLines {
            #expect(!line.contains("|") || line.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    @Test("Unicode handling - emoji")
    func unicodeEmoji() {
        let table = ASCIITable(columns: ["Emoji", "Text"])
            .addRow(["😀", "Happy"])
            .addRow(["😢", "Sad"])

        let output = table.render()

        // Table should render without crashing and contain emoji
        #expect(output.contains("😀"))
        #expect(output.contains("😢"))
        #expect(output.contains("Happy"))
        #expect(output.contains("Sad"))
    }

    @Test("Unicode handling - CJK characters")
    func unicodeCJK() {
        let table = ASCIITable(columns: ["中文", "日本語"])
            .addRow(["你好", "こんにちは"])

        let output = table.render()

        // Table should render CJK characters properly
        #expect(output.contains("中文"))
        #expect(output.contains("日本語"))
        #expect(output.contains("你好"))
        #expect(output.contains("こんにちは"))
    }

    @Test("Method chaining")
    func methodChaining() {
        let output = ASCIITable(columns: ["A", "B"])
            .addRow(["1", "2"])
            .addRow(["3", "4"])
            .border(true)
            .header(true)
            .padding(1)
            .alignment(.center)
            .render()

        #expect(!output.isEmpty)
        #expect(output.contains("A"))
        #expect(output.contains("1"))
    }

    @Test("CustomStringConvertible")
    func customStringConvertible() {
        let table = ASCIITable(columns: ["A"])
            .addRow(["1"])

        let description = String(describing: table)

        #expect(!description.isEmpty)
        #expect(description.contains("A"))
        #expect(description.contains("1"))
    }

    @Test("Wide characters display width")
    func wideCharactersDisplayWidth() {
        // CJK characters should count as 2 width
        #expect("中".displayWidth == 2)
        #expect("文".displayWidth == 2)
        #expect("你好".displayWidth == 4)

        // Standard ASCII should count as 1 width
        #expect("A".displayWidth == 1)
        #expect("Hello".displayWidth == 5)

        // Emoji should count as 2 width
        #expect("😀".displayWidth == 2)
    }

    @Test("String padding")
    func stringPadding() {
        // Left alignment
        #expect("A".padded(to: 5, alignment: .left) == "A    ")

        // Right alignment
        #expect("A".padded(to: 5, alignment: .right) == "    A")

        // Center alignment
        #expect("A".padded(to: 5, alignment: .center) == "  A  ")

        // Already at target width
        #expect("Hello".padded(to: 5, alignment: .left) == "Hello")
    }
}

@Suite("Sorting Tests")
struct SortingTests {

    @Test("Sort by column - ascending")
    func sortAscending() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Charlie", "35"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "25"])
            .sort(.by(column: "Name"))

        let output = table.render()
        let lines = output.components(separatedBy: "\n")
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let bobIndex = lines.firstIndex { $0.contains("Bob") }!
        let charlieIndex = lines.firstIndex { $0.contains("Charlie") }!

        #expect(aliceIndex < bobIndex)
        #expect(bobIndex < charlieIndex)
    }

    @Test("Sort by column - descending")
    func sortDescending() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "25"])
            .addRow(["Charlie", "35"])
            .sort(.by(column: "Age", order: .descending))

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // Lexicographic descending: "35" > "30" > "25"
        let charlieIndex = lines.firstIndex { $0.contains("Charlie") }!
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let bobIndex = lines.firstIndex { $0.contains("Bob") }!

        #expect(charlieIndex < aliceIndex)
        #expect(aliceIndex < bobIndex)
    }

    @Test("Sort with custom transform - numeric")
    func sortNumeric() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "5"])
            .addRow(["Charlie", "100"])
            .sort(.by(column: "Age", transform: { str in
                // Zero-pad numbers for correct string comparison
                if let num = Int(str) {
                    return String(format: "%05d", num)
                }
                return str
            }))

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // Numeric order: 5, 30, 100 (not lexicographic: 100, 30, 5)
        let bobIndex = lines.firstIndex { $0.contains("Bob") }!
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let charlieIndex = lines.firstIndex { $0.contains("Charlie") }!

        #expect(bobIndex < aliceIndex)
        #expect(aliceIndex < charlieIndex)
    }

    @Test("Sort with custom transform - case insensitive")
    func sortCaseInsensitive() {
        let table = ASCIITable(columns: ["Name"])
            .addRow(["banana"])
            .addRow(["Apple"])
            .addRow(["cherry"])
            .sort(.by(column: "Name", transform: { $0.lowercased() }))

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        let appleIndex = lines.firstIndex { $0.contains("Apple") }!
        let bananaIndex = lines.firstIndex { $0.contains("banana") }!
        let cherryIndex = lines.firstIndex { $0.contains("cherry") }!

        #expect(appleIndex < bananaIndex)
        #expect(bananaIndex < cherryIndex)
    }

    @Test("Sort by invalid column")
    func sortInvalidColumn() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Alice", "30"])
            .addRow(["Bob", "25"])
            .sort(.by(column: "NonexistentColumn"))

        let output = table.render()

        // Should render without crashing, in original order
        let lines = output.components(separatedBy: "\n")
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let bobIndex = lines.firstIndex { $0.contains("Bob") }!
        #expect(aliceIndex < bobIndex)
    }

    @Test("Sort empty table")
    func sortEmptyTable() {
        let table = ASCIITable(columns: ["Name", "Age"])
            .sort(.by(column: "Name"))

        let output = table.render()
        #expect(output.contains("Name"))
        #expect(output.contains("Age"))
    }

    @Test("No sort option - original order")
    func noSort() {
        let table = ASCIITable(columns: ["Name"])
            .addRow(["Charlie"])
            .addRow(["Alice"])
            // Don't call .sort() at all

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // Original order preserved
        let charlieIndex = lines.firstIndex { $0.contains("Charlie") }!
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        #expect(charlieIndex < aliceIndex)
    }

    @Test("Sort maintains Unicode alignment")
    func sortUnicode() {
        let table = ASCIITable(columns: ["Name", "Emoji"])
            .addRow(["Charlie", "😢"])
            .addRow(["Alice", "😀"])
            .sort(.by(column: "Name"))

        let output = table.render()
        let lines = output.components(separatedBy: "\n")

        // Check sorted order
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let charlieIndex = lines.firstIndex { $0.contains("Charlie") }!
        #expect(aliceIndex < charlieIndex)

        // Check alignment is maintained
        let aliceLine = lines[aliceIndex]
        let charlieLine = lines[charlieIndex]
        #expect(aliceLine.count == charlieLine.count)
    }

    @Test("Method chaining with sorting")
    func sortMethodChaining() {
        let output = ASCIITable(columns: ["Name", "Age"])
            .addRow(["Bob", "25"])
            .addRow(["Alice", "30"])
            .sort(.by(column: "Name", order: .ascending))
            .border(true)
            .padding(2)
            .alignment(.center)
            .render()

        #expect(!output.isEmpty)
        let lines = output.components(separatedBy: "\n")
        let aliceIndex = lines.firstIndex { $0.contains("Alice") }!
        let bobIndex = lines.firstIndex { $0.contains("Bob") }!
        #expect(aliceIndex < bobIndex)
    }
}
