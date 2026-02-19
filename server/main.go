package main

import (
	"fmt"
	"log"
	"net"

	pb "github.com/mispice/Poker-dist-assignment/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

const (
	port = ":50051"
)

func main() {
	// Create a TCP listener
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// Create a new gRPC server
	grpcServer := grpc.NewServer()

	// Register the poker service
	pokerServer := NewPokerServer()
	pb.RegisterPokerServiceServer(grpcServer, pokerServer)

	// Register reflection service for debugging with grpcurl
	reflection.Register(grpcServer)

	fmt.Printf("🃏 Poker gRPC server listening on %s\n", port)
	fmt.Println("Ready to evaluate poker hands!")

	// Start serving
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
