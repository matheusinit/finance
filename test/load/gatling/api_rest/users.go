package main

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type userRoutes struct{}

func (rs userRoutes) Routes() chi.Router {
	r := chi.NewRouter()

	r.Delete("/", rs.DeleteAllRecords)

	return r
}

type Response struct {
	Message string `json:"message"`
}

func (rs userRoutes) DeleteAllRecords(w http.ResponseWriter, r *http.Request) {
	dsn := "host=localhost user=dba password=pandaninja!. dbname=finance_app_rb port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	db.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&Account{})
	db.Session(&gorm.Session{AllowGlobalUpdate: true}).Unscoped().Delete(&User{})

	response := Response{
		Message: "All records deleted",
	}

	w.Header().Set("Content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}
