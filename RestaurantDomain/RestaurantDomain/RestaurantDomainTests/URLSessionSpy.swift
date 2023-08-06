//

import Foundation

final class URLSessionSpy: URLSession {
	struct Stub {
		let task: URLSessionDataTask
		let data: Data?
		let response: URLResponse?
		let error: Error?

		init(
			task: URLSessionDataTask,
			error: Error? = nil,
			data: Data? = nil,
			response: URLResponse? = nil)
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
		response: URLResponse? = nil
	) {
		stubs[url] = Stub(task: task, error: error, data: data, response: response)
	}
}
