# 📄 GUÍA RÁPIDA - PARA IMPRIMIR

## ✅ CHECKLIST RÁPIDO

### ANTES DE IR (En tu casa):
```bash
cd c:\Users\Juan\Documents\Proyectos\Apps\CalculadoraBCV\CalculadoraBCV
git add .
git commit -m "feat: migración historial"
git push origin main
```

---

## EN LA LAPTOP DE TU AMIGO:

### 1️⃣ INSTALAR GIT (si no está)
- Windows: https://git-scm.com/download/win
- Verificar: `git --version`

### 2️⃣ INSTALAR NODE.JS (si no está)
- Windows: https://nodejs.org/ (versión LTS)
- Verificar: `node --version` y `npm --version`

### 3️⃣ CLONAR REPOSITORIO
```bash
git clone https://github.com/JAlvarezGW19/CalculadoraBCV.git
cd CalculadoraBCV/migration
```

### 4️⃣ DESCARGAR SERVICE ACCOUNT KEY
1. Ir a: https://console.firebase.google.com/
2. Login: jalvarezgw19@gmail.com
3. Proyecto: calculadora-bcv-f1f2f
4. Settings ⚙️ → Cuentas de servicio
5. "Generar nueva clave privada"
6. Descargar JSON
7. Renombrar a: `serviceAccountKey.json`
8. Mover a: `CalculadoraBCV/migration/`

### 5️⃣ INSTALAR DEPENDENCIAS
```bash
cd migration
npm install
```

### 6️⃣ EJECUTAR MIGRACIÓN
```bash
npm run migrate
```

### 7️⃣ VERIFICAR
- Ir a: https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas
- Debe existir SOLO el documento `consolidated`

### 8️⃣ LIMPIAR (IMPORTANTE)
```bash
del serviceAccountKey.json    # Windows
rm serviceAccountKey.json     # Mac/Linux
```

### 9️⃣ CERRAR SESIÓN
- Google: https://accounts.google.com/ → Cerrar sesión

---

## LINKS IMPORTANTES:

**Firebase Console:**
https://console.firebase.google.com/project/calculadora-bcv-f1f2f

**Service Accounts:**
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk

**Firestore:**
https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas

**GitHub Repo:**
https://github.com/JAlvarezGW19/CalculadoraBCV

---

## TIEMPO ESTIMADO: ~15 minutos
## DATOS NECESARIOS: ~230 MB

---

## ⚠️ NO OLVIDES:
- [ ] Eliminar serviceAccountKey.json
- [ ] Cerrar sesión de Google
- [ ] Verificar en Firestore que funcionó

---

**Cuenta:** jalvarezgw19@gmail.com  
**Proyecto:** calculadora-bcv-f1f2f
