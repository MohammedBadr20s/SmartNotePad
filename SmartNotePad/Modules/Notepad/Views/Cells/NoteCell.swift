//
//  NoteCell.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit

class NoteCell: UITableViewCell {

    static let identifier = "NoteCell"
    static func nib() -> UINib {
        return UINib(nibName: "NoteCell", bundle: nil)
    }
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var nearestLbl: UILabel!
    @IBOutlet weak var containslocationImageView: UIImageView!
    @IBOutlet weak var containsImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nearestLbl.adjustsFontSizeToFitWidth = true
        nearestLbl.minimumScaleFactor = 0.75
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func config(title: String, noteDescription: String, isNearest: Bool, constainsLocation: Bool, containsImage: Bool) {
        self.titleLbl.text = title
        self.descriptionLbl.text = noteDescription
        self.nearestLbl.isHidden = !isNearest
        self.containslocationImageView.isHidden = !constainsLocation
        self.containsImageView.isHidden = !containsImage
    }
}
