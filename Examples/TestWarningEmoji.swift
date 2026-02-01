#!/usr/bin/env swift

import Foundation

// Test different approaches for warning emoji
let warning = "⚠️"
let checkmark = "✅"

print("Testing emoji widths:")
print("====================\n")

print("Warning emoji: '\(warning)'")
print("Character count: \(warning.count)")
print("Unicode scalars:")
for scalar in warning.unicodeScalars {
    print("  U+\(String(scalar.value, radix: 16, uppercase: true))")
}

print("\nCheckmark emoji: '\(checkmark)'")
print("Character count: \(checkmark.count)")
print("Unicode scalars:")
for scalar in checkmark.unicodeScalars {
    print("  U+\(String(scalar.value, radix: 16, uppercase: true))")
}

// Test with actual terminal width
print("\nTerminal rendering test (count the | characters):")
print("|⚠️|")
print("|✅|")
print("|XX|")

print("\nExpected: if emoji is 2 cells, pipe should be at same position as XX")
