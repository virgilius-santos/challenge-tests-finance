import XCTest

extension XCTestCase {

    private var defaultConfigurations: [SnapshotConfiguration] {
        [
            .iPhone8(style: .light),
            .iPhone8(style: .dark)
        ]
    }

    private func name(forFile file: StaticString, function: StaticString, style: String) -> String {

        let url = URL(fileURLWithPath: file.description).deletingPathExtension()
        let fileName = url.lastPathComponent

        return "\(fileName)__\(function.description)_\(style)".replacingOccurrences(of: "()", with: "")
    }

    func assertSnapshot(_ viewController: UIViewController, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {

        defaultConfigurations.forEach { config in
            let snapshot = viewController.snapshot(for: config)

            let name = name(forFile: file, function: function, style: config.style.description)

            let snapshotURL = makeSnapshotURL(named: name, file: file)
            let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

            guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
                XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
                return
            }

            if snapshotData != storedSnapshotData {
                let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                    .appendingPathComponent(snapshotURL.lastPathComponent)

                try? snapshotData?.write(to: temporarySnapshotURL)

                XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
            }
        }
    }

    func recordSnapshot(_ viewController: UIViewController, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {

        defaultConfigurations.forEach { config in
            let snapshot = viewController.snapshot(for: config)
            let name = name(forFile: file, function: function, style: config.style.description)

            let snapshotURL = makeSnapshotURL(named: name, file: file)
            let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

            do {
                try FileManager.default.createDirectory(
                    at: snapshotURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try snapshotData?.write(to: snapshotURL)

                XCTFail("Snapshot recorded at: \(snapshotURL.absoluteString)", file: file, line: line)
            } catch {
                XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
            }
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }

        return data
    }

}
