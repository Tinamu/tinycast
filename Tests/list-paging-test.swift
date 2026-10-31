import CoreGraphics
import Foundation

/// ⇞/⇟ step a measured band of rows, one step at a time, so a grid pages by whole cell rows.
@main
@MainActor
struct ListPagingTests {
    static var failures = 0
    static var passes = 0

    /// The palette's real proportions, as `scroll-reveal-test` measures them.
    static let band: CGFloat = 369
    static let rowHeight: CGFloat = 36

    static func expect(_ actual: Int, _ expected: Int, _ message: String) {
        if actual == expected {
            passes += 1
        } else {
            failures += 1
            print("FAIL: \(message) — got \(actual), want \(expected)")
        }
    }

    /// A plain list: the flat index, and nil once a step would leave the rows.
    static func listStep(_ delta: Int, count: Int) -> (Int) -> Int? {
        { index in
            let next = index + delta
            return (0..<count).contains(next) ? next : nil
        }
    }

    static func main() {
        aPageIsTheRowsTheBandShows()
        anUnmeasuredListFallsBack()
        aPageWalksTheList()
        aPageStopsAtTheListEnds()
        aGridPagesByCellRows()

        print("\(passes) passed, \(failures) failed")
        if failures > 0 { exit(1) }
    }

    // MARK: - Measuring the page

    static func aPageIsTheRowsTheBandShows() {
        expect(ListPaging.rows(band: band, rowHeight: rowHeight), 10, "ten 36pt rows fit the band")
        expect(ListPaging.rows(band: band, rowHeight: 40), 9, "and nine 40pt ones")
        // A part-row at the bottom edge is not a row the page may count on.
        expect(ListPaging.rows(band: 100, rowHeight: 30), 3, "a partial row does not count")
        expect(ListPaging.rows(band: 200, rowHeight: 400), 1, "a row taller than the band is a page")
    }

    static func anUnmeasuredListFallsBack() {
        expect(
            ListPaging.rows(band: 0, rowHeight: rowHeight), ListPaging.unmeasuredRows,
            "a band reported before layout falls back")
        expect(
            ListPaging.rows(band: band, rowHeight: 0), ListPaging.unmeasuredRows,
            "and so does a row with no height")
    }

    // MARK: - Walking a list

    static func aPageWalksTheList() {
        let down = listStep(1, count: 40)
        expect(
            ListPaging.destination(from: 0, rows: 10, step: down), 10,
            "a page down from the first row lands a band lower")
        expect(
            ListPaging.destination(from: 10, rows: 10, step: listStep(-1, count: 40)), 0,
            "and a page up comes back to it")
        // Zero rows would stand still, which no key press may do.
        expect(ListPaging.destination(from: 0, rows: 0, step: down), 1, "a zero page still steps once")
    }

    static func aPageStopsAtTheListEnds() {
        expect(
            ListPaging.destination(from: 35, rows: 10, step: listStep(1, count: 40)), 39,
            "a page down near the end stops on the last row")
        expect(
            ListPaging.destination(from: 39, rows: 10, step: listStep(1, count: 40)), 39,
            "and the last row has nowhere left to go")
        expect(
            ListPaging.destination(from: 4, rows: 10, step: listStep(-1, count: 40)), 0,
            "a page up near the start stops on the first row")
    }

    // MARK: - Paging a grid

    static func aGridPagesByCellRows() {
        let grid = EmojiGridGeometry(counts: [100], columns: 8)
        expect(
            ListPaging.destination(from: 0, rows: 5, step: { grid.down(from: $0) }), 40,
            "five pages of a grid row move five rows of cells, not five cells")
        expect(
            ListPaging.destination(from: 40, rows: 5, step: { grid.up(from: $0) }), 0,
            "and back up the same five")
        // The last row is where a page ends, however much of it is left.
        expect(
            ListPaging.destination(from: 80, rows: 5, step: { grid.down(from: $0) }), 96,
            "a page down in the last rows stops on the last one")
        expect(
            ListPaging.destination(from: 96, rows: 5, step: { grid.down(from: $0) }), 96,
            "and a selection already there stays put")
    }
}
