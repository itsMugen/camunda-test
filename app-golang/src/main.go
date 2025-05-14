// TODO: implement the exporter code here

package main

import (
	"encoding/json"
	"net/http"
	"os"
	"time"
)

// helper: fetches JSON response from URL and parses that into a given interface
func getJSON(url string, target interface{}) error {
	var myClient = &http.Client{Timeout: 20 * time.Second}
	r, err := myClient.Get(url)
	if err != nil {
		return err
	}
	defer r.Body.Close()

	return json.NewDecoder(r.Body).Decode(target)
}

// helper: gets environment value with a fallback to a default one
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return defaultValue
	}
	return value
}

func main() {
	// TODO
}
