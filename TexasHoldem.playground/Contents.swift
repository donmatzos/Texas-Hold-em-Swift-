import UIKit


enum Rank: Int, CaseIterable, CustomStringConvertible {
    case Two = 2, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace
    
    var description: String {
        switch self {
        case .Ace:
            return "Ace"
        case .King:
            return "King"
        case .Queen:
            return "Queen"
        case .Jack:
            return "Jack"
        default:
            return "\(self.rawValue)"
        }
    }
}

enum Suit: String, CaseIterable, CustomStringConvertible {
    case spade = "♠️"
    case heart = "♥️"
    case club = "♣️"
    case diamond = "♦️"
    
    var description: String {
        switch self {
        case .spade:
            return "♠️"
        case .heart:
            return "♥️"
        case .club:
            return "♣️"
        case .diamond:
            return "♦️"
        }
    }
}

public struct Card: CustomStringConvertible, Hashable {
    let rank: Rank
    let suit: Suit

    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    public var description: String {
        return "\(rank) of \(suit.rawValue)"
    }
}

var deck: [Card] = Array<Card>()
for suit in Suit.allCases {
    for rank in Rank.allCases {
        let newCard = Card(rank: rank, suit: suit)
        deck.append(newCard)
    }
}

public struct Player: CustomStringConvertible {
    let playerIndex: Int
    let result: String
    let hand: [Card]
    let score: Int
    
    init(playerIndex: Int, result: String, hand: [Card], score: Int) {
        self.playerIndex = playerIndex
        self.result = result
        self.hand = hand
        self.score = score
    }
    
    public var description: String {
        return "Player \(playerIndex+1) with \(result) and hand \(hand)"
    }
}

//print(deck)

/*
 extension to Array<Card>
 In this extension functions to determine the winner are implemented
 */
extension Array where Element == Card {
    /*
     Due to the fact that there has to be an ace for the royal flush,
     the problem with the straight flush is cancelled out
     */
    func isRoyalFlush() -> Bool {
        let (strghtBool, strghtVal) = self.isStraight()
        let (flushBool, flushVal) = self.isFlush()
        if strghtBool && flushBool && strghtVal == flushVal && strghtVal == 14 {
            return true
        }
        return false
    }

    /*
     Problem with straight flush:
     if whloe hand is flush (eg. heart 2 to 6 and ace, the flush return value is off (is 14 for high card))
     while the probability to fail is low due to the circumstances, its not zero
     */
    func isStraightFlush() -> (Bool, Int?) {
        let (strghtBool, strghtVal) = self.isStraight()
        let (flushBool, flushVal) = self.isFlush()
        if strghtBool && flushBool && strghtVal == flushVal {
            return (true, strghtVal)
        }
        return (false, 0)
    }

    func isPoker() -> (Bool, Rank?) {
        var cardRankDict: [Rank: Int] = [Rank.Two : 0, Rank.Three : 0, Rank.Four : 0, Rank.Five : 0, Rank.Six : 0, Rank.Seven : 0, Rank.Eight : 0, Rank.Nine : 0, Rank.Ten : 0, Rank.Jack : 0, Rank.Queen : 0, Rank.King : 0, Rank.Ace : 0]
        for card in self {
            cardRankDict.updateValue(cardRankDict[card.rank]! + 1, forKey: card.rank)
        }
        for (key, val) in cardRankDict {
            if val == 4 {
                return (true, key)
            }
        }
        return (false, nil)
    }

    func isFullHouse() -> (Bool, Rank?, Rank?) {
        var cardRankDict: [Rank: Int] = [Rank.Two : 0, Rank.Three : 0, Rank.Four : 0, Rank.Five : 0, Rank.Six : 0, Rank.Seven : 0, Rank.Eight : 0, Rank.Nine : 0, Rank.Ten : 0, Rank.Jack : 0, Rank.Queen : 0, Rank.King : 0, Rank.Ace : 0]
        for card in self {
            cardRankDict.updateValue(cardRankDict[card.rank]! + 1, forKey: card.rank)
        }
        var tripBool = false
        var tripRank: Rank?
        var pairBool = false
        var pairRank: Rank?
        for (key, value) in cardRankDict {
            if value == 3 {
                tripBool = true
                tripRank = key
            }
            if value == 2 {
                pairBool = true
                pairRank = key
            }
        }
        if tripBool && pairBool {
            return (true, tripRank, pairRank)
        }
        return (false, nil, nil)
    }

    func isFlush() -> (Bool, Int?) {
        var suitDict: [Suit: Int] = [Suit.spade : 0, Suit.heart : 0, Suit.club : 0, Suit.diamond : 0]
        for card in self {
            suitDict.updateValue(suitDict[card.suit]! + 1 , forKey: card.suit)
        }
        //high card in case 2 people have a flush
        var highCard = 0
        for (key, value) in suitDict {
            if value > 4 {
                for card in self {
                    if card.suit == key {
                        highCard = card.rank.rawValue
                    }
                }
                return (true, highCard)
            }
        }
        return (false, highCard)
    }

    func isStraight() -> (Bool, Int?) {
        var cardRankRawDict: [Int: Int] = [Rank.Two.rawValue : 0, Rank.Three.rawValue : 0, Rank.Four.rawValue : 0, Rank.Five.rawValue : 0, Rank.Six.rawValue : 0, Rank.Seven.rawValue : 0, Rank.Eight.rawValue : 0, Rank.Nine.rawValue : 0, Rank.Ten.rawValue : 0, Rank.Jack.rawValue : 0, Rank.Queen.rawValue : 0, Rank.King.rawValue : 0, Rank.Ace.rawValue : 0]
        for card in self {
            cardRankRawDict.updateValue(cardRankRawDict[card.rank.rawValue]! + 1, forKey: card.rank.rawValue)
        }
        //iterator to iterate over the sorted hand
        var itr = 2
        //counter for consecutive cards
        var counter = 1
        //high card in case 2 people have a straight
        var highCard = 0
        while itr < Rank.Ace.rawValue {
            if cardRankRawDict[itr]! >= 1 && cardRankRawDict[itr+1]! >= 1 {
                counter += 1
                highCard = itr
            } else {
                if counter < 5 {
                    counter = 0
                }
            }
            itr += 1
        }
        if counter > 4 {
            return (true, highCard+1)
        }
        return (false, highCard)
    }
    
    func isTriple() -> (Bool, Rank?) {
        var cardRankDict: [Rank: Int] = [Rank.Two : 0, Rank.Three : 0, Rank.Four : 0, Rank.Five : 0, Rank.Six : 0, Rank.Seven : 0, Rank.Eight : 0, Rank.Nine : 0, Rank.Ten : 0, Rank.Jack : 0, Rank.Queen : 0, Rank.King : 0, Rank.Ace : 0]
        for card in self {
            cardRankDict.updateValue(cardRankDict[card.rank]! + 1, forKey: card.rank)
        }
        for (key, val) in cardRankDict {
            if val == 3 {
                return (true, key)
            }
        }
        return (false, nil)
    }

    func isTwoPair() -> (Bool, Rank?, Rank?) {
        var cardRankDict: [Rank: Int] = [Rank.Two : 0, Rank.Three : 0, Rank.Four : 0, Rank.Five : 0, Rank.Six : 0, Rank.Seven : 0, Rank.Eight : 0, Rank.Nine : 0, Rank.Ten : 0, Rank.Jack : 0, Rank.Queen : 0, Rank.King : 0, Rank.Ace : 0]
        for card in self {
            cardRankDict.updateValue(cardRankDict[card.rank]! + 1, forKey: card.rank)
        }
        var counter = 0
        var firstPair: Rank?
        var secPair: Rank?
        for (key, val) in cardRankDict {
            if val == 2 {
                if counter == 0 {
                    counter += 1
                    firstPair = key
                } else {
                    secPair = key
                    return (true, firstPair, secPair)
                }
            }
        }
        return (false, nil, nil)
    }
    
    func isPair() -> (Bool, Rank?) {
        var cardRankDict: [Rank: Int] = [Rank.Two : 0, Rank.Three : 0, Rank.Four : 0, Rank.Five : 0, Rank.Six : 0, Rank.Seven : 0, Rank.Eight : 0, Rank.Nine : 0, Rank.Ten : 0, Rank.Jack : 0, Rank.Queen : 0, Rank.King : 0, Rank.Ace : 0]
        for card in self {
            cardRankDict.updateValue(cardRankDict[card.rank]! + 1, forKey: card.rank)
        }
        for (key, val) in cardRankDict {
            if val == 2 {
                return (true, key)
            }
        }
        return (false, nil)
    }
    
    func getHighCard() -> Int {
        let sortedHand = self.sorted { (lhs, rhs) -> Bool in
            return lhs.rank.rawValue < rhs.rank.rawValue
        }
        var highCard = 0
        for card in sortedHand {
            if highCard < card.rank.rawValue {
                highCard = card.rank.rawValue
            }
        }
        return highCard
    }
}

/*
 Class Game
 function getPlayerHands(players: n) deals n player hands consisting of 2 cards each
 function getCardPool() deals a card pool consistig of 5 cards
 The dealt cards are selected by choosing a random number between 0 and the lenght of the deck,
 the card is then from the array after it is dealt
 */
class Game {
    public func getPlayerHands(players: Int) -> [[Card]] {
        /*
         variable actualPlayers to simplify input, otherwise input would be from 0 to 7
         also used for wrong input (min 2 to max 8 players)
        */
        var actualPlayers: Int
        if players > 7 {
            actualPlayers = 7
            print("Maximum of 8 players. Player count was set to 8.")
        } else if players < 0 {
            actualPlayers = 1
            print("Minimum of 2 players. Player count was set to 2.")
        } else {
            actualPlayers = players-1
        }
        var playerHands: [[Card]] = Array<Array<Card>>()
        for _ in 0...actualPlayers {
            var randNum = Int.random(in: 0...deck.count-1)
            var hand: [Card] = Array<Card>()
            hand.append(deck[randNum])
            deck.remove(at: randNum)
            randNum = Int.random(in: 0...deck.count-1)
            hand.append(deck[randNum])
            deck.remove(at: randNum)
            playerHands.append(hand)
        }
        return playerHands
    }
    
    public func getCardPool() -> [Card] {
        var cardPool: [Card] = Array<Card>()
        var randNum: Int
        for _ in 0...4 {
            randNum = Int.random(in: 0...deck.count-1)
            cardPool.append(deck[randNum])
            deck.remove(at: randNum)
        }
        return cardPool
    }

    /*
     Royal Flush: Die Folge 10 bis Ass in einer Farbe                   max Score: 15000
     Straight Flush: Fünf aufeinanderfolgende Karten einer Farbe        max Score: 12000 + high card
     Vierling, Poker, Four of a kind: Vier Karten des gleichen Wertes   max Score:  9000 + high card * 4
     Full House: Ein Drilling und ein Paar                              max Score:  5000 + high card (of triple) * 4
     Flush: Fünf beliebige Karten einer Farbe                           max Score:  3000 + high card
     Straße, Straight: Fünf aufeinanderfolgende Karten                  max Score:  1000 + high card
     Drilling, Three of a kind: Drei Karten des gleichen Wertes         max Score:   800 + high card * 3
     Zwei Paare, Two pair: Zwei Paare                                   max Score:   500 + high card
     Ein Paar, One pair: Zwei Karten gleichen Wertes                    max Score:   100 + high card
     High Card: Die höchste einzelne Karte                              max Score: 2..14
     */
    public func getWinner(pool: [Card], hands: [[Card]]) -> Player {
        var playerArray: [Player] = Array<Player>()
        var index = 0
        for hand in hands {
            var curHand: [Card] = Array<Card>()
            curHand.append(contentsOf: pool)
            curHand.append(contentsOf: hand)
            let player = calcResult(playerIndex: index, playerHand: hand, curHand: curHand)
            index += 1
            playerArray.append(player)
        }
        var winnerIndex = 0
        var winnerScore = 0
        for player in playerArray {
            if winnerScore < player.score {
                winnerIndex = player.playerIndex
                winnerScore = player.score
            }
        }
        return playerArray[winnerIndex]
    }
    
    private func calcResult(playerIndex: Int, playerHand: [Card], curHand: [Card]) -> Player {
        if curHand.isRoyalFlush() {
            return Player(playerIndex: playerIndex, result: "a Royal Flush", hand: playerHand, score: 15000)
        }
        let (boolStraightFlush, highCardStraightFlush) = curHand.isStraightFlush()
        if boolStraightFlush {
            return Player(playerIndex: playerIndex, result: "a Straight Flush", hand: playerHand, score: (12000 + highCardStraightFlush!))
        }
        let (boolPoker, highCardPoker) = curHand.isPoker()
        if boolPoker {
            return Player(playerIndex: playerIndex, result: "a Poker", hand: playerHand, score: (9000 + (highCardPoker!.rawValue * 4)))
        }
        let (boolFullHouse, highCardFHTriple, _) = curHand.isFullHouse()
        if boolFullHouse {
            return Player(playerIndex: playerIndex, result: "a Full House", hand: playerHand, score: (5000 + (highCardFHTriple!.rawValue * 3)))
        }
        let (boolFlush, highCardFlush) = curHand.isFlush()
        if boolFlush {
            return Player(playerIndex: playerIndex, result: "a Flush", hand: playerHand, score: (3000 + highCardFlush!))
        }
        let (boolStr, highCardStr) = curHand.isStraight()
        if boolStr {
            return Player(playerIndex: playerIndex, result: "a Straight", hand: playerHand, score: (1000 + highCardStr!))
        }
        let (boolTriple, highCardTriple) = curHand.isTriple()
        if boolTriple {
            return Player(playerIndex: playerIndex, result: "a Triple", hand: playerHand, score: (800 + (highCardTriple!.rawValue * 3)))
        }
        let (boolTwoPair, firstCardTwoPair, secCardTwoPair) = curHand.isTwoPair()
        if boolTwoPair {
            if firstCardTwoPair!.rawValue < secCardTwoPair!.rawValue {
                return Player(playerIndex: playerIndex, result: "two Pairs", hand: playerHand, score: (500 + secCardTwoPair!.rawValue))
            }
            return Player(playerIndex: playerIndex, result: "two Pairs", hand: playerHand, score: (500 + firstCardTwoPair!.rawValue))
        }
        let (boolPair, highCardPair) = curHand.isPair()
        if boolPair {
            return Player(playerIndex: playerIndex, result: "a Pair", hand: playerHand, score: 100 + highCardPair!.rawValue)
        }
        return Player(playerIndex: playerIndex, result: "the highest card", hand: playerHand, score: curHand.getHighCard())
    }
}


let game = Game()
let playerHands = game.getPlayerHands(players: 2)
let cardPool = game.getCardPool()
var playerNumber = 1
for hand in playerHands {
    print("Player \(playerNumber): \(hand)")
    playerNumber += 1
}
print("Pool: \(cardPool)")
let winner = game.getWinner(pool: cardPool, hands: playerHands)
print("The Winner is \(winner)")

//test
let testHand = [Card(rank: Rank(rawValue: 2) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 2) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 4) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 3) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 5) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 6) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit),
                Card(rank: Rank(rawValue: 14) ?? deck[0].rank, suit: Suit(rawValue: "♥️") ?? deck[0].suit)]
print(testHand.isFlush())

