package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	pb "github.com/mispice/Poker-dist-assignment/proto"
)

func main() {
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPokerServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	fmt.Println("================================================================================")
	fmt.Println("POKER SERVER TEST SUITE")
	fmt.Println("================================================================================")
	fmt.Println()

	// Test 1: Evaluate Hand - Royal Flush
	fmt.Println("TEST 1: Evaluate Hand - Royal Flush")
	fmt.Println("Input: Hole Cards [HA, HK], Community [HQ, HJ, H10]")
	evalReq1 := &pb.HandRequest{
		HoleCards:      []string{"HA", "HK"},
		CommunityCards: []string{"HQ", "HJ", "H10"},
	}
	evalResp1, err := client.EvaluateHand(ctx, evalReq1)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		fmt.Printf("✅ Result: %s (Rank: %d)\n", evalResp1.BestHandName, evalResp1.HandRankValue)
		fmt.Printf("   Best Cards: %v\n", evalResp1.BestCards)
	}
	fmt.Println()

	// Test 2: Evaluate Hand - Pair
	fmt.Println("TEST 2: Evaluate Hand - Pair")
	fmt.Println("Input: Hole Cards [HA, HK], Community [C2, D7, S9]")
	evalReq2 := &pb.HandRequest{
		HoleCards:      []string{"HA", "HK"},
		CommunityCards: []string{"C2", "D7", "S9"},
	}
	evalResp2, err := client.EvaluateHand(ctx, evalReq2)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		fmt.Printf("✅ Result: %s (Rank: %d)\n", evalResp2.BestHandName, evalResp2.HandRankValue)
		fmt.Printf("   Best Cards: %v\n", evalResp2.BestCards)
	}
	fmt.Println()

	// Test 3: Evaluate Hand - Full House
	fmt.Println("TEST 3: Evaluate Hand - Full House")
	fmt.Println("Input: Hole Cards [HA, HK], Community [CA, DA, CK]")
	evalReq3 := &pb.HandRequest{
		HoleCards:      []string{"HA", "HK"},
		CommunityCards: []string{"CA", "DA", "CK"},
	}
	evalResp3, err := client.EvaluateHand(ctx, evalReq3)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		fmt.Printf("✅ Result: %s (Rank: %d)\n", evalResp3.BestHandName, evalResp3.HandRankValue)
		fmt.Printf("   Best Cards: %v\n", evalResp3.BestCards)
	}
	fmt.Println()

	// Test 4: Compare Hands
	fmt.Println("TEST 4: Compare Hands")
	fmt.Println("Hand 1: [HA, HK, HQ, HJ, H10] vs Hand 2: [SA, SK, C2, D3, S4]")
	compareReq := &pb.CompareRequest{
		Hand1: &pb.HandRequest{
			HoleCards:      []string{"HA", "HK"},
			CommunityCards: []string{"HQ", "HJ", "H10"},
		},
		Hand2: &pb.HandRequest{
			HoleCards:      []string{"SA", "SK"},
			CommunityCards: []string{"C2", "D3", "S4"},
		},
	}
	compareResp, err := client.CompareHands(ctx, compareReq)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		winner := "TIE"
		if compareResp.Winner == 1 {
			winner = "HAND 1 WINS"
		} else if compareResp.Winner == 2 {
			winner = "HAND 2 WINS"
		}
		fmt.Printf("✅ Result: %s\n", winner)
		fmt.Printf("   Hand 1: %s (Rank: %d)\n", compareResp.Hand1Result.BestHandName, compareResp.Hand1Result.HandRankValue)
		fmt.Printf("   Hand 2: %s (Rank: %d)\n", compareResp.Hand2Result.BestHandName, compareResp.Hand2Result.HandRankValue)
	}
	fmt.Println()

	// Test 5: Calculate Probability
	fmt.Println("TEST 5: Calculate Probability (1000 simulations)")
	fmt.Println("Input: Hole Cards [HA, HK], No Community Cards")
	probReq := &pb.SimRequest{
		HoleCards:      []string{"HA", "HK"},
		CommunityCards: []string{},
		NumSimulations: 1000,
	}
	probResp, err := client.CalculateProbability(ctx, probReq)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		fmt.Printf("✅ Results after %d simulations:\n", probResp.SimulationsRun)
		fmt.Printf("   Win:  %.1f%%\n", probResp.WinProbability)
		fmt.Printf("   Tie:  %.1f%%\n", probResp.TieProbability)
		fmt.Printf("   Lose: %.1f%%\n", probResp.LoseProbability)
	}
	fmt.Println()

	// Test 6: Calculate Probability with Community Cards
	fmt.Println("TEST 6: Calculate Probability with Flop (1000 simulations)")
	fmt.Println("Input: Hole [HA, HK], Community [HQ, HJ, C2]")
	probReq2 := &pb.SimRequest{
		HoleCards:      []string{"HA", "HK"},
		CommunityCards: []string{"HQ", "HJ", "C2"},
		NumSimulations: 1000,
	}
	probResp2, err := client.CalculateProbability(ctx, probReq2)
	if err != nil {
		fmt.Printf("❌ ERROR: %v\n", err)
	} else {
		fmt.Printf("✅ Results after %d simulations:\n", probResp2.SimulationsRun)
		fmt.Printf("   Win:  %.1f%%\n", probResp2.WinProbability)
		fmt.Printf("   Tie:  %.1f%%\n", probResp2.TieProbability)
		fmt.Printf("   Lose: %.1f%%\n", probResp2.LoseProbability)
	}
	fmt.Println()

	fmt.Println("================================================================================")
	fmt.Println("ALL TESTS COMPLETED")
	fmt.Println("================================================================================")
}
