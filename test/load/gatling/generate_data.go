package main

import (
	"encoding/csv"
	"fmt"
	"github.com/brianvoe/gofakeit/v7"
	"os"
	"strings"
)

func force_password_pattern(password string) string {
	has_uppercase_letter := false
	has_lowercase_letter := false

	var last_uppercase_letter byte
	var last_lowercase_letter byte

	for i := 0; i < len(password); i++ {
		letter := password[i]

		if letter >= 65 && letter <= 90 {
			has_uppercase_letter = true

			last_uppercase_letter = letter
		}

		if letter >= 97 && letter <= 122 {
			has_lowercase_letter = true

			last_lowercase_letter = letter
		}
	}

	if has_lowercase_letter == false {
		password = strings.Replace(password, string(last_uppercase_letter), strings.ToLower(string(last_uppercase_letter)), 1)
	}

	if has_uppercase_letter == false {
		password = strings.Replace(password, string(last_lowercase_letter), strings.ToUpper(string(last_lowercase_letter)), 1)
	}

	return password
}

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
		password := gofakeit.Password(true, true, true, true, false, 10)

		password = force_password_pattern(password)

		var row = []string{
			name, email, password, password,
		}

		records = append(records, row)
	}

	writer.WriteAll(records)

	fmt.Println(records)
}
