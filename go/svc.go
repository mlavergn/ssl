package main

import (
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte("SUCCESS"))
}

func main() {
	http.HandleFunc("/", handler)
	err := http.ListenAndServeTLS(":8443", "../demo.crt", "../demo.key", nil)
	if err != nil {
		log.Fatal(err)
	}
}
