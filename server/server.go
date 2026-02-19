package main

import (
	"context"
	"fmt"

	pb "github.com/mispice/Poker-dist-assignment/proto"
)

// PokerServer implements the PokerService gRPC service
type PokerServer struct {
	pb.UnimplementedPokerServiceServer
}

// NewPokerServer creates a new PokerServer instance
func NewPokerServer() *PokerServer {
	return &PokerServer{}
}

// EvaluateHand evaluates the best poker hand from hole cards and community cards
func (s *PokerServer) EvaluateHand(ctx context.Context, req *pb.HandRequest) (*pb.HandResponse, error) {
	// Parse hole cards
	holeCards := make([]Card, 0, len(req.HoleCards))
	for _, cardStr := range req.HoleCards {
		card, err := ParseCard(cardStr)
		if err != nil {
			return nil, fmt.Errorf("invalid hole card %s: %v", cardStr, err)
		}
		holeCards = append(holeCards, card)
	}

	// Parse community cards
	communityCards := make([]Card, 0, len(req.CommunityCards))
	for _, cardStr := range req.CommunityCards {
		card, err := ParseCard(cardStr)
		if err != nil {
			return nil, fmt.Errorf("invalid community card %s: %v", cardStr, err)
		}
		communityCards = append(communityCards, card)
	}

	// Combine all cards
	allCards := append(holeCards, communityCards...)

	if len(allCards) < 5 {
		return nil, fmt.Errorf("need at least 5 cards, got %d", len(allCards))
	}

	// Evaluate the best hand
	bestHand := EvaluateBestHand(allCards)

	// Convert best cards to strings
	bestCardStrings := make([]string, len(bestHand.Cards))
	for i, card := range bestHand.Cards {
		bestCardStrings[i] = CardToString(card)
	}

	return &pb.HandResponse{
		BestHandName:  GetHandName(bestHand.Rank),
		HandRankValue: bestHand.RankValue,
		BestCards:     bestCardStrings,
	}, nil
}

// CompareHands compares two poker hands and determines the winner
func (s *PokerServer) CompareHands(ctx context.Context, req *pb.CompareRequest) (*pb.CompareResponse, error) {
	// Evaluate hand 1
	hand1Result, err := s.EvaluateHand(ctx, req.Hand1)
	if err != nil {
		return nil, fmt.Errorf("error evaluating hand 1: %v", err)
	}

	// Evaluate hand 2
	hand2Result, err := s.EvaluateHand(ctx, req.Hand2)
	if err != nil {
		return nil, fmt.Errorf("error evaluating hand 2: %v", err)
	}

	// Determine winner
	var winner int32
	if hand1Result.HandRankValue > hand2Result.HandRankValue {
		winner = 1
	} else if hand2Result.HandRankValue > hand1Result.HandRankValue {
		winner = 2
	} else {
		winner = 0 // Tie
	}

	return &pb.CompareResponse{
		Winner:       winner,
		Hand1Result:  hand1Result,
		Hand2Result:  hand2Result,
	}, nil
}

// CalculateProbability runs Monte Carlo simulation to calculate win probability
func (s *PokerServer) CalculateProbability(ctx context.Context, req *pb.SimRequest) (*pb.SimResponse, error) {
	// Parse hole cards
	holeCards := make([]Card, 0, len(req.HoleCards))
	for _, cardStr := range req.HoleCards {
		card, err := ParseCard(cardStr)
		if err != nil {
			return nil, fmt.Errorf("invalid hole card %s: %v", cardStr, err)
		}
		holeCards = append(holeCards, card)
	}

	// Parse community cards
	communityCards := make([]Card, 0, len(req.CommunityCards))
	for _, cardStr := range req.CommunityCards {
		card, err := ParseCard(cardStr)
		if err != nil {
			return nil, fmt.Errorf("invalid community card %s: %v", cardStr, err)
		}
		communityCards = append(communityCards, card)
	}

	// Validate inputs
	if len(holeCards) != 2 {
		return nil, fmt.Errorf("need exactly 2 hole cards, got %d", len(holeCards))
	}
	if len(communityCards) > 5 {
		return nil, fmt.Errorf("cannot have more than 5 community cards, got %d", len(communityCards))
	}

	numSimulations := int(req.NumSimulations)
	if numSimulations <= 0 {
		numSimulations = 10000 // Default
	}

	// Run Monte Carlo simulation
	winProb, tieProb, loseProb := MonteCarloSimulation(holeCards, communityCards, numSimulations)

	return &pb.SimResponse{
		WinProbability:  winProb,
		TieProbability:  tieProb,
		LoseProbability: loseProb,
		SimulationsRun:  int32(numSimulations),
	}, nil
}
