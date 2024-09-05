FROM oven/bun:latest

# 作業ディレクトリを指定
WORKDIR /app

# パッケージファイルをコピーして依存関係をインストール
COPY package.json bun.lockb ./
RUN bun install

# ソースコードをコピー
COPY . .

# アプリケーションをビルド
RUN bun run build

# アプリケーションを実行するポートを指定
EXPOSE 3000

# アプリケーションを起動
CMD ["bun", "run", "start"]
