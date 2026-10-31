import CoreGraphics

/// How far ⇞/⇟ carry the selection; band and row arrive measured, as `SelectionReveal`'s do.
enum ListPaging {
    /// A page before any row has been measured, which is one palette band at the default size.
    static let unmeasuredRows = 8

    /// Whole rows in the band, never fewer than one, so a page always moves the selection.
    static func rows(band: CGFloat, rowHeight: CGFloat) -> Int {
        guard band > 0, rowHeight > 0 else { return unmeasuredRows }
        return max(1, Int(band / rowHeight))
    }

    /// A page of single steps, so a grid pages by cell rows; a step that stands still is the end.
    static func destination(from selection: Int, rows: Int, step: (Int) -> Int?) -> Int {
        var index = selection
        for _ in 0..<max(rows, 1) {
            guard let next = step(index), next != index else { return index }
            index = next
        }
        return index
    }
}
