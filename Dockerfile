FROM golang:1.21 AS base
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o reshmav .

######################################
FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=base /app/reshmav .
EXPOSE 8080
CMD ["./reshmav"]
