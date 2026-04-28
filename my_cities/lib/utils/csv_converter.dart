import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:convert';
import 'dart:io';

// CsvConverter converte un file Excel (.xlsx) in CSV con ; come separatore.
// il punto e virgola evita conflitti con le virgole nelle coordinate
// e nei campi come "Bus 6, 9, 30"
class CsvConverter {
  // converte il file Excel al percorso indicato in un file CSV.
  // restituisce il percorso del file CSV generato,
  // oppure null se la conversione fallisce
  static Future<String?> converti(String percorsoXlsx) async {
    try {
      final file = File(percorsoXlsx);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      // SpreadsheetDecoder legge il file Excel senza crashare
      // su file generati da openpyxl o LibreOffice
      final decoder = SpreadsheetDecoder.decodeBytes(bytes);

      // prende il primo foglio del file
      final foglio = decoder.tables[decoder.tables.keys.first];
      if (foglio == null) return null;

      final buffer = StringBuffer();

      for (int r = 0; r < foglio.rows.length; r++) {
        final riga = foglio.rows[r];

        // salta righe completamente vuote
        if (riga.every((cella) => cella == null || cella.toString().isEmpty)) {
          continue;
        }

        // converte ogni cella in stringa pulita.
        // null diventa stringa vuota, i valori vengono trimmati
        final valori = riga.map((cella) {
          if (cella == null) return '';
          return cella.toString().trim();
        }).toList();

        // scrive la riga nel buffer con ; come separatore
        buffer.writeln(valori.join(';'));
      }

      // salva il CSV nella stessa cartella del file Excel
      // con lo stesso nome ma estensione .csv
      final percorsoCsv = percorsoXlsx.replaceAll('.xlsx', '.csv');
      final fileCsv = File(percorsoCsv);
      await fileCsv.writeAsString(buffer.toString(), encoding: utf8);

      return percorsoCsv;
    } catch (e) {
      print('ERRORE conversione: $e');
      return null;
    }
  }
}
