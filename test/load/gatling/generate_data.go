package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	// "strings"

	"github.com/brianvoe/gofakeit/v7"
	// "github.com/google/uuid"
	// "github.com/jor-go/csrf"
	"github.com/sethvargo/go-password/password"
)

func getCsrfToken() string {
	url := "http://0.0.0.0:8080/csrf_token"

	resp, err := http.Get(url)

	if err != nil {
		log.Fatalf("Failed to make request: %v", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)

	if err != nil {
		log.Fatalf("Failed to read response body: %v", err)
	}

	csrf_token := string(body)
	csrf_token = csrf_token[15:]

	// csrf_token := strings.Replace(string(body), "\"csrf_token\"", "", -1)
	// csrf_token = strings.Replace(csrf_token, ":", "", -1)
	// csrf_token = strings.Replace(csrf_token, "\"", "", -1)
	// csrf_token = strings.Replace(csrf_token, "{", "", -1)
	// csrf_token = strings.Replace(csrf_token, "}", "", -1)

	csrf_token = csrf_token[:len(csrf_token)-2]

	return csrf_token
}

func main() {
	const NUMBER_OF_RECORDS = 60000

	columns := []string{
		"name", "email", "password", "password_confirmation",
	}
  
  csv_name := os.Args[1]

	file, err := os.Create(csv_name)
	// file, err := os.Create("create-users-data.csv")
	// file, err := os.Create("login-users-data.csv")

	if err != nil {
		panic(err)
	}

	defer file.Close()

	writer := csv.NewWriter(file)

	records := [][]string{}

	records = append(records, columns)

	for i := 0; i < NUMBER_OF_RECORDS; i++ {
		email := gofakeit.Email()
		name := gofakeit.Name()
		password, err := password.Generate(12, 1, 1, false, false)
		// csrf_token := getCsrfToken()
		// uuid, _ := uuid.NewUUID()
		// csrf_token := csrf.CreateToken(uuid.String())
		// println(csrf_token)

		if err != nil {
			fmt.Println("Error:", err)
			return
		}

		var row = []string{
			name, email, password, password,
		}

		records = append(records, row)
	}

	writer.WriteAll(records)

  fmt.Println("✅ Fake data generated with success!!!")

	// fmt.Println(records)
}
