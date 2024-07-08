#!/bin/bash

# Schritt 1: Daten herunterladen
curl https://haraldmueller.ch/schueler/m122_projektunterlagen/b/MOCK_DATA.csv > mock_data.csv

# Funktion zur Generierung eines Initialpassworts
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Schritt 2: E-Mail-Adressen und Passwörter generieren
input_file="mock_data.csv"
output_file="$(date '+%Y-%m-%d_%H-%M')_mailimports.csv"

# Kopfzeile für die Output-Datei
echo "Email;Password" > "$output_file"

# E-Mail-Adressen und Passwörter generieren
emails=()
while IFS=, read -r id first_name last_name gender street_address street_number postal_code city; do
    # Sonderzeichen entfernen und in Kleinbuchstaben umwandeln
    clean_first_name=$(echo "$first_name" | iconv -f utf8 -t ascii//TRANSLIT | tr -d "'\"" | tr '[:upper:]' '[:lower:]')
    clean_last_name=$(echo "$last_name" | iconv -f utf8 -t ascii//TRANSLIT | tr -d "'\"" | tr '[:upper:]' '[:lower:]')

    # Eindeutige E-Mail-Adresse generieren
    email="${clean_first_name}.${clean_last_name}@edu.tbz.ch"
    count=1
    while [[ " ${emails[@]} " =~ " ${email} " ]]; do
        email="${clean_first_name}.${clean_last_name}${count}@edu.tbz.ch"
        count=$((count + 1))
    done
    emails+=("$email")

    password=$(generate_password)
    echo "${email};${password}" >> "$output_file"

    # Brief erstellen
    echo "Technische Berufsschule Zürich
Ausstellungsstrasse 70
8005 Zürich

Zürich, den $(date '+%d.%m.%Y')

                        ${first_name} ${last_name}
                        ${street_address} ${street_number}
                        ${postal_code} ${city}

Liebe${gender} ${first_name}

Es freut uns, Sie im neuen Schuljahr begrüssen zu dürfen.

Damit Sie am ersten Tag sich in unsere Systeme einloggen
können, erhalten Sie hier Ihre neue Emailadresse und Ihr
Initialpasswort, das Sie beim ersten Login wechseln müssen.

Emailadresse:   ${email}
Passwort:       ${password}

Mit freundlichen Grüssen

[IhrVorname] [IhrNachname]
(TBZ-IT-Service)

admin.it@tbz.ch, Abt. IT: +41 44 446 96 60" > "${email}.brf"
done < <(tail -n +2 "$input_file")

# Schritt 3: Archiv erstellen
archive_file="$(date '+%Y-%m-%d')_newMailadr_[IhreKlasse_IhrNachname].zip"
zip -r "$archive_file" *_mailimports.csv *.brf

# Schritt 4: FTP-Transfer
ftp_server="ftp.example.com"
ftp_user="your_username"
ftp_password="your_password"

ftp -inv $ftp_server <<EOF
user $ftp_user $ftp_password
put $archive_file
bye
EOF

# Schritt 5: E-Mail mit Anhang senden
recipient="your_email@example.com"
subject="Neue TBZ-Mailadressen $(wc -l < "$output_file")"
body="Lieber Empfänger,

Die Emailadressen-Generierung ist beendet. 
Es wurden $(wc -l < "$output_file") erzeugt.

Bei Fragen kontaktiere bitte [IhreTBZ-Emailadresse]

Gruss [IhrVorname] [IhrNachname]"

echo "$body" | mail -s "$subject" -a "$archive_file" "$recipient"

# Schritt 6: Automatisierung mit Cron
# Fügen Sie die Skripte in Crontab ein:
# crontab -e
# Fügen Sie die folgende Zeile hinzu, um das Skript täglich um Mitternacht auszuführen:
# 0 0 * * * /path/to/this_script.sh
