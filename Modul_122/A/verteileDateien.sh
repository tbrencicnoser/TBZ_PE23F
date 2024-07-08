#!/bin/bash

# Lese alle Dateien aus dem Verzeichnis "_schulklassen"
for klasse in _schulklassen/*.txt; do
  # Entferne die Dateiendung und erstelle ein Verzeichnis für die Klasse
  klassenname=$(basename "$klasse" .txt)
  mkdir -p "gen/$klassenname"
  
  # Lese jede Zeile (Schülername) aus der Klassen-Datei
  while IFS= read -r schueler; do
    # Erstelle ein Verzeichnis für jeden Schüler in der Klasse
    mkdir -p "gen/$klassenname/$schueler"
    
    # Kopiere die Dateien aus dem Template-Verzeichnis in das Schülerverzeichnis
    cp _templates/* "gen/$klassenname/$schueler/"
  done < "$klasse"
done
