import XCTest
@testable import ToDo

class APIClientTests: XCTestCase {
    
    var sut: APIClient!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        sut = APIClient()
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        sut.session = mockURLSession
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: - URL CONSTRUCTION
    func test_Login_UsesExpectedHost() {
        
        let completion = {(token: Token?, error: Error?) in }
        sut.loginUser(withName: "dasdom",
                      password: "1234",
                      completion: completion)
        
        XCTAssertEqual(mockURLSession.urlComponents?.host, "awesometodos.com")
    }
    
    func test_Login_UsesExpectedPath() {
        
        let completion = {(token: Token?, error: Error?) in }
        sut.loginUser(withName: "dasdom",
                      password: "1234",
                      completion: completion)
        
        XCTAssertEqual(mockURLSession.urlComponents?.path, "/login")
    }
    
    func test_Login_UsesExpectedQuery() {
        
        let completion = {(token: Token?, error: Error?) in }
        sut.loginUser(withName: "dasdöm",
                      password: "%&34",
                      completion: completion)
        
        guard let queryItems = mockURLSession.urlComponents?.queryItems else {
            XCTFail()
            return
        }
     
        let username = (URLQueryItem(name: "username", value: "dasdöm"))
        let password = (URLQueryItem(name: "password", value: "%&34"))
        XCTAssertEqual(queryItems.count, 2)

        XCTAssertTrue(queryItems.contains(username))
        XCTAssertTrue(queryItems.contains(password))
        //XCTAssertEqual(mockURLSession.urlComponents?.percentEncodedQuery, "username=dasd%C3%B6m&password=%25%2634")
    }
    
    //MARK: - DATA RETURN
    func test_Login_WhenSuccessful_CreatesToken() {
        let jsonData = "{\"token\": \"1234567890\"}".data(using: .utf8)
        
        mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: nil)
        sut.session = mockURLSession
        let tokenExpectation = expectation(description: "Token")
        var caughtToken: Token? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { token, _ in
            caughtToken = token
            tokenExpectation.fulfill()
        }
        
            waitForExpectations(timeout: 3) {_ in
            XCTAssertEqual(caughtToken?.id, "1234567890")
        }
    }
    
    //MARK: - ERROR RETURN
    func test_Login_WhenJSONIsInvalid_ReturnsError() {
        mockURLSession = MockURLSession(data: Data(), urlResponse: nil, error: nil)
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_Login_WhenDataIsNil_ReturnsError() {
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.loginUser(withName: "Foo", password: "Bar") {
            (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) {(error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_Login_WhenResponseHasError_ReturnsError() {
        
        let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
        let jsonData = "{\"token\": \"1234567890\"}".data(using: .utf8)
        
        mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: error)
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
}

//MARK: - MOCK URL SESSION & TASK
extension APIClientTests {
    
    class MockTask: URLSessionDataTask {
        private let data: Data?
        private let urlResponse: URLResponse?
        private let responseError: Error?
        
        typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
        var completionHandler: CompletionHandler?
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.responseError = error
        }
        
        override func resume() {
            DispatchQueue.main.async() {
                self.completionHandler?(self.data, self.urlResponse, self.responseError)
            }
        }
    }
        class MockURLSession: SessionProtocol {
            var url: URL?
            private let dataTask: MockTask
            
            var urlComponents: URLComponents? {
                guard let url = url else { return nil }
                return URLComponents(url: url, resolvingAgainstBaseURL: true)
            }
            
            init(data: Data?, urlResponse: URLResponse?, error: Error?) {
                dataTask = MockTask(data: data, urlResponse: urlResponse, error: error)
            }
            
            func dataTask(
                with url: URL,
                completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                
                self.url = url
                print(url)
                dataTask.completionHandler = completionHandler
                return dataTask
                
            }
        }
    }
    
    
    

