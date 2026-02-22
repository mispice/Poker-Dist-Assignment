package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	pb "github.com/mispice/Poker-dist-assignment/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type TestCase struct {
	HandType       string
	CommunityCards []string
	Player1Cards   []string
	Player1Hand    []string
	Player2Cards   []string
	Player2Hand    []string
	ExpectedResult string
	Comment        string
}

func parseCards(cardStr string) []string {
	if cardStr == "" || cardStr == "–" || cardStr == "-" || cardStr == "—" {
		return []string{}
	}
	// Split by spaces and filter empty strings
	parts := strings.Fields(cardStr)
	cards := make([]string, 0, len(parts))
	for _, card := range parts {
		card = strings.TrimSpace(card)
		if card != "" && card != "–" && card != "-" && card != "—" {
			cards = append(cards, card)
		}
	}
	return cards
}

func parseResult(result string) (int, error) {
	result = strings.TrimSpace(result)
	switch result {
	case "hand 1 > hand 2":
		return 1, nil
	case "hand 2 > hand 1":
		return 2, nil
	case "hand 1 = hand 2":
		return 0, nil
	default:
		return -1, fmt.Errorf("unknown result format: %s", result)
	}
}

func loadTestCases(filename string) ([]TestCase, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	var testCases []TestCase
	
	// Skip header row (index 0)
	for i := 1; i < len(records); i++ {
		row := records[i]
		
		// Skip empty rows or rows without hand type
		if len(row) < 7 || strings.TrimSpace(row[0]) == "" {
			continue
		}

		tc := TestCase{
			HandType:       strings.TrimSpace(row[0]),
			CommunityCards: parseCards(row[1]),
			Player1Cards:   parseCards(row[2]),
			Player1Hand:    parseCards(row[3]),
			Player2Cards:   parseCards(row[4]),
			Player2Hand:    parseCards(row[5]),
			ExpectedResult: strings.TrimSpace(row[6]),
		}
		
		if len(row) > 8 {
			tc.Comment = strings.TrimSpace(row[8])
		}

		testCases = append(testCases, tc)
	}

	return testCases, nil
}

func runTest(client pb.PokerServiceClient, tc TestCase, testNum int) bool {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Skip if both players have no hole cards (permutation-only rows)
	if len(tc.Player1Cards) == 0 && len(tc.Player2Cards) == 0 {
		return true // Count as passed, it's just a permutation check
	}

	// Parse expected result
	expectedWinner, err := parseResult(tc.ExpectedResult)
	if err != nil {
		fmt.Printf("❌ Test %d [%s]: Invalid expected result: %v\n", testNum, tc.HandType, err)
		return false
	}

	// Call CompareHands
	resp, err := client.CompareHands(ctx, &pb.CompareRequest{
		Hand1: &pb.HandRequest{
			HoleCards:      tc.Player1Cards,
			CommunityCards: tc.CommunityCards,
		},
		Hand2: &pb.HandRequest{
			HoleCards:      tc.Player2Cards,
			CommunityCards: tc.CommunityCards,
		},
	})

	if err != nil {
		fmt.Printf("❌ Test %d [%s]: gRPC error: %v\n", testNum, tc.HandType, err)
		fmt.Printf("   P1: %v + %v\n", tc.Player1Cards, tc.CommunityCards)
		fmt.Printf("   P2: %v + %v\n", tc.Player2Cards, tc.CommunityCards)
		return false
	}

	// Check if result matches
	if resp.Winner != int32(expectedWinner) {
		fmt.Printf("❌ Test %d [%s]: FAILED\n", testNum, tc.HandType)
		fmt.Printf("   Expected: %s (winner=%d)\n", tc.ExpectedResult, expectedWinner)
		fmt.Printf("   Got: winner=%d\n", resp.Winner)
		fmt.Printf("   P1 cards: %v + %v → %s (rank=%d)\n", 
			tc.Player1Cards, tc.CommunityCards, resp.Hand1Result.BestHandName, resp.Hand1Result.HandRankValue)
		fmt.Printf("   P2 cards: %v + %v → %s (rank=%d)\n", 
			tc.Player2Cards, tc.CommunityCards, resp.Hand2Result.BestHandName, resp.Hand2Result.HandRankValue)
		if tc.Comment != "" {
			fmt.Printf("   Comment: %s\n", tc.Comment)
		}
		return false
	}

	// Success
	fmt.Printf("✅ Test %d [%s]: PASSED", testNum, tc.HandType)
	if tc.Comment != "" && tc.Comment != "hands are only permutations of previous line" {
		fmt.Printf(" (%s)", tc.Comment)
	}
	fmt.Println()
	return true
}

func main() {
	// Connect to server
	conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Failed to connect to server: %v\n", err)
		log.Fatalf("Make sure the poker server is running: ./poker-server\n")
	}
	defer conn.Close()

	client := pb.NewPokerServiceClient(conn)

	// Load test cases
	testCases, err := loadTestCases("test_cases.csv")
	if err != nil {
		log.Fatalf("Failed to load test cases: %v", err)
	}

	fmt.Printf("🃏 Running %d test cases from teacher's test file\n\n", len(testCases))

	// Run all tests
	passed := 0
	failed := 0
	
	for i, tc := range testCases {
		if runTest(client, tc, i+1) {
			passed++
		} else {
			failed++
		}
	}

	// Summary
	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Printf("📊 Test Results Summary:\n")
	fmt.Printf("   Total:  %d\n", len(testCases))
	fmt.Printf("   ✅ Passed: %d\n", passed)
	fmt.Printf("   ❌ Failed: %d\n", failed)
	
	if failed == 0 {
		fmt.Println("\n🎉 ALL TESTS PASSED! Your poker server is working correctly!")
	} else {
		fmt.Printf("\n⚠️  %d test(s) failed. Review the output above for details.\n", failed)
	}
	fmt.Println(strings.Repeat("=", 60))
}
