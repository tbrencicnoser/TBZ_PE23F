#!/bin/bash

# Depot-Konfiguration: Anzahl der Aktien, Fremdwährungen und Kryptowährungen
declare -A depot=(
    ["Novartis"]=10
    ["Nestle"]=15
    ["ABB"]=20
    ["Swisscom"]=5
    ["UBS"]=25
    ["CreditSuisse"]=30
    ["Roche"]=8
    ["Zurich"]=12
    ["USD"]=3000
    ["Bitcoin"]=0.1
)

# Historische Kaufpreise in CHF
declare -A kaufpreise=(
    ["Novartis"]=85.00
    ["Nestle"]=100.00
    ["ABB"]=25.00
    ["Swisscom"]=500.00
    ["UBS"]=10.00
    ["CreditSuisse"]=8.00
    ["Roche"]=300.00
    ["Zurich"]=250.00
    ["USD"]=0.95
    ["Bitcoin"]=45000.00
)

# Aktuelle Wechselkurse und Kursdaten abrufen (API-URLs müssen angepasst werden)
get_current_price() {
    case $1 in
        "Novartis") echo $(curl -s "https://api.example.com/stock/novartis" | jq -r '.price') ;;
        "Nestle") echo $(curl -s "https://api.example.com/stock/nestle" | jq -r '.price') ;;
        "ABB") echo $(curl -s "https://api.example.com/stock/abb" | jq -r '.price') ;;
        "Swisscom") echo $(curl -s "https://api.example.com/stock/swisscom" | jq -r '.price') ;;
        "UBS") echo $(curl -s "https://api.example.com/stock/ubs" | jq -r '.price') ;;
        "CreditSuisse") echo $(curl -s "https://api.example.com/stock/creditsuisse" | jq -r '.price') ;;
        "Roche") echo $(curl -s "https://api.example.com/stock/roche" | jq -r '.price') ;;
        "Zurich") echo $(curl -s "https://api.example.com/stock/zurich" | jq -r '.price') ;;
        "USD") echo $(curl -s "https://api.example.com/fx/usdchf" | jq -r '.price') ;;
        "Bitcoin") echo $(curl -s "https://api.example.com/crypto/bitcoin" | jq -r '.price') ;;
    esac
}

# Schritt 2: Depotwert berechnen
calculate_depot_value() {
    local current_value=0
    local historical_value=0

    for asset in "${!depot[@]}"; do
        local current_price=$(get_current_price "$asset")
        local amount=${depot[$asset]}
        local purchase_price=${kaufpreise[$asset]}
        
        current_value=$(echo "$current_value + $current_price * $amount" | bc)
        historical_value=$(echo "$historical_value + $purchase_price * $amount" | bc)
    done

    echo "Current Value: CHF $current_value"
    echo "Historical Value: CHF $historical_value"
    local difference=$(echo "scale=2; (($current_value - $historical_value) / $historical_value) * 100" | bc)
    echo "Difference: $difference %"
}

# Schritt 3: Protokollierung der Werte
log_values() {
    local logfile="depot_values.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local current_value=0
    local historical_value=0

    for asset in "${!depot[@]}"; do
        local current_price=$(get_current_price "$asset")
        local amount=${depot[$asset]}
        local purchase_price=${kaufpreise[$asset]}
        
        current_value=$(echo "$current_value + $current_price * $amount" | bc)
        historical_value=$(echo "$historical_value + $purchase_price * $amount" | bc)
    done

    local difference=$(echo "scale=2; (($current_value - $historical_value) / $historical_value) * 100" | bc)
    
    echo "$timestamp, CHF $current_value, CHF $historical_value, $difference %" >> "$logfile"
}

# Schritt 4: Automatisierung mit Cron
# (Dieser Teil wird nur einmalig zur Einrichtung des Cron-Jobs ausgeführt)
setup_cron_job() {
    crontab -l > mycron
    echo "0 * * * * /path/to/depot_monitor.sh" >> mycron
    crontab mycron
    rm mycron
}

# Depotwert berechnen und protokollieren
calculate_depot_value
log_values

# Hinweis: Um den Cron-Job einzurichten, entfernen Sie den Kommentar und führen Sie das Skript einmal manuell aus.
# setup_cron_job
