//
//  TravelTests.swift
//  TravelTests
//
//  Created by SoniaWu on 2024/1/17.
//

import XCTest
@testable import Travel
import MapKit

final class TravelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    func testPhotoApi() {
        let fetchAPIUtility = FetchApiDataUtility()
        let input = fetchAPIUtility.prepareURL(forDataType: .photo, loactionid: "123456", searchQuery: nil, category: nil, language: "zh-TW")
        let answer = URL(string: "https://api.content.tripadvisor.com/api/v1/location/4800782/photos?key=AF48615F85EB441CB66C36342C521A6A&language=en")
        
        XCTAssertEqual(input, answer)

    }
    
    func testConvertAddress() {
        let uis = UISettingUtility()
        let output = uis.getCoordinates()
        XCTAssertEqual(output, nil)
      
        
    }

}
