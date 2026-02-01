import Foundation

extension String {
    /// Strips ANSI escape codes from the string.
    /// Returns the string without any ANSI color or formatting codes.
    var strippingANSI: String {
        // Pattern matches ANSI escape sequences: ESC [ <params> <command>
        // where ESC is \u{001B}, params are numbers/semicolons, and command is a letter
        let ansiPattern = "\\u{001B}\\[[0-9;]*[A-Za-z]"
        guard let regex = try? NSRegularExpression(pattern: ansiPattern, options: []) else {
            return self
        }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }

    /// Calculates the display width of a string, accounting for Unicode characters
    /// that occupy more or less than one character cell (e.g., CJK characters, emoji, combining marks).
    /// ANSI escape codes are stripped before calculating width.
    var displayWidth: Int {
        // Strip ANSI codes before calculating width
        let cleanString = self.strippingANSI
        var width = 0
        for scalar in cleanString.unicodeScalars {
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
            // Check for combining marks, variation selectors, and zero-width characters
            else if scalar.properties.isNoncharacterCodePoint ||
                    (0xFE00...0xFE0F).contains(value) ||  // Variation Selectors
                    (0x200B...0x200D).contains(value) {   // Zero Width Joiner, etc.
                width += 0
            }
            // Emoji ranges - only true emoji characters that are always 2 cells wide
            else if (0x1F300...0x1F9FF).contains(value) ||  // Emoticons, symbols, pictographs
                    (0x2700...0x27BF).contains(value) ||    // Dingbats (✅, ✔️, ❌, etc.)
                    (0x1F000...0x1F02F).contains(value) ||  // Mahjong tiles, Domino tiles
                    (0x1F0A0...0x1F0FF).contains(value) ||  // Playing cards
                    (0x1FA00...0x1FAFF).contains(value) {   // Extended pictographs
                width += 2
            }
            // Miscellaneous Symbols (⚠, ☀, ⭐) are 1 cell - NOT 2
            // These are text symbols, not emoji, even with variation selectors
            // Standard ASCII and most other characters
            else {
                width += 1
            }
        }
        return width
    }

    /// Pads the string to the specified width using the given alignment.
    /// Uses displayWidth to account for Unicode characters that may occupy more than one cell.
    /// ANSI escape codes are preserved in the output but not counted in width calculations.
    func padded(to width: Int, alignment: Alignment) -> String {
        let currentWidth = self.displayWidth // displayWidth already strips ANSI internally
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
