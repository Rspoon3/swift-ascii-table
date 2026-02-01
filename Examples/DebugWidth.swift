#!/usr/bin/env swift

import Foundation

// Copy displayWidth calculation
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
            } else if scalar.properties.isNoncharacterCodePoint ||
                    (0xFE00...0xFE0F).contains(value) ||
                    (0x200B...0x200D).contains(value) {
                width += 0
            } else if (0x1F300...0x1F9FF).contains(value) ||
                    (0x2600...0x26FF).contains(value) ||
                    (0x2700...0x27BF).contains(value) ||
                    (0x1F000...0x1F02F).contains(value) ||
                    (0x1F0A0...0x1F0FF).contains(value) ||
                    (0x1FA00...0x1FAFF).contains(value) {
                width += 2
            } else {
                width += 1
            }
        }
        return width
    }
}

let str1 = "✅ Up to date"
let str2 = "⚠️  Update available"

print("String 1: '\(str1)'")
print("  Length: \(str1.count)")
print("  Display Width: \(str1.displayWidth)")
print("  Unicode Scalars:")
for scalar in str1.unicodeScalars {
    print("    U+\(String(scalar.value, radix: 16, uppercase: true)) - \(scalar)")
}

print("\nString 2: '\(str2)'")
print("  Length: \(str2.count)")
print("  Display Width: \(str2.displayWidth)")
print("  Unicode Scalars:")
for scalar in str2.unicodeScalars {
    print("    U+\(String(scalar.value, radix: 16, uppercase: true)) - \(scalar)")
}
