package main

import (
	"loadtest.com/finance/generate_data"
	"loadtest.com/finance/insert_batches"
)

func main() {
	generate_data.Generate()

	insert_batches.InsertLoginData()
}
