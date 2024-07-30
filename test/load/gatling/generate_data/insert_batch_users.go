package main

import (
	"database/sql"
	"encoding/csv"
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	// "gorm.io/driver/sqlite"
)

type User struct {
	id              string `gorm:"primaryKey"`
	name            string
	email           string
	password_digest string
	created_at      time.Time
	updated_at      sql.NullTime
	deleted_at      sql.NullTime
}

type Account struct {
	id           string `gorm:"primaryKey"`
	userId       string
	created_at   time.Time
	updated_at   sql.NullTime
	loginAttemps uint
}

func read_login_csv() [][]string {
	file, err := os.Open("login-users-data.csv")

	if err != nil {
		fmt.Println("Error opening file:", err)
	}

	defer file.Close()

	reader := csv.NewReader(file)

	records, err := reader.ReadAll()

	if err != nil {
		fmt.Println("Error reading file:", err)
		return nil
	}

	return records
}

func main() {
	dsn := "host=localhost user=dba password=pandaninja!. dbname=finance_app_rb port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	var count int64

	db.Table("users").Count(&count)

	records := read_login_csv()

	println("Database connected")
	println(count)

	var users []User

	for _, record := range records {
		fmt.Println(record)

		user := User{name: record[0], email: record[1], password_digest: record[2], created_at: time.Now()}

		users = append(users, user)
	}

	fmt.Println(users[0])
}
