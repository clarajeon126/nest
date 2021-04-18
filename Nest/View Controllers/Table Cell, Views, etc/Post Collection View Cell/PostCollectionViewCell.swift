//
//  PostCollectionViewCell.swift
//  Nest
//
//  Created by Clara Jeon on 3/6/21.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var overallImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var hashtagLabel: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var post: Post?
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        print("delete button on \(userNameLabel.text)'s post was pressed")
        DatabaseManager.shared.deletePost(post: post!) { (success) in
            if success {
                NotificationCenter.default.post(name: .reloadProfileView, object: nil)
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicImageView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 15
        deleteButton.layer.cornerRadius = 15
    }
    
    
    //set values in the post cell
    func set(post: Post, isUsers: Bool){
        self.post = post
        
        if !post.isAnonymous {

            //receiving profile data
            DatabaseManager.shared.getUserProfileFromUid(uid: post.author) { (userProfile) in
                
                //setting image
                ImageService.getImage(withURL: userProfile.profilePicUrl) { (profileImage, url) in
                    self.profilePicImageView.image = profileImage
                }
                
                self.userNameLabel.text = userProfile.firstName + " " + userProfile.lastName
            }
            
        }
        else {
            self.profilePicImageView.image = #imageLiteral(resourceName: "blankprofilepic")
            self.userNameLabel.text = "User"
        }
        
        
        //setting main image
        ImageService.getImage(withURL: post.postImage) { (postImage, url) in
            guard let _post = self.post else {
                return
            }
            
            if _post.postImage.absoluteString == url.absoluteString {
                self.overallImageView.image = postImage
            } else {
                print("wrong post image for some reason error")
            }
        }
        
        //showing the delete button if it is the user's post
        if isUsers {
            deleteButton.isHidden = false
        }
        
        
        //setting text
        hashtagLabel.setTitle("#\(post.hashtag)", for: .normal)
        contentLabel.text = post.postCaption
        
        //setting time
        timeLabel.text = post.createdAt.calenderTimeSinceNow()
        
    }

}
