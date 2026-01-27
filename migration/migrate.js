/**
 * Script de Migración de Historial BCV
 * 
 * Este script consolida todos los documentos de historial_tasas
 * en un solo documento y elimina los antiguos.
 * 
 * INSTRUCCIONES:
 * 1. Descarga tu Service Account Key desde Firebase Console
 * 2. Guárdalo como 'serviceAccountKey.json' en esta carpeta
 * 3. Ejecuta: npm install
 * 4. Ejecuta: npm run migrate
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Verificar que existe el archivo de credenciales
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
    console.error(`
❌ ERROR: No se encontró el archivo de credenciales.

📋 PASOS PARA OBTENERLO:

1. Ve a Firebase Console:
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/settings/serviceaccounts/adminsdk

2. Haz clic en "Generar nueva clave privada"

3. Descarga el archivo JSON

4. Guárdalo en esta carpeta como: serviceAccountKey.json

5. Ejecuta nuevamente: npm run migrate
  `);
    process.exit(1);
}

// Inicializar Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateToConsolidated() {
    try {
        console.log('\n🔄 Iniciando migración completa del historial BCV...\n');

        // Leer TODOS los documentos existentes
        console.log('📖 Leyendo documentos de Firestore...');
        const snapshot = await db.collection('historial_tasas')
            .orderBy('rate_date')
            .get();

        const ratesArray = [];
        const docsToDelete = [];

        snapshot.docs.forEach(doc => {
            // Saltar el documento consolidado si ya existe
            if (doc.id === 'consolidated') {
                console.log('⏭️  Saltando documento consolidado existente');
                return;
            }

            const data = doc.data();
            if (data.rate_date && data.usd) {
                ratesArray.push({
                    rate_date: data.rate_date.split('T')[0],
                    usd: parseFloat(data.usd),
                    eur: parseFloat(data.eur || data.usd),
                    source: data.source || 'migration'
                });

                // Marcar para eliminar
                docsToDelete.push(doc.id);
            }
        });

        console.log(`\n📊 Encontrados ${ratesArray.length} registros para consolidar`);

        if (ratesArray.length === 0) {
            console.log('\n⚠️  No hay registros para migrar. Abortando.');
            process.exit(0);
        }

        // Ordenar por fecha
        ratesArray.sort((a, b) => a.rate_date.localeCompare(b.rate_date));

        console.log(`📅 Rango: ${ratesArray[0].rate_date} → ${ratesArray[ratesArray.length - 1].rate_date}`);

        // Guardar en documento consolidado
        console.log('\n💾 Guardando documento consolidado...');
        await db.collection('historial_tasas').doc('consolidated').set({
            rates: ratesArray,
            last_updated: admin.firestore.FieldValue.serverTimestamp(),
            total_records: ratesArray.length,
            migration_date: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`✅ Documento consolidado creado con ${ratesArray.length} registros`);

        // Eliminar documentos antiguos en lotes de 500
        console.log(`\n🗑️  Eliminando ${docsToDelete.length} documentos antiguos...`);
        let deletedCount = 0;
        const batchSize = 500;

        for (let i = 0; i < docsToDelete.length; i += batchSize) {
            const batch = db.batch();
            const chunk = docsToDelete.slice(i, i + batchSize);

            chunk.forEach(docId => {
                const docRef = db.collection('historial_tasas').doc(docId);
                batch.delete(docRef);
            });

            await batch.commit();
            deletedCount += chunk.length;

            const progress = Math.round((deletedCount / docsToDelete.length) * 100);
            console.log(`   Progreso: ${deletedCount}/${docsToDelete.length} (${progress}%)`);
        }

        console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  ✅ ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

📊 Registros consolidados: ${ratesArray.length}
🗑️  Documentos antiguos eliminados: ${deletedCount}
📅 Rango de fechas: ${ratesArray[0].rate_date} → ${ratesArray[ratesArray.length - 1].rate_date}

✨ Ahora solo existe el documento 'consolidated' con todo el historial.

🔍 Verifica en Firebase Console:
   https://console.firebase.google.com/project/calculadora-bcv-f1f2f/firestore/data/historial_tasas/consolidated

📱 Próximo paso: Compila y prueba la app Flutter
    `);

        process.exit(0);

    } catch (error) {
        console.error('\n❌ Error en migración:', error);
        console.error('\nDetalles del error:', error.message);
        process.exit(1);
    }
}

// Ejecutar migración
migrateToConsolidated();
