//
//  DatabaseResultViewController.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 13/04/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import UIKit

class DatabaseResultViewController: UICollectionViewController {

    var result: DisplayResult?

    class func getViewController() -> DatabaseResultViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseResultViewController.self))
        return storyboard.instantiateViewController(withIdentifier: "DatabaseResultViewController") as? DatabaseResultViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.setCollectionViewLayout(DuplexCollectionViewLayout(), animated: false)
        navigationController?.navigationBar.backgroundColor = UIColor.white
    }

    func prepareContentLayout() {
        if let viewLayout = collectionView?.collectionViewLayout as? DuplexCollectionViewLayout,
            let result = result,
            result.titles.count + 1 == result.columnWidth.count {
            viewLayout.columnSizes = result.columnWidth.map { CGSize(width: $0, height: DisplayResult.displayHeight) }
            navigationItem.title = "Result (\(result.contents.count))"
        }
        
        DispatchQueue.main.async { [weak self] in self?.collectionView?.reloadData() }
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result?.titles.count ?? -1) + 1 // add title row
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (result?.contents.count ?? -1) + 1
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let row = indexPath.section - 1
        let column = indexPath.row - 1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatabaseResultCollectionViewCell", for: indexPath)
        if let cell = cell as? DatabaseResultCollectionViewCell, let result = result {
            let isNil = indexPath.section > 0 && indexPath.row > 0 && result.contents[row][column] == nil
            cell.label.text = indexPath.section == 0 && indexPath.row == 0 ? nil :
                indexPath.section == 0 ? result.titles[column] :
                indexPath.row == 0 ? "\(indexPath.section)" :
                result.contents[row][column] ?? "NULL"
            cell.label.textAlignment = indexPath.row == 0 ? .right : .left
            cell.label.textColor = indexPath.row == 0 ? UIColor.gray :
                indexPath.section == 0 ? UIColor.darkText :
                isNil ? UIColor.gray : UIColor.darkText
            cell.backgroundColor = indexPath.section % 2 == 1 ? UIColor.groupTableViewBackground : UIColor.white
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section > 0 && indexPath.row > 0 else {
            return
        }
        let columnTitle = result?.titles[indexPath.row - 1]
        let content = result?.contents[indexPath.section - 1][indexPath.row - 1]
        
        guard content != nil else {
            return
        }
        let alert = UIAlertController(title: columnTitle, message: content, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
