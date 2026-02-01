import ASCIITable

print("=== Example 1: Basic Alphabetical Sorting ===\n")
let table1 = ASCIITable(columns: ["Name", "Age", "City"])
    .addRow(["Charlie", "35", "NYC"])
    .addRow(["Alice", "30", "SF"])
    .addRow(["Bob", "25", "LA"])
    .sort(.by(column: "Name"))

print(table1.render())
print("\nRows sorted alphabetically by Name (Alice, Bob, Charlie)\n")

print("=== Example 2: Numeric Sorting with Transform ===\n")
let table2 = ASCIITable(columns: ["Name", "Age"])
    .addRow(["Alice", "30"])
    .addRow(["Bob", "5"])
    .addRow(["Charlie", "100"])
    .sort(.by(column: "Age", transform: { str in
        // Zero-pad numbers for proper numeric sorting
        if let num = Int(str) {
            return String(format: "%05d", num)
        }
        return str
    }))

print(table2.render())
print("\nRows sorted numerically by Age: 5, 30, 100 (not lexicographic)\n")

print("=== Example 3: Descending Sort ===\n")
let table3 = ASCIITable(columns: ["Name", "Score"])
    .addRow(["Alice", "95"])
    .addRow(["Bob", "87"])
    .addRow(["Charlie", "92"])
    .sort(.by(column: "Score", order: .descending))

print(table3.render())
print("\nRows sorted by Score in descending order: 95, 92, 87\n")

print("=== Example 4: Case-Insensitive Sort ===\n")
let table4 = ASCIITable(columns: ["Name", "Category"])
    .addRow(["banana", "Fruit"])
    .addRow(["Apple", "Fruit"])
    .addRow(["cherry", "Fruit"])
    .sort(.by(column: "Name", transform: { $0.lowercased() }))

print(table4.render())
print("\nRows sorted case-insensitively: Apple, banana, cherry\n")

print("=== Example 5: Unicode Characters with Sorting ===\n")
let table5 = ASCIITable(columns: ["Name", "Emoji", "Chinese"])
    .addRow(["Charlie", "😢", "你好"])
    .addRow(["Alice", "😀", "世界"])
    .addRow(["Bob", "🎉", "谢谢"])
    .sort(.by(column: "Name"))

print(table5.render())
print("\nUnicode characters maintain proper alignment after sorting\n")

print("=== Example 6: Sorting with Method Chaining ===\n")
let table6 = ASCIITable(columns: ["Product", "Price"])
    .addRow(["Widget", "29.99"])
    .addRow(["Gadget", "49.99"])
    .addRow(["Doohickey", "19.99"])
    .sort(.by(column: "Product"))
    .alignment(.right, for: "Price")
    .padding(2)
    .horizontalRules(.all)

print(table6.render())
print("\nSorting works seamlessly with other configuration options\n")
