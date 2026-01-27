# 🚀 Guía Completa: Desde Cero hasta Migración Exitosa

Esta guía te llevará paso a paso desde una laptop limpia hasta ejecutar la migración exitosamente.

---

## 📋 PARTE 1: Preparación en Tu Casa (Antes de Ir)

### Paso 1: Subir el Código a GitHub

```bash
# Abrir PowerShell en la carpeta del proyecto
cd c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV

# Verificar qué se va a subir
git status

# Agregar todos los cambios
git add .

# Hacer commit
git commit -m "feat: migración de historial consolidado + traducciones"

# Subir a GitHub
git push origin main
```

**✅ Verificación:** Ve a GitHub en el navegador y confirma que el código se subió.

---

## 💻 PARTE 2: En la Laptop de tu Amigo (Paso a Paso)

### 🔧 Paso 1: Instalar Git (Si no está instalado)

#### Verificar si Git está instalado:
```bash
git --version
```

#### Si NO está instalado:

**Windows:**
1. Descargar: https://git-scm.com/download/win
2. Ejecutar el instalador
3. Dejar todas las opciones por defecto
4. Click "Next" hasta terminar
5. Reiniciar PowerShell/CMD

**Mac:**
```bash
# Instalar Homebrew primero (si no está)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Git
brew install git
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install git
```

---

### 🟢 Paso 2: Instalar Node.js (Requerido para la migración)

#### Verificar si Node.js está instalado:
```bash
node --version
npm --version
```

#### Si NO está instalado:

**Windows:**
1. Descargar: https://nodejs.org/
2. Descargar la versión **LTS** (recomendada)
3. Ejecutar el instalador
4. Dejar todas las opciones por defecto
5. Click "Next" hasta terminar
6. Reiniciar PowerShell/CMD

**Mac:**
```bash
# Con Homebrew
brew install node
```

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### ✅ Verificar instalación:
```bash
node --version    # Debe mostrar: v20.x.x o similar
npm --version     # Debe mostrar: 10.x.x o similar
```

---

### 📥 Paso 3: Clonar el Repositorio

```bash
# Crear una carpeta para proyectos (opcional pero recomendado)
mkdir Proyectos
cd Proyectos

# Clonar el repositorio
git clone https://github.com/JAlvarezGW19/CalculadoraBCV.git

# Entrar a la carpeta
cd CalculadoraBCV
```

**✅ Verificación:** Deberías ver la estructura del proyecto:
```bash
ls    # o 'dir' en Windows
```

Deberías ver carpetas como: `lib/`, `android/`, `migration/`, etc.

---

### 🔑 Paso 4: Descargar Service Account Key de Firebase

**Este es el paso MÁS IMPORTANTE para la migración.**

#### 4.1 Abrir Firebase Console

En el navegador, ve a:
```
https://console.firebase.google.com/
```

#### 4.2 Iniciar Sesión
- Email: `jalvarezgw19@gmail.com`
- Contraseña: [tu contraseña de Google]

#### 4.3 Seleccionar el Proyecto
- Click en el proyecto: **"calculadora-bcv-f1f2f"**

#### 4.4 Ir a Service Accounts

Opción A - Link directo:
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
```

Opción B - Manual:
1. Click en el ⚙️ (Settings) arriba a la izquierda
2. Click en "Configuración del proyecto"
3. Click en la pestaña "Cuentas de servicio"

#### 4.5 Generar Nueva Clave

1. Scroll hacia abajo hasta "SDK de Admin de Firebase"
2. Click en el botón **"Generar nueva clave privada"**
3. Aparecerá un diálogo de confirmación
4. Click en **"Generar clave"**
5. Se descargará un archivo JSON (algo como `calculadora-bcv-f1f2f-firebase-adminsdk-xxxxx-xxxxxxxxxx.json`)

#### 4.6 Renombrar y Mover el Archivo

**Windows (PowerShell):**
```powershell
# Ir a la carpeta de Descargas
cd ~\Downloads

# Renombrar el archivo (ajusta el nombre original)
Rename-Item "calculadora-bcv-f1f2f-firebase-adminsdk-*.json" "serviceAccountKey.json"

# Mover a la carpeta del proyecto
Move-Item "serviceAccountKey.json" "C:\Users\[USUARIO]\Proyectos\CalculadoraBCV\migration\"
```

**Mac/Linux:**
```bash
# Ir a Descargas
cd ~/Downloads

# Renombrar
mv calculadora-bcv-f1f2f-firebase-adminsdk-*.json serviceAccountKey.json

# Mover a la carpeta del proyecto
mv serviceAccountKey.json ~/Proyectos/CalculadoraBCV/migration/
```

**✅ Verificación:**
```bash
cd ~/Proyectos/CalculadoraBCV/migration    # Mac/Linux
cd C:\Users\[USUARIO]\Proyectos\CalculadoraBCV\migration    # Windows

ls serviceAccountKey.json    # Debe existir
```

---

### 🔄 Paso 5: Instalar Dependencias de Node.js

```bash
# Asegúrate de estar en la carpeta migration
cd migration

# Instalar dependencias
npm install
```

**Esto descargará:**
- `firebase-admin` y sus dependencias (~20 MB)
- Creará la carpeta `node_modules/`

**⏱️ Tiempo estimado:** 1-2 minutos

**✅ Verificación:**
```bash
ls node_modules    # Debe existir y tener carpetas dentro
```

---

### 🚀 Paso 6: Ejecutar la Migración

```bash
# Asegúrate de estar en la carpeta migration
npm run migrate
```

**📺 Lo que verás:**

```
🔄 Iniciando migración completa del historial BCV...

📖 Leyendo documentos de Firestore...
📊 Encontrados 1095 registros para consolidar
📅 Rango: 2023-01-03 → 2026-01-27

💾 Guardando documento consolidado...
✅ Documento consolidado creado con 1095 registros

🗑️  Eliminando 1095 documentos antiguos...
   Progreso: 500/1095 (45%)
   Progreso: 1000/1095 (91%)
   Progreso: 1095/1095 (100%)

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  ✅ ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

📊 Registros consolidados: 1095
🗑️  Documentos antiguos eliminados: 1095
📅 Rango de fechas: 2023-01-03 → 2026-01-27

✨ Ahora solo existe el documento 'consolidated' con todo el historial.
```

**⏱️ Tiempo estimado:** 30-60 segundos

---

### ✅ Paso 7: Verificar en Firebase Console

#### 7.1 Abrir Firestore

En el navegador:
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
```

#### 7.2 Verificar

Deberías ver:
- ✅ **SOLO 1 documento:** `consolidated`
- ❌ **NO deberían existir:** documentos con fechas (2023-01-03, 2023-01-04, etc.)

#### 7.3 Abrir el documento `consolidated`

Click en `consolidated` y verifica:
- ✅ Campo `rates`: Array con ~1095 elementos
- ✅ Campo `total_records`: 1095
- ✅ Campo `last_updated`: Timestamp reciente
- ✅ Campo `migration_date`: Timestamp de hoy

---

### 🧹 Paso 8: Limpiar (MUY IMPORTANTE)

**Antes de cerrar sesión o irte:**

```bash
# Eliminar el Service Account Key
cd migration
rm serviceAccountKey.json    # Mac/Linux
del serviceAccountKey.json   # Windows
```

**⚠️ CRÍTICO:** NO dejes este archivo en la computadora de tu amigo.

**✅ Verificación:**
```bash
ls serviceAccountKey.json    # Debe dar error "no existe"
```

---

### 🚪 Paso 9: Cerrar Sesión de Firebase

1. En el navegador, ve a: https://accounts.google.com/
2. Click en tu foto de perfil (arriba a la derecha)
3. Click en "Cerrar sesión"

---

## 🏠 PARTE 3: De Vuelta en Tu Casa

### Paso 1: Verificar que la Migración Funcionó

En el navegador (desde tu casa):
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
```

Deberías ver solo el documento `consolidated`.

### Paso 2: Compilar la App (Opcional)

Si quieres probar la app con los cambios:

```bash
cd c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV

flutter clean
flutter pub get
flutter build apk --split-per-abi
```

---

## 📊 Resumen de Tiempo y Datos

| Paso | Tiempo | Datos |
|------|--------|-------|
| Instalar Git | 2-3 min | ~50 MB |
| Instalar Node.js | 3-5 min | ~100 MB |
| Clonar repo | 2-5 min | ~50 MB |
| Descargar Service Account Key | 1 min | ~2 KB |
| npm install | 1-2 min | ~20 MB |
| Ejecutar migración | 30-60 seg | ~5 MB |
| **TOTAL** | **~15 min** | **~230 MB** |

---

## ⚠️ Troubleshooting

### Error: "git: command not found"
**Solución:** Instalar Git (Paso 1)

### Error: "npm: command not found"
**Solución:** Instalar Node.js (Paso 2)

### Error: "No se encontró el archivo de credenciales"
**Solución:** Verificar que `serviceAccountKey.json` esté en la carpeta `migration/`

### Error: "Permission denied" al ejecutar migración
**Solución:** 
1. Verificar que el archivo `serviceAccountKey.json` sea el correcto
2. Verificar que estés logueado en Firebase Console con la cuenta correcta

### Error: "ECONNREFUSED" o "Network error"
**Solución:** Verificar conexión a internet

### La migración se ejecutó pero no veo cambios en Firestore
**Solución:** 
1. Refrescar la página de Firebase Console (F5)
2. Verificar que estés viendo el proyecto correcto

---

## 📝 Checklist Final

### Antes de Ir:
- [ ] Código subido a GitHub (`git push`)
- [ ] Verificado en GitHub que el código está actualizado

### En la Laptop de tu Amigo:
- [ ] Git instalado y funcionando
- [ ] Node.js instalado y funcionando
- [ ] Repositorio clonado
- [ ] Service Account Key descargado
- [ ] Service Account Key movido a `migration/`
- [ ] `npm install` ejecutado exitosamente
- [ ] `npm run migrate` ejecutado exitosamente
- [ ] Verificado en Firebase Console
- [ ] **Service Account Key eliminado**
- [ ] **Sesión de Google cerrada**

### De Vuelta en Casa:
- [ ] Verificar migración en Firebase Console
- [ ] (Opcional) Compilar app y probar

---

## 🎯 Comandos Rápidos (Resumen)

```bash
# 1. Verificar instalaciones
git --version
node --version
npm --version

# 2. Clonar repo
git clone https://github.com/JAlvarezGW19/CalculadoraBCV.git
cd CalculadoraBCV/migration

# 3. Instalar dependencias
npm install

# 4. Ejecutar migración (después de descargar serviceAccountKey.json)
npm run migrate

# 5. Limpiar
rm serviceAccountKey.json    # Mac/Linux
del serviceAccountKey.json   # Windows
```

---

## ✨ ¡Listo!

Siguiendo esta guía paso a paso, podrás ejecutar la migración sin problemas desde cualquier computadora con buena conexión a internet.

**¿Alguna duda? Revisa la sección de Troubleshooting.** 🚀
