# Stage 1: Build the Go binary
FROM golang:1.21-alpine as builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# CRITICAL: Build for Linux AMD64 for GKE compatibility
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o poker-server ./server/main.go

# Stage 2: Create a tiny production image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/poker-server .
EXPOSE 50051
CMD ["./poker-server"]