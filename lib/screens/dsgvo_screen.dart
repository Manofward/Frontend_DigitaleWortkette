import 'package:flutter/material.dart';

class DsgvoScreen extends StatelessWidget {
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  const DsgvoScreen({
    super.key,
    required this.onAccepted,
    required this.onDeclined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Datenschutzerklärung (DSGVO)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Datenschutzerklärung\n\n"
                  "Wir freuen uns über Ihr Interesse an unserer App. "
                  "Der Schutz Ihrer persönlichen Daten ist uns ein wichtiges Anliegen. "
                  "Im Folgenden informieren wir Sie gemäß Art. 13 DSGVO über die Verarbeitung Ihrer Daten.\n\n"
                  
                  "1. Verantwortlicher\n"
                  "Verantwortlich für die Datenverarbeitung sind:\n"
                  "Betreiber dieser App:\n"
                  "\t\t\tJanik Meyer\n"
                  "\t\t\tE-Mail: janikmeyer1607@outlook.de\n\n"

                  "Bereitsteller vom Server:\n"
                  "\t\t\tDavid-Paul Adams\n"
                  "\t\t\tE-Mail: david-paul.adams@outlook.de\n\n"

                  "2. Verarbeitete Daten\n"
                  "Im Rahmen der Nutzung dieser App werden folgende Daten verarbeitet:\n"
                  "- Kamera (für Video-Spiel-Funktion)\n"
                  "- Mikrofon (für Sprachkommunikation)\n"
                  "- IP-Adresse (für Verbindung und Sicherheit)\n"
                  "- Lobby- und Spieldaten (für Spielfortschritt und Spielerinteraktionen)\n\n"

                  "3. Zweck und Rechtsgrundlage\n"
                  "Die Daten werden ausschließlich für folgende Zwecke verwendet:\n"
                  "- Durchführung von Online-Spielen\n"
                  "- Anzeige und Verwaltung von Spieler-Lobbys\n"
                  "Rechtsgrundlage für die Verarbeitung ist Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung).\n\n"

                  "4. Weitergabe von Daten\n"
                  "Es erfolgt keine Weitergabe Ihrer Daten an Dritte.\n\n"

                  "5. Speicherdauer\n"
                  "Ihre Daten werden nur so lange gespeichert, wie es für den Zweck der App-Nutzung erforderlich ist.\n\n"

                  "6. Ihre Rechte\n"
                  "Sie haben jederzeit folgende Rechte:\n"
                  "- Auskunft über Ihre gespeicherten Daten (Art. 15 DSGVO)\n"
                  "- Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n"
                  "- Löschung Ihrer Daten (Art. 17 DSGVO)\n"
                  "- Einschränkung der Verarbeitung (Art. 18 DSGVO)\n"
                  "- Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n"
                  "- Datenübertragbarkeit (Art. 20 DSGVO)\n"
                  "Zur Ausübung Ihrer Rechte kontaktieren Sie uns bitte unter der oben angegebenen E-Mail-Adresse.\n\n"

                  "Mit Klick auf 'Akzeptieren' stimmen Sie der Verarbeitung Ihrer Daten gemäß dieser Datenschutzerklärung zu. "
                  "Wenn Sie 'Ablehnen' wählen, kann die Nutzung der App eingeschränkt sein.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onAccepted,
                  child: const Text("Akzeptieren"),
                ),
                OutlinedButton(
                  onPressed: onDeclined,
                  child: const Text("Ablehnen"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}