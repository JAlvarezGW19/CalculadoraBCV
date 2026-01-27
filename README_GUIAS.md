# 📚 Índice de Guías - CalculadoraBCV

Todas las guías que necesitas para trabajar con el proyecto.

---

## 🚀 GUÍAS DE MIGRACIÓN

### 1. **EJECUTAR_AHORA.md** ⭐ **EMPIEZA AQUÍ**
**Cuándo usar:** AHORA, antes de ir a la laptop de tu amigo
- Comandos para subir código a GitHub
- Links para guardar en tu teléfono
- Verificación rápida

### 2. **GUIA_COMPLETA_MIGRACION.md** 📖 **GUÍA DETALLADA**
**Cuándo usar:** En la laptop de tu amigo (paso a paso completo)
- Instalación de Git y Node.js desde cero
- Cómo clonar el repositorio
- Cómo descargar Service Account Key
- Ejecución de la migración
- Troubleshooting completo
- **Tiempo de lectura:** ~15 minutos

### 3. **GUIA_RAPIDA_IMPRIMIR.md** 📄 **PARA LLEVAR**
**Cuándo usar:** Como referencia rápida (imprimir o fotografiar)
- Checklist condensado
- Comandos esenciales
- Links importantes
- **1 página** - Fácil de llevar

### 4. **MIGRATION_GUIDE.md** 🔧 **GUÍA TÉCNICA**
**Cuándo usar:** Para entender cómo funciona la migración
- Explicación técnica del sistema
- Estructura antes y después
- Beneficios y métricas
- Funcionamiento automático

---

## 🔑 GUÍAS DE CONFIGURACIÓN

### 5. **ARCHIVOS_PROTEGIDOS.md** 🔒 **CÓMO OBTENER ARCHIVOS**
**Cuándo usar:** Cuando necesites algún archivo de configuración
- Cómo descargar `google-services.json`
- Cómo generar `serviceAccountKey.json`
- Cómo crear `.firebaserc` y `firebase.json`
- Cuándo necesitas cada archivo
- Casos de uso comunes

### 6. **COMANDOS_GITHUB.md** 💻 **REFERENCIA DE GIT**
**Cuándo usar:** Como referencia rápida de comandos Git
- Comandos para subir código
- Verificación de seguridad
- Links de Firebase

---

## 📂 GUÍAS EN CARPETAS ESPECÍFICAS

### 7. **migration/README.md** 🔄 **SCRIPT DE MIGRACIÓN**
**Cuándo usar:** Para entender el script de migración local
- Requisitos del script
- Pasos de ejecución
- Troubleshooting específico del script

### 8. **REMOTE_MIGRATION_GUIDE.md** 🌐 **TRABAJO REMOTO**
**Cuándo usar:** Para trabajar desde otra computadora
- Preparación en tu casa
- Pasos en computadora remota
- Limpieza y seguridad

---

## 🎯 FLUJO DE TRABAJO RECOMENDADO

### Escenario 1: Primera Vez - Ejecutar Migración

```
1. EJECUTAR_AHORA.md          (En tu casa - 5 min)
   ↓
2. GUIA_COMPLETA_MIGRACION.md (En laptop amigo - 15 min)
   ↓
3. Verificar en Firebase Console
   ↓
4. ✅ ¡Migración exitosa!
```

### Escenario 2: Compilar App en Otra Computadora

```
1. Clonar repo de GitHub
   ↓
2. ARCHIVOS_PROTEGIDOS.md     (Descargar google-services.json)
   ↓
3. flutter build apk
   ↓
4. ✅ ¡App compilada!
```

### Escenario 3: Desplegar Cloud Functions

```
1. Clonar repo de GitHub
   ↓
2. ARCHIVOS_PROTEGIDOS.md     (Crear .firebaserc y firebase.json)
   ↓
3. firebase deploy --only functions
   ↓
4. ✅ ¡Functions desplegadas!
```

---

## 📋 CHECKLIST POR SITUACIÓN

### ✅ Para Migración de Historial:
- [ ] Leer: `EJECUTAR_AHORA.md`
- [ ] Leer: `GUIA_COMPLETA_MIGRACION.md`
- [ ] Imprimir: `GUIA_RAPIDA_IMPRIMIR.md`
- [ ] Consultar si hay dudas: `ARCHIVOS_PROTEGIDOS.md`

### ✅ Para Compilar App:
- [ ] Clonar repositorio
- [ ] Consultar: `ARCHIVOS_PROTEGIDOS.md` (sección google-services.json)
- [ ] Descargar archivo de Firebase
- [ ] Compilar

### ✅ Para Entender el Sistema:
- [ ] Leer: `MIGRATION_GUIDE.md`
- [ ] Leer: `migration/README.md`

---

## 🔍 BÚSQUEDA RÁPIDA

**¿Necesitas...?**

- **Subir código a GitHub?** → `EJECUTAR_AHORA.md`
- **Ejecutar migración paso a paso?** → `GUIA_COMPLETA_MIGRACION.md`
- **Referencia rápida para llevar?** → `GUIA_RAPIDA_IMPRIMIR.md`
- **Descargar google-services.json?** → `ARCHIVOS_PROTEGIDOS.md`
- **Generar serviceAccountKey.json?** → `ARCHIVOS_PROTEGIDOS.md`
- **Entender cómo funciona la migración?** → `MIGRATION_GUIDE.md`
- **Comandos de Git?** → `COMANDOS_GITHUB.md`
- **Trabajar desde otra PC?** → `REMOTE_MIGRATION_GUIDE.md`

---

## 📞 LINKS IMPORTANTES

**GitHub Repo:**
```
https://github.com/JAlvarezGW19/CalculadoraBCV
```

**Firebase Console:**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f
```

**Firebase Settings (para descargar archivos):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/general
```

**Service Accounts (para serviceAccountKey.json):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
```

**Firestore (para verificar migración):**
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
```

---

## 🎓 ORDEN DE LECTURA RECOMENDADO

### Para Principiantes:
1. `EJECUTAR_AHORA.md` - Qué hacer ahora
2. `GUIA_COMPLETA_MIGRACION.md` - Paso a paso completo
3. `ARCHIVOS_PROTEGIDOS.md` - Entender archivos de configuración

### Para Usuarios Avanzados:
1. `GUIA_RAPIDA_IMPRIMIR.md` - Checklist rápido
2. `MIGRATION_GUIDE.md` - Detalles técnicos
3. `ARCHIVOS_PROTEGIDOS.md` - Referencia cuando necesites

---

## ⚡ ACCESO RÁPIDO

| Necesito | Archivo | Tiempo |
|----------|---------|--------|
| Subir a GitHub AHORA | `EJECUTAR_AHORA.md` | 5 min |
| Migración completa | `GUIA_COMPLETA_MIGRACION.md` | 15 min |
| Referencia rápida | `GUIA_RAPIDA_IMPRIMIR.md` | 1 min |
| Descargar archivos | `ARCHIVOS_PROTEGIDOS.md` | 5 min |
| Entender sistema | `MIGRATION_GUIDE.md` | 10 min |

---

## 📱 PARA GUARDAR EN TU TELÉFONO

Toma captura de pantalla de estos links:

```
Repo: https://github.com/JAlvarezGW19/CalculadoraBCV
Firebase: https://console.firebase.google.com/project/calculadora-bcv-f1f2f
Service Accounts: .../settings/serviceaccounts/adminsdk
Firestore: .../firestore/data/historial_tasas
```

---

## ✨ RESUMEN

**Tienes 8 guías completas que cubren:**
- ✅ Migración de historial
- ✅ Configuración de archivos
- ✅ Trabajo remoto
- ✅ Compilación de app
- ✅ Deploy de functions
- ✅ Troubleshooting
- ✅ Seguridad

**Todo lo que necesitas está documentado.** 🚀

---

**Última actualización:** 2026-01-27  
**Proyecto:** CalculadoraBCV  
**Firebase:** calculadora-bcv-f1f2f
