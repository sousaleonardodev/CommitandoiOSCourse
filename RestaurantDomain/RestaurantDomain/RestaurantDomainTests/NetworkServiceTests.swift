//

import Foundation
import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
	func testRequestAndCreateDataTaskWithURLAndResume() throws {
		let (sut, session, task) = makeSUT()
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))

		session.stub(url: url, task: task)

		sut.request(from: url) { _ in }

		XCTAssertEqual(task.resumeCount, 1)
	}

	func testLoadRequestWithError() throws {
		let (sut, session, task) = makeSUT()
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))

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

	func testLoadRequestWithSuccess() throws {
		let (sut, session, task) = makeSUT()
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))
		let data = Data()
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

		session.stub(url: url, task: task, data: data, response: response)

		let expectation = XCTestExpectation(description: "reqeust return")

		sut.request(from: url) { result in
			switch result {
			case let .success((returnedData, returnedResponse)):
				XCTAssertEqual(returnedData, data)
				XCTAssertEqual(returnedResponse, response)
			default:
				XCTFail("Should receive success")
			}
			expectation.fulfill()
		}

		wait(for: [expectation])
	}

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: NetworkClient, session: URLSessionSpy, task: URLSessionDataTaskSpy) {
		let session = URLSessionSpy()
		let sut = NetworkService(session: session)
		let task = URLSessionDataTaskSpy()

		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(session)

		return (sut, session, task)
	}

	private func resultErrorForInvalidCase(
		data: Data?,
		response: HTTPURLResponse?,
		error: Error?,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> Error? {
		let result: NetworkClient.NetworkResult? = assert(data: data, response: response, error: error)

		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Should receive error", file: file, line: line)
		}
		return nil
	}

	private func assert(
		data: Data?,
		response: HTTPURLResponse?,
		error: Error?,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> NetworkService.NetworkResult? {
		let (sut, session, task) = makeSUT()
		let url = URL(string: "https://commitando.comb.br")!

		session.stub(url: url, task: task, error: error, data: data, response: response)

		let expectation = XCTestExpectation(description: "resquest expectation")
		var returnedResut: NetworkService.NetworkResult?

		sut.request(from: url) { result in
			expectation.fulfill()
			returnedResut = result
		}

		wait(for: [expectation], timeout: CGFloat(1))
		return returnedResut
	}
}

final class URLSessionSpy: URLSession {
	struct Stub {
		let task: URLSessionDataTask
		let data: Data?
		let response: HTTPURLResponse?
		let error: Error?

		init(
			task: URLSessionDataTask,
			error: Error? = nil,
			data: Data? = nil,
			response: HTTPURLResponse? = nil)
		{
			self.task = task
			self.error = error
			self.data = data
			self.response = response
		}
	}

	private(set) var stubs: [URL: Stub] = [:]

	override func dataTask(
		with url: URL,
		completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
	) -> URLSessionDataTask {
		guard let stub = stubs[url] else {
			return URLSessionDataTaskSpy()
		}

		completionHandler(stub.data, stub.response, stub.error)
		return stub.task
	}

	func stub(
		url: URL,
		task: URLSessionDataTask,
		error: Error? = nil,
		data: Data? = nil,
		response: HTTPURLResponse? = nil
	) {
		stubs[url] = Stub(task: task, error: error, data: data, response: response)
	}
}

final class URLSessionDataTaskSpy: URLSessionDataTask {
	private(set) var resumeCount = 0

	override func resume() {
		resumeCount += 1
	}
}
