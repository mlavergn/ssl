package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
)

func dfltHandler(resp http.ResponseWriter, req *http.Request) {
	defer req.Body.Close()
	resp.Header().Set("Content-Type", "text/html")
	file, err := os.Open("../static/cors.html")
	if err != nil {
		fmt.Println(err)
		resp.WriteHeader(http.StatusNotFound)
		return
	}
	defer file.Close()
	fileStat, _ := file.Stat()

	resp.Header().Add("Content-Length", strconv.FormatInt(fileStat.Size(), 10))
	resp.WriteHeader(http.StatusOK)
	io.Copy(resp, file)
}

func corsHandler(resp http.ResponseWriter, req *http.Request) {
	defer req.Body.Close()
	if req.Method == http.MethodOptions {
		resp.Header().Set("Access-Control-Allow-Origin", "*")
		resp.WriteHeader(http.StatusNoContent)
		return
	}
	resp.Header().Set("Access-Control-Allow-Origin", "*")
	resp.Header().Set("Content-Type", "text/plain")
	resp.Write([]byte("SUCCESS"))
}

func certHandler(resp http.ResponseWriter, req *http.Request) {
	defer req.Body.Close()
	resp.Header().Set("Content-Type", "application/x-x509-ca-cert")
	file, err := os.Open("../demo.crt")
	if err != nil {
		fmt.Println(err)
		resp.WriteHeader(http.StatusNotFound)
		return
	}
	defer file.Close()
	fileStat, _ := file.Stat()

	resp.Header().Add("Content-Length", strconv.FormatInt(fileStat.Size(), 10))
	resp.WriteHeader(http.StatusOK)
	io.Copy(resp, file)

}

func main() {
	http.HandleFunc("/", dfltHandler)
	http.HandleFunc("/cors", corsHandler)
	http.HandleFunc("/cert", certHandler)
	err := http.ListenAndServeTLS(":8443", "../demo.crt", "../demo.key", nil)
	if err != nil {
		log.Fatal(err)
	}
}
