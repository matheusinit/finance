package main

import (
	"fmt"
	"log"
	"os/exec"
	"strings"
)

func generate_data(args ...string) string {
	cmd := exec.Command("fakedata", args...)

	output, err := cmd.Output()

	if err != nil {
		log.Fatalf("Failed to execute command: %s", err)
	}

	return strings.TrimSpace(strings.ReplaceAll(string(output), ",", ""))
}

func main() {
	const NUMBER_OF_RECORDS = 1000

	var csv_content strings.Builder

	for i := 0; i < NUMBER_OF_RECORDS; i++ {
		email := generate_data("email", "-l", "1")
		name := generate_data("name.first", "-l", "1")
		password := generate_data("sentence", "-l", "1")

		row := name + ", " + email + ", " + password + "\n"

		csv_content.WriteString(row)
	}

	fmt.Println(csv_content.String())
}
