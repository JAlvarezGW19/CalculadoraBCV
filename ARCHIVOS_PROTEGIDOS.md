# 🔑 Guía: Cómo Obtener los Archivos Protegidos

Esta guía te explica cómo obtener cada archivo que está protegido en `.gitignore` y cuándo los necesitas.

---

## 📋 Lista de Archivos Protegidos y Cómo Obtenerlos

### 1. `google-services.json` (Android)

**¿Qué es?**
- Archivo de configuración de Firebase para Android
- Contiene las credenciales de tu app

**¿Cuándo lo necesitas?**
- Para compilar la app en Android
- Para que Firebase funcione (Firestore, Analytics, etc.)

**¿Cómo obtenerlo?**

#### Opción A: Descargarlo de Firebase Console

1. Ve a Firebase Console:
   ```
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/general
   ```

2. Scroll hacia abajo hasta "Tus apps"

3. Busca la app de Android (icono de Android verde)
   - Package name: `com.juanalvarez.calculadorabcv`

4. Click en el ícono de **configuración** (⚙️) de la app

5. Click en **"Descargar google-services.json"**

6. Guardar en:
   ```
   android/app/google-services.json
   ```

#### Opción B: Ya lo tienes localmente

Si ya compilaste la app antes, el archivo está en:
```
c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV\android\app\google-services.json
```

**Puedes copiarlo de ahí cuando lo necesites.**

---

### 2. `serviceAccountKey.json` (Para Migración)

**¿Qué es?**
- Credenciales de administrador de Firebase
- Permite acceso completo a Firestore desde scripts

**¿Cuándo lo necesitas?**
- SOLO para ejecutar el script de migración
- NO lo necesitas para compilar la app

**¿Cómo obtenerlo?**

1. Ve a Firebase Console:
   ```
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
   ```

2. Click en **"Generar nueva clave privada"**

3. Confirmar en el diálogo

4. Se descarga un archivo JSON con nombre largo

5. Renombrar a: `serviceAccountKey.json`

6. Guardar en:
   ```
   migration/serviceAccountKey.json
   ```

**⚠️ IMPORTANTE:**
- Este archivo da acceso TOTAL a tu Firebase
- NUNCA lo subas a GitHub
- Elimínalo después de usarlo
- Puedes generar uno nuevo cada vez que lo necesites

---

### 3. `.firebaserc` (Configuración de Firebase CLI)

**¿Qué es?**
- Archivo de configuración de Firebase CLI
- Indica qué proyecto usar

**¿Cuándo lo necesitas?**
- Para desplegar Cloud Functions
- Para usar Firebase CLI

**¿Cómo obtenerlo/crearlo?**

#### Si ya existe localmente:
Está en la raíz del proyecto:
```
c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV\.firebaserc
```

#### Si necesitas crearlo nuevo:

```bash
# En la raíz del proyecto
firebase init

# Seleccionar:
# - Functions
# - Usar proyecto existente: calculadora-bcv-f1f2f
```

#### O créalo manualmente:

Crear archivo `.firebaserc` con este contenido:

```json
{
  "projects": {
    "default": "calculadora-bcv-f1f2f"
  }
}
```

---

### 4. `firebase.json` (Configuración de Firebase)

**¿Qué es?**
- Configuración de servicios de Firebase
- Define reglas de hosting, functions, etc.

**¿Cuándo lo necesitas?**
- Para desplegar Cloud Functions
- Para configurar Firebase Hosting

**¿Cómo obtenerlo/crearlo?**

#### Si ya existe localmente:
```
c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV\firebase.json
```

#### Si necesitas crearlo nuevo:

```bash
firebase init
```

#### O créalo manualmente:

Crear archivo `firebase.json` con este contenido:

```json
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": [
        "node_modules",
        ".git",
        "firebase-debug.log",
        "firebase-debug.*.log"
      ]
    }
  ]
}
```

---

### 5. `GoogleService-Info.plist` (iOS)

**¿Qué es?**
- Equivalente de `google-services.json` para iOS
- Configuración de Firebase para iOS

**¿Cuándo lo necesitas?**
- Para compilar la app en iOS/Mac
- Para que Firebase funcione en iOS

**¿Cómo obtenerlo?**

1. Ve a Firebase Console:
   ```
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/general
   ```

2. Scroll hasta "Tus apps"

3. Busca la app de iOS (si existe)

4. Click en **"Descargar GoogleService-Info.plist"**

5. Guardar en:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

**Nota:** Si no tienes app de iOS configurada, no necesitas este archivo.

---

## 🎯 Casos de Uso Comunes

### Caso 1: Quiero compilar la app en otra computadora

**Necesitas:**
- ✅ `google-services.json`
- ❌ `serviceAccountKey.json` (NO)
- ❌ `.firebaserc` (NO)
- ❌ `firebase.json` (NO)

**Pasos:**
1. Clonar repo de GitHub
2. Descargar `google-services.json` de Firebase Console
3. Colocar en `android/app/`
4. Ejecutar `flutter build apk`

---

### Caso 2: Quiero ejecutar la migración

**Necesitas:**
- ❌ `google-services.json` (NO)
- ✅ `serviceAccountKey.json`
- ❌ `.firebaserc` (NO)
- ❌ `firebase.json` (NO)

**Pasos:**
1. Clonar repo de GitHub
2. Descargar `serviceAccountKey.json` de Firebase Console
3. Colocar en `migration/`
4. Ejecutar `npm run migrate`
5. **Eliminar `serviceAccountKey.json`**

---

### Caso 3: Quiero desplegar Cloud Functions

**Necesitas:**
- ❌ `google-services.json` (NO)
- ❌ `serviceAccountKey.json` (NO)
- ✅ `.firebaserc`
- ✅ `firebase.json`

**Pasos:**
1. Clonar repo de GitHub
2. Crear `.firebaserc` y `firebase.json` (ver arriba)
3. Ejecutar `firebase deploy --only functions`

---

## 📝 Resumen Rápido

| Archivo | Para Compilar App | Para Migración | Para Deploy Functions |
|---------|-------------------|----------------|----------------------|
| `google-services.json` | ✅ SÍ | ❌ NO | ❌ NO |
| `serviceAccountKey.json` | ❌ NO | ✅ SÍ | ❌ NO |
| `.firebaserc` | ❌ NO | ❌ NO | ✅ SÍ |
| `firebase.json` | ❌ NO | ❌ NO | ✅ SÍ |

---

## 🔒 Seguridad - Muy Importante

### ✅ Archivos que PUEDES compartir:
- Código fuente de la app
- `pubspec.yaml`
- Archivos de configuración de Flutter

### ❌ Archivos que NUNCA debes compartir:
- `google-services.json` (tiene API keys)
- `serviceAccountKey.json` (acceso total a Firebase)
- Cualquier archivo con credenciales

### 💡 Buenas Prácticas:

1. **Mantén copias locales seguras:**
   - Guarda `google-services.json` en un lugar seguro
   - NO lo subas a GitHub
   - Puedes re-descargarlo cuando lo necesites

2. **Service Account Keys:**
   - Genera uno nuevo cada vez que lo necesites
   - Elimínalo después de usarlo
   - NUNCA lo dejes en computadoras compartidas

3. **Usa variables de entorno:**
   - Para API keys en producción
   - Para configuraciones sensibles

---

## 🆘 ¿Perdiste un Archivo?

### Si perdiste `google-services.json`:
✅ **Solución:** Descárgalo nuevamente de Firebase Console (ver arriba)

### Si perdiste `serviceAccountKey.json`:
✅ **Solución:** Genera uno nuevo de Firebase Console (ver arriba)

### Si perdiste `.firebaserc` o `firebase.json`:
✅ **Solución:** Créalos manualmente (ver arriba) o ejecuta `firebase init`

---

## 📞 Links Rápidos

**Firebase Console (General):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/general
```

**Service Accounts (para serviceAccountKey.json):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
```

---

## ✨ Conclusión

- **Para compilar la app:** Solo necesitas `google-services.json`
- **Para la migración:** Solo necesitas `serviceAccountKey.json` (temporal)
- **Todos se pueden descargar de Firebase Console**
- **Ninguno se sube a GitHub por seguridad**
- **Puedes obtenerlos cuando los necesites**

**¡No te preocupes! Siempre puedes descargarlos de Firebase Console.** 🚀
