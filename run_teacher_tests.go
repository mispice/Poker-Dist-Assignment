package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	pb "github.com/mispice/Poker-dist-assignment/proto"
)

func parseCards(cardStr string) []string {
	if cardStr == "" || cardStr == "–" {
		return []string{}
	}
	cards := strings.Fields(cardStr)
	return cards
}

func main() {
	// Connect to server
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewPokerServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	// Read CSV file
	file, err := os.Open("test_cases.csv")
	if err != nil {
		log.Fatalf("Failed to open CSV: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatalf("Failed to read CSV: %v", err)
	}

	fmt.Println("================================================================================")
	fmt.Println("POKER SERVER - CSV TEST SUITE (test_cases.csv)")
	fmt.Println("================================================================================")
	fmt.Println()

	passed := 0
	failed := 0
	skipped := 0
	currentCategory := ""

	for i, record := range records {
		if i == 0 {
			continue // Skip header
		}

		category := strings.TrimSpace(record[0])
		if category != "" {
			currentCategory = category
			fmt.Printf("\n📋 Testing: %s\n", strings.ToUpper(currentCategory))
			fmt.Println(strings.Repeat("-", 80))
		}

		// Parse all columns
		community := parseCards(record[1])
		p1Cards := parseCards(record[2])
		hand1Expected := parseCards(record[3])
		p2Cards := parseCards(record[4])
		hand2Expected := parseCards(record[5])
		expectedResult := strings.TrimSpace(record[6])
		comment := strings.TrimSpace(record[8])

		// Skip rows without expected result or without any hand data
		if expectedResult == "" {
			continue
		}
		if len(p1Cards) == 0 && len(hand1Expected) == 0 {
			continue
		}
		if len(p2Cards) == 0 && len(hand2Expected) == 0 {
			continue
		}

		// For permutation tests, use the expected hand directly
		var p1Hole, p1Comm, p2Hole, p2Comm []string
		
		if len(p1Cards) > 0 {
			// Normal test: player has hole cards
			p1Hole = p1Cards
			p1Comm = community
		} else if len(hand1Expected) > 0 {
			// Permutation test: use expected hand as all cards
			if len(hand1Expected) >= 2 {
				p1Hole = hand1Expected[:2]
				p1Comm = hand1Expected[2:]
			} else {
				skipped++
				fmt.Printf("⊘ Skipped %d: %s (hand1 too short)\n", i, comment)
				continue
			}
		} else {
			skipped++
			fmt.Printf("⊘ Skipped %d: %s (no p1 data)\n", i, comment)
			continue
		}

		if len(p2Cards) > 0 {
			// Normal test: player has hole cards
			p2Hole = p2Cards
			p2Comm = community
		} else if len(hand2Expected) > 0 {
			// Permutation test: use expected hand as all cards
			if len(hand2Expected) >= 2 {
				p2Hole = hand2Expected[:2]
				p2Comm = hand2Expected[2:]
			} else {
				skipped++
				fmt.Printf("⊘ Skipped %d: %s (hand2 too short)\n", i, comment)
				continue
			}
		} else {
			skipped++
			fmt.Printf("⊘ Skipped %d: %s (no p2 data)\n", i, comment)
			continue
		}

		// Compare hands
		compareReq := &pb.CompareRequest{
			Hand1: &pb.HandRequest{
				HoleCards:      p1Hole,
				CommunityCards: p1Comm,
			},
			Hand2: &pb.HandRequest{
				HoleCards:      p2Hole,
				CommunityCards: p2Comm,
			},
		}

		resp, err := client.CompareHands(ctx, compareReq)
		if err != nil {
			fmt.Printf("❌ Test %d FAILED: %v\n", i, err)
			fmt.Printf("   Community: %v\n", p1Comm)
			fmt.Printf("   Player 1: %v + %v\n", p1Hole, p1Comm)
			fmt.Printf("   Player 2: %v + %v\n", p2Hole, p2Comm)
			failed++
			continue
		}

		// Determine actual result
		var actualResult string
		if resp.Winner == 1 {
			actualResult = "hand 1 > hand 2"
		} else if resp.Winner == 2 {
			actualResult = "hand 2 > hand 1"
		} else {
			actualResult = "hand 1 = hand 2"
		}

		// Check if result matches
		if actualResult == expectedResult {
			fmt.Printf("✅ Test %d: %s\n", i, comment)
			fmt.Printf("   Player 1: %v → %s (Rank: %d)\n", p1Hole, resp.Hand1Result.BestHandName, resp.Hand1Result.HandRankValue)
			fmt.Printf("   Player 2: %v → %s (Rank: %d)\n", p2Hole, resp.Hand2Result.BestHandName, resp.Hand2Result.HandRankValue)
			fmt.Printf("   Result: %s ✓\n", actualResult)
			passed++
		} else {
			fmt.Printf("❌ Test %d FAILED: %s\n", i, comment)
			fmt.Printf("   Player 1: %v → %s (Rank: %d)\n", p1Hole, resp.Hand1Result.BestHandName, resp.Hand1Result.HandRankValue)
			fmt.Printf("   Player 2: %v → %s (Rank: %d)\n", p2Hole, resp.Hand2Result.BestHandName, resp.Hand2Result.HandRankValue)
			fmt.Printf("   Expected: %s\n", expectedResult)
			fmt.Printf("   Got:      %s ✗\n", actualResult)
			failed++
		}
		fmt.Println()
	}

	fmt.Println("================================================================================")
	fmt.Println("TEST SUMMARY")
	fmt.Println("================================================================================")
	fmt.Printf("Total Tests:  %d\n", passed+failed)
	fmt.Printf("✅ Passed:    %d\n", passed)
	fmt.Printf("❌ Failed:    %d\n", failed)
	fmt.Printf("⊘  Skipped:   %d (empty rows)\n", skipped)
	fmt.Println("================================================================================")

	if failed == 0 {
		fmt.Println("🎉 ALL CSV TESTS PASSED!")
	} else {
		fmt.Printf("⚠️  %d TEST(S) FAILED\n", failed)
		os.Exit(1)
	}
}
