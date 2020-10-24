//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Weirong Wu on 10/23/20.
//  Copyright © 2020 Weirong Wu. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numTweets: Int!
    let refereshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        refereshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = refereshControl
    }
    
    @objc func loadTweets() {
        numTweets = 20
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myCount = ["count": numTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: myCount, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.refereshControl.endRefreshing()
        }, failure: { (Error) in
            print("Failure to retrieve tweets")
        })
    }
    
    
    func loadMoreTweets() {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numTweets = numTweets + 20
        let myCount = ["count": numTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: myCount, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Failure to retrieve tweets")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    

    @IBAction func onLogOut(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let userName = user["name"] as! String
        
        cell.userNameLabel.text = userName
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"]) as! String)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
