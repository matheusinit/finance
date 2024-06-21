package main

import (
	"encoding/csv"
	"fmt"
	"github.com/brianvoe/gofakeit/v7"
	"github.com/sethvargo/go-password/password"
	"os"
)

func main() {
	const NUMBER_OF_RECORDS = 1000000

	columns := []string{
		"name", "email", "password", "password_confirmation",
	}

	file, err := os.Create("users.csv")

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

	fmt.Println(records)
}
