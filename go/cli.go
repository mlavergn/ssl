package main

import (
	"crypto/tls"
	"crypto/x509"
	"io"
	"io/ioutil"
	"log"
)

func main() {
	log.SetFlags(log.Lshortfile)

	cert, err := ioutil.ReadFile("../demo.crt")
	if err != nil {
		log.Fatalf("Couldn't load file %s", err)
	}

	certPool := x509.NewCertPool()
	certPool.AppendCertsFromPEM(cert)

	conf := &tls.Config{
		RootCAs: certPool,
	}

	conn, err := tls.Dial("tcp", "localhost:8443", conf)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	n, err := conn.Write([]byte("GET /\n\n"))
	if err != nil {
		log.Println(n, err)
		return
	}

	body, err := ioutil.ReadAll(io.Reader(conn))
	if err != nil {
		log.Println(n, err)
		return
	}

	println(string(body))
}
