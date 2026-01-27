# 🚀 Script de Migración de Historial

Este script consolida todos los documentos del historial de tasas en un solo documento y elimina los antiguos.

## 📋 Requisitos Previos

- Node.js instalado
- Acceso a Firebase Console

## 🎯 Pasos para Ejecutar la Migración

### 1️⃣ Descargar Service Account Key

1. **Abre Firebase Console:**
   ```
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk
   ```

2. **Haz clic en "Generar nueva clave privada"**

3. **Descarga el archivo JSON**

4. **Guárdalo en esta carpeta (`migration/`) con el nombre:**
   ```
   serviceAccountKey.json
   ```

### 2️⃣ Instalar Dependencias

```bash
cd migration
npm install
```

### 3️⃣ Ejecutar la Migración

```bash
npm run migrate
```

### 4️⃣ Verificar Resultado

Deberías ver algo como:

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

### 5️⃣ Verificar en Firebase Console

Abre:
```
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas/consolidated
```

Deberías ver:
- ✅ Solo 1 documento: `consolidated`
- ✅ Campo `rates` con un array de ~1095 elementos
- ✅ Campo `total_records: 1095`

## ⚠️ Notas Importantes

- ✅ **Es seguro ejecutar múltiples veces** - No duplica datos
- ✅ **Copia antes de eliminar** - Los datos se consolidan primero
- ❌ **NO subas `serviceAccountKey.json` a Git** - Ya está en `.gitignore`

## 🔒 Seguridad

El archivo `serviceAccountKey.json` contiene credenciales sensibles. **NUNCA** lo compartas ni lo subas a repositorios públicos.

## ❓ Troubleshooting

### Error: "No se encontró el archivo de credenciales"

**Solución:** Descarga el Service Account Key desde Firebase Console y guárdalo como `serviceAccountKey.json` en esta carpeta.

### Error: "Permission denied"

**Solución:** Verifica que tu cuenta de Firebase tenga permisos de administrador en el proyecto.

### Error: "ECONNREFUSED"

**Solución:** Verifica tu conexión a internet y que Firestore esté habilitado en tu proyecto.

## 📞 Soporte

Si tienes problemas, revisa:
1. Firebase Console → Firestore Database
2. Logs del script (se muestran en la terminal)
3. Verifica que el Service Account Key sea correcto
