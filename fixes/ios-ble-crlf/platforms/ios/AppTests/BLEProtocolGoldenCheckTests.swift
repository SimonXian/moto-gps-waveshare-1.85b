import Foundation
import XCTest
@testable import MOTO_GPS

final class BLEProtocolGoldenCheckTests: XCTestCase {
    func testPackagedGoldenVectorAcceptsUnixAndWindowsLineEndings() throws {
        let resource = try XCTUnwrap(Bundle.main.url(
            forResource: "ble-navigation-v1.golden", withExtension: "txt"
        ))
        let original = try String(contentsOf: resource, encoding: .utf8)
        let lines = original.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let fixture = FileManager.default.temporaryDirectory
            .appendingPathComponent("ble-golden-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: fixture) }

        for newline in ["\n", "\r\n"] {
            try (lines.joined(separator: newline) + newline)
                .write(to: fixture, atomically: true, encoding: .utf8)
            let codec = MotoBLEProtocolCodec(maximumFrameSize: 182)
            XCTAssertNoThrow(try BLEProtocolGoldenCheck.verify(codec: codec, fixtureURL: fixture))
        }
    }
}
