
import json
import os

# Data structure defining all strings for all languages
# Keys match the ARB keys.
# Values are dictionaries with language codes as keys.

languages = ['es', 'en', 'pt', 'fr', 'de', 'it', 'ru', 'zh', 'ja', 'ko', 'ar', 'hi', 'tr', 'id', 'vi']

translations = {
    "appTitle": {
        "es": "Calculadora BCV", "en": "BCV Calculator", "pt": "Calculadora BCV", "fr": "Calculatrice BCV", "de": "BCV Rechner", "it": "Calcolatrice BCV", "ru": "Калькулятор BCV", "zh": "BCV 计算器", "ja": "BCV電卓", "ko": "BCV 계산기", "ar": "حاسبة BCV", "hi": "BCV कैलकुलेटर", "tr": "BCV Hesap Makinesi", "id": "Kalkulator BCV", "vi": "Máy tính BCV"
    },
    "settings": {
        "es": "Ajustes", "en": "Settings", "pt": "Configurações", "fr": "Paramètres", "de": "Einstellungen", "it": "Impostazioni", "ru": "Настройки", "zh": "设置", "ja": "設定", "ko": "설정", "ar": "الإعدادات", "hi": "सेटिंग्स", "tr": "Ayarlar", "id": "Pengaturan", "vi": "Cài đặt"
    },
    "general": {
        "es": "General", "en": "General", "pt": "Geral", "fr": "Général", "de": "Allgemein", "it": "Generale", "ru": "Общие", "zh": "常规", "ja": "一般", "ko": "일반", "ar": "عام", "hi": "सामान्य", "tr": "Genel", "id": "Umum", "vi": "Chung"
    },
    "storageNetwork": {
        "es": "Almacenamiento y Red", "en": "Storage & Network", "pt": "Armazenamento e Rede", "fr": "Stockage et Réseau", "de": "Speicher & Netzwerk", "it": "Archiviazione e Rete", "ru": "Память и сеть", "zh": "存储与网络", "ja": "ストレージとネットワーク", "ko": "저장 공간 및 네트워크", "ar": "التخزين والشبكة", "hi": "भंडारण और नेटवर्क", "tr": "Depolama ve Ağ", "id": "Penyimpanan & Jaringan", "vi": "Lưu trữ & Mạng"
    },
    "storageNetworkSubtitle": {
        "es": "Gestionar caché y actualizaciones", "en": "Manage cache and updates", "pt": "Gerenciar cache e atualizações", "fr": "Gérer le cache et les mises à jour", "de": "Cache und Updates verwalten", "it": "Gestisci cache e aggiornamenti", "ru": "Управление кэшем и обновлениями", "zh": "管理缓存和更新", "ja": "キャッシュと更新の管理", "ko": "캐시 및 업데이트 관리", "ar": "إدارة التخزين المؤقت والتحديثات", "hi": "कैश और अपडेट प्रबंधित करें", "tr": "Önbelleği ve güncellemeleri yönet", "id": "Kelola cache dan pembaruan", "vi": "Quản lý bộ nhớ đệm và cập nhật"
    },
    "notifications": {
        "es": "Notificaciones", "en": "Notifications", "pt": "Notificações", "fr": "Notifications", "de": "Benachrichtigungen", "it": "Notifiche", "ru": "Уведомления", "zh": "通知", "ja": "通知", "ko": "알림", "ar": "إشعارات", "hi": "सूचनाएं", "tr": "Bildirimler", "id": "Notifikasi", "vi": "Thông báo"
    },
    "notificationsSubtitle": {
        "es": "Avisar cuando salga nueva tasa", "en": "Notify when new rate is available", "pt": "Avisar quando houver nova taxa", "fr": "Avertir quand un nouveau taux est disponible", "de": "Benachrichtigen bei neuem Kurs", "it": "Avvisa quando è disponibile un nuovo tasso", "ru": "Уведомлять о новом курсе", "zh": "新汇率可用时通知", "ja": "新しいレートが利用可能なときに通知", "ko": "새로운 환율이 나오면 알림", "ar": "إشعار عند توفر سعر جديد", "hi": "नई दर उपलब्ध होने पर सूचित करें", "tr": "Yeni oran mevcut olduğunda bildir", "id": "Beritahu saat kurs baru tersedia", "vi": "Thông báo khi có tỷ giá mới"
    },
    "language": {
        "es": "Idioma", "en": "Language", "pt": "Idioma", "fr": "Langue", "de": "Sprache", "it": "Lingua", "ru": "Язык", "zh": "语言", "ja": "言語", "ko": "언어", "ar": "اللغة", "hi": "भाषा", "tr": "Dil", "id": "Bahasa", "vi": "Ngôn ngữ"
    },
     "systemDefault": {
        "es": "Predeterminado del sistema", "en": "System Default", "pt": "Padrão do sistema", "fr": "Défaut du système", "de": "Systemstandard", "it": "Predefinito di sistema", "ru": "Системный по умолчанию", "zh": "系统默认", "ja": "システムデフォルト", "ko": "시스템 기본값", "ar": "الافتراضي للنظام", "hi": "सिस्टम डिफ़ॉल्ट", "tr": "Sistem Varsayılanı", "id": "Default Sistem", "vi": "Mặc định hệ thống"
    },
    "information": {
        "es": "Información", "en": "Information", "pt": "Informações", "fr": "Information", "de": "Informationen", "it": "Informazioni", "ru": "Информация", "zh": "信息", "ja": "情報", "ko": "정보", "ar": "معلومات", "hi": "जानकारी", "tr": "Bilgi", "id": "Informasi", "vi": "Thông tin"
    },
    "aboutApp": {
        "es": "Acerca de la App", "en": "About the App", "pt": "Sobre o App", "fr": "À propos de l'application", "de": "Über die App", "it": "Informazioni sull'App", "ru": "О приложении", "zh": "关于应用", "ja": "アプリについて", "ko": "앱 정보", "ar": "حول التطبيق", "hi": "ऐप के बारे में", "tr": "Uygulama Hakkında", "id": "Tentang Aplikasi", "vi": "Về ứng dụng"
    },
    "aboutAppSubtitle": {
        "es": "Versión, desarrollador y licencias", "en": "Version, developer and licenses", "pt": "Versão, desenvolvedor e licenças", "fr": "Version, développeur et licences", "de": "Version, Entwickler und Lizenzen", "it": "Versione, sviluppatore e licenze", "ru": "Версия, разработчик и лицензии", "zh": "版本、开发者和许可", "ja": "バージョン、開発者、ライセンス", "ko": "버전, 개발자 및 라이선스", "ar": "الإصدار، المطور والتراخيص", "hi": "संस्करण, डेवलपर और लाइसेंस", "tr": "Sürüm, geliştirici ve lisanslar", "id": "Versi, pengembang, dan lisensi", "vi": "Phiên bản, nhà phát triển và giấy phép"
    },
    "forceUpdate": {
        "es": "Forzar Actualización", "en": "Force Update", "pt": "Forçar Atualização", "fr": "Forcer la mise à jour", "de": "Update erzwingen", "it": "Forza Aggiornamento", "ru": "Обновить принудительно", "zh": "强制更新", "ja": "強制更新", "ko": "강제 업데이트", "ar": "فرض التحديث", "hi": "अपडेट के लिए बाध्य करें", "tr": "Güncellemeyi Zorla", "id": "Paksa Pembaruan", "vi": "Bắt buộc cập nhật"
    },
    "forceUpdateSubtitle": {
        "es": "Actualizar tasas desde la API", "en": "Update rates from API", "pt": "Atualizar taxas da API", "fr": "Mettre à jour les taux depuis l'API", "de": "Kurse von API aktualisieren", "it": "Aggiorna tassi dall'API", "ru": "Обновить курсы через API", "zh": "从 API 更新汇率", "ja": "APIからレートを更新", "ko": "API에서 환율 업데이트", "ar": "تحديث الأسعار من API", "hi": "API से दरें अपडेट करें", "tr": "Oranları API'den güncelle", "id": "Perbarui nilai tukar dari API", "vi": "Cập nhật tỷ giá từ API"
    },
    "clearCache": {
        "es": "Borrar Caché", "en": "Clear Cache", "pt": "Limpar Cache", "fr": "Vider le cache", "de": "Cache leeren", "it": "Cancella Cache", "ru": "Очистить кэш", "zh": "清除缓存", "ja": "キャッシュをクリア", "ko": "캐시 지우기", "ar": "مسح التخزين المؤقت", "hi": "कैश साफ़ करें", "tr": "Önbelleği Temizle", "id": "Hapus Cache", "vi": "Xóa bộ nhớ đệm"
    },
    "clearCacheSubtitle": {
        "es": "Eliminar datos guardados localmente", "en": "Delete locally stored data", "pt": "Excluir dados armazenados localmente", "fr": "Supprimer les données locales", "de": "Lokal gespeicherte Daten löschen", "it": "Elimina dati salvati localmente", "ru": "Удалить локальные данные", "zh": "删除本地存储的数据", "ja": "ローカルデータを削除", "ko": "로컬 데이터 삭제", "ar": "حذف البيانات المحفوظة محليًا", "hi": "स्थानीय रूप से सहेजा गया डेटा हटाएं", "tr": "Yerel verileri sil", "id": "Hapus data yang tersimpan secara lokal", "vi": "Xóa dữ liệu được lưu trữ cục bộ"
    },
    "cancel": {
        "es": "Cancelar", "en": "Cancel", "pt": "Cancelar", "fr": "Annuler", "de": "Abbrechen", "it": "Annulla", "ru": "Отмена", "zh": "取消", "ja": "キャンセル", "ko": "취소", "ar": "إلغاء", "hi": "रद्द करें", "tr": "İptal", "id": "Batal", "vi": "Hủy"
    },
    "close": {
        "es": "Cerrar", "en": "Close", "pt": "Fechar", "fr": "Fermer", "de": "Schließen", "it": "Chiudi", "ru": "Закрыть", "zh": "关闭", "ja": "閉じる", "ko": "닫기", "ar": "إغلاق", "hi": "बंद करें", "tr": "Kapat", "id": "Tutup", "vi": "Đóng"
    },
    "updatingRates": {
        "es": "Actualizando tasas...", "en": "Updating rates...", "pt": "Atualizando taxas...", "fr": "Mise à jour des taux...", "de": "Kurse werden aktualisiert...", "it": "Aggiornamento tassi...", "ru": "Обновление курсов...", "zh": "正在更新汇率...", "ja": "レートを更新中...", "ko": "환율 업데이트 중...", "ar": "جاري تحديث الأسعار...", "hi": "दरें अपडेट हो रही हैं...", "tr": "Oranlar güncelleniyor...", "id": "Memperbarui nilai tukar...", "vi": "Đang cập nhật tỷ giá..."
    },
    "cacheCleared": {
        "es": "Caché eliminada", "en": "Cache cleared", "pt": "Cache limpo", "fr": "Cache vidé", "de": "Cache geleert", "it": "Cache cancellata", "ru": "Кэш очищен", "zh": "缓存已清除", "ja": "キャッシュを消去しました", "ko": "캐시 삭제됨", "ar": "تم مسح الذاكرة المؤقتة", "hi": "कैश साफ़ किया गया", "tr": "Önbellek temizlendi", "id": "Cache dihapus", "vi": "Đã xóa bộ nhớ đệm"
    },
    "developer": {
        "es": "Desarrollador", "en": "Developer", "pt": "Desenvolvedor", "fr": "Développeur", "de": "Entwickler", "it": "Sviluppatore", "ru": "Разработчик", "zh": "开发者", "ja": "開発者", "ko": "개발자", "ar": "المطور", "hi": "डेवलपर", "tr": "Geliştirici", "id": "Pengembang", "vi": "Nhà phát triển"
    },
    "dataSource": {
        "es": "Fuente de Datos", "en": "Data Source", "pt": "Fonte de Dados", "fr": "Source de données", "de": "Datenquelle", "it": "Fonte Dati", "ru": "Источник данных", "zh": "数据来源", "ja": "データソース", "ko": "데이터 출처", "ar": "مصدر البيانات", "hi": "डेटा स्रोत", "tr": "Veri Kaynağı", "id": "Sumber Data", "vi": "Nguồn dữ liệu"
    },
    "legalNotice": {
        "es": "Aviso Legal", "en": "Legal Notice", "pt": "Aviso Legal", "fr": "Mentions légales", "de": "Rechtliche Hinweise", "it": "Avviso Legale", "ru": "Правовое уведомление", "zh": "法律声明", "ja": "法的通知", "ko": "법적 고지", "ar": "إشعار قانوني", "hi": "कानूनी नोटिस", "tr": "Yasal Uyarı", "id": "Pemberitahuan Hukum", "vi": "Thông báo pháp lý"
    },
    "legalNoticeText": {
        "es": "Esta aplicación NO representa a ninguna entidad gubernamental ni bancaria. No tenemos afiliación con el Banco Central de Venezuela. Los datos son obtenidos a través de una API que consulta la página oficial del BCV. El uso de la información es responsabilidad exclusiva del usuario.",
        "en": "This application does NOT represent any government or banking entity. We are not affiliated with the Central Bank of Venezuela. Data is obtained via an API querying the official BCV website. Use of information is the sole responsibility of the user.",
        "pt": "Este aplicativo NÃO representa nenhuma entidade governamental ou bancária. Não temos afiliação com o Banco Central da Venezuela. Os dados são obtidos por meio de uma API que consulta o site oficial do BCV. O uso das informações é de responsabilidade exclusiva do usuário.",
        "fr": "Cette application ne représente AUCUNE entité gouvernementale ou bancaire. Nous ne sommes pas affiliés à la Banque Centrale du Venezuela. Les données sont obtenues via une API interrogeant le site officiel de la BCV. L'utilisation des informations relève de la seule responsabilité de l'utilisateur.",
        "de": "Diese App vertritt KEINE Regierungs- oder Bankbehörde. Wir sind nicht mit der Zentralbank von Venezuela verbunden. Die Daten werden über eine API abgerufen, die die offizielle BCV-Website abfragt. Die Nutzung der Informationen liegt in der alleinigen Verantwortung des Benutzers.",
        "it": "Questa applicazione NON rappresenta alcuna entità governativa o bancaria. Non siamo affiliati alla Banca Centrale del Venezuela. I dati sono ottenuti tramite un'API che consulta il sito ufficiale della BCV. L'uso delle informazioni è di esclusiva responsabilità dell'utente.",
        "ru": "Это приложение НЕ представляет собой государственную или банковскую структуру. Мы не связаны с Центральным банком Венесуэлы. Данные получены через API с официального сайта BCV. Ответственность за использование информации лежит на пользователе.",
        "zh": "此应用程序不代表任何政府或银行实体。我们与委内瑞拉中央银行没有关联。数据通过查询 BCV 官方网站的 API 获取。信息的使用由用户自行承担责任。",
        "ja": "このアプリケーションは政府や銀行機関を代表するものではありません。ベネズエラ中央銀行（BCV）とは提携していません。データはBCV公式サイトを照会するAPIを通じて取得されます。情報の利用はユーザー自身の責任となります。",
        "ko": "이 애플리케이션은 정부나 은행 기관을 대표하지 않습니다. 베네수엘라 중앙은행(BCV)과 제휴하지 않았습니다. 데이터는 BCV 공식 웹사이트를 조회하는 API를 통해 얻습니다. 정보 사용에 대한 책임은 사용자에게 있습니다.",
        "ar": "هذا التطبيق لا يمثل أي جهة حكومية أو مصرفية. ليس لدينا أي ارتباط بالبنك المركزي الفنزويلي. يتم الحصول على البيانات عبر API تستعلم من موقع BCV الرسمي. استخدام المعلومات هو مسؤولية المستخدم وحده.",
        "hi": "यह एप्लिकेशन किसी भी सरकारी या बैंकिंग इकाई का प्रतिनिधित्व नहीं करता है। हमारा वेनेजुएला के केंद्रीय बैंक (BCV) से कोई संबंध नहीं है। डेटा एक API के माध्यम से प्राप्त किया जाता है जो आधिकारिक BCV वेबसाइट से पूछताछ करता है। जानकारी का उपयोग पूरी तरह से उपयोगकर्ता की जिम्मेदारी है।",
        "tr": "Bu uygulama herhangi bir devlet veya banka kurumunu temsil ETMEMEKTEDİR. Venezuela Merkez Bankası (BCV) ile bir bağlantımız yoktur. Veriler, resmi BCV web sitesini sorgulayan bir API aracılığıyla elde edilir. Bilgilerin kullanımı tamamen kullanıcının sorumluluğundadır.",
        "id": "Aplikasi ini TIDAK mewakili entitas pemerintah atau perbankan mana pun. Kami tidak berafiliasi dengan Bank Sentral Venezuela. Data diperoleh melalui API yang menanyakan situs web resmi BCV. Penggunaan informasi sepenuhnya merupakan tanggung jawab pengguna.",
        "vi": "Ứng dụng này KHÔNG đại diện cho bất kỳ tổ chức chính phủ hoặc ngân hàng nào. Chúng tôi không liên kết với Ngân hàng Trung ương Venezuela. Dữ liệu được lấy thông qua API truy vấn trang web chính thức của BCV. Việc sử dụng thông tin hoàn toàn là trách nhiệm của người dùng."
    },
    "openSourceLicenses": {
        "es": "Licencias de Código Abierto", "en": "Open Source Licenses", "pt": "Licenças de Código Aberto", "fr": "Licences Open Source", "de": "Open-Source-Lizenzen", "it": "Licenze Open Source", "ru": "Лицензии ПО", "zh": "开源许可证", "ja": "オープンソースライセンス", "ko": "오픈 소스 라이선스", "ar": "تراخيص المصدر المفتوح", "hi": "ओपन सोर्स लाइसेंस", "tr": "Açık Kaynak Lisansları", "id": "Lisensi Sumber Terbuka", "vi": "Giấy phép mã nguồn mở"
    },
    "version": {
        "es": "Versión", "en": "Version", "pt": "Versão", "fr": "Version", "de": "Version", "it": "Versione", "ru": "Версия", "zh": "版本", "ja": "バージョン", "ko": "버전", "ar": "الإصدار", "hi": "संस्करण", "tr": "Sürüm", "id": "Versi", "vi": "Phiên bản"
    },
    "becomePro": {
        "es": "¡Conviértete en usuario PRO!", "en": "Become a PRO user!", "pt": "Torne-se PRO!", "fr": "Devenez utilisateur PRO !", "de": "Werde PRO!", "it": "Diventa PRO!", "ru": "Стать PRO!", "zh": "成为 PRO 用户！", "ja": "PROユーザーになろう！", "ko": "PRO 사용자가 되세요!", "ar": "كن مستخدم PRO!", "hi": "PRO उपयोगकर्ता बनें!", "tr": "PRO Olun!", "id": "Dapatkan PRO!", "vi": "Trở thành người dùng PRO!"
    },
    "proUser": {
        "es": "¡Eres Usuario PRO!", "en": "You are a PRO User!", "pt": "Você é um Usuário PRO!", "fr": "Vous êtes utilisateur PRO !", "de": "Du bist ein PRO-Benutzer!", "it": "Sei un Utente PRO!", "ru": "Вы PRO пользователь!", "zh": "您是 PRO 用户！", "ja": "あなたはPROユーザーです！", "ko": "당신은 PRO 사용자입니다!", "ar": "أنت مستخدم PRO!", "hi": "आप एक PRO उपयोगकर्ता हैं!", "tr": "PRO Kullanıcısısınız!", "id": "Anda Pengguna PRO!", "vi": "Bạn là người dùng PRO!"
    },
    "getPro": {
        "es": "Obtener PRO por", "en": "Get PRO for", "pt": "Obter PRO por", "fr": "Obtenir PRO pour", "de": "PRO holen für", "it": "Ottieni PRO per", "ru": "Купить PRO за", "zh": "获取 PRO 仅需", "ja": "PROを入手：", "ko": "PRO 구매:", "ar": "احصل على PRO بـ", "hi": "PRO प्राप्त करें", "tr": "PRO Satın Al:", "id": "Dapatkan PRO seharga", "vi": "Nhận PRO với giá"
    },
    "oneTimePayment": {
        "es": "(Pago único de por vida)", "en": "(Lifetime one-time payment)", "pt": "(Pagamento único vitalício)", "fr": "(Paiement unique à vie)", "de": "(Einmalige Zahlung auf Lebenszeit)", "it": "(Pagamento unico a vita)", "ru": "(Единовременный платеж)", "zh": "（终身一次性付款）", "ja": "（生涯一度限りの支払い）", "ko": "(평생 일회성 결제)", "ar": "(دفع لمرة واحدة مدى الحياة)", "hi": "(जीवन भर के लिए एक बार का भुगतान)", "tr": "(Ömür boyu tek seferlik ödeme)", "id": "(Pembayaran satu kali seumur hidup)", "vi": "(Thanh toán một lần trọn đời)"
    },
    "restorePurchases": {
        "es": "Restaurar Compras", "en": "Restore Purchases", "pt": "Restaurar Compras", "fr": "Restaurer les achats", "de": "Einkäufe wiederherstellen", "it": "Ripristina Acquisti", "ru": "Восстановить", "zh": "恢复购买", "ja": "購入を復元", "ko": "구매 복원", "ar": "استعادة المشتريات", "hi": "खरीदारी पुनर्स्थापित करें", "tr": "Satın Alımları Geri Yükle", "id": "Pulihkan Pembelian", "vi": "Khôi phục mua hàng"
    },
    "benefitAds": {
        "es": "Adiós a la publicidad", "en": "No Ads", "pt": "Sem anúncios", "fr": "Pas de publicité", "de": "Keine Werbung", "it": "Niente pubblicità", "ru": "Без рекламы", "zh": "无广告", "ja": "広告なし", "ko": "광고 없음", "ar": "بدون إعلانات", "hi": "कोई विज्ञापन नहीं", "tr": "Reklamsız", "id": "Tanpa Iklan", "vi": "Không quảng cáo"
    },
    "benefitAdsDesc": {
        "es": "Disfruta de una interfaz limpia y sin interrupciones.", "en": "Enjoy a clean, interruption-free interface.", "pt": "Desfrute de uma interface limpa e sem interrupções.", "fr": "Profitez d'une interface propre et sans interruption.", "de": "Genieße eine saubere Oberfläche ohne Unterbrechungen.", "it": "Goditi un'interfaccia pulita e senza interruzioni.", "ru": "Чистый интерфейс без отвлекающих факторов.", "zh": "享受干净无干扰的界面。", "ja": "中断のないクリーンなインターフェースをお楽しみください。", "ko": "방해 없는 깔끔한 인터페이스를 즐기세요.", "ar": "استمتع بواجهة نظيفة وبدون انقطاع.", "hi": "बिना किसी रुकावट के एक साफ़ इंटरफ़ेस का आनंद लें।", "tr": "Kesintisiz ve temiz bir arayüzün keyfini çıkarın.", "id": "Nikmati antarmuka yang bersih tanpa gangguan.", "vi": "Tận hưởng giao diện sạch sẽ không bị gián đoạn."
    },
    "benefitPdf": {
        "es": "Exportación Instantánea", "en": "Instant Export", "pt": "Exportação Instantânea", "fr": "Exportation instantanée", "de": "Sofortiger Export", "it": "Esportazione Istantanea", "ru": "Мгновенный экспорт", "zh": "即时导出", "ja": "即時エクスポート", "ko": "즉시 내보내기", "ar": "تصدير فوري", "hi": "तत्काल निर्यात", "tr": "Anında Dışa Aktar", "id": "Ekspor Instan", "vi": "Xuất ngay lập tức"
    },
    "benefitPdfDesc": {
        "es": "Genera PDFs de tu historial sin ver anuncios de video.", "en": "Generate history PDFs without watching video ads.", "pt": "Gere PDFs do seu histórico sem assistir anúncios.", "fr": "Générez des PDF d'historique sans regarder de pubs vidéo.", "de": "Erstelle Verlauf-PDFs ohne Videoanzeigen.", "it": "Genera PDF della cronologia senza guardare video pubblicitari.", "ru": "PDF без просмотра видеорекламы.", "zh": "无需观看视频广告即可生成历史 PDF。", "ja": "動画広告を見ずに履歴PDFを作成できます。", "ko": "동영상 광고 시청 없이 기록 PDF를 생성하세요.", "ar": "أنشئ تقارير PDF للسجل دون مشاهدة إعلانات الفيديو.", "hi": "वीडियो विज्ञापन देखे बिना इतिहास PDF बनाएं।", "tr": "Video reklam izlemeden geçmiş PDF'leri oluşturun.", "id": "Buat PDF riwayat tanpa menonton iklan video.", "vi": "Tạo PDF lịch sử mà không cần xem quảng cáo video."
    },
    "benefitSpeed": {
        "es": "Máxima Velocidad", "en": "Max Speed", "pt": "Velocidade Máxima", "fr": "Vitesse maximale", "de": "Maximale Geschwindigkeit", "it": "Massima Velocità", "ru": "Макс. скорость", "zh": "极速体验", "ja": "最高速度", "ko": "최고 속도", "ar": "سرعة قصوى", "hi": "अधिकतम गति", "tr": "Maksimum Hız", "id": "Kecepatan Maksimum", "vi": "Tốc độ tối đa"
    },
    "benefitSpeedDesc": {
        "es": "Navegación más fluida y menor consumo de batería.", "en": "Smoother navigation and lower battery consumption.", "pt": "Navegação mais fluida e menor consumo de bateria.", "fr": "Navigation plus fluide et consommation réduite.", "de": "Flüssigere Navigation und weniger Batterieverbrauch.", "it": "Navigazione più fluida e minor consumo di batteria.", "ru": "Плавная навигация и экономия заряда.", "zh": "更流畅的导航和更低的电池消耗。", "ja": "よりスムーズな操作とバッテリー消費の削減。", "ko": "더 부드러운 탐색과 배터리 소모 감소.", "ar": "تصفح أكثر سلاسة واستهلاك أقل للبطارية.", "hi": "बेहतर नेविगेशन और कम बैटरी खपत।", "tr": "Daha akıcı gezinme ve daha az pil tüketimi.", "id": "Navigasi lebih lancar dan konsumsi baterai lebih sedikit.", "vi": "Điều hướng mượt mà hơn và tiêu thụ ít pin hơn."
    },
    "benefitSupport": {
        "es": "Apoya el proyecto", "en": "Support the project", "pt": "Apoie o projeto", "fr": "Soutenir le projet", "de": "Projekt unterstützen", "it": "Supporta il progetto", "ru": "Поддержать проект", "zh": "支持项目", "ja": "プロジェクトを支援", "ko": "프로젝트 후원", "ar": "ادعم المشروع", "hi": "परियोजना का समर्थन करें", "tr": "Projeyi Destekle", "id": "Dukung Proyek", "vi": "Hỗ trợ dự án"
    },
    "benefitSupportDesc": {
        "es": "Ayúdanos a seguir mejorando la herramienta.", "en": "Help us continue improving the tool.", "pt": "Ajude-nos a continuar melhorando a ferramenta.", "fr": "Aidez-nous à continuer d'améliorer l'outil.", "de": "Hilf uns, das Tool weiter zu verbessern.", "it": "Aiutaci a continuare a migliorare lo strumento.", "ru": "Помогите нам улучшать инструмент.", "zh": "帮助我们持续改进工具。", "ja": "ツールの改善にご協力ください。", "ko": "도구를 지속적으로 개선할 수 있도록 도와주세요.", "ar": "ساعدنا في مواصلة تحسين الأداة.", "hi": "हमें टूल को बेहतर बनाने में मदद करें।", "tr": "Aracı geliştirmeye devam etmemize yardımcı olun.", "id": "Bantu kami terus meningkatkan alat ini.", "vi": "Giúp chúng tôi tiếp tục cải thiện công cụ."
    },
    "usd": {
        "es": "Dólares", "en": "Dollars", "pt": "Dólares", "fr": "Dollars", "de": "Dollar", "it": "Dollari", "ru": "Доллары", "zh": "美元", "ja": "ドル", "ko": "달러", "ar": "دولار", "hi": "डॉलर", "tr": "Dolar", "id": "Dolar", "vi": "Đô la"
    },
    "eur": {
        "es": "Euros", "en": "Euros", "pt": "Euros", "fr": "Euros", "de": "Euro", "it": "Euro", "ru": "Евро", "zh": "欧元", "ja": "ユーロ", "ko": "유로", "ar": "يورو", "hi": "यूरो", "tr": "Euro", "id": "Euro", "vi": "Euro"
    },
    "ves": {
        "es": "Bolívares", "en": "Bolivars", "pt": "Bolívares", "fr": "Bolivars", "de": "Bolivar", "it": "Bolivar", "ru": "Боливары", "zh": "玻利瓦尔", "ja": "ボリバル", "ko": "볼리바르", "ar": "بوليفار", "hi": "बोलिवर", "tr": "Bolivar", "id": "Bolivar", "vi": "Bolivar"
    },
    "history": {
        "es": "Historial", "en": "History", "pt": "Histórico", "fr": "Historique", "de": "Verlauf", "it": "Cronologia", "ru": "История", "zh": "历史记录", "ja": "履歴", "ko": "기록", "ar": "السجل", "hi": "इतिहास", "tr": "Geçmiş", "id": "Riwayat", "vi": "Lịch sử"
    },
    "historyRates": {
        "es": "Historial de Tasas", "en": "Rate History", "pt": "Histórico de Taxas", "fr": "Historique des taux", "de": "Kursverlauf", "it": "Cronologia Tassi", "ru": "История курсов", "zh": "汇率历史", "ja": "レート履歴", "ko": "환율 기록", "ar": "سجل الأسعار", "hi": "दर इतिहास", "tr": "Oran Geçmişi", "id": "Riwayat Nilai Tukar", "vi": "Lịch sử tỷ giá"
    },
    "start": {
        "es": "Inicio", "en": "Start", "pt": "Início", "fr": "Début", "de": "Start", "it": "Inizio", "ru": "Начало", "zh": "开始", "ja": "開始", "ko": "시작", "ar": "البداية", "hi": "प्रारंभ", "tr": "Başlangıç", "id": "Mulai", "vi": "Bắt đầu"
    },
    "end": {
        "es": "Fin", "en": "End", "pt": "Fim", "fr": "Fin", "de": "Ende", "it": "Fine", "ru": "Конец", "zh": "结束", "ja": "終了", "ko": "종료", "ar": "النهاية", "hi": "अंत", "tr": "Bitiş", "id": "Selesai", "vi": "Kết thúc"
    },
    "generatePdf": {
        "es": "Generar PDF", "en": "Generate PDF", "pt": "Gerar PDF", "fr": "Générer PDF", "de": "PDF generieren", "it": "Genera PDF", "ru": "Создать PDF", "zh": "生成 PDF", "ja": "PDF生成", "ko": "PDF 생성", "ar": "إنشاء PDF", "hi": "PDF उत्पन्न करें", "tr": "PDF Oluştur", "id": "Buat PDF", "vi": "Tạo PDF"
    },
    "watchAd": {
        "es": "Ver anuncio para desbloquear", "en": "Watch ad to unlock", "pt": "Assista ao anúncio para desbloquear", "fr": "Regarder une pub pour débloquer", "de": "Werbung ansehen zum Entsperren", "it": "Guarda pubblicità per sbloccare", "ru": "Смотреть рекламу для разблокировки", "zh": "观看广告以解锁", "ja": "広告を見てロック解除", "ko": "광고 보고 잠금 해제", "ar": "شاهد إعلان لفتح الميزة", "hi": "अनलॉक करने के लिए विज्ञापन देखें", "tr": "Kilidi açmak için reklam izle", "id": "Tonton iklan untuk membuka", "vi": "Xem quảng cáo để mở khóa"
    },
    "loadingAd": {
        "es": "Cargando anuncio...", "en": "Loading ad...", "pt": "Carregando anúncio...", "fr": "Chargement de la publicité...", "de": "Werbung lädt...", "it": "Caricamento pubblicità...", "ru": "Загрузка...", "zh": "加载广告中...", "ja": "広告読み込み中...", "ko": "광고 로딩 중...", "ar": "جاري تحميل الإعلان...", "hi": "विज्ञापन लोड हो रहा है...", "tr": "Reklam yükleniyor...", "id": "Memuat iklan...", "vi": "Đang tải quảng cáo..."
    },
    "errorAd": {
        "es": "Error al cargar anuncio", "en": "Error loading ad", "pt": "Erro ao carregar anúncio", "fr": "Erreur de chargement", "de": "Fehler beim Laden", "it": "Errore caricamento", "ru": "Ошибка", "zh": "加载错误", "ja": "読み込みエラー", "ko": "로딩 오류", "ar": "خطأ في التحميل", "hi": "लोड करने में त्रुटि", "tr": "Yükleme hatası", "id": "Kesalahan memuat", "vi": "Lỗi tải"
    },
    "today": {
        "es": "Hoy", "en": "Today", "pt": "Hoje", "fr": "Aujourd'hui", "de": "Heute", "it": "Oggi", "ru": "Сегодня", "zh": "今天", "ja": "今日", "ko": "오늘", "ar": "اليوم", "hi": "आज", "tr": "Bugün", "id": "Hari Ini", "vi": "Hôm nay"
    },
    "tomorrow": {
        "es": "Mañana", "en": "Tomorrow", "pt": "Amanhã", "fr": "Demain", "de": "Morgen", "it": "Domani", "ru": "Завтра", "zh": "明天", "ja": "明日", "ko": "내일", "ar": "غداً", "hi": "कल", "tr": "Yarın", "id": "Besok", "vi": "Ngày mai"
    },
    "officialRate": {
        "es": "Tasa Oficial", "en": "Official Rate", "pt": "Taxa Oficial", "fr": "Taux Officiel", "de": "Offizieller Kurs", "it": "Tasso Ufficiale", "ru": "Офиц. курс", "zh": "官方汇率", "ja": "公式レート", "ko": "공식 환율", "ar": "السعر الرسمي", "hi": "आधिकारिक दर", "tr": "Resmi Kur", "id": "Kurs Resmi", "vi": "Tỷ giá chính thức"
    },
    "customRate": {
        "es": "Tasa Personalizada", "en": "Custom Rate", "pt": "Taxa Personalizada", "fr": "Taux Personnalisé", "de": "Benutzerdef. Kurs", "it": "Tasso Personalizzato", "ru": "Свой курс", "zh": "自定义汇率", "ja": "カスタムレート", "ko": "사용자 지정 환율", "ar": "سعر مخصص", "hi": "कस्टम दर", "tr": "Özel Kur", "id": "Kurs Kustom", "vi": "Tỷ giá tùy chỉnh"
    },
    "convert": {
        "es": "Convertir", "en": "Convert", "pt": "Converter", "fr": "Convertir", "de": "Konvertieren", "it": "Convertire", "ru": "Конвертировать", "zh": "转换", "ja": "変換", "ko": "변환", "ar": "تحويل", "hi": "परिवर्तित करें", "tr": "Dönüştür", "id": "Konversi", "vi": "Chuyển đổi"
    },
    
    # NEW KEYS
    "priceScanner": {
        "es": "Escáner de Precios", "en": "Price Scanner", "pt": "Scanner de Preços", "fr": "Scanner de prix", "de": "Preisscanner", "it": "Scanner Prezzi", "ru": "Сканер цен", "zh": "价格扫描仪", "ja": "価格スキャナー", "ko": "가격 스캐너", "ar": "ماسح الأسعار", "hi": "मूल्य स्कैनर", "tr": "Fiyat Tarayıcı", "id": "Pemindai Harga", "vi": "Máy quét giá"
    },
    "cameraPermissionText": {
        "es": "Esta herramienta utiliza la cámara para detectar precios y convertirlos en tiempo real.\n\nPara funcionar, necesita acceso a la Cámara y a la Galería (para seleccionar imágenes).",
        "en": "This tool uses the camera to detect prices and convert them in real time.\n\nTo function, it needs access to Camera and Gallery (to pick images).",
        "pt": "Esta ferramenta usa a câmera para detectar preços e convertê-los em tempo real.\n\nRequer acesso à Câmera e Galeria.",
        "fr": "Cet outil utilise la caméra pour détecter les prix et les convertir en temps réel.\n\nNécessite l'accès à la caméra et à la galerie.",
        "de": "Dieses Tool nutzt die Kamera, um Preise zu erkennen und umzurechnen.\n\nBenötigt Zugriff auf Kamera und Galerie.",
        "it": "Questo strumento usa la fotocamera per rilevare i prezzi e convertirli in tempo reale.\n\nRichiede accesso a Fotocamera e Galleria.",
        "ru": "Этот инструмент использует камеру для определения цен и конвертации.\n\nТребуется доступ к камере и галерее.",
        "zh": "此工具使用相机检测价格并实时转换。\n\n需要相机和图库访问权限。",
        "ja": "このツールはカメラを使用して価格を検出し、リアルタイムで変換します。\n\nカメラとギャラリーへのアクセスが必要です。",
        "ko": "이 도구는 카메라를 사용하여 가격을 감지하고 실시간으로 변환합니다.\n\n카메라 및 갤러리 액세스가 필요합니다.",
        "ar": "تستخدم هذه الأداة الكاميرا لاكتشاف الأسعار وتحويلها في الوقت الفعلي.\n\nيتطلب الوصول إلى الكاميرا والمعرض.",
        "hi": "यह टूल कीमतों का पता लगाने के लिए कैमरे का उपयोग करता है।\n\nकैमरा और गैलरी तक पहुंच की आवश्यकता है।",
        "tr": "Bu araç fiyatları algılamak ve dönüştürmek için kamerayı kullanır.\n\nKamera ve Galeri erişimi gerekir.",
        "id": "Alat ini menggunakan kamera untuk mendeteksi harga dan mengonversinya.\n\nMemerlukan akses Kamera dan Galeri.",
        "vi": "Công cụ này sử dụng camera để phát hiện giá và chuyển đổi.\n\nCần quyền truy cập Camera và Thư viện."
    },
     "allowAndContinue": {
        "es": "Permitir y Continuar", "en": "Allow and Continue", "pt": "Permitir e Continuar", "fr": "Autoriser et continuer", "de": "Erlauben und fortfahren", "it": "Consenti e Continua", "ru": "Разрешить и продолжить", "zh": "允许并继续", "ja": "許可して続行", "ko": "허용 및 계속", "ar": "سماح ومتابعة", "hi": "अनुमति दें और जारी रखें", "tr": "İzin Ver ve Devam Et", "id": "Izinkan dan Lanjutkan", "vi": "Cho phép và Tiếp tục"
    },
    "whatToScan": {
        "es": "¿Qué vas a escanear?", "en": "What will you scan?", "pt": "O que você vai escanear?", "fr": "Que allez-vous scanner?", "de": "Was möchtest du scannen?", "it": "Cosa vuoi scansionare?", "ru": "Что сканируем?", "zh": "你要扫描什么？", "ja": "何をスキャンしますか？", "ko": "무엇을 스캔하시겠습니까?", "ar": "ماذا ستمسح ضوئيًا؟", "hi": "आप क्या स्कैन करेंगे?", "tr": "Ne tarayacaksınız?", "id": "Apa yang akan Anda pindai?", "vi": "Bạn sẽ quét gì?"
    },
    "amountUsd": {
        "es": "Monto USD", "en": "Amount USD", "pt": "Valor USD", "fr": "Montant USD", "de": "Betrag USD", "it": "Importo USD", "ru": "Сумма USD", "zh": "USD 金额", "ja": "USD金額", "ko": "USD 금액", "ar": "مبلغ دولار", "hi": "USD राशि", "tr": "USD Tutarı", "id": "Jumlah USD", "vi": "Số tiền USD"
    },
    "amountEur": {
        "es": "Monto EUR", "en": "Amount EUR", "pt": "Valor EUR", "fr": "Montant EUR", "de": "Betrag EUR", "it": "Importo EUR", "ru": "Сумма EUR", "zh": "EUR 金额", "ja": "EUR金額", "ko": "EUR 금액", "ar": "مبلغ يورو", "hi": "EUR राशि", "tr": "EUR Tutarı", "id": "Jumlah EUR", "vi": "Số tiền EUR"
    },
    "amountVes": {
        "es": "Monto Bs.", "en": "Amount Bs.", "pt": "Valor Bs.", "fr": "Montant Bs.", "de": "Betrag Bs.", "it": "Importo Bs.", "ru": "Сумма Bs.", "zh": "Bs. 金额", "ja": "Bs.金額", "ko": "Bs. 금액", "ar": "مبلغ بوليفار", "hi": "Bs. राशि", "tr": "Bs. Tutarı", "id": "Jumlah Bs.", "vi": "Số tiền Bs."
    },
     "ratePers": {
        "es": "Tasa Pers.", "en": "Cust. Rate", "pt": "Taxa Pers.", "fr": "Taux Pers.", "de": "Benutzerd.", "it": "Tasso Pers.", "ru": "Свой курс", "zh": "自定义", "ja": "カスタム", "ko": "사용자 지정", "ar": "مخصص", "hi": "कस्टम", "tr": "Özel", "id": "Kustom", "vi": "Tùy chỉnh"
    },
    "noCustomRates": {
        "es": "Sin tasas personalizadas", "en": "No custom rates", "pt": "Sem taxas personalizadas", "fr": "Aucun taux personnalisé", "de": "Keine eigenen Kurse", "it": "Nessun tasso personalizzato", "ru": "Нет своих курсов", "zh": "无自定义汇率", "ja": "カスタムレートなし", "ko": "사용자 지정 환율 없음", "ar": "لا توجد أسعار مخصصة", "hi": "कोई कस्टम दर नहीं", "tr": "Özel oran yok", "id": "Tidak ada kurs kustom", "vi": "Không có tỷ giá tùy chỉnh"
    },
    "noCustomRatesDesc": {
        "es": "Necesitas agregar una tasa personalizada para usar esta función.", "en": "You need to add a custom rate to use this feature.", "pt": "Adicione uma taxa personalizada para usar este recurso.", "fr": "Ajoutez un taux personnalisé pour utiliser cette fonction.", "de": "Füge einen eigenen Kurs hinzu, um dies zu nutzen.", "it": "Aggiungi un tasso per usare questa funzione.", "ru": "Добавьте свой курс для использования функции.", "zh": "需要添加自定义汇率才能使用此功能。", "ja": "この機能を使用するにはカスタムレートを追加してください。", "ko": "이 기능을 사용하려면 사용자 지정 환율을 추가하세요.", "ar": "تحتاج لإضافة سعر مخصص لاستخدام هذه الميزة.", "hi": "इस सुविधा का उपयोग करने के लिए कस्टम दर जोड़ें।", "tr": "Bu özelliği kullanmak için özel oran ekleyin.", "id": "Tambahkan kurs kustom untuk menggunakan fitur ini.", "vi": "Thêm tỷ giá tùy chỉnh để sử dụng tính năng này."
    },
    "createRate": {
        "es": "Crear Tasa", "en": "Create Rate", "pt": "Criar Taxa", "fr": "Créer Taux", "de": "Kurs erstellen", "it": "Crea Tasso", "ru": "Создать курс", "zh": "创建汇率", "ja": "レート作成", "ko": "환율 생성", "ar": "إنشاء سعر", "hi": "दर बनाएं", "tr": "Oran Oluştur", "id": "Buat Kurs", "vi": "Tạo tỷ giá"
    },
    "chooseRate": {
        "es": "Elige una tasa", "en": "Choose a rate", "pt": "Escolha uma taxa", "fr": "Choisir un taux", "de": "Kurs wählen", "it": "Scegli un tasso", "ru": "Выберите курс", "zh": "选择汇率", "ja": "レートを選択", "ko": "환율 선택", "ar": "اختر سعرًا", "hi": "दर चुनें", "tr": "Oran seçin", "id": "Pilih kurs", "vi": "Chọn tỷ giá"
    },
    "newRate": {
        "es": "Nueva Tasa...", "en": "New Rate...", "pt": "Nova Taxa...", "fr": "Nouveau Taux...", "de": "Neuer Kurs...", "it": "Nuovo Tasso...", "ru": "Новый курс...", "zh": "新汇率...", "ja": "新しいレート...", "ko": "새 환율...", "ar": "سعر جديد...", "hi": "नई दर...", "tr": "Yeni Oran...", "id": "Kurs Baru...", "vi": "Tỷ giá mới..."
    },
    "convertVesTo": {
        "es": "Convertir Bolívares a...", "en": "Convert Bolivars to...", "pt": "Converter Bolívares para...", "fr": "Convertir Bolivars en...", "de": "Bolivar umrechnen in...", "it": "Converti Bolivar in...", "ru": "Конвертировать Боливары в...", "zh": "玻利瓦尔兑换为...", "ja": "ボリバルを変換...", "ko": "볼리바르 변환...", "ar": "تحويل بوليفار إلى...", "hi": "बोलिवर को इसमें बदलें...", "tr": "Bolivar'ı şuna dönüştür...", "id": "Konversi Bolivar ke...", "vi": "Chuyển đổi Bolivar sang..."
    },
     "homeScreen": {
        "es": "Inicio", "en": "Home", "pt": "Início", "fr": "Accueil", "de": "Home", "it": "Home", "ru": "Главная", "zh": "首页", "ja": "ホーム", "ko": "홈", "ar": "الرئيسية", "hi": "होम", "tr": "Ana Sayfa", "id": "Beranda", "vi": "Trang chủ"
    },
    "calculatorScreen": {
        "es": "Calculadora", "en": "Calculator", "pt": "Calculadora", "fr": "Calculatrice", "de": "Rechner", "it": "Calcolatrice", "ru": "Калькулятор", "zh": "计算器", "ja": "電卓", "ko": "계산기", "ar": "آلة حاسبة", "hi": "कैलकुलेटर", "tr": "Hesap Makinesi", "id": "Kalkulator", "vi": "Máy tính"
    },
     "rateDate": {
        "es": "Fecha Valor", "en": "Value Date", "pt": "Data Valor", "fr": "Date de valeur", "de": "Valutadatum", "it": "Data Valuta", "ru": "Дата курса", "zh": "起息日", "ja": "評価日", "ko": "기준일", "ar": "تاريخ الاستحقاق", "hi": "मूल्य तिथि", "tr": "Valör Tarihi", "id": "Tanggal Nilai", "vi": "Ngày giá trị"
    },
    "officialRateBcv": {
        "es": "Tasa Oficial BCV", "en": "Official BCV Rate", "pt": "Taxa Oficial BCV", "fr": "Taux Officiel BCV", "de": "Offizieller BCV-Kurs", "it": "Tasso Ufficiale BCV", "ru": "Офиц. курс BCV", "zh": "BCV 官方汇率", "ja": "BCV公式レート", "ko": "BCV 공식 환율", "ar": "سعر BCV الرسمي", "hi": "BCV आधिकारिक दर", "tr": "Resmi BCV Kuru", "id": "Kurs Resmi BCV", "vi": "Tỷ giá chính thức BCV"
    },
    "createYourFirstRate": {
        "es": "Crea tu primera tasa personalizada", "en": "Create your first custom rate", "pt": "Crie sua primeira taxa", "fr": "Créez votre premier taux", "de": "Erstellen Sie Ihren ersten Kurs", "it": "Crea il tuo primo tasso", "ru": "Создайте свой первый курс", "zh": "创建您的第一个汇率", "ja": "最初のカスタムレートを作成", "ko": "첫 번째 사용자 지정 환율 생성", "ar": "أنشئ سعرك المخصص الأول", "hi": "अपनी पहली कस्टम दर बनाएं", "tr": "İlk özel oranınızı oluşturun", "id": "Buat kurs kustom pertama Anda", "vi": "Tạo tỷ giá tùy chỉnh đầu tiên của bạn"
    },
    "addCustomRatesDescription": {
        "es": "Agrega tasas de cambios personalizadas para calcular tus conversiones.", "en": "Add custom exchange rates to calculate your conversions.", "pt": "Adicione taxas personalizadas para calcular conversões.", "fr": "Ajoutez des taux personnalisés pour vos conversions.", "de": "Fügen Sie eigene Kurse für Berechnungen hinzu.", "it": "Aggiungi tassi personalizzati per i calcoli.", "ru": "Добавьте свои курсы для расчетов.", "zh": "添加自定义汇率以计算转换。", "ja": "変換計算用にカスタムレートを追加します。", "ko": "환산 계산을 위해 사용자 지정 환율을 추가하세요.", "ar": "أضف أسعار صرف مخصصة لحساب تحويلاتك.", "hi": "अपने रूपांतरणों की गणना के लिए कस्टम विनिमय दरें जोड़ें।", "tr": "Dönüşümlerinizi hesaplamak için özel döviz kurları ekleyin.", "id": "Tambahkan nilai tukar kustom untuk menghitung konversi Anda.", "vi": "Thêm tỷ giá hối đoái tùy chỉnh để tính toán chuyển đổi của bạn."
    },
    "errorLoadingRate": {
        "es": "Error cargando tasa", "en": "Error loading rate", "pt": "Erro ao carregar taxa", "fr": "Erreur de chargement du taux", "de": "Fehler beim Laden des Kurses", "it": "Errore caricamento tasso", "ru": "Ошибка загрузки курса", "zh": "加载汇率错误", "ja": "レートの読み込みエラー", "ko": "환율 로딩 오류", "ar": "خطأ في تحميل السعر", "hi": "दर लोड करने में त्रुटि", "tr": "Oran yüklenirken hata", "id": "Kesalahan memuat kurs", "vi": "Lỗi tải tỷ giá"
    },
    "unlockPdfTitle": {
        "es": "Desbloquear Exportación PDF", "en": "Unlock PDF Export", "pt": "Desbloquear Exportação PDF", "fr": "Débloquer l'export PDF", "de": "PDF-Export entsperren", "it": "Sblocca Export PDF", "ru": "Разблокировать PDF", "zh": "解锁 PDF 导出", "ja": "PDFエクスポートを解除", "ko": "PDF 내보내기 잠금 해제", "ar": "فتح تصدير PDF", "hi": "PDF निर्यात अनलॉक करें", "tr": "PDF Dışa Aktarmayı Aç", "id": "Buka Ekspor PDF", "vi": "Mở khóa xuất PDF"
    },
    "unlockPdfDesc": {
        "es": "Para exportar el historial a PDF, por favor ve un anuncio corto. Esto desbloqueará la función por 24 horas.",
        "en": "To export history to PDF, please watch a short ad. This will unlock the feature for 24 hours.",
        "pt": "Para exportar para PDF, assista a um anúncio. Isso desbloqueará o recurso por 24h.",
        "fr": "Pour exporter en PDF, regardez une courte pub. Cela débloquera la fonction pour 24h.",
        "de": "Um als PDF zu exportieren, schau dir eine Werbung an. Dies schaltet die Funktion für 24h frei.",
        "it": "Per esportare in PDF, guarda una pubblicità. Sbloccherà la funzione per 24 ore.",
        "ru": "Чтобы экспортировать в PDF, посмотрите рекламу. Это разблокирует функцию на 24 часа.",
        "zh": "要导出 PDF，请观看简短广告。这将解锁该功能 24 小时。",
        "ja": "PDFにエクスポートするには、短い広告をご覧ください。24時間機能が解放されます。",
        "ko": "PDF로 내보내려면 짧은 광고를 시청하세요. 24시간 동안 기능이 잠금 해제됩니다.",
        "ar": "لتصدير السجل إلى PDF، يرجى مشاهدة إعلان قصير. سيؤدي هذا إلى فتح الميزة لمدة 24 ساعة.",
        "hi": "PDF में निर्यात करने के लिए, कृपया एक छोटा विज्ञापन देखें। यह सुविधा को 24 घंटे के लिए अनलॉक कर देगा।",
        "tr": "PDF'ye aktarmak için lütfen kısa bir reklam izleyin. Bu özellik 24 saatliğine açılacaktır.",
        "id": "Untuk mengekspor ke PDF, silakan tonton iklan singkat. Ini akan membuka fitur selama 24 jam.",
        "vi": "Để xuất sang PDF, vui lòng xem một quảng cáo ngắn. Điều này sẽ mở khóa tính năng trong 24 giờ."
    },
    "adNotReady": {
        "es": "El anuncio aún no está listo. Intenta de nuevo en unos segundos.",
        "en": "The ad is not ready yet. Try again in a few seconds.",
        "pt": "O anúncio ainda não está pronto. Tente novamente em alguns segundos.",
        "fr": "La pub n'est pas encore prête. Réessayez dans quelques secondes.",
        "de": "Die Werbung ist noch nicht bereit. Versuch es gleich noch einmal.",
        "it": "La pubblicità non è ancora pronta. Riprova tra qualche secondo.",
        "ru": "Реклама еще не готова. Попробуйте через несколько секунд.",
        "zh": "广告尚未准备好。请几秒钟后再试。",
        "ja": "広告の準備ができていません。数秒後にもう一度お試しください。",
        "ko": "광고가 아직 준비되지 않았습니다. 몇 초 후에 다시 시도하세요.",
        "ar": "الإعلان ليس جاهزًا بعد. حاول مرة أخرى في غضون ثوان.",
        "hi": "विज्ञापन अभी तैयार नहीं है। कुछ सेकंड में पुनः प्रयास करें।",
        "tr": "Reklam henüz hazır değil. Birkaç saniye sonra tekrar deneyin.",
        "id": "Iklan belum siap. Coba lagi dalam beberapa detik.",
        "vi": "Quảng cáo chưa sẵn sàng. Hãy thử lại sau vài giây."
    },
    "featureUnlocked": {
        "es": "¡Función desbloqueada por 24 horas!",
        "en": "Feature unlocked for 24 hours!",
        "pt": "Recurso desbloqueado por 24 horas!",
        "fr": "Fonctionnalité débloquée pour 24 heures !",
        "de": "Funktion für 24 Stunden freigeschaltet!",
        "it": "Funzione sbloccata per 24 ore!",
        "ru": "Функция разблокирована на 24 часа!",
        "zh": "功能已解锁 24 小时！",
        "ja": "機能が24時間解放されました！",
        "ko": "기능이 24시간 동안 잠금 해제되었습니다!",
        "ar": "تم فتح الميزة لمدة 24 ساعة!",
        "hi": "सुविधा 24 घंटे के लिए अनलॉक हो गई!",
        "tr": "Özellik 24 saatliğine açıldı!",
        "id": "Fitur dibuka selama 24 jam!",
        "vi": "Tính năng đã được mở khóa trong 24 giờ!"
    },
    "pdfHeader": {
       "es": "Historial de Precios BCV", "en": "BCV Price History", "pt": "Histórico de Preços BCV", "fr": "Historique des prix BCV", "de": "BCV-Preisverlauf", "it": "Cronologia Prezzi BCV", "ru": "История цен BCV", "zh": "BCV 价格历史", "ja": "BCV価格履歴", "ko": "BCV 가격 기록", "ar": "تاريخ أسعار BCV", "hi": "BCV मूल्य इतिहास", "tr": "BCV Fiyat Geçmişi", "id": "Riwayat Harga BCV", "vi": "Lịch sử giá BCV"
    },
    "statsPeriod": {
        "es": "Estadísticas del Periodo", "en": "Period Statistics", "pt": "Estatísticas do Período", "fr": "Statistiques de la période", "de": "Periodenstatistik", "it": "Statistiche del Periodo", "ru": "Статистика за период", "zh": "期间统计", "ja": "期間統計", "ko": "기간 통계", "ar": "إحصائيات الفترة", "hi": "अवधि सांख्यिकी", "tr": "Dönem İstatistikleri", "id": "Statistik Periode", "vi": "Thống kê giai đoạn"
    },
    "copiedClipboard": {
        "es": "Copiado al portapapeles", "en": "Copied to clipboard", "pt": "Copiado para a área de transferência", "fr": "Copié dans le presse-papiers", "de": "In die Zwischenablage kopiert", "it": "Copiato negli appunti", "ru": "Скопировано в буфер обмена", "zh": "已复制到剪贴板", "ja": "クリップボードにコピーしました", "ko": "클립보드에 복사됨", "ar": "تم النسخ إلى الحافظة", "hi": "क्लिपबोर्ड पर कॉपी किया गया", "tr": "Panoya kopyalandı", "id": "Disalin ke papan klip", "vi": "Đã sao chép vào khay nhớ tạm"
    },
    "amountDollars": {
        "es": "Monto en Dólares", "en": "Amount in Dollars", "pt": "Valor em Dólares", "fr": "Montant en Dollars", "de": "Betrag in Dollar", "it": "Importo in Dollari", "ru": "Сумма в долларах", "zh": "美元金额", "ja": "ドルの金額", "ko": "달러 금액", "ar": "المبلغ بالدولار", "hi": "डॉलर में राशि", "tr": "Dolar Tutarı", "id": "Jumlah dalam Dolar", "vi": "Số tiền bằng Đô la"
    },
    "amountEuros": {
        "es": "Monto en Euros", "en": "Amount in Euros", "pt": "Valor em Euros", "fr": "Montant en Euros", "de": "Betrag in Euro", "it": "Importo in Euro", "ru": "Сумма в евро", "zh": "欧元金额", "ja": "ユーロの金額", "ko": "유로 금액", "ar": "المبلغ باليورو", "hi": "यूरो में राशि", "tr": "Euro Tutarı", "id": "Jumlah dalam Euro", "vi": "Số tiền bằng Euro"
    },
    "amountBolivars": {
        "es": "Monto en Bolívares", "en": "Amount in Bolivars", "pt": "Valor em Bolívares", "fr": "Montant en Bolivars", "de": "Betrag in Bolivar", "it": "Importo in Bolivar", "ru": "Сумма в боливарах", "zh": "玻利瓦尔金额", "ja": "ボリバルの金額", "ko": "볼리바르 금액", "ar": "المبلغ بالبوليفار", "hi": "बोलिवर में राशि", "tr": "Bolivar Tutarı", "id": "Jumlah dalam Bolivar", "vi": "Số tiền bằng Bolivar"
    },
    "amountCustom": {
        "es": "Monto en", "en": "Amount in", "pt": "Valor em", "fr": "Montant en", "de": "Betrag in", "it": "Importo in", "ru": "Сумма в", "zh": "金额", "ja": "金額", "ko": "금액", "ar": "المبلغ بـ", "hi": "राशि", "tr": "Tutar", "id": "Jumlah dalam", "vi": "Số tiền bằng"
    },
    "shareError": {
        "es": "Error al compartir", "en": "Error sharing", "pt": "Erro ao compartilhar", "fr": "Erreur de partage", "de": "Fehler beim Teilen", "it": "Errore condivisione", "ru": "Ошибка при отправке", "zh": "分享错误", "ja": "共有エラー", "ko": "공유 오류", "ar": "خطأ في المشاركة", "hi": "साझा करने में त्रुटि", "tr": "Paylaşma hatası", "id": "Kesalahan berbagi", "vi": "Lỗi chia sẻ"
    },
     "pdfError": {
        "es": "Error al generar PDF", "en": "Error generating PDF", "pt": "Erro ao gerar PDF", "fr": "Erreur de génération PDF", "de": "Fehler beim PDF-Erstellen", "it": "Errore generazione PDF", "ru": "Ошибка создания PDF", "zh": "生成 PDF 错误", "ja": "PDF生成エラー", "ko": "PDF 생성 오류", "ar": "خطأ في إنشاء PDF", "hi": "PDF बनाने में त्रुटि", "tr": "PDF oluşturma hatası", "id": "Kesalahan membuat PDF", "vi": "Lỗi tạo PDF"
    },
    "viewList": {
        "es": "Ver Lista", "en": "View List", "pt": "Ver Lista", "fr": "Voir Liste", "de": "Liste anzeigen", "it": "Vedi Lista", "ru": "Списком", "zh": "查看列表", "ja": "リスト表示", "ko": "목록 보기", "ar": "عرض القائمة", "hi": "सूची देखें", "tr": "Listeyi Görüntüle", "id": "Lihat Daftar", "vi": "Xem danh sách"
    },
    "viewChart": {
        "es": "Ver Gráfico", "en": "View Chart", "pt": "Ver Gráfico", "fr": "Voir Graphique", "de": "Diagramm anzeigen", "it": "Vedi Grafico", "ru": "График", "zh": "查看图表", "ja": "チャート表示", "ko": "차트 보기", "ar": "عرض الرسم البياني", "hi": "चार्ट देखें", "tr": "Grafiği Görüntüle", "id": "Lihat Grafik", "vi": "Xem biểu đồ"
    },
    "noData": {
        "es": "No hay datos disponibles", "en": "No data available", "pt": "Sem dados disponíveis", "fr": "Aucune donnée disponible", "de": "Keine Daten verfügbar", "it": "Nessun dato disponibile", "ru": "Нет данных", "zh": "无可用数据", "ja": "データなし", "ko": "데이터 없음", "ar": "لا توجد بيانات", "hi": "कोई डेटा उपलब्ध नहीं", "tr": "Veri yok", "id": "Tidak ada data", "vi": "Không có dữ liệu"
    },
    "mean": {
        "es": "Promedio", "en": "Average", "pt": "Média", "fr": "Moyenne", "de": "Durchschnitt", "it": "Media", "ru": "Среднее", "zh": "平均", "ja": "平均", "ko": "평균", "ar": "متوسط", "hi": "औसत", "tr": "Ortalama", "id": "Rata-rata", "vi": "Trung bình"
    },
    "min": {
        "es": "Mínimo", "en": "Minimum", "pt": "Mínimo", "fr": "Minimum", "de": "Minimum", "it": "Minimo", "ru": "Мин.", "zh": "最小", "ja": "最小", "ko": "최소", "ar": "الحد الأدنى", "hi": "न्यूनतम", "tr": "Minimum", "id": "Minimum", "vi": "Tối thiểu"
    },
    "max": {
        "es": "Máximo", "en": "Maximum", "pt": "Máximo", "fr": "Maximum", "de": "Maximum", "it": "Massimo", "ru": "Макс.", "zh": "最大", "ja": "最大", "ko": "최대", "ar": "الحد الأقصى", "hi": "अधिकतम", "tr": "Maksimum", "id": "Maksimum", "vi": "Tối đa"
    },
    "change": {
        "es": "Cambio", "en": "Change", "pt": "Variação", "fr": "Variation", "de": "Veränderung", "it": "Variazione", "ru": "Изм.", "zh": "变化", "ja": "変化", "ko": "변동", "ar": "تغيير", "hi": "परिवर्तन", "tr": "Değişim", "id": "Perubahan", "vi": "Thay đổi"
    },
    "statsPeriod": {"es": "Estadísticas del Periodo", "en": "Period Statistics", "pt": "Estatísticas do Período", "fr": "Statistiques de la Période", "de": "Periodenstatistik", "it": "Statistiche del Periodo", "ru": "Статистика за период", "zh": "期间统计", "ja": "期間統計", "ko": "기간 통계", "ar": "إحصائيات الفترة", "hi": "अवधि सांख्यिकी", "tr": "Dönem İstatistikleri", "id": "Statistik Periode", "vi": "Thống kê giai đoạn"},
    "rangeWeek": {"es": "1 Sem", "en": "1 Wk", "pt": "1 Sem", "fr": "1 Sem", "de": "1 Wo", "it": "1 Sett", "ru": "1 Нед", "zh": "1周", "ja": "1週間", "ko": "1주", "ar": "1 أسبوع", "hi": "1 सप्ताह", "tr": "1 Haf", "id": "1 Mgg", "vi": "1 Tuần"},
    "rangeMonth": {"es": "1 Mes", "en": "1 Mo", "pt": "1 Mês", "fr": "1 Mois", "de": "1 Mon", "it": "1 Mese", "ru": "1 Мес", "zh": "1月", "ja": "1ヶ月", "ko": "1개월", "ar": "1 شهر", "hi": "1 महीना", "tr": "1 Ay", "id": "1 Bln", "vi": "1 Tháng"},
    "rangeThreeMonths": {"es": "3 Meses", "en": "3 Mos", "pt": "3 Meses", "fr": "3 Mois", "de": "3 Mon", "it": "3 Mesi", "ru": "3 Мес", "zh": "3月", "ja": "3개월", "ko": "3개월", "ar": "3 أشهر", "hi": "3 महीने", "tr": "3 Ay", "id": "3 Bln", "vi": "3 Tháng"},
    "rangeYear": {"es": "1 Año", "en": "1 Yr", "pt": "1 Ano", "fr": "1 An", "de": "1 Jahr", "it": "1 Anno", "ru": "1 Год", "zh": "1年", "ja": "1年", "ko": "1년", "ar": "1 سنة", "hi": "1 साल", "tr": "1 Yıl", "id": "1 Thn", "vi": "1 Năm"},
    "rangeCustom": {"es": "Personalizado", "en": "Custom", "pt": "Adoc", "fr": "Perso", "de": "Benutzer", "it": "Person", "ru": "Свой", "zh": "自定义", "ja": "カスタム", "ko": "맞춤", "ar": "مخصص", "hi": "कस्टम", "tr": "Özel", "id": "Kustom", "vi": "Tùy chỉnh"},
    
    "removeAdsLink": {
        "es": "Quitar anuncios", "en": "Remove Ads", "pt": "Remover Anúncios", "fr": "Supprimer les pubs", "de": "Werbung entfernen", "it": "Rimuovi pubblicità", "ru": "Убрать рекламу", "zh": "移除广告", "ja": "広告を削除", "ko": "광고 제거", "ar": "إزالة الإعلانات", "hi": "विज्ञापन हटाएं", "tr": "Reklamları Kaldır", "id": "Hapus Iklan", "vi": "Xóa quảng cáo"
    },
    "thanksSupport": {
        "es": "¡Gracias por tu apoyo!", "en": "Thanks for your support!", "pt": "Obrigado pelo seu apoio!", "fr": "Merci pour votre soutien !", "de": "Danke für deine Unterstützung!", "it": "Grazie per il tuo supporto!", "ru": "Спасибо за поддержку!", "zh": "感谢您的支持！", "ja": "ご支援ありがとうございます！", "ko": "지원해 주셔서 감사합니다!", "ar": "شكرا لدعمك!", "hi": "आपके समर्थन के लिए धन्यवाद!", "tr": "Desteğiniz için teşekkürler!", "id": "Terima kasih atas dukungan Anda!", "vi": "Cảm ơn sự hỗ trợ của bạn!"
    }
}

for lang in languages:
    content = {}
    content["@@locale"] = lang
    for key, values in translations.items():
        if lang in values:
            content[key] = values[lang]
        else:
            content[key] = values["es"] # Fallback

    file_path = f"c:\\Users\\Juan\\Documents\\Proyectos\\Apps\\CalculadoraBCV\\calculadora_bcv\\lib\\l10n\\app_{lang}.arb"
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    print(f"Generated {file_path}")

