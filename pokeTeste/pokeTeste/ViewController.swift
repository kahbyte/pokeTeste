//
//  ViewController.swift
//  pokeTeste
//
//  Created by Kauê Sales on 09/02/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    var pokeNumber: String!
    @IBOutlet weak var currentWeatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var precipitacaoLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    struct weatherResponse: Codable {
        let name: String
        let weather: [Weather]
        let main: Main
    }
    
    struct Main: Codable {
        let temp: Float
    }
    
    struct Weather: Codable {
        let main: String
    }
    
    
    struct pokeResponse: Codable {
        let species: Species
        let sprites: Sprites
    }
    struct Species: Codable {
        let name: String
    }
    struct Sprites: Codable {
        let front_default: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLocation()
    }

    @IBAction func okPressed(_ sender: Any) {
        if txtField.hasText == true {
            extractPokemonData(pokeNumber: txtField.text!)
        }
    }
    
    func extractPokemonData(pokeNumber: String) {
        if let url = URL(string: "https://pokeapi.co/api/v2/pokemon/" + pokeNumber) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(pokeResponse.self, from: data)
                        
                        self.updateName(name: res.species.name)
                        self.updateImage(image: res.sprites.front_default)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func updateName(name: String){
        print("Name")
        DispatchQueue.main.async {
            self.label.text = name.uppercased()
        }
    }
    
    func updateImage(image: String){
        guard let url = URL(string: image) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                return
            }

            DispatchQueue.main.async {
                self.image.image = UIImage(data: data!)
            }
        }.resume()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func updateWeatherData() {
        guard let currentLocation = currentLocation else { return }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        print("\(long) | \(lat)")
        if let url = URL(string: "https://fcc-weather-api.glitch.me/api/current?lat=\(lat)&lon=\(long)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(weatherResponse.self, from: data)
                        self.updateWeatherDisplayInfo(currentWeather: res.weather[0].main, temperature: res.main.temp, location: res.name)
                        
                    } catch {
                        print(error)
                    }
                }
                
            }.resume()
        }
    }
    
    func updateWeatherDisplayInfo(currentWeather: String, temperature: Float, location: String) {
        
        DispatchQueue.main.async {
            self.currentWeatherLbl.text = currentWeather
            self.tempLbl.text = "\(temperature)"
            self.locationLbl.text = location
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            updateWeatherData()
        }
    }
}



extension ViewController: CLLocationManagerDelegate {
    
}
