# Poker Distributed Assignment

A distributed poker hand evaluation system using gRPC for backend (Go) and frontend (Flutter Web).

## Project Structure

```
poker-assignment/
├── proto/               # gRPC protocol definitions
│   ├── poker.proto     # Service and message definitions
│   ├── poker.pb.go     # Generated Go code (protobuf)
│   └── poker_grpc.pb.go # Generated Go code (gRPC)
├── server/             # Go backend
│   ├── main.go         # gRPC server entry point
│   ├── server.go       # gRPC service implementation
│   └── evaluator.go    # Poker hand evaluation logic
└── frontend/           # Flutter web frontend
    ├── lib/
    │   └── main.dart   # UI implementation
    └── pubspec.yaml    # Flutter dependencies
```

## Features

### Backend (Go + gRPC)
1. **EvaluateHand** - Evaluates the best 5-card poker hand from 2 hole cards + up to 5 community cards
2. **CompareHands** - Compares two poker hands and determines the winner
3. **CalculateProbability** - Runs Monte Carlo simulation to calculate win/tie/lose probabilities

### Poker Hand Rankings (Highest to Lowest)
- Straight Flush
- Four of a Kind
- Full House
- Flush
- Straight
- Three of a Kind
- Two Pair
- One Pair
- High Card

### Frontend (Flutter Web)
- Simple UI with text fields for entering cards
- Supports card format: `<Suit><Rank>` (e.g., HA, D10, SK)
- Two main operations:
  - Evaluate Hand
  - Calculate Probability (Monte Carlo simulation)

## Getting Started

### Prerequisites
- **Go** 1.21+ (`go version`)
- **protoc** compiler (`brew install protobuf`)
- **Flutter** (`flutter doctor`)
- **protoc-gen-go** and **protoc-gen-go-grpc** (see installation steps below)

### Installation

#### 1. Install Go protobuf plugins
```bash
GOTOOLCHAIN=go1.21.6 go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
GOTOOLCHAIN=go1.21.6 go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0
```

#### 2. Generate gRPC code from proto (already done, but if you modify `poker.proto`)
```bash
protoc --go_out=. --go-grpc_out=. proto/poker.proto
```

#### 3. Install Go dependencies
```bash
GOTOOLCHAIN=go1.21.6 go mod tidy
```

#### 4. Install Flutter dependencies
```bash
cd frontend
flutter pub get
```

### Running the Application

#### Start the Backend Server
```bash
# From the project root
GOTOOLCHAIN=go1.21.6 go run server/main.go
```

The server will start on `localhost:50051`

#### Start the Frontend (Flutter Web)
```bash
cd frontend
flutter run -d chrome
```

The web app will open in Chrome.

## Card Format

### Suits
- `H` - Hearts
- `D` - Diamonds
- `C` - Clubs
- `S` - Spades

### Ranks
- `2-10` - Number cards
- `J` - Jack
- `Q` - Queen
- `K` - King
- `A` - Ace

### Examples
- `HA` - Ace of Hearts
- `D10` - 10 of Diamonds
- `SK` - King of Spades
- `C7` - 7 of Clubs

## Testing with grpcurl (Optional)

Install grpcurl:
```bash
brew install grpcurl
```

Test EvaluateHand:
```bash
grpcurl -plaintext -d '{
  "hole_cards": ["HA", "HK"],
  "community_cards": ["HQ", "HJ", "H10", "D2", "C3"]
}' localhost:50051 poker.PokerService/EvaluateHand
```

Test CalculateProbability:
```bash
grpcurl -plaintext -d '{
  "hole_cards": ["HA", "HK"],
  "community_cards": ["HQ", "HJ"],
  "num_simulations": 1000
}' localhost:50051 poker.PokerService/CalculateProbability
```

## How It Works

### Backend Logic

#### Hand Evaluation
1. Accepts 2 hole cards + up to 5 community cards
2. Generates all possible 5-card combinations (if 7 cards provided)
3. Evaluates each combination for poker hands
4. Returns the best hand with its rank value

#### Monte Carlo Simulation
1. Takes your hole cards and known community cards
2. Randomly deals remaining community cards
3. Randomly deals opponent's hole cards
4. Evaluates both hands and determines winner
5. Repeats N times (default 10,000)
6. Returns win/tie/lose probabilities

### Frontend
- Pure Flutter UI (no gRPC connection yet)
- Validates card inputs
- Ready to be connected to backend via gRPC-Web or HTTP proxy

## Next Steps (To Complete the Assignment)

### Option 1: gRPC-Web (Recommended for Production)
1. Set up Envoy proxy to translate HTTP/2 to gRPC
2. Generate Dart gRPC code from `poker.proto`
3. Connect Flutter UI to proxy

### Option 2: REST API Wrapper (Easier for Development)
1. Create a simple HTTP server in Go that wraps gRPC calls
2. Use Flutter's `http` package to call the REST endpoints
3. Example:
   ```go
   // Add HTTP handler in server/main.go
   http.HandleFunc("/evaluate", handleEvaluate)
   ```

### Option 3: Use Google Cloud Run (Easiest for Demo)
1. Deploy the Go gRPC server to Cloud Run
2. Cloud Run automatically provides HTTP/2 and gRPC support
3. Connect Flutter directly

## Assignment Checklist

- [x] Create folder structure
- [x] Initialize Go module
- [x] Define gRPC proto file
- [x] Generate Go gRPC code
- [x] Implement poker hand evaluation logic
- [x] Implement gRPC server
- [x] Create Flutter web frontend
- [ ] Connect frontend to backend (requires gRPC-Web setup or REST wrapper)
- [ ] Deploy to cloud (optional)
- [ ] Test end-to-end

## Troubleshooting

### Go version compatibility issues
Use `GOTOOLCHAIN=go1.21.6` prefix for all Go commands to avoid compatibility issues with macOS 11.

### Flutter web not working
Make sure Chrome is available and run:
```bash
flutter devices
```

### Proto generation fails
Ensure protoc and Go plugins are in your PATH:
```bash
export PATH="$PATH:$(go env GOPATH)/bin"
```

## License
MIT
