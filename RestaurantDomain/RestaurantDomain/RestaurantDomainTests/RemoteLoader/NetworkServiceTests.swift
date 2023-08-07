//

import Foundation
import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
	func testRequestAndCreateDataTaskWithURLAndResume() {
		let (sut, session, task) = makeSUT()
		let url = URL(string: "https://comitando.com.br")!
		session.stub(url: url, task: task)

		sut.request(from: url) { _ in }

		XCTAssertEqual(task.resumeCount, 1)
	}

	func testLoadRequestWithError() {
		let (sut, session, task) = makeSUT()
		let url = URL(string: "https://comitando.com.br")!
		let expectation = XCTestExpectation(description: "reqeust return")
		let error = NSError(domain: "error", code: -1)
		session.stub(url: url, task: task, error: error)

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

	func testLoadRequestWithSuccess() {
		let (sut, session, task) = makeSUT()
		let url = URL(string: "https://comitando.com.br")!
		let data = Data()
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expectation = XCTestExpectation(description: "reqeust return")
		session.stub(url: url, task: task, data: data, response: response)

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

	func testLoadRequestWithErrorForInvalidCases() {
		let url = URL(string: "https://commitando.com.br")!
		let data = Data()
		let anyError = NSError(domain: "testing error", code: -1)
		let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: nil))

		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: urlResponse, error: nil))

		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: anyError))

		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: urlResponse, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: httpResponse, error: anyError))

		let validResult = resultErrorForInvalidCases(data: nil, response: nil, error: anyError)
		XCTAssertNotNil(validResult)
		XCTAssertEqual(validResult as? NSError, anyError)
	}

	func testLoadRequestWithSuccessForValidCases() {
		let url = URL(string: "https://commitando.com.br")!
		let data = Data()
		let okResponse = Int(200)
		let httpResponse = HTTPURLResponse(url: url, statusCode: okResponse, httpVersion: nil, headerFields: nil)
		let result = resultSuccessForValidCases(data: data, response: httpResponse, error: nil)

		XCTAssertNotNil(result)
		XCTAssertEqual(result?.data, data)
		XCTAssertEqual(result?.response.url, url)
		XCTAssertEqual(result?.response.statusCode, okResponse)
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

	private func resultErrorForInvalidCases(
		data: Data?,
		response: URLResponse?,
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

	private func resultSuccessForValidCases(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (data: Data, response: HTTPURLResponse)? {
		let result: NetworkClient.NetworkResult? = assert(data: data, response: response, error: error)

		switch result {
		case let .success((data, response)):
			return (data, response)
		default:
			XCTFail("Should receive success", file: file, line: line)
		}
		return nil
	}

	private func assert(
		data: Data?,
		response: URLResponse?,
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
