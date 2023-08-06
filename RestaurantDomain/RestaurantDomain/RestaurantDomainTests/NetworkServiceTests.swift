//

import Foundation
import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
	func testRequestAndCreateDataTaskWithURLAndResume() throws {
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))
		let session = URLSessionSpy()
		let sut =  NetworkService(session: session)
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)

		sut.request(from: url) { _ in }

		XCTAssertEqual(task.resumeCount, 1)
	}

	func testLoadRequestWithError() throws {
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))
		let session = URLSessionSpy()
		let sut =  NetworkService(session: session)
		let task = URLSessionDataTaskSpy()

		let error = NSError(domain: "error", code: -1)
		session.stub(url: url, task: task, error: error)
		let expectation = XCTestExpectation(description: "reqeust return")

		sut.request(from: url) { result in
			switch result {
			case let .failure(returnedError):
				XCTAssertEqual(returnedError as NSError, error)
			default:
				XCTFail("Should receive error")
			}
			expectation.fulfill()
		}

		wait(for: [expectation])
	}
}

final class URLSessionSpy: URLSession {
	struct Stub {
		let task: URLSessionDataTask
		let error: Error?

		init(task: URLSessionDataTask, error: Error? = nil) {
			self.task = task
			self.error = error
		}
	}

	private(set) var stubs: [URL: Stub] = [:]

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		guard let stub = stubs[url] else {
			return URLSessionDataTaskSpy()
		}

		completionHandler(nil, nil, stub.error)
		return stub.task
	}

	func stub(url: URL, task: URLSessionDataTask, error: Error? = nil) {
		stubs[url] = Stub(task: task, error: error)
	}
}

final class URLSessionDataTaskSpy: URLSessionDataTask {
	private(set) var resumeCount = 0

	override func resume() {
		resumeCount += 1
	}
}
