package main

import (
	"context"
	"fmt"
	"log"
	"time"

	pb "github.com/mispice/Poker-dist-assignment/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	// Connect to the server
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPokerServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	fmt.Println("🃏 Testing Poker gRPC Server\n")

	// Test 1: Evaluate a royal flush
	fmt.Println("Test 1: Royal Flush")
	resp1, err := client.EvaluateHand(ctx, &pb.HandRequest{
		HoleCards:       []string{"HA", "HK"},
		CommunityCards:  []string{"HQ", "HJ", "H10", "D2", "C3"},
	})
	if err != nil {
		log.Printf("Error: %v", err)
	} else {
		fmt.Printf("Result: %s (Rank Value: %d)\n", resp1.BestHandName, resp1.HandRankValue)
		fmt.Printf("Best Cards: %v\n\n", resp1.BestCards)
	}

	// Test 2: Evaluate a pair
	fmt.Println("Test 2: One Pair")
	resp2, err := client.EvaluateHand(ctx, &pb.HandRequest{
		HoleCards:       []string{"HA", "HK"},
		CommunityCards:  []string{"DK", "C7", "S2", "H5", "D9"},
	})
	if err != nil {
		log.Printf("Error: %v", err)
	} else {
		fmt.Printf("Result: %s (Rank Value: %d)\n", resp2.BestHandName, resp2.HandRankValue)
		fmt.Printf("Best Cards: %v\n\n", resp2.BestCards)
	}

	// Test 3: Compare two hands
	fmt.Println("Test 3: Compare Hands")
	resp3, err := client.CompareHands(ctx, &pb.CompareRequest{
		Hand1: &pb.HandRequest{
			HoleCards:      []string{"HA", "HK"},
			CommunityCards: []string{"HQ", "HJ", "H10"},
		},
		Hand2: &pb.HandRequest{
			HoleCards:      []string{"DA", "DK"},
			CommunityCards: []string{"HQ", "HJ", "H10"},
		},
	})
	if err != nil {
		log.Printf("Error: %v", err)
	} else {
		winnerStr := "Tie"
		if resp3.Winner == 1 {
			winnerStr = "Hand 1 wins"
		} else if resp3.Winner == 2 {
			winnerStr = "Hand 2 wins"
		}
		fmt.Printf("Winner: %s\n", winnerStr)
		fmt.Printf("Hand 1: %s (Rank Value: %d)\n", resp3.Hand1Result.BestHandName, resp3.Hand1Result.HandRankValue)
		fmt.Printf("Hand 2: %s (Rank Value: %d)\n\n", resp3.Hand2Result.BestHandName, resp3.Hand2Result.HandRankValue)
	}

	// Test 4: Monte Carlo simulation
	fmt.Println("Test 4: Monte Carlo Probability (this may take a moment...)")
	resp4, err := client.CalculateProbability(ctx, &pb.SimRequest{
		HoleCards:       []string{"HA", "HK"},
		CommunityCards:  []string{"HQ", "HJ"},
		NumSimulations:  1000,
	})
	if err != nil {
		log.Printf("Error: %v", err)
	} else {
		fmt.Printf("Simulations: %d\n", resp4.SimulationsRun)
		fmt.Printf("Win:  %.2f%%\n", resp4.WinProbability*100)
		fmt.Printf("Tie:  %.2f%%\n", resp4.TieProbability*100)
		fmt.Printf("Lose: %.2f%%\n\n", resp4.LoseProbability*100)
	}

	fmt.Println("✅ All tests completed!")
}
