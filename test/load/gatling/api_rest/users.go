package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"
)

type userRoutes struct{}

func (rs userRoutes) Routes() chi.Router {
	r := chi.NewRouter()

	r.Delete("/", rs.DeleteAllRecords)

	return r

}

func (rs userRoutes) DeleteAllRecords(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Delete users..."))
}
