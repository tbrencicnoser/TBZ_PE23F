#!/bin/bash

# Erstelle das Template-Verzeichnis
mkdir -p _templates

# Erstelle die Dateien im Template-Verzeichnis
touch _templates/datei-1.txt
touch _templates/datei-2.pdf
touch _templates/datei-3.doc

# Erstelle das Verzeichnis für die Schulklassen
mkdir -p _schulklassen

# Erstelle die Schulklassen-Dateien mit Schülernamen
echo -e "Amherd\nBaume\nKeller\nMüller\nSchmidt\nMeier\nHuber\nWeber\nFischer\nMeyer\nWagner\nBecker" > _schulklassen/M122-AP22b.txt
echo -e "Arslan\nBuehler\nCamenisch\nMuster\nKunz\nHofmann\nKeller\nMeyer\nFischer\nSchneider\nLehmann\nBrunner" > _schulklassen/M122-AP22c.txt
