
import json
import os

pdf_keys = {
    "pdfCurrency": {
        "es": "Moneda",
        "en": "Currency",
        "pt": "Moeda",
        "fr": "Devise",
        "it": "Valuta",
        "de": "Währung",
        "default": "Currency"
    },
    "pdfRange": {
        "es": "Rango",
        "en": "Range",
        "pt": "Intervalo",
        "fr": "Intervalle",
        "it": "Intervallo",
        "de": "Bereich",
        "default": "Range"
    },
    "pdfDailyDetails": {
        "es": "Detalles Diarios (Crono. Inverso)",
        "en": "Daily Details (Reverse Chronological)",
        "pt": "Detalhes Diários (Crono. Inverso)",
        "fr": "Détails Quotidiens",
        "it": "Dettagli Giornalieri",
        "de": "Tägliche Details",
        "default": "Daily Details"
    },
    "pdfDate": {
        "es": "Fecha",
        "en": "Date",
        "pt": "Data",
        "fr": "Date",
        "it": "Data",
        "de": "Datum",
        "default": "Date"
    },
    "pdfRate": {
        "es": "Tasa (Bs)",
        "en": "Rate (Bs)",
        "pt": "Taxa (Bs)",
        "fr": "Taux (Bs)",
        "it": "Tasso (Bs)",
        "de": "Kurs (Bs)",
        "default": "Rate (Bs)"
    },
    "pdfChangePercent": {
        "es": "Cambio %",
        "en": "Change %",
        "pt": "Variação %",
        "fr": "Chang. %",
        "it": "Var. %",
        "de": "Änd. %",
        "default": "Change %"
    }
}

l10n_dir = "lib/l10n"

for filename in os.listdir(l10n_dir):
    if filename.endswith(".arb"):
        filepath = os.path.join(l10n_dir, filename)
        lang = filename.split("_")[1].split(".")[0]
        
        with open(filepath, "r", encoding="utf-8-sig") as f:
            data = json.load(f)
            
        modified = False
        for key, trans_map in pdf_keys.items():
            if key not in data:
                val = trans_map.get(lang, trans_map["default"])
                data[key] = val
                modified = True
                
        if modified:
            print(f"Updating {filename}...")
            with open(filepath, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
