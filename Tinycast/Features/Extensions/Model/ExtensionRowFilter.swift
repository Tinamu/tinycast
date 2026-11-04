import Foundation

/// A command's own search, folded once per rebuild: Raycast filters on title and keywords alone.
struct ExtensionRowFilter: Sendable {
    private let needle: FuzzyMatch.Query
    /// The same text with word starts marked, which is what rules a gapped hit in or out.
    private let query: SearchText

    var isEmpty: Bool { needle.isEmpty }

    init(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        needle = FuzzyMatch.Query(trimmed)
        query = SearchText(trimmed, transliterated: false)
    }

    /// A contiguous hit counts anywhere; a gapped one only where each of its pieces starts a word.
    func matches(_ candidate: String) -> Bool {
        guard !isEmpty else { return true }
        guard let match = FuzzyMatch.match(needle, candidate: candidate) else { return false }
        guard match.tier == .subsequence else { return true }
        switch LauncherMatch.match(query, in: SearchText(candidate, transliterated: false)) {
        case .exact: return true
        // A word start pays three where a letter inside one pays two: anchoring clears this.
        case .scored(let score, let skipped): return score > 2 * (query.units.count - skipped)
        case nil: return false
        }
    }
}
