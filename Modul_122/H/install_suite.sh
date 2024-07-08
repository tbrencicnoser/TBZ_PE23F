#!/bin/bash

# install_suite.sh

# Pfade
log_file="install_log.txt"
config_file="install_config.cfg"
test_results="test_results.txt"

# Funktion zum Schreiben ins Log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Funktion zur Installation eines Tools
install_tool() {
    tool_name=$1
    install_command=$2
    
    log "Starte Installation von $tool_name"
    if $install_command &>> "$log_file"; then
        log "$tool_name wurde erfolgreich installiert."
    else
        log "Fehler bei der Installation von $tool_name."
    fi
}

# Funktion zur Durchführung von Tests
run_tests() {
    echo "Durchführung der Tests:" > "$test_results"
    log "Starte Tests"

    # Beispiel-Test: Überprüfung, ob ein bestimmtes Tool installiert ist
    for tool in "${!tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool ist installiert" >> "$test_results"
            log "Test erfolgreich: $tool ist installiert."
        else
            echo "$tool ist nicht installiert" >> "$test_results"
            log "Test fehlgeschlagen: $tool ist nicht installiert."
        fi
    done
}

# Hauptfunktion
main() {
    log "Start der Installation"

    if [ ! -f "$config_file" ]; then
        log "Konfigurationsdatei $config_file nicht gefunden."
        echo "Konfigurationsdatei $config_file nicht gefunden. Bitte sicherstellen, dass die Datei existiert."
        exit 1
    fi

    # Lesen der Konfigurationsdatei
    declare -A tools
    while IFS='=' read -r key value; do
        tools["$key"]="$value"
    done < "$config_file"

    # Installation der Tools
    for tool in "${!tools[@]}"; do
        install_tool "$tool" "${tools[$tool]}"
    done

    # Durchführung der Tests
    run_tests

    # Anzeige der Testergebnisse
    cat "$test_results"
    log "Installation abgeschlossen."
}

# Ausführen der Hauptfunktion
main
