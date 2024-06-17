package main

import (
	"encoding/csv"
	"fmt"
	"github.com/brianvoe/gofakeit/v7"
	"os"
)

func main() {
	const NUMBER_OF_RECORDS = 1000000

	// var csv_content strings.Builder

	columns := []string{
		"name", "email", "password", "password_confirmation",
	}

	// csv_content.WriteString(columns)

	file, err := os.Create("users.csv")

	if err != nil {
		panic(err)
	}

	defer file.Close()

	writer := csv.NewWriter(file)

	// var records [][]string

	records := [][]string{}

	records = append(records, columns)

	for i := 0; i < NUMBER_OF_RECORDS; i++ {
		email := gofakeit.Email()
		name := gofakeit.Name()
		password := gofakeit.Password(true, true, true, true, false, 10)

		var row = []string{
			name, email, password, password,
		}

		records = append(records, row)

		// csv_content.WriteString(row)
	}

	writer.WriteAll(records)

	fmt.Println(records)
}
