//
//  ViewController.swift
//  alaskaAirlinesTestProject
//
//  Created by Dominick Hera on 12/7/21.
//

import UIKit


struct scheduledDateTime: Codable
{
    let outValue: Date
    let inValue: Date
    
    private enum CodingKeys : String, CodingKey
    {
        case outValue = "out"
        case inValue = "in"
    }
}

struct gate: Decodable
{
    let podium: String?
    let parkingSpot: String?
    let carousel: String?
}

struct actualDepartureStation: Decodable
{
    let airportCode: String
    let gate: gate
}

struct flightLegs: Decodable
{
    let scheduledDateTimeUTC: scheduledDateTime
    let actualDepartureStation: actualDepartureStation
    let actualArrivalStation: actualDepartureStation
}

struct flightDetails: Decodable
{
    let operatingFlightNumber: String
    let scheduledFlightOriginationDateLocal: String
    let flightLegs: [flightLegs]
}

struct flight: Decodable
{
    let flightDetails: flightDetails
    let flightLookupKey: String
}

struct flightsObject: Decodable
{
    let flights: [flight]
}

class ViewController: UIViewController
{
    
    @IBOutlet weak var flightTableView: UITableView!
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var tempUrl = URLComponents(string: "https://apis.qa.alaskaair.com/aag/1/guestServices/flights/")
    var flightBoard = [flight]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupDatePicker()
    }
    
    func setupDatePicker()
    {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        if #available(iOS 14, *)
        {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        datePickerTextField.inputView = datePicker
    }
    
    @objc func didSelectDate(_ datePicker: UIDatePicker)
    {
        datePickerTextField.text = datePicker.date.formatted
    }
    
    @IBAction func didPressSearch()
    {
        datePickerTextField.resignFirstResponder()
        originTextField.resignFirstResponder()
        destinationTextField.resignFirstResponder()
        
        guard let origin = originTextField.text, let destination = destinationTextField.text, let travelDate = datePickerTextField.text else { return }
        
        loadingIndicator.isHidden = false
        searchForFlights(origin: origin.uppercased(), destination: destination.uppercased(), travelDate: travelDate)
        {
            matchingFlights, error in
            
            self.flightBoard = matchingFlights.sorted(by: {
                $0.flightDetails.flightLegs[0].scheduledDateTimeUTC.outValue.compare($1.flightDetails.flightLegs[0].scheduledDateTimeUTC.outValue) == .orderedAscending
            })
            
            DispatchQueue.main.async
            {
                self.loadingIndicator.isHidden = true
                self.flightTableView.reloadData()
            }
        }
    }
    
    func searchForFlights(origin: String, destination: String, travelDate: String, callback: @escaping(_ matchingFlights: [flight], _ error: Error?) -> Void)
    {
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
                callback([flight](), error)
                
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flights = try decoder.decode(flightsObject.self, from: receivedData)
                callback(flights.flights, nil)
            }
            catch
            {
                print("Invalid Response")
                print(error)
                callback([flight](), error)
            }
        }
        
        task.resume()
    }
}

//MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return flightBoard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let flight = flightBoard[indexPath.row]
        cell.textLabel?.text = "Flight #: \(flight.flightDetails.operatingFlightNumber)"
        cell.detailTextLabel?.text = "Departure Time: \(flight.flightDetails.flightLegs[0].scheduledDateTimeUTC.outValue) | Arrival Time: \(flight.flightDetails.flightLegs[0].scheduledDateTimeUTC.inValue)"
        
        return cell
    }
}

//MARK: Date
extension Date
{
    static let formatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var formatted: String
    {
        return Date.formatter.string(from: self)
    }
}

//MARK: Formatter

extension Formatter
{
    static let iso8601: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
