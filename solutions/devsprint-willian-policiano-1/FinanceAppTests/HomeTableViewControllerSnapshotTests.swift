import XCTest
import Core
import UIKit

@testable import FinanceApp

class HomeTableViewControllerSnapshotTests: XCTestCase {

    func test_onSuccess_shouldHaveValidSnapshot() {
        let (sut, service) = makeSUT()

        sut.render()
        service.completeWithSuccess(Home(balance: 123, savings: 321, spending: 213))

        assertSnapshot(sut)
    }

    // MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (TestableHomeTableViewController, HomeLoaderSpy) {
        let service = HomeLoaderSpy()
        let adapter = HomeLoaderFetcherAdapter(homeLoader: service)
        let sut = TestableHomeTableViewController(service: adapter)

        return (sut, service)
    }
}
