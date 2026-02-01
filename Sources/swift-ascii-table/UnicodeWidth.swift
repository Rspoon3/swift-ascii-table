import Foundation

extension String {
    /// Calculates the display width of a string, accounting for Unicode characters
    /// that occupy more or less than one character cell (e.g., CJK characters, emoji, combining marks).
    var displayWidth: Int {
        var width = 0
        for scalar in unicodeScalars {
            let value = scalar.value

            // CJK Unified Ideographs and other wide characters
            // These ranges cover common CJK, Japanese Kana, and Hangul
            if (0x1100...0x115F).contains(value) ||      // Hangul Jamo
               (0x2E80...0x2EFF).contains(value) ||      // CJK Radicals
               (0x3000...0x303F).contains(value) ||      // CJK Symbols and Punctuation
               (0x3040...0x309F).contains(value) ||      // Hiragana
               (0x30A0...0x30FF).contains(value) ||      // Katakana
               (0x3100...0x312F).contains(value) ||      // Bopomofo
               (0x3130...0x318F).contains(value) ||      // Hangul Compatibility Jamo
               (0x3190...0x319F).contains(value) ||      // Kanbun
               (0x31A0...0x31BF).contains(value) ||      // Bopomofo Extended
               (0x31C0...0x31EF).contains(value) ||      // CJK Strokes
               (0x31F0...0x31FF).contains(value) ||      // Katakana Phonetic Extensions
               (0x3200...0x32FF).contains(value) ||      // Enclosed CJK Letters and Months
               (0x3300...0x33FF).contains(value) ||      // CJK Compatibility
               (0x3400...0x4DBF).contains(value) ||      // CJK Unified Ideographs Extension A
               (0x4DC0...0x4DFF).contains(value) ||      // Yijing Hexagram Symbols
               (0x4E00...0x9FFF).contains(value) ||      // CJK Unified Ideographs
               (0xA000...0xA48F).contains(value) ||      // Yi Syllables
               (0xA490...0xA4CF).contains(value) ||      // Yi Radicals
               (0xAC00...0xD7AF).contains(value) ||      // Hangul Syllables
               (0xF900...0xFAFF).contains(value) ||      // CJK Compatibility Ideographs
               (0xFE10...0xFE1F).contains(value) ||      // Vertical Forms
               (0xFE30...0xFE4F).contains(value) ||      // CJK Compatibility Forms
               (0xFF00...0xFF60).contains(value) ||      // Fullwidth Forms
               (0xFFE0...0xFFE6).contains(value) {       // Fullwidth Forms
                width += 2
            }
            // Check for combining marks and zero-width characters
            else if scalar.properties.isNoncharacterCodePoint {
                width += 0
            }
            // Most emoji are multi-byte and should count as 2
            else if (0x1F300...0x1F9FF).contains(value) {  // Emoji ranges
                width += 2
            }
            // Standard ASCII and most other characters
            else {
                width += 1
            }
        }
        return width
    }

    /// Pads the string to the specified width using the given alignment.
    /// Uses displayWidth to account for Unicode characters that may occupy more than one cell.
    func padded(to width: Int, alignment: Alignment) -> String {
        let currentWidth = self.displayWidth
        guard currentWidth < width else { return self }
        let padding = width - currentWidth

        switch alignment {
        case .left:
            return self + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + self
        case .center:
            let leftPad = padding / 2
            let rightPad = padding - leftPad
            return String(repeating: " ", count: leftPad) + self + String(repeating: " ", count: rightPad)
        }
    }
}
