# go 1.20 をベースにする
FROM golang:1.20.3-alpine

# 作業ディレクトリを指定
WORKDIR /app

# パッケージファイルをコピーして依存関係をインストール
COPY go.mod go.sum ./

# パッケージをインストール
RUN go mod download

# ソースコードをコピー
COPY . .

# アプリケーションをビルド
RUN go build -o main .

# アプリケーションを実行するポートを指定
EXPOSE 8070

# アプリケーションを起動
CMD ["./main"]
