#!/bin/bash

# Verzeichnisse und Dateien
output_dir="/path/to/output"
log_file="${output_dir}/api_log.txt"
html_file="${output_dir}/api_data.html"

# API URLs
weather_api="https://api.open-meteo.com/v1/forecast?latitude=47.3769&longitude=8.5417&hourly=temperature_2m"
exchange_rate_api="https://v6.exchangerate-api.com/v6/YOUR_API_KEY/latest/CHF"
crypto_api="https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=3&page=1&sparkline=false"

# Funktion zum Abrufen und Verarbeiten von API-Daten
fetch_data() {
    echo "$(date): Fetching data..." >> "$log_file"
    
    # Wetterdaten abrufen
    weather_data=$(curl -s "$weather_api")
    temperature=$(echo "$weather_data" | jq -r '.hourly.temperature_2m[0]')
    
    # Wechselkurse abrufen
    exchange_data=$(curl -s "$exchange_rate_api")
    usd_chf=$(echo "$exchange_data" | jq -r '.conversion_rates.USD')
    eur_chf=$(echo "$exchange_data" | jq -r '.conversion_rates.EUR')
    
    # Kryptowährungsdaten abrufen
    crypto_data=$(curl -s "$crypto_api")
    bitcoin_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="bitcoin") | .current_price')
    ethereum_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="ethereum") | .current_price')
    tether_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="tether") | .current_price')
    
    # Daten in HTML formatieren
    generate_html "$temperature" "$usd_chf" "$eur_chf" "$bitcoin_price" "$ethereum_price" "$tether_price"
    
    echo "$(date): Data fetched and HTML generated." >> "$log_file"
}

# Funktion zum Generieren der HTML-Datei
generate_html() {
    temperature=$1
    usd_chf=$2
    eur_chf=$3
    bitcoin_price=$4
    ethereum_price=$5
    tether_price=$6
    
    cat <<EOF > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Data</title>
    <style>
        table {
            width: 50%;
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 18px;
            text-align: left;
        }
        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <h1>Aktuelle Daten</h1>
    <table>
        <tr>
            <th>Information</th>
            <th>Wert</th>
        </tr>
        <tr>
            <td>Temperatur (Zürich)</td>
            <td>${temperature} °C</td>
        </tr>
        <tr>
            <td>USD/CHF</td>
            <td>${usd_chf}</td>
        </tr>
        <tr>
            <td>EUR/CHF</td>
            <td>${eur_chf}</td>
        </tr>
        <tr>
            <td>Bitcoin Preis (USD)</td>
            <td>${bitcoin_price}</td>
        </tr>
        <tr>
            <td>Ethereum Preis (USD)</td>
            <td>${ethereum_price}</td>
        </tr>
        <tr>
            <td>Tether Preis (USD)</td>
            <td>${tether_price}</td>
        </tr>
    </table>
</body>
</html>
EOF
}

# Funktion zum Senden der HTML-Datei per E-Mail
send_email() {
    recipient="your_email@example.com"
    subject="Aktuelle API-Daten"
    body="Anbei die aktuellen Daten von den abgerufenen APIs."
    
    echo "$body" | mail -s "$subject" -a "$html_file" "$recipient"
}

# Hauptteil des Skripts
mkdir -p "$output_dir"
fetch_data
send_email

# Hinweis: Um den Cron-Job einzurichten, entfernen Sie den Kommentar und führen Sie das Skript einmal manuell aus.
# setup_cron_job
