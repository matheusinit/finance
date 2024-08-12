package main

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
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
