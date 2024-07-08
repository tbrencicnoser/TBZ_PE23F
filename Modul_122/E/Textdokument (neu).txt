#!/bin/bash

# convert_to_csv.sh

# Funktion zum Umwandeln einer .data Datei in eine CSV-Zeile
convert_data_to_csv() {
    input_file=$1
    output_file=$2

    # Initialisiere die CSV-Zeile
    csv_line=""

    # Lese die .data Datei Zeile für Zeile
    while IFS=: read -r key value; do
        # Entferne Leerzeichen am Anfang und Ende
        key=$(echo $key | xargs)
        value=$(echo $value | xargs)
        
        # Füge den Wert zur CSV-Zeile hinzu
        if [ -z "$csv_line" ]; then
            csv_line="$value"
        else
            csv_line="$csv_line,$value"
        fi
    done < "$input_file"

    # Schreibe die CSV-Zeile in die Output-Datei
    echo $csv_line >> "$output_file"
}

# Hauptteil des Skripts
output_file="qr_rechnungen.csv"

# Schreibe die Kopfzeile in die Output-Datei
echo "KundenNr,Name,Strasse,PLZ,Ort,Betrag,Währung,Referenz,Fälligkeitsdatum,IBAN" > "$output_file"

# Verarbeite alle .data Dateien
for data_file in x-ressourcen/rechnung*.data; do
    convert_data_to_csv "$data_file" "$output_file"
done

echo "CSV-Datei wurde erfolgreich erstellt: $output_file"
