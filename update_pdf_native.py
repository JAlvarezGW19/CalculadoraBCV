
import json
import os

# Translations for the new PDF keys
translations = {
    "ar": {
        "pdfCurrency": "العملة",
        "pdfRange": "النطاق",
        "pdfDailyDetails": "التفاصيل اليومية",
        "pdfDate": "التاريخ",
        "pdfRate": "السعر (Bs)",
        "pdfChangePercent": "التغيير %"
    },
    "zh": {
        "pdfCurrency": "货币",
        "pdfRange": "范围",
        "pdfDailyDetails": "每日详情",
        "pdfDate": "日期",
        "pdfRate": "汇率 (Bs)",
        "pdfChangePercent": "涨跌 %"
    },
    "ja": {
        "pdfCurrency": "通貨",
        "pdfRange": "範囲",
        "pdfDailyDetails": "日次詳細",
        "pdfDate": "日付",
        "pdfRate": "レート (Bs)",
        "pdfChangePercent": "変動 %"
    },
    "ko": {
        "pdfCurrency": "통화",
        "pdfRange": "범위",
        "pdfDailyDetails": "일일 상세",
        "pdfDate": "날짜",
        "pdfRate": "환율 (Bs)",
        "pdfChangePercent": "변동 %"
    },
    "ru": {
        "pdfCurrency": "Валюта",
        "pdfRange": "Диапазон",
        "pdfDailyDetails": "Ежедневные детали",
        "pdfDate": "Дата",
        "pdfRate": "Курс (Bs)",
        "pdfChangePercent": "Изм. %"
    },
    "tr": {
        "pdfCurrency": "Para Birimi",
        "pdfRange": "Aralık",
        "pdfDailyDetails": "Günlük Detaylar",
        "pdfDate": "Tarih",
        "pdfRate": "Kur (Bs)",
        "pdfChangePercent": "Değişim %"
    },
    "vi": {
        "pdfCurrency": "Tiền tệ",
        "pdfRange": "Phạm vi",
        "pdfDailyDetails": "Chi tiết hàng ngày",
        "pdfDate": "Ngày",
        "pdfRate": "Tỷ giá (Bs)",
        "pdfChangePercent": "Thay đổi %"
    },
    "hi": {
        "pdfCurrency": "मुद्रा",
        "pdfRange": "श्रेणी",
        "pdfDailyDetails": "दैनिक विवरण",
        "pdfDate": "दिनांक",
        "pdfRate": "दर (Bs)",
        "pdfChangePercent": "परिवर्तन %"
    },
    "id": {
        "pdfCurrency": "Mata Uang",
        "pdfRange": "Rentang",
        "pdfDailyDetails": "Rincian Harian",
        "pdfDate": "Tanggal",
        "pdfRate": "Kurs (Bs)",
        "pdfChangePercent": "Perubahan %"
    }
}

l10n_dir = "lib/l10n"

for lang, keys in translations.items():
    filename = f"app_{lang}.arb"
    filepath = os.path.join(l10n_dir, filename)
    
    if os.path.exists(filepath):
        print(f"Updating {filename} with native translations...")
        try:
            with open(filepath, "r", encoding="utf-8-sig") as f:
                data = json.load(f)
            
            # Update keys
            for key, value in keys.items():
                data[key] = value
                
            with open(filepath, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                
        except Exception as e:
            print(f"Error updating {filename}: {e}")
