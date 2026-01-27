# 🌐 Guía para Trabajar desde Otra Computadora

Esta guía te ayudará a ejecutar la migración desde la laptop de tu amigo con buena conexión a internet.

## 📋 Preparación en Tu Computadora (Ahora)

### 1️⃣ Verificar que NO subirás información sensible

Ejecuta este comando para ver qué archivos se subirán:

```bash
git status
```

**Archivos que NO deben aparecer (están protegidos):**
- ❌ `android/app/google-services.json`
- ❌ `migration/serviceAccountKey.json`
- ❌ `.firebaserc`
- ❌ `firebase.json`
- ❌ `*.apk` o `*.aab`

Si aparecen, están protegidos por `.gitignore` ✅

### 2️⃣ Subir a GitHub

```bash
# Agregar todos los cambios
git add .

# Hacer commit
git commit -m "feat: migración de historial a documento consolidado"

# Subir a GitHub
git push origin main
```

---

## 💻 En la Laptop de tu Amigo (Con Internet)

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/TU-USUARIO/CalculadoraBCV.git
cd CalculadoraBCV
```

### 2️⃣ Descargar Service Account Key

**Desde la laptop de tu amigo:**

1. Abre Firebase Console:
   ```
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
   ```

2. Inicia sesión con tu cuenta de Google (jalvarezgw19@gmail.com)

3. Haz clic en **"Generar nueva clave privada"**

4. Se descargará un archivo JSON

5. **Renómbralo a:** `serviceAccountKey.json`

6. **Muévelo a:** `CalculadoraBCV/migration/serviceAccountKey.json`

### 3️⃣ Ejecutar la Migración

```bash
# Ir a la carpeta de migración
cd migration

# Instalar dependencias (solo la primera vez)
npm install

# Ejecutar migración
npm run migrate
```

### 4️⃣ Verificar Resultado

Deberías ver:

```
╔═══════════════════════════════════════════════════════════╗
║  ✅ ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!                   ║
╚═══════════════════════════════════════════════════════════╝

📊 Registros consolidados: 1095
🗑️  Documentos antiguos eliminados: 1095
```

### 5️⃣ Verificar en Firebase Console

Abre:
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
```

Deberías ver **SOLO** el documento `consolidated`.

### 6️⃣ Limpiar (Importante)

**Antes de cerrar la sesión en la laptop de tu amigo:**

```bash
# Eliminar el Service Account Key
rm migration/serviceAccountKey.json

# O en Windows:
del migration\serviceAccountKey.json
```

**NO dejes el archivo de credenciales en la computadora de tu amigo.**

---

## 🔙 De Vuelta en Tu Computadora

### Actualizar tu Código Local

```bash
# Descargar los últimos cambios (si hiciste algún commit desde la laptop)
git pull origin main

# Compilar la app con los cambios
flutter clean
flutter pub get
flutter build apk --split-per-abi
```

---

## 🔒 Seguridad - MUY IMPORTANTE

### ✅ Lo que SÍ puedes subir a GitHub:
- ✅ Código fuente de la app
- ✅ Scripts de migración (`migrate.js`, `package.json`)
- ✅ Documentación
- ✅ Archivos de configuración de Flutter

### ❌ Lo que NUNCA debes subir a GitHub:
- ❌ `google-services.json` (credenciales de Firebase)
- ❌ `serviceAccountKey.json` (credenciales de administrador)
- ❌ `.firebaserc` (configuración de Firebase)
- ❌ `firebase.json` (configuración de Firebase)
- ❌ APKs compilados (son muy pesados)

**Todos estos archivos ya están protegidos en `.gitignore`** ✅

---

## 📝 Checklist Completo

### En Tu Computadora (Ahora):
- [ ] Verificar `.gitignore` protege archivos sensibles
- [ ] Hacer commit de los cambios
- [ ] Subir a GitHub (`git push`)

### En la Laptop de tu Amigo:
- [ ] Clonar repositorio
- [ ] Descargar Service Account Key desde Firebase Console
- [ ] Mover `serviceAccountKey.json` a `migration/`
- [ ] Ejecutar `npm install` en la carpeta `migration/`
- [ ] Ejecutar `npm run migrate`
- [ ] Verificar en Firebase Console
- [ ] **ELIMINAR `serviceAccountKey.json`** antes de cerrar sesión

### De Vuelta en Tu Computadora:
- [ ] Hacer `git pull` (si es necesario)
- [ ] Compilar app con `flutter build apk`
- [ ] Probar que el historial funciona correctamente

---

## ⚠️ Notas Importantes

1. **Internet Necesario:**
   - Para clonar el repo: ~50-100 MB
   - Para `npm install`: ~20 MB
   - Para ejecutar migración: ~5 MB
   - **Total estimado: ~100 MB**

2. **Tiempo Estimado:**
   - Clonar repo: 2-5 minutos
   - npm install: 1-2 minutos
   - Migración: 30-60 segundos
   - **Total: ~10 minutos**

3. **Requisitos en la Laptop:**
   - Node.js instalado (si no está, descargar de nodejs.org)
   - Git instalado
   - Navegador web (para Firebase Console)

---

## 🆘 Troubleshooting

### "git: command not found"
**Solución:** Instala Git desde https://git-scm.com/downloads

### "npm: command not found"
**Solución:** Instala Node.js desde https://nodejs.org/

### "Permission denied" al ejecutar migración
**Solución:** Verifica que el `serviceAccountKey.json` esté en la carpeta correcta y sea el archivo correcto de Firebase.

### No puedo acceder a Firebase Console
**Solución:** Inicia sesión con tu cuenta de Google (jalvarezgw19@gmail.com) en el navegador.

---

## ✨ Ventajas de Este Método

✅ **No necesitas buena internet en tu casa**  
✅ **El código está en GitHub (respaldo)**  
✅ **Puedes trabajar desde cualquier computadora**  
✅ **Seguro** (no dejas credenciales en otras computadoras)  
✅ **Rápido** (solo ~10 minutos en total)  

---

¿Listo para subir a GitHub? 🚀
