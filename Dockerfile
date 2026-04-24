FROM golang:1.21 AS base
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o reshma1 .

######################################
FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=base /app/reshma1 .
EXPOSE 8080
CMD ["./reshma1"]
