# Go 1.20.3をベースイメージとして使用
FROM golang:1.20.3-alpine

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係ファイルをコピー
COPY go.mod go.sum ./

# 依存関係をダウンロード
RUN go mod download

# ソースコードをコピー
COPY . .

# アプリケーションをビルド
RUN go build -o main .

# コンテナのポートを公開
EXPOSE 8080

# アプリケーションを実行
CMD ["./main"]
