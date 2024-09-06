package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

const (
	PORT = "8080"
	HOST = "0.0.0.0"
)

func main() {
	r := gin.Default()

	// CORSミドルウェアを追加
	r.Use(cors.Default())

	r.GET("/api/v1/date", func(c *gin.Context) {
		c.String(http.StatusOK, time.Now().String())
	})

	addr := HOST + ":" + PORT
	fmt.Printf("Running on http://%s\n", addr)
	r.Run(addr)
}
