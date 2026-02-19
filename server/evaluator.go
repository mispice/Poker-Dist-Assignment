package main

import (
	"fmt"
	"math/rand"
	"sort"
	"strings"
	"time"
)

// Card represents a playing card
type Card struct {
	Rank int    // 2-14 (2-10, J=11, Q=12, K=13, A=14)
	Suit string // H, D, C, S
}

// HandRank represents different poker hand rankings
type HandRank int

const (
	HighCard HandRank = iota
	OnePair
	TwoPair
	ThreeOfAKind
	Straight
	Flush
	FullHouse
	FourOfAKind
	StraightFlush
)

var handNames = map[HandRank]string{
	HighCard:      "High Card",
	OnePair:       "One Pair",
	TwoPair:       "Two Pair",
	ThreeOfAKind:  "Three of a Kind",
	Straight:      "Straight",
	Flush:         "Flush",
	FullHouse:     "Full House",
	FourOfAKind:   "Four of a Kind",
	StraightFlush: "Straight Flush",
}

// ParseCard converts string like "HA", "D10", "SK" to Card
func ParseCard(s string) (Card, error) {
	s = strings.TrimSpace(strings.ToUpper(s))
	if len(s) < 2 {
		return Card{}, fmt.Errorf("invalid card: %s", s)
	}

	suit := string(s[0])
	rankStr := s[1:]

	if suit != "H" && suit != "D" && suit != "C" && suit != "S" {
		return Card{}, fmt.Errorf("invalid suit: %s", suit)
	}

	var rank int
	switch rankStr {
	case "2":
		rank = 2
	case "3":
		rank = 3
	case "4":
		rank = 4
	case "5":
		rank = 5
	case "6":
		rank = 6
	case "7":
		rank = 7
	case "8":
		rank = 8
	case "9":
		rank = 9
	case "10", "T":
		rank = 10
	case "J":
		rank = 11
	case "Q":
		rank = 12
	case "K":
		rank = 13
	case "A":
		rank = 14
	default:
		return Card{}, fmt.Errorf("invalid rank: %s", rankStr)
	}

	return Card{Rank: rank, Suit: suit}, nil
}

// CardToString converts a Card back to string format
func CardToString(c Card) string {
	rankStr := ""
	switch c.Rank {
	case 10:
		rankStr = "10"
	case 11:
		rankStr = "J"
	case 12:
		rankStr = "Q"
	case 13:
		rankStr = "K"
	case 14:
		rankStr = "A"
	default:
		rankStr = fmt.Sprintf("%d", c.Rank)
	}
	return c.Suit + rankStr
}

// EvaluatedHand holds the result of hand evaluation
type EvaluatedHand struct {
	Rank      HandRank
	Cards     []Card
	RankValue int32
}

// EvaluateBestHand finds the best 5-card poker hand from 7 cards
func EvaluateBestHand(cards []Card) EvaluatedHand {
	if len(cards) < 5 {
		return EvaluatedHand{Rank: HighCard, Cards: cards, RankValue: 0}
	}

	best := EvaluatedHand{Rank: HighCard, RankValue: 0}

	// Generate all 5-card combinations from 7 cards
	combinations := generateCombinations(cards, 5)

	for _, combo := range combinations {
		evaluated := evaluateFiveCards(combo)
		if evaluated.RankValue > best.RankValue {
			best = evaluated
		}
	}

	return best
}

// generateCombinations generates all k-combinations from the given cards
func generateCombinations(cards []Card, k int) [][]Card {
	var result [][]Card
	n := len(cards)

	var helper func(start int, combo []Card)
	helper = func(start int, combo []Card) {
		if len(combo) == k {
			tmp := make([]Card, k)
			copy(tmp, combo)
			result = append(result, tmp)
			return
		}

		for i := start; i < n; i++ {
			helper(i+1, append(combo, cards[i]))
		}
	}

	helper(0, []Card{})
	return result
}

// evaluateFiveCards evaluates exactly 5 cards
func evaluateFiveCards(cards []Card) EvaluatedHand {
	sorted := make([]Card, len(cards))
	copy(sorted, cards)
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].Rank > sorted[j].Rank
	})

	isFlush := checkFlush(sorted)
	isStraight, straightHigh := checkStraight(sorted)

	if isFlush && isStraight {
		return EvaluatedHand{
			Rank:      StraightFlush,
			Cards:     sorted,
			RankValue: int32(StraightFlush)*10000000 + int32(straightHigh)*100000,
		}
	}

	rankCounts := make(map[int]int)
	for _, card := range sorted {
		rankCounts[card.Rank]++
	}

	counts := make([]int, 0, len(rankCounts))
	for _, count := range rankCounts {
		counts = append(counts, count)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(counts)))

	// Get all kickers sorted by rank
	getKickers := func(excludeRanks []int) []int {
		kickers := []int{}
		for _, card := range sorted {
			isExcluded := false
			for _, excludeRank := range excludeRanks {
				if card.Rank == excludeRank {
					isExcluded = true
					break
				}
			}
			if !isExcluded {
				kickers = append(kickers, card.Rank)
			}
		}
		return kickers
	}

	// Four of a kind
	if counts[0] == 4 {
		fourRank := 0
		for rank, count := range rankCounts {
			if count == 4 {
				fourRank = rank
				break
			}
		}
		kickers := getKickers([]int{fourRank})
		kickerValue := int32(0)
		if len(kickers) > 0 {
			kickerValue = int32(kickers[0])
		}
		return EvaluatedHand{
			Rank:      FourOfAKind,
			Cards:     sorted,
			RankValue: int32(FourOfAKind)*10000000 + int32(fourRank)*100000 + kickerValue*1000,
		}
	}

	// Full house
	if counts[0] == 3 && counts[1] == 2 {
		threeRank := 0
		pairRank := 0
		for rank, count := range rankCounts {
			if count == 3 {
				threeRank = rank
			} else if count == 2 {
				pairRank = rank
			}
		}
		return EvaluatedHand{
			Rank:      FullHouse,
			Cards:     sorted,
			RankValue: int32(FullHouse)*10000000 + int32(threeRank)*100000 + int32(pairRank)*1000,
		}
	}

	// Flush
	if isFlush {
		// Include all 5 cards in ranking for flush comparison
		rankValue := int32(Flush) * 10000000
		for i := 0; i < 5 && i < len(sorted); i++ {
			rankValue += int32(sorted[i].Rank) * int32(1000000/(i+1)/(i+1))
		}
		return EvaluatedHand{
			Rank:      Flush,
			Cards:     sorted,
			RankValue: rankValue,
		}
	}

	// Straight
	if isStraight {
		return EvaluatedHand{
			Rank:      Straight,
			Cards:     sorted,
			RankValue: int32(Straight)*10000000 + int32(straightHigh)*100000,
		}
	}

	// Three of a kind
	if counts[0] == 3 {
		threeRank := 0
		for rank, count := range rankCounts {
			if count == 3 {
				threeRank = rank
				break
			}
		}
		kickers := getKickers([]int{threeRank})
		kickerValue := int32(0)
		if len(kickers) >= 2 {
			kickerValue = int32(kickers[0])*100 + int32(kickers[1])
		} else if len(kickers) == 1 {
			kickerValue = int32(kickers[0]) * 100
		}
		return EvaluatedHand{
			Rank:      ThreeOfAKind,
			Cards:     sorted,
			RankValue: int32(ThreeOfAKind)*10000000 + int32(threeRank)*100000 + kickerValue*100,
		}
	}

	// Two pair
	if counts[0] == 2 && counts[1] == 2 {
		pairs := []int{}
		for rank, count := range rankCounts {
			if count == 2 {
				pairs = append(pairs, rank)
			}
		}
		sort.Sort(sort.Reverse(sort.IntSlice(pairs)))
		kickers := getKickers(pairs)
		kickerValue := int32(0)
		if len(kickers) > 0 {
			kickerValue = int32(kickers[0])
		}
		return EvaluatedHand{
			Rank:      TwoPair,
			Cards:     sorted,
			RankValue: int32(TwoPair)*10000000 + int32(pairs[0])*100000 + int32(pairs[1])*1000 + kickerValue,
		}
	}

	// One pair
	if counts[0] == 2 {
		pairRank := 0
		for rank, count := range rankCounts {
			if count == 2 {
				pairRank = rank
				break
			}
		}
		kickers := getKickers([]int{pairRank})
		kickerValue := int32(0)
		if len(kickers) >= 3 {
			kickerValue = int32(kickers[0])*10000 + int32(kickers[1])*100 + int32(kickers[2])
		} else if len(kickers) == 2 {
			kickerValue = int32(kickers[0])*10000 + int32(kickers[1])*100
		} else if len(kickers) == 1 {
			kickerValue = int32(kickers[0]) * 10000
		}
		return EvaluatedHand{
			Rank:      OnePair,
			Cards:     sorted,
			RankValue: int32(OnePair)*10000000 + int32(pairRank)*100000 + kickerValue,
		}
	}

	// High card - all 5 cards matter for comparison
	rankValue := int32(HighCard) * 10000000
	for i := 0; i < 5 && i < len(sorted); i++ {
		multiplier := int32(100000)
		for j := 0; j < i; j++ {
			multiplier /= 15 // Reduce each subsequent card's impact
		}
		rankValue += int32(sorted[i].Rank) * multiplier
	}
	return EvaluatedHand{
		Rank:      HighCard,
		Cards:     sorted,
		RankValue: rankValue,
	}
}

// checkFlush checks if all cards have the same suit
func checkFlush(cards []Card) bool {
	suit := cards[0].Suit
	for _, card := range cards {
		if card.Suit != suit {
			return false
		}
	}
	return true
}

// checkStraight checks if cards form a straight
func checkStraight(cards []Card) (bool, int) {
	ranks := make([]int, len(cards))
	for i, card := range cards {
		ranks[i] = card.Rank
	}
	sort.Sort(sort.Reverse(sort.IntSlice(ranks)))

	// Check for regular straight
	for i := 0; i < len(ranks)-1; i++ {
		if ranks[i]-ranks[i+1] != 1 {
			// Check for A-2-3-4-5 straight (wheel)
			if ranks[0] == 14 && ranks[1] == 5 && ranks[2] == 4 && ranks[3] == 3 && ranks[4] == 2 {
				return true, 5 // In wheel, the high card is 5
			}
			return false, 0
		}
	}
	return true, ranks[0]
}

// MonteCarloSimulation runs Monte Carlo simulation for win probability
func MonteCarloSimulation(holeCards []Card, communityCards []Card, numSimulations int) (win, tie, lose float64) {
	rand.Seed(time.Now().UnixNano())

	wins := 0
	ties := 0
	losses := 0

	// Create a deck and remove known cards
	usedCards := make(map[string]bool)
	for _, card := range holeCards {
		usedCards[CardToString(card)] = true
	}
	for _, card := range communityCards {
		usedCards[CardToString(card)] = true
	}

	// Determine how many community cards to deal
	cardsNeeded := 5 - len(communityCards)

	for i := 0; i < numSimulations; i++ {
		// Deal remaining community cards
		simulatedCommunity := make([]Card, len(communityCards))
		copy(simulatedCommunity, communityCards)

		for j := 0; j < cardsNeeded; j++ {
			card := dealRandomCard(usedCards)
			simulatedCommunity = append(simulatedCommunity, card)
			usedCards[CardToString(card)] = true
		}

		// Deal opponent's hole cards
		opponentHole := []Card{
			dealRandomCard(usedCards),
			dealRandomCard(usedCards),
		}
		usedCards[CardToString(opponentHole[0])] = true
		usedCards[CardToString(opponentHole[1])] = true

		// Evaluate both hands
		playerCards := append(holeCards, simulatedCommunity...)
		opponentCards := append(opponentHole, simulatedCommunity...)

		playerHand := EvaluateBestHand(playerCards)
		opponentHand := EvaluateBestHand(opponentCards)

		if playerHand.RankValue > opponentHand.RankValue {
			wins++
		} else if playerHand.RankValue == opponentHand.RankValue {
			ties++
		} else {
			losses++
		}

		// Remove simulated cards for next iteration
		for _, card := range simulatedCommunity[len(communityCards):] {
			delete(usedCards, CardToString(card))
		}
		delete(usedCards, CardToString(opponentHole[0]))
		delete(usedCards, CardToString(opponentHole[1]))
	}

	total := float64(numSimulations)
	return float64(wins) / total, float64(ties) / total, float64(losses) / total
}

// dealRandomCard deals a random card that hasn't been used
func dealRandomCard(usedCards map[string]bool) Card {
	suits := []string{"H", "D", "C", "S"}
	ranks := []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	for {
		suit := suits[rand.Intn(len(suits))]
		rank := ranks[rand.Intn(len(ranks))]
		card := Card{Rank: rank, Suit: suit}
		cardStr := CardToString(card)

		if !usedCards[cardStr] {
			return card
		}
	}
}

// GetHandName returns the name of a hand rank
func GetHandName(rank HandRank) string {
	return handNames[rank]
}
