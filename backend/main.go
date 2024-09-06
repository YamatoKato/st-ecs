package main

import (
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

const (
	PORT          = "8070"
	HOST          = "0.0.0.0"
	REST_URL      = "http://restapi.ecs.internal:8080"
	REST_API_PATH = "/api/v1/date"
)

func main() {
	r := gin.Default()

	r.GET("/api", func(c *gin.Context) {
		resp, err := http.Get(REST_URL + REST_API_PATH)
		if err != nil {
			log.Println("ERROR in Backend")
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
			return
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Println("ERROR reading response")
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
			return
		}

		c.Data(http.StatusOK, "application/json", body)
	})

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "health check")
	})

	addr := fmt.Sprintf("%s:%s", HOST, PORT)
	log.Printf("Running on http://%s\n", addr)
	r.Run(addr)
}
