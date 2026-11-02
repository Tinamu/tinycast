import Foundation

/// A tap macOS refuses to enable is as dead as one it refused to create, so both must ask.
@main
@MainActor
struct ModifierTapGrantTests {
    static var failures = 0
    static var passes = 0

    static func expect(_ actual: Bool, _ expected: Bool, _ message: String) {
        if actual == expected {
            passes += 1
        } else {
            failures += 1
            print("FAIL: \(message) — got \(actual), want \(expected)")
        }
    }

    static func main() {
        aTapThatIsNotLiveAsksForTheGrant()
        nothingBoundAsksForNothing()
        anotherSessionAsksForNothing()

        print("\(passes) passed, \(failures) failed")
        if failures > 0 { exit(1) }
    }

    // MARK: - What the tap's state means

    static func aTapThatIsNotLiveAsksForTheGrant() {
        // The case this harness exists for: the tap stands, and the system never enabled it.
        expect(
            ModifierTapGrant.isMissing(isBound: true, isSessionActive: true, isTapEnabled: false),
            true, "a tap that will not enable asks for the grant")
        expect(
            ModifierTapGrant.isMissing(isBound: true, isSessionActive: true, isTapEnabled: nil),
            true, "so does a tap that could not be created")
        expect(
            ModifierTapGrant.isMissing(isBound: true, isSessionActive: true, isTapEnabled: true),
            false, "a live tap asks for nothing")
    }

    static func nothingBoundAsksForNothing() {
        // No shortcut wants the tap, so its absence is the resting state, not a missing grant.
        expect(
            ModifierTapGrant.isMissing(isBound: false, isSessionActive: true, isTapEnabled: nil),
            false, "no binding means no warning")
        expect(
            ModifierTapGrant.isMissing(isBound: false, isSessionActive: true, isTapEnabled: false),
            false, "nor does the tap being torn down on the way out")
    }

    static func anotherSessionAsksForNothing() {
        // Fast user switching takes the keyboard away; the grant is still there when it returns.
        expect(
            ModifierTapGrant.isMissing(isBound: true, isSessionActive: false, isTapEnabled: nil),
            false, "an inactive session means no warning")
        expect(
            ModifierTapGrant.isMissing(isBound: true, isSessionActive: false, isTapEnabled: false),
            false, "nor does a tap already disabled for it")
    }
}
