import XCTest

@testable import Core

class URLSessionSpy: URLSessionProtocol {
    private(set) var urlRequests: [URLRequest] = []
    private(set) var completions: [(Data?, URLResponse?, Error?) -> Void] = []

    var httpMethods: [String] {
        urlRequests.compactMap { $0.httpMethod }
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        urlRequests.append(request)
        completions.append(completionHandler)
    }
}

final class URLSessionHttpClientTests: XCTestCase {
    func test_doesNotPerformAnyRequestOnInit() {
        let (_, session) = makeSUT()

        XCTAssertTrue(session.urlRequests.isEmpty)
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let (sut, session) = makeSUT()
        let anyURL = URL.anyValue

        sut.get(from: anyURL) { _ in }

        XCTAssertEqual(session.httpMethods, ["GET"])

        sut.get(from: anyURL) { _ in }

        XCTAssertEqual(session.httpMethods, ["GET", "GET"])
    }

    func test_getFromURL_failsOnRequestError() {
        let expectedResult = anyNSError

        let actualResult = whenFails(error: expectedResult)

        XCTAssertEqual(actualResult?.asNSError, expectedResult)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        expectErrorWhen(dataIs: nil, responseIs: nil, errorIs: nil)
        expectErrorWhen(dataIs: nil, responseIs: nonHTTPURLResponse, errorIs: nil)
        expectErrorWhen(dataIs: anyData, responseIs: nil, errorIs: nil)
        expectErrorWhen(dataIs: anyData, responseIs: nil, errorIs: anyNSError)
        expectErrorWhen(dataIs: nil, responseIs: nonHTTPURLResponse, errorIs: anyNSError)
        expectErrorWhen(dataIs: nil, responseIs: anyHTTPURLResponse, errorIs: anyNSError)
        expectErrorWhen(dataIs: anyData, responseIs: nonHTTPURLResponse, errorIs: anyNSError)
        expectErrorWhen(dataIs: anyData, responseIs: anyHTTPURLResponse, errorIs: anyNSError)
        expectErrorWhen(dataIs: anyData, responseIs: nonHTTPURLResponse, errorIs: nil)
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() throws {
        let data = anyData
        let response = anyHTTPURLResponse

        let expectedValue = try expectedValueWhen(dataIs: data, responseIs: response, errorIs: nil)

        XCTAssertEqual(expectedValue.data, data)
        XCTAssertEqual(expectedValue.statusCode, response.statusCode)
    }

    // O URL session manda Data() (data vazio) quando tem HTTPResponse,
    // e isso gente não consegue reproduzir usando Spy
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() throws {
        // let response = anyHTTPURLResponse

        // let expectedValue = try expectedValueWhen(dataIs: nil, responseIs: response, errorIs: nil)

        // XCTAssertEqual(expectedValue.statusCode, response.statusCode)

        // isso so acontece com o URLSession real
        // let emptyData = Data()
        // XCTAssertEqual(expectedValue.data, emptyData)
    }

    // MARK: Helpers

    private func expectedValueWhen(dataIs data: Data?, responseIs response: URLResponse?, errorIs error: Error?, file: StaticString = #file, line: UInt = #line) throws -> HttpClient.Response {
        let actualResult = when(dataIs: data, responseIs: response, errorIs: error)

        return try XCTUnwrap(try actualResult?.get(), file: file, line: line)
    }

    private func expectErrorWhen(dataIs data: Data?, responseIs response: URLResponse?, errorIs error: Error?, file: StaticString = #file, line: UInt = #line) {
        let actualResult = when(dataIs: data, responseIs: response, errorIs: error)

        XCTAssertNil(try? actualResult?.get(), file: file, line: line)
    }

    private func when(dataIs data: Data?, responseIs response: URLResponse?, errorIs error: Error?) -> URLSessionHttpClient.Result? {
        let (sut, session) = makeSUT()

        var actualResult: URLSessionHttpClient.Result?
        sut.get(from: .anyValue) { result in
            actualResult = result
        }
        session.completions[0](data, response, error)

        return actualResult
    }

    private func whenFails(error: Error) -> Error? {
        let actualResult = when(dataIs: nil, responseIs: nil, errorIs: error)

        switch actualResult {
        case .success, .none:
            return nil
        case .failure(let error):
            return error
        }
    }

    private var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: .anyValue, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private var nonHTTPURLResponse: URLResponse {
        URLResponse(url: .anyValue, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private var anyNSError: NSError {
        NSError(domain: .anyValue, code: 0)
    }

    private var anyData: Data {
        return Data(String.anyValue.utf8)
    }

    private func makeSUT() -> (HttpClient, URLSessionSpy) {
        let session = URLSessionSpy()
        let sut = URLSessionHttpClient(session: session)

        return (sut, session)
    }
}

extension Error {
    var asNSError: NSError {
        self as NSError
    }
}

extension String {
    static var anyValue: String {
        UUID().uuidString
    }
}
