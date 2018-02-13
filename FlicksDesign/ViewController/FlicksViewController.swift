//
//  FlicksViewController.swift
//  FlicksDesign
//
//  Created by Emmanuel Sarella on 2/11/18.
//  Copyright © 2018 Emmanuel Sarella. All rights reserved.
//

import UIKit
import AFNetworking

class FlicksViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var moviesDict: [NSDictionary]?
    var endpoint: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMovies()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.moviesDict {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = moviesDict![indexPath.row]
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = "\(title)"
        cell.overViewLabel.text = "\(overview)"
        
        if let posterPath = movie["poster_path"] as? String {

            let posterBaseUrl = "https://image.tmdb.org/t/p/"
            let lowResPosterUrl = URL(string: posterBaseUrl + "w45" + posterPath)
            let highResPosterUrl = URL(string: posterBaseUrl + "original" + posterPath)

            let lowResImageRequest = NSURLRequest(url: lowResPosterUrl!)
            let highResImageRequest = NSURLRequest(url: highResPosterUrl!)
        
            cell.posterView.setImageWith(
                lowResImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (lowResImageRequest, lowResImageResponse, lowResImage) -> Void in

                    cell.posterView.alpha = 0.0
                    cell.posterView.image = lowResImage
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    }, completion: { (success) -> Void in

                        cell.posterView.setImageWith(
                            highResImageRequest as URLRequest,
                            placeholderImage: lowResImage,
                            success: { (highResImageRequest, highResImageResponse, highResImage) -> Void in

                                cell.posterView.image = highResImage;
                        },
                            failure: { (request, response, error) -> Void in

                                print(error)
                        })
                    })

            },
                failure: { (request, response, error) -> Void in
                    print(error)

            })
        } else {
            cell.posterView.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
    func loadMovies() {
        let apiKey = "dd14cbf0944a25730ce1050bf471193b"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)

        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            
            
            if let httpError = error {
                print("\(httpError)")
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.moviesDict = responseDictionary["results"] as? [NSDictionary]
                        self.tableView.reloadData()
                    }
                }
            }
        });
        
        task.resume()
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if (fromInterfaceOrientation == UIInterfaceOrientation.portrait){
            print("Switched from Potrait to Landscape")
        }
        else if ((fromInterfaceOrientation == UIInterfaceOrientation.landscapeLeft)
            || (fromInterfaceOrientation == UIInterfaceOrientation.landscapeRight)){
            print("Switched from Landscape to Potrait")
        }
    }

}
