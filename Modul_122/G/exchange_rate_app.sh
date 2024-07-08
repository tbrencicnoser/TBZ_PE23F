#!/bin/bash

# API URLs für verschiedene Währungen und Kryptowährungen
api_url="https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,usd,euro,swiss-franc&vs_currencies=chf"

# Datei zur Speicherung der alten Daten
data_file="exchange_rates.csv"
old_data_file="old_exchange_rates.csv"

# Funktion zum Abrufen der aktuellen Kurse
fetch_exchange_rates() {
    curl -s "$api_url" | jq -r 'to_entries | map([.key, .value.chf] | join(",")) | .[]' > "$data_file"
}

# Funktion zum Vergleichen der alten und neuen Daten
compare_rates() {
    if [[ ! -f "$old_data_file" ]]; then
        echo "Keine alten Daten zum Vergleichen gefunden."
        return
    fi

    echo "Vergleich der Wechselkurse:"
    printf "%-15s %-15s %-15s %-15s\n" "Währung" "Alter Kurs" "Neuer Kurs" "Differenz (%)"
    printf "%-15s %-15s %-15s %-15s\n" "--------" "---------" "----------" "-------------"

    while IFS=, read -r currency old_rate; do
        new_rate=$(grep "^$currency," "$data_file" | cut -d, -f2)
        if [[ -n "$new_rate" ]]; then
            diff=$(echo "scale=2; ($new_rate - $old_rate) / $old_rate * 100" | bc)
            color="\033[0m" # Keine Farbe
            if (( $(echo "$diff > 0" | bc -l) )); then
                color="\033[0;32m" # Grün
            elif (( $(echo "$diff < 0" | bc -l) )); then
                color="\033[0;31m" # Rot
            fi
            printf "${color}%-15s %-15.5f %-15.5f %-15.2f%%\033[0m\n" "$currency" "$old_rate" "$new_rate" "$diff"
        fi
    done < "$old_data_file"
}

# Funktion zur Umrechnung von CHF in verschiedene Währungen
convert_currency() {
    amount_chf=$1
    echo "Umrechnung von CHF ${amount_chf}:"
    printf "%-15s %-15s\n" "Währung" "Betrag"
    printf "%-15s %-15s\n" "--------" "------"

    while IFS=, read -r currency rate; do
        amount=$(echo "scale=2; $amount_chf / $rate" | bc)
        printf "%-15s %-15.2f\n" "$currency" "$amount"
    done < "$data_file"
}

# Hauptfunktion
main() {
    echo "Abrufen der aktuellen Wechselkurse..."
    fetch_exchange_rates

    echo "Vergleichen der alten und neuen Wechselkurse..."
    compare_rates

    echo "Bitte geben Sie den Betrag in CHF ein, den Sie umrechnen möchten:"
    read amount_chf
    convert_currency "$amount_chf"

    # Alte Daten speichern
    cp "$data_file" "$old_data_file"
}

# Ausführen der Hauptfunktion
main
