import XCTest
@testable import SimplifySwift

final class SimplifySwiftTests: XCTestCase {
    private struct TestPoint: SimplifyValue, Equatable {
        let x: Double
        let y: Double

        var xValue: Double { x }
        var yValue: Double { y }
    }

    func testEmptyInputReturnsEmpty() {
        let simplified = Simplify.simplify([TestPoint](), tolerance: 1)
        XCTAssertTrue(simplified.isEmpty)
    }

    func testSinglePointReturnsOriginal() {
        let points = [TestPoint(x: 0, y: 0)]
        let simplified = Simplify.simplify(points, tolerance: 1)
        XCTAssertEqual(simplified, points)
    }

    func testTwoPointsReturnOriginal() {
        let points = [TestPoint(x: 0, y: 0), TestPoint(x: 5, y: 5)]
        let simplified = Simplify.simplify(points, tolerance: 1)
        XCTAssertEqual(simplified, points)
    }

    func testStraightLineCollapsesToEndpoints() {
        let points = (0...10).map { TestPoint(x: Double($0), y: Double($0)) }
        let simplified = Simplify.simplify(points, tolerance: 1, highQuality: true)

        XCTAssertEqual(simplified, [points.first!, points.last!])
    }

    func testDuplicatePointsAreDropped() {
        let points = [
            TestPoint(x: 0, y: 0),
            TestPoint(x: 0, y: 0),
            TestPoint(x: 1, y: 1),
            TestPoint(x: 1, y: 1),
            TestPoint(x: 2, y: 2)
        ]

        let simplified = Simplify.simplify(points, tolerance: 0.5)
        XCTAssertEqual(simplified, [TestPoint(x: 0, y: 0), TestPoint(x: 2, y: 2)])
    }

    func testZeroTolerancePreservesNonCollinearPoints() {
        let points = [
            TestPoint(x: 0, y: 0),
            TestPoint(x: 1, y: 2),
            TestPoint(x: 2, y: 0),
            TestPoint(x: 3, y: 2),
            TestPoint(x: 4, y: 0)
        ]

        let simplified = Simplify.simplify(points, tolerance: 0, highQuality: true)
        XCTAssertEqual(simplified, points)
    }

    func testNegativeToleranceMatchesPositiveTolerance() {
        let points = [
            TestPoint(x: 0, y: 0),
            TestPoint(x: 1, y: 2),
            TestPoint(x: 2, y: 1),
            TestPoint(x: 3, y: 3),
            TestPoint(x: 4, y: 2),
            TestPoint(x: 5, y: 4)
        ]

        let positive = Simplify.simplify(points, tolerance: 1.5)
        let negative = Simplify.simplify(points, tolerance: -1.5)

        XCTAssertEqual(negative, positive)
    }

    func testReferenceVectorMatchesExpectedEndpoints() {
        let points = [
            TestPoint(x: 0, y: 0),
            TestPoint(x: 1, y: 1),
            TestPoint(x: 2, y: 2),
            TestPoint(x: 3, y: 3),
            TestPoint(x: 4, y: 4),
            TestPoint(x: 5, y: 5)
        ]

        let simplified = Simplify.simplify(points, tolerance: 1)
        XCTAssertEqual(simplified, [TestPoint(x: 0, y: 0), TestPoint(x: 5, y: 5)])
    }

    @available(*, deprecated)
    func testLegacyFloatAPIProducesSameResultAsDoubleAPI() {
        let points = [
            TestPoint(x: 0, y: 0),
            TestPoint(x: 1, y: 2),
            TestPoint(x: 2, y: 1),
            TestPoint(x: 3, y: 4)
        ]

        let fromDouble = Simplify.simplify(points, tolerance: 1.25)
        let fromFloat = Simplify.simplify(points, tolerance: Float(1.25))

        XCTAssertEqual(fromDouble, fromFloat)
    }
}
