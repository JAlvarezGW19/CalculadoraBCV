# 🚀 Comandos para Subir a GitHub - COPIA Y PEGA

## 📋 Ejecuta estos comandos en orden:

```bash
# 1. Ir a la carpeta del proyecto
cd c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV

# 2. Ver qué archivos se van a subir (verificación)
git status

# 3. Agregar todos los cambios
git add .

# 4. Hacer commit con mensaje descriptivo
git commit -m "feat: sistema de migración de historial consolidado + traducciones payment"

# 5. Subir a GitHub
git push origin main
```

---

## ✅ Verificación de Seguridad

Después del `git status`, verifica que **NO aparezcan** estos archivos:
- ❌ `android/app/google-services.json`
- ❌ `*.apk`
- ❌ `*.py` (excepto setup.py o build.py)

Si aparecen, están protegidos y no se subirán ✅

---

## 📦 Lo que SÍ se subirá (es seguro):

✅ Código fuente de Flutter (`lib/`)  
✅ Scripts de migración (`migration/`)  
✅ Cloud Functions actualizadas (`functions/src/`)  
✅ Guías de migración (`.md`)  
✅ Configuración de Flutter (`pubspec.yaml`)  
✅ `.gitignore` actualizado  

---

## 🌐 Después de Subir a GitHub

Desde la laptop de tu amigo:

```bash
# Clonar el repositorio
git clone https://github.com/JAlvarezGW19/CalculadoraBCV.git
cd CalculadoraBCV/migration

# Instalar dependencias
npm install

# Ejecutar migración (después de descargar serviceAccountKey.json)
npm run migrate
```

---

## 🔗 Links Importantes

**Firebase Console (para descargar Service Account Key):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
```

**Firestore (para verificar migración):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
```

---

## ⚠️ IMPORTANTE: Después de la Migración

En la laptop de tu amigo, **ANTES de cerrar sesión:**

```bash
# Eliminar credenciales
rm migration/serviceAccountKey.json

# O en Windows:
del migration\serviceAccountKey.json
```

**NO dejes el archivo de credenciales en otra computadora.**

---

## 📱 De Vuelta en Tu Casa

```bash
# Compilar la app con los cambios
flutter clean
flutter pub get
flutter build apk --split-per-abi
```

---

¡Listo! Copia y pega estos comandos 🚀
