//
//  alaskaAirlinesTestProjectTests.swift
//  alaskaAirlinesTestProjectTests
//
//  Created by Dominick Hera on 12/7/21.
//

import XCTest
@testable import alaskaAirlinesTestProject

class alaskaAirlinesTestProjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchFlightsWithFunctionalData() throws {
        let expectation = XCTestExpectation(description: "Retrieve List of Applicable Flights")
        
        var tempUrl = URLComponents(string: "https://apis.qa.alaskaair.com/aag/1/guestServices/flights/")
        let travelDate = "2021-12-10"
        let origin = "PDX"
        let destination = "LAX"
        
        tempUrl?.queryItems = [
            URLQueryItem(name: "fromDate", value: travelDate),
            URLQueryItem(name: "toDate", value: travelDate),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination)
        ]
        
        let url = URL(string: tempUrl?.string ?? "")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "8420dcb1d57f4c13b47b18a4faf0d990"
        ]
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flights = try decoder.decode(flightsObject.self, from: receivedData)
                XCTAssert(flights.flights.count > 0)
                expectation.fulfill()
            }
            catch
            {
                print("Invalid Response")
                print(error)
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchFlightsWithEmptyOrigin() throws {
        let expectation = XCTestExpectation(description: "Failt to Retrieve List of Applicable Flights")
        
        var tempUrl = URLComponents(string: "https://apis.qa.alaskaair.com/aag/1/guestServices/flights/")
        let travelDate = "2021-12-10"
        let origin = ""
        let destination = "LAX"
        
        tempUrl?.queryItems = [
            URLQueryItem(name: "fromDate", value: travelDate),
            URLQueryItem(name: "toDate", value: travelDate),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination)
        ]
        
        let url = URL(string: tempUrl?.string ?? "")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "8420dcb1d57f4c13b47b18a4faf0d990"
        ]
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                XCTAssertNil(error, "No Flights were found.")
                expectation.fulfill()
                
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flights = try decoder.decode(flightsObject.self, from: receivedData)
            }
            catch
            {
                print("Invalid Response")
                print(error)
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchFlightsWithEmptyDestination() throws {
        let expectation = XCTestExpectation(description: "Fail to Retrieve List of Applicable Flights")
        
        var tempUrl = URLComponents(string: "https://apis.qa.alaskaair.com/aag/1/guestServices/flights/")
        let travelDate = "2021-12-10"
        let origin = "LAX"
        let destination = ""
        
        tempUrl?.queryItems = [
            URLQueryItem(name: "fromDate", value: travelDate),
            URLQueryItem(name: "toDate", value: travelDate),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination)
        ]
        
        let url = URL(string: tempUrl?.string ?? "")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "8420dcb1d57f4c13b47b18a4faf0d990"
        ]
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                XCTAssertNil(error, "No Flights were found.")
                expectation.fulfill()
                
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flights = try decoder.decode(flightsObject.self, from: receivedData)
            }
            catch
            {
                print("Invalid Response")
                print(error)
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchFlightsWithEmptyDate() throws {
        let expectation = XCTestExpectation(description: "Fail to Retrieve List of Applicable Flights")
        
        var tempUrl = URLComponents(string: "https://apis.qa.alaskaair.com/aag/1/guestServices/flights/")
        let travelDate = ""
        let origin = "LAX"
        let destination = "PDX"
        
        tempUrl?.queryItems = [
            URLQueryItem(name: "fromDate", value: travelDate),
            URLQueryItem(name: "toDate", value: travelDate),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination)
        ]
        
        let url = URL(string: tempUrl?.string ?? "")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "8420dcb1d57f4c13b47b18a4faf0d990"
        ]
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                XCTAssertNil(error, "No Flights were found.")
                expectation.fulfill()
                
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flights = try decoder.decode(flightsObject.self, from: receivedData)
            }
            catch
            {
                print("Invalid Response")
                print(error)
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 5.0)
    }
}
