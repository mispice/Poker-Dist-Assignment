# Poker Hand Evaluator - Project Summary

## 📋 Project Overview
Built a distributed poker hand evaluation system with a Go gRPC backend and Flutter web frontend for Texas Hold'em poker analysis.

## 🏗️ Architecture

### Backend (Go + gRPC)
- **Language**: Go 1.21.6
- **Framework**: gRPC v1.56.3 with Protocol Buffers (proto3)
- **Port**: 50051
- **Location**: `server/` directory

#### Components:
1. **`proto/poker.proto`** - Service definitions with 3 RPC methods:
   - `EvaluateHand` - Evaluates best 5-card hand from 7 cards
   - `CompareHands` - Compares two hands and returns winner (0=tie, 1=player1, 2=player2)
   - `CalculateProbability` - Monte Carlo simulation for win probability

2. **`server/evaluator.go`** - Core poker logic:
   - 9 hand types: High Card → Royal Flush
   - Ranking system with 10,000,000 base multiplier per hand type
   - Kicker comparison for all applicable hands
   - Generates all 21 possible 5-card combinations from 7 cards

3. **`server/server.go`** - gRPC service implementation
4. **`server/main.go`** - Server entry point

### Frontend (Flutter Web)
- **Framework**: Flutter 3.2.6+
- **Port**: 8082
- **Location**: `frontend/` directory

#### Features:
- Professional dark theme UI with gradient backgrounds
- Card-style input sections
- Three main features:
  1. Hand evaluation
  2. Hand comparison (2 players)
  3. Win probability calculation (Monte Carlo)

### Middleware
- **grpcwebproxy** - Bridges browser HTTP requests to gRPC server
- **Port**: 8081
- **Why needed**: Browsers can't make direct gRPC calls, proxy converts gRPC-Web → gRPC

## 🎯 What Was Built

### 1. Protocol Buffers Schema (`proto/poker.proto`)
```protobuf
service PokerService {
  rpc EvaluateHand(HandRequest) returns (HandResponse);
  rpc CompareHands(CompareRequest) returns (CompareResponse);
  rpc CalculateProbability(SimRequest) returns (SimResponse);
}
```

### 2. Poker Hand Evaluator
- **Input**: 2 hole cards + up to 5 community cards (7 total)
- **Output**: Best 5-card hand with rank value
- **Algorithm**: 
  - Generates all C(7,5) = 21 combinations
  - Evaluates each using rank multipliers
  - Returns highest-ranked hand

**Ranking System**:
```
Royal Flush:     90,000,000+
Straight Flush:  80,000,000+
Four of a Kind:  70,000,000+
Full House:      60,000,000+
Flush:           50,000,000+
Straight:        40,000,000+
Three of a Kind: 30,000,000+
Two Pair:        20,000,000+
One Pair:        10,000,000+
High Card:       0-14
```

### 3. Kicker Comparison
Implemented detailed kicker logic for tie-breaking:
- **High Card**: Compares all 5 cards in descending order
- **One Pair**: Compares pair rank, then 3 kickers
- **Three of a Kind**: Compares triplet rank, then 2 kickers
- **Four of a Kind**: Compares quad rank, then 1 kicker

### 4. Test Suite Automation
- **File**: `run_teacher_tests.go`
- **Test Data**: `test_cases.csv` (55 test cases from Excel)
- **Features**:
  - CSV parsing with special character handling (em-dash "–")
  - Skips empty permutation rows
  - Color-coded terminal output
  - Detailed pass/fail reporting

### 5. Flutter UI with gRPC Integration
- Uses `grpc_web.dart` package
- Connects via `GrpcWebClientChannel` to proxy
- Real-time hand evaluation and comparison
- Formatted result displays

## ✅ Final Outcomes

### Test Results
```
📊 Test Results Summary:
   Total:  55
   ✅ Passed: 55
   ❌ Failed: 0

🎉 ALL TESTS PASSED!
```

### Validated Scenarios
- ✅ All 9 poker hand types correctly identified
- ✅ Kicker comparison working (SK > SQ, K > 8, 7 > 6, etc.)
- ✅ Tie detection functional
- ✅ Monte Carlo simulation returns win/tie/lose probabilities
- ✅ Empty card handling (skips invalid rows)
- ✅ Special character parsing (em-dash in Royal Flush test)

### System Integration
```
Browser (localhost:8082)
    ↓ HTTP/gRPC-Web
grpcwebproxy (localhost:8081)
    ↓ gRPC
poker-server (localhost:50051)
```

## 📦 File Structure
```
Poker-dist-assignment/
├── .dockerignore                     # Docker build exclusions
├── Dockerfile.proxy                  # gRPC-Web proxy Docker image
├── PROJECT_SUMMARY.md                # Complete project documentation
├── QUICKSTART.md                     # Quick start guide
├── README.md                         # Main documentation
├── go.mod                            # Go dependencies
├── go.sum                            # Go dependency checksums
├── poker-server                      # Compiled backend binary
├── run_tests                         # Compiled test runner binary
├── run_teacher_tests.go              # Test suite source code
├── test_cases.csv                    # 55 teacher test cases
├── test_client.go                    # gRPC client test utility
│
├── proto/
│   ├── poker.proto                   # gRPC service definition (proto3)
│   ├── poker.pb.go                   # Generated Go protobuf code
│   └── poker_grpc.pb.go              # Generated Go gRPC code
│
├── server/
│   ├── Dockerfile                    # Backend Docker image
│   ├── main.go                       # Server entry point (port 50051)
│   ├── server.go                     # gRPC service implementation
│   └── evaluator.go                  # Poker hand evaluation logic
│
└── frontend/
    ├── Dockerfile                    # Frontend Docker image (Flutter + nginx)
    ├── pubspec.yaml                  # Flutter dependencies
    ├── pubspec.lock                  # Flutter dependency lock
    ├── analysis_options.yaml         # Dart linter configuration
    ├── frontend.iml                  # IntelliJ project file
    ├── README.md                     # Frontend documentation
    ├── .metadata                     # Flutter metadata
    │
    ├── lib/
    │   ├── main.dart                 # Flutter UI application
    │   └── proto/                    # Generated Dart proto files
    │       ├── poker.pb.dart         # Dart protobuf classes
    │       ├── poker.pbenum.dart     # Dart enums
    │       ├── poker.pbgrpc.dart     # Dart gRPC client
    │       └── poker.pbjson.dart     # JSON serialization
    │
    ├── web/
    │   ├── index.html                # Web app entry point
    │   ├── manifest.json             # PWA manifest
    │   ├── favicon.png               # Site favicon
    │   └── icons/                    # App icons (192, 512, maskable)
    │
    └── test/
        └── widget_test.dart          # Flutter widget tests
```

## 🔧 Key Technical Decisions

1. **Go 1.21.6 instead of latest**: macOS 11 compatibility (go1.25+ requires macOS 12+)
2. **gRPC v1.56.3**: Newer versions incompatible with Go 1.21
3. **10,000,000 base multiplier**: Ensures clean separation between hand types and kickers
4. **GrpcWebClientChannel**: Required for browser-to-gRPC communication
5. **Port 8082 for Flutter**: Port 8080 was already in use during development

## 🐳 Next Steps: Dockerization & Kubernetes

### Services to Containerize
1. **poker-server** (Go backend)
2. **grpcwebproxy** (middleware)
3. **frontend** (Flutter web - nginx static hosting)

### Docker Images Needed
```
poker-backend:latest        # Go gRPC server
grpcweb-proxy:latest        # Proxy middleware  
poker-frontend:latest       # Nginx + Flutter build
```

### Kubernetes Resources Required
```yaml
# Deployments
- poker-server-deployment (3 replicas)
- grpcweb-proxy-deployment (2 replicas)
- frontend-deployment (2 replicas)

# Services
- poker-server-service (ClusterIP, port 50051)
- grpcweb-proxy-service (ClusterIP, port 8081)
- frontend-service (LoadBalancer/NodePort, port 80)

# ConfigMaps (optional)
- poker-config (environment variables)

# Ingress (optional)
- poker-ingress (HTTP routing)
```

### Port Mapping for K8s
```
External → 80 → frontend-service → 8080 (nginx)
Internal → 8081 → grpcweb-proxy → 50051 → poker-server
```

### Environment Variables Needed
```bash
# Backend
GRPC_PORT=50051

# Proxy
BACKEND_ADDR=poker-server-service:50051
SERVER_HTTP_DEBUG_PORT=8081
ALLOWED_ORIGINS=*

# Frontend (build-time)
GRPC_PROXY_URL=http://grpcweb-proxy-service:8081
```

## 📝 Build Commands Summary

### Backend
```bash
cd /Users/new/Desktop/Poker-dist-assignment
GOTOOLCHAIN=go1.21.6 go build -o poker-server server/main.go server/server.go server/evaluator.go
```

### Frontend
```bash
cd frontend
flutter build web --release
# Output: frontend/build/web/
```

### Proto Generation
```bash
# Go
protoc --go_out=. --go-grpc_out=. proto/poker.proto

# Dart
protoc --dart_out=grpc:frontend/lib/proto -I proto proto/poker.proto
```

## 🎮 Running the System

### Manual Startup (Development)
```bash
# Terminal 1: Backend
./poker-server

# Terminal 2: Proxy
~/go/bin/grpcwebproxy \
  --backend_addr=localhost:50051 \
  --run_tls_server=false \
  --allow_all_origins \
  --server_http_debug_port=8081

# Terminal 3: Frontend
cd frontend
flutter run -d chrome --web-port=8082
```

### Run Tests
```bash
./run_tests
```

## 📊 Project Metrics
- **Lines of Code**: ~3,900
- **Files**: 33
- **Languages**: Go, Dart, Protocol Buffers
- **Test Coverage**: 55 comprehensive test cases
- **Success Rate**: 100% (55/55 passing)

## 🔐 Card Format
```
Format: <Suit><Rank>
Suits: H (Hearts), D (Diamonds), C (Clubs), S (Spades)
Ranks: A, 2-10, J, Q, K

Examples:
  HA  = Ace of Hearts
  D10 = 10 of Diamonds
  SK  = King of Spades
```

## 🚀 GitHub Repository
- **URL**: https://github.com/mispice/Poker-Dist-Assignment
- **Branch**: main
- **Commit**: "Initial commit: Poker hand evaluator with gRPC backend and Flutter frontend - All 55 test cases passing"

---

## 💡 For Gemini: Kubernetes Deployment Guide

To containerize and deploy this to Kubernetes, you'll need to:

1. **Create 3 Dockerfiles**:
   - `Dockerfile.backend` - Multi-stage Go build
   - `Dockerfile.proxy` - grpcwebproxy binary
   - `Dockerfile.frontend` - Flutter build + nginx

2. **Write Kubernetes manifests**:
   - `k8s/backend-deployment.yaml`
   - `k8s/proxy-deployment.yaml`
   - `k8s/frontend-deployment.yaml`
   - `k8s/services.yaml`

3. **Configure networking**:
   - Backend: ClusterIP (internal only)
   - Proxy: ClusterIP (internal only)
   - Frontend: LoadBalancer or Ingress (external access)

4. **Handle dependencies**:
   - Proxy must wait for backend readiness
   - Frontend build needs proxy URL at build time

5. **Optimization considerations**:
   - Use Alpine-based images for smaller size
   - Implement health checks (readinessProbe/livenessProbe)
   - Set resource limits (CPU/memory)
   - Enable horizontal pod autoscaling (HPA)

The system is production-ready with all tests passing. Start with Dockerfiles for each component.
