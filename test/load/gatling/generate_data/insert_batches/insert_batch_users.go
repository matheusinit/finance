package insert_batches

import (
	"database/sql"
	"encoding/csv"
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/google/uuid"

	"golang.org/x/crypto/bcrypt"

	"log"
)

type User struct {
	ID             uuid.UUID      `gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Name           string         `gorm:"type:varchar(255);not null"`
	Email          string         `gorm:"type:varchar(255);unique;not null"`
	PasswordDigest string         `gorm:"type:varchar(255);not null"`
	CreatedAt      time.Time      `gorm:"type:timestamp(6);autoCreateTime"`
	UpdatedAt      time.Time      `gorm:"type:timestamp(6);autoUpdateTime"`
	DeletedAt      gorm.DeletedAt `gorm:"type:timestamp(6);index"`
}

type Account struct {
	ID            uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserId        uuid.UUID
	User          User
	CreatedAt     time.Time
	UpdatedAt     sql.NullTime
	LoginAttempts uint
}

func read_login_csv() [][]string {
	file, err := os.Open("./login-users-data.csv")

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

func hash_password(password string) string {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 4)
	if err != nil {
		log.Fatal(err)
	}

	return string(hashedPassword)
}

func InsertLoginData() {
	dsn := "host=localhost user=dba password=pandaninja!. dbname=finance_app_rb port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	records := read_login_csv()

	println("Database connected")

	var users []User
	var accounts []Account

	for index, record := range records {
		fmt.Printf("Started index %d\n", index)
		if index == 0 {
			continue
		}

		user := User{ID: uuid.New(), Name: record[0], Email: record[1], PasswordDigest: hash_password(record[2])}
		account := Account{UserId: user.ID}

		users = append(users, user)
		accounts = append(accounts, account)
	}

	db.CreateInBatches(users, 100)
	db.CreateInBatches(accounts, 100)

	var count int64

	db.Table("users").Count(&count)
	println(count)
}
