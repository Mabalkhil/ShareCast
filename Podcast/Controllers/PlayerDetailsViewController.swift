//
//  playerDetailsView.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import UIKit
import AVKit
import ACBAVPlayer



class PlayerDetailsViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //names outlets
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var channelName: UILabel!
    
    //TimeSlider outlets
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    //volume outlet
    @IBOutlet weak var volumeSlider: UISlider!
    
    //
    @IBOutlet weak var SSLabel: UILabel!
    
    var episodeImg: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "appicon")
        //img.sizeToFit()
        return img
    }()
    
    var noMarksText: UITextView = {
        let text = UITextView()
        text.textColor = .white
        
        text.backgroundColor = #colorLiteral(red: 0.2548794746, green: 0.254914552, blue: 0.2548675537, alpha: 1)
        return text
    }()
    
    struct Mark {
        var time:String
        var desc:String
    }
    
    var episode:Episode!
    
    var myTableView: UITableView!
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //view.removeConstraints(view.constraints)
        // Do any additional setup after loading the view.
        setScrollView()
        
        //Innitializing episode and start playing it
        episodeName?.text = episode.title
        playEpisode()
        guard let url = URL(string: episode.imageUrl ?? "") else { return }
        episodeImg.sd_setImage(with: url)
       
        
    }
    
    //MARK:- Scroll View
    //change the pageview when scrolled
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    //setting scroll view
    func setScrollView() {
        pageControl.numberOfPages = 2
        
        frame.origin.x = scrollView.frame.size.width * 0
        frame.size = scrollView.frame.size
        
        episodeImg.frame = frame
        scrollView.addSubview(episodeImg)
        handleTimeMark()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2 + 2, height: scrollView.frame.size.height)
        scrollView.delegate = self
        //scrollView.isScrollEnabled = false
    }
    
    
    //MARK:- Table view functions
    
    var marks: [Mark] = []
    
    func setTable() {
        
        frame.origin.x = scrollView.frame.size.width + 5
        //frame.size = scrollView.frame.size
        
        myTableView = UITableView(frame: frame)
        myTableView.backgroundColor = #colorLiteral(red: 0.2548794746, green: 0.254914552, blue: 0.2548675537, alpha: 1)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.register(TimeMarkCell.self, forCellReuseIdentifier: "TimeMarkCell")
        
        scrollView.addSubview(myTableView)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeMarkCell", for: indexPath) as! TimeMarkCell
        let tm = self.marks[indexPath.row]
        cell.time = tm.time
        cell.desc = tm.desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.2548794746, green: 0.254914552, blue: 0.2548675537, alpha: 1)
    }
    
    //Handing the selected time mark
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTime = self.marks[indexPath.row].time
        
        let timeInSecondsList = selectedTime.split(whereSeparator: { $0 == ":" || $0 == " " })//.map { Double($0)!}
        var timeInSeconds:Double = 0
        if (timeInSecondsList.count == 3 ) {
            let hours = (Double(timeInSecondsList[0]) ?? 0.0 ) * 3600
            let minutes = (Double(timeInSecondsList[1])  ?? 0.0) * 60
            let seconds = (Double( timeInSecondsList[2])  ?? 0.0)
            timeInSeconds = hours + minutes + seconds
                        }
        else {
            let minutes = (Double(timeInSecondsList[0])  ?? 0.0) * 60
            let seconds = (Double( timeInSecondsList[1])  ?? 0.0)
            timeInSeconds =  minutes + seconds
                    }
        
        self.player.seek(to: CMTimeMakeWithSeconds(timeInSeconds, preferredTimescale: 1))
        
    }
    //##################################################################################################
    
    //MARK:- Showing Progress
    //this function for displaying the progress (time)
    //This function would be called every passing second
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            self.currentTimeLabel.text = time.toDisplayString()
            var durationTime = self.player.currentItem?.duration
            durationTime = CMTime(seconds: (self.player.currentItem?.duration.seconds ?? 0) - (time.seconds ), preferredTimescale: durationTime!.timescale)
            
            
            self.durationLabel.text = "-"+(durationTime?.toDisplayString() ?? "--:--")
            self.updateCurrentTimeSlider()
        }
    }
    
    //this function for displaying the progress (slider)
    fileprivate func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    //??
    override func awakeFromNib() {
        super.awakeFromNib()
        observePlayerCurrentTime()
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main){
            
        }
    }
    
    
    //this function to start playing when an episode is selected
    fileprivate func playEpisode(){
        guard let url = URL(string: episode.streamURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        
        player.isMeteringEnabled = true
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    //##################################################################################################
    
    
    //MARK:- Player Declaration
    //declaring the player
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    //MARK:- Play & Pause
    //the pause button
    @IBOutlet weak var playPauseButton: UIButton!{
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused{
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "PAUSE-1"), for: .normal)
        }else{
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "round-play-button"), for: .normal)
            
        }
        
    }
    
    //MARK:- Other Playing related stuff
    
    //controlling playing by sliding the progress bar
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        self.player.seek(to: seekTime)
        player.play()
        
    }
    
    //rewind button
    @IBAction func handleRewind(_ sender: Any) {
        
        seekToCurrentTime(delta: -15)
    }
    
    //forword button
    @IBAction func handleFastForword(_ sender: Any) {
        
        seekToCurrentTime(delta: 15)
        
    }
    
    //rewinding and forwording episode by 15 seconds
    fileprivate func seekToCurrentTime(delta: Int64){
        
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
        
    }
    
    //controlling volume
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    
    //Dismiss Button
    @IBAction func handleDismiss(_ sender: Any) {
        
        self.player.pause()
        //player.stop()
        self.dismiss(animated: true, completion: nil)
    }
    //##################################################################################################
    
    
    //MARK:- Voice Boost
    @IBOutlet weak var speedUpLabel: UILabel!
    
    @IBOutlet weak var speedUpButton: UIButton!{
        didSet{
            speedUpButton.addTarget(self, action: #selector(handleSpeedUp), for: .touchUpInside)
        }
    }
    
    var count = 1
    @objc func handleSpeedUp(){
        
        
        if (count == 1){
            self.player.playImmediately(atRate: 1.5)
            self.speedUpLabel.text = "1.5"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            count = count + 1
        }else if(count == 2){
            self.player.playImmediately(atRate: 2.0)
            self.speedUpLabel.text = "2.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            count = count + 1
        }else if(count == 3){
            self.player.playImmediately(atRate: 0.5)
            self.speedUpLabel.text = "0.5"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            count = 0
        }else{
            self.player.playImmediately(atRate: 1.0)
            self.speedUpLabel.text = "1.0"
            self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            count = count + 1
        }
        
    }
    
    //##################################################################################################
    
    //MARK:- Time Mark
    //only handle if there is a time marks in an episode(Show table or don't)
    @objc func handleTimeMark(){
        print("abcd")
        
        print(self.episode)
        //print(episode.timeStampLables ?? ["a","b"])
        episode.timeStampLables = ["a","b"]
        if (episode.timeStampLables!.count-1 > 0 ) {
            for i in stride(from: 0, through: episode.timeStampLables!.count-1, by: 1){
                let title = episode.timeStampLables![i]
                let time  = episode.timeStamps![i]
                
                self.marks.append(Mark.init(time: time, desc: title))
            }
            setTable()
        }
        else {
            frame.origin.x = scrollView.frame.size.width + 5
            noMarksText.frame = frame
            noMarksText.text = "No time marks for this episode"
            noMarksText.textAlignment = .center
            scrollView.addSubview(noMarksText)
        }//
        
    }

    
    
//    //MARK:- Smart Speed
//    
//    let decibelThreshold = Float(-35)
//    let defaultPlaybackRate = 1
//    let sampleRate = 0.1
//    var skippedSeconds = 0.0
    
    
    //smart speed button
//    @IBOutlet weak var smartSpeedButton: UIButton!{
//        didSet{
//            smartSpeedButton.addTarget(self, action: #selector(callingTimer), for: .touchUpInside)
//        }
//    }
//
//    //calling findSilences function every 0.1 seconds
//    @objc func callingTimer() {
//        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(findSilences), userInfo: nil, repeats: true)
//    }
//
//    //finding the silences in episode and increase speed to 3
//    //NOTE: it is still not working, the averagePower is always ZERO
//    @objc func findSilences() {
//        guard player.isPlaying == true else { return }
//        player.updateMeters()
//
//        let averagePower = player.averagePower(forChannel: 0)
//
//        //print(player.averagePowerInLinearForm(forChannel: 1))
//        if averagePower < decibelThreshold {
//            self.player.playImmediately(atRate: 3)
//            skippedSeconds += sampleRate - (sampleRate / 3)
//        } else {
//            self.player.playImmediately(atRate: 1)
//        }
//    }
    
    
    func setEpisode(episode:Episode){
        
        episodeName.text = episode.title
        channelName.text = episode.author
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        episodeImg.sd_setImage(with: url)
        self.episode.timeStampLables = ["a","b"]
        
    }
    
   
   
    
}
