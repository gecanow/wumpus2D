//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class ViewController: UIViewController {
    
    var board = [[Cell]]()
    var player = UILabel()
    var on = [Int]()
    var bullet = UILabel()
    
    let cols = 8
    let rows = 12
    
    var display: UIView!
    var message: UILabel!
    var buttons = [UIButton]()
    
    let info = "Welcome to the Wumpus Cave! \nTap on a cell to kill the sleeping (but dangerous) wumpus. But beware: tap on the wrong cell, and risk moving the wumpus to a new location. Use the arrow keys to move in search for the wumpus, and, when the wumpus is in an adjacent cell, you'll be able to smell him. Along the way, watch out for flying bats and deep pits! Good luck!"
    
    //===============================================
    // VIEW DID LOAD
    //===============================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        fillBoard() // first, fill the board
        addArrowKeys() // then add the arrow keys
        createPlayer() // create the player
        createResetButton() // add a reset button
        createTheDisplay() // create the display
        resetGame() // start the game!
    }
    
    //===============================================
    // Resets the game
    //===============================================
    @objc func resetGame() {
        display.isHidden = true
        emptyCells()
        randomizeCharacters()
    }
    
    //===============================================
    // 1 - Moves the player in the direction 
    //     specified by the button
    // 2 - Moves the player to the cell specified
    //===============================================
    @objc func movePlayerButton(sender: UIButton) {
        movePlayer(toPoint: adj(buttons.index(of: sender)!))
    }
    func movePlayer(toPoint: [Int]) {
        board[on[0]][on[1]].alpha = 0.5
        on = toPoint
        
        UIView.animate(withDuration: 0.2, animations: {
            self.player.center = self.board[self.on[0]][self.on[1]].center
        }) { (Void) in
            self.checkMyCell()
        }
        
    }
    
    //===============================================
    // Checks player's cell for bats, pits, or the
    // wumpus
    //===============================================
    func checkMyCell() {
        if board[on[0]][on[1]].hasPit {
            showDisplay("You fell into a pit and died.", true)
        } else if board[on[0]][on[1]].hasWumpus {
            showDisplay("You battled the Wumpus and lost.", true)
        } else if board[on[0]][on[1]].hasBat {
            showDisplay("The bats flew you to a new location.", false)
            movePlayer(toPoint: newPoint())
            checkAdjacentCells()
        } else {
            checkAdjacentCells()
        }
    }
    
    //===============================================
    // Checks the adjacent cells for bats, pits
    // or the wumpus
    //===============================================
    func checkAdjacentCells() {
        for x in 0...3 {
            let adjacent = adj(x)
            if board[adjacent[0]][adjacent[1]].hasBat {
                showDisplay("Bats nearby", false)
            }
            if board[adjacent[0]][adjacent[1]].hasPit {
                showDisplay("I feel a draft", false)
            }
            if board[adjacent[0]][adjacent[1]].hasWumpus {
                showDisplay("I smell a wumpus", false)
            }
        }
    }
    
    //===============================================
    // Returns the adjection cell in the direction
    // of @param direction:
    // 0 = up, 1 = left, 2 = down, 3 = right
    //===============================================
    func adj(_ direction: Int) -> [Int] {
        var r = on[0], c = on[1]
        
        if direction == 0 {
            r -= 1
            if r < 0 { r = rows }
        } else if direction == 1 {
            c -= 1
            if c < 0 { c = cols }
        } else if direction == 2 {
            r += 1
            if r > rows { r = 0 }
        } else {
            c += 1
            if c > cols { c = 0 }
        }
        return [r,c]
    }
    
    //===============================================
    // Returns a new, random cell
    //===============================================
    func newPoint() -> [Int] {
        let randR = Int(arc4random_uniform(UInt32(rows)))
        let randC = Int(arc4random_uniform(UInt32(cols)))
        return [randR, randC]
    }
    
    //===============================================
    // Handles firing arrows into a specific cell
    //===============================================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first = touches.first?.location(in: self.view)
        
        for ro in board {
            for cell in ro {
                if cell.frame.contains(first!) {
                    // an arrow was fired
                    sendArrow(toCell: cell)
                    
                    if cell.hasWumpus {
                        showDisplay("You won! You killed the wumpus!", true)
                    } else {
                        // the wumpus was rattled...
                        showDisplay("You rattled the wumpus, who moved to a new location", false)
                        for row in board {
                            for c in row {
                                c.hasWumpus = false
                            }
                        }
                        
                        let wPt = newPoint()
                        board[wPt[0]][wPt[1]].hasWumpus = true
                    }
                }
            }
        }
    }
    
    //===============================================
    // Handles sending "arrows" to a cell
    //===============================================
    func sendArrow(toCell: Cell) {
        bullet.frame.size = CGSize(width: 30, height: 30)
        bullet.center = board[on[0]][on[1]].center
        bullet.backgroundColor = UIColor.magenta
        bullet.clipsToBounds = true
        bullet.layer.cornerRadius = bullet.frame.width/2
        bullet.isHidden = false
        self.view.bringSubview(toFront: bullet)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.bullet.center = toCell.center
            self.bullet.frame.size = CGSize(width: 10, height: 10)
            self.bullet.layer.cornerRadius = 5
        }) { (Void) in
            self.bullet.isHidden = true
        }
    }
    
    //===============================================
    // Two functions to show the display:
    // - A custom messaged display with the option
    //   of ending the game
    // - A default display
    //===============================================
    func showDisplay(_ m: String, _ isFinal: Bool) {
        message.text = m
        display.isHidden = false
        
        if (isFinal) {
            message.text = m + "\n\nRED = Wumpus\nWHITE = Pit\nBLACK = Bats"
            for b in buttons {
                b.isEnabled = false
                b.alpha = 0.5
            }
            for row in board {
                for c in row {
                    c.showTrueSelf()
                }
            }
        }
    }
    @objc func showDisplaySimple() {
        message.text = info
        display.isHidden = false
    }
    
    //===============================================
    // Hides the display
    //===============================================
    @objc func removeDisplay() {
        display.isHidden = true
    }
    
    
    //===============================================//
    //            GUI / HELPER FUNCTIONS               //
    //===============================================//
    
    
    //===============================================
    // Fills the board with cells
    //===============================================
    func fillBoard() {
        let size = 42
        for row in 0...rows {
            var toAdd = [Cell]()
            
            for col in 0...cols {
                let myCell = Cell(rect: CGRect(x: col*size, y: row*size, width: size, height: size))
                toAdd.append(myCell)
                self.view.addSubview(myCell)
            }
            
            board.append(toAdd)
        }
    }
    
    //===============================================
    // Creates the arrow keys and the bullet
    //===============================================
    func addArrowKeys() {
        let up = UIButton(frame: CGRect(x: 150, y: 587, width: 70, height: 30))
        up.setTitle("UP", for: .normal)
        buttons.append(up)
        
        let left = UIButton(frame: CGRect(x: 78, y: 620, width: 70, height: 30))
        left.setTitle("LEFT", for: .normal)
        buttons.append(left)
        
        let down = UIButton(frame: CGRect(x: 150, y: 620, width: 70, height: 30))
        down.setTitle("DOWN", for: .normal)
        buttons.append(down)
        
        let right = UIButton(frame: CGRect(x: 222, y: 620, width: 70, height: 30))
        right.setTitle("RIGHT", for: .normal)
        buttons.append(right)
        
        for b in buttons {
            b.backgroundColor = UIColor.darkGray
            b.addTarget(self, action: #selector(movePlayerButton), for: .touchUpInside)
            self.view.addSubview(b)
        }
        
        bullet.isHidden = true
        self.view.addSubview(bullet)
    }
    
    //===============================================
    // Handles creating the player
    //===============================================
    func createPlayer() {
        player.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        player.backgroundColor = UIColor.darkGray
        player.clipsToBounds = true
        player.layer.cornerRadius = 15
        self.view.addSubview(player)
        self.view.bringSubview(toFront: player)
    }
    
    //===============================================
    // Handles creating the reset button and
    // information button
    //===============================================
    func createResetButton() {
        let resetAll = UIButton(frame: CGRect(x: 5, y: 550, width: 70, height: 30))
        resetAll.setTitle("RESET", for: .normal)
        resetAll.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        resetAll.backgroundColor = UIColor.darkGray
        self.view.addSubview(resetAll)
        
        let infoButton = UIButton(frame: CGRect(x: 340, y: 550, width: 30, height: 30))
        infoButton.setTitle("?", for: .normal)
        infoButton.addTarget(self, action: #selector(showDisplaySimple), for: .touchUpInside)
        infoButton.backgroundColor = UIColor.darkGray
        self.view.addSubview(infoButton)
    }
    
    //===============================================
    // Handles creating the display
    //===============================================
    func createTheDisplay() {
        display = UIView(frame: CGRect(x: 20, y: 20, width: 340, height: 500))
        display.backgroundColor = UIColor.black
        
        message = UILabel(frame: CGRect(x: 10, y: 10, width: 320, height: 400))
        message.textColor = UIColor.green
        message.numberOfLines = 0
        message.contentMode = .center
        message.textAlignment = .center
        
        let ok = UIButton(frame: CGRect(x: 135, y: 465, width: 60, height: 30))
        ok.setTitle("OK", for: .normal)
        ok.addTarget(self, action: #selector(removeDisplay), for: .touchUpInside)
        ok.backgroundColor = UIColor.gray
        
        display.addSubview(message)
        display.addSubview(ok)
        display.isHidden = true
        self.view.addSubview(display)
    }
    
    //===============================================
    // Empties all the cells and resets all the
    // buttons
    //===============================================
    func emptyCells() {
        for row in 0...rows {
            for col in 0...cols {
                board[row][col].resetAll()
            }
        }
        for b in buttons {
            b.isEnabled = true
            b.alpha = 1.0
        }
    }
    
    //===============================================
    // Randmozies the locations of the game
    // characters
    //===============================================
    func randomizeCharacters() {
        on = newPoint()
        board[on[0]][on[1]].playerStartedHere = true
        player.center = board[on[0]][on[1]].center
        
        for next in 0..<5 {
            // find a random, unused cell!
            var randR = 0, randC = 0
            repeat {
                let rand = newPoint()
                randR = rand[0]
                randC = rand[1]
            } while (board[randR][randC].hasWumpus ||
                board[randR][randC].hasBat ||
                board[randR][randC].hasPit ||
                board[randR][randC].playerStartedHere)
            if next <= 1 {
                board[randR][randC].hasBat = true
            } else if next <= 3 {
                board[randR][randC].hasPit = true
            } else {
                board[randR][randC].hasWumpus = true
            }
            
        }
    }
}

//===============================================//
//-----------------------------------------------//
//         Custom Board Cell class               //
//-----------------------------------------------//
//===============================================//
class Cell: UILabel {
    var hasWumpus = false
    var hasBat = false
    var hasPit = false
    var playerStartedHere = false
    
    convenience init(rect: CGRect) {
        self.init()
        backgroundColor = UIColor.green
        layer.borderWidth = 1.0
        frame = rect
    }
    
    func resetAll() {
        hasWumpus = false
        hasBat = false
        hasPit = false
        playerStartedHere = false
        alpha = 1.0
        backgroundColor = UIColor.green
    }
    
    func showTrueSelf() {
        if hasBat {
            backgroundColor = UIColor.black
        }
        if hasPit {
            backgroundColor = UIColor.white
        }
        if hasWumpus {
            backgroundColor = UIColor.red
        }
    }
}

//---------------------------------------------------
PlaygroundPage.current.liveView = ViewController()
//---------------------------------------------------
