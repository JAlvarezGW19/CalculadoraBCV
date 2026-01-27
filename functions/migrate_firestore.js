/**
 * Script para migrar historial a documento consolidado
 * 
 * PASOS PREVIOS:
 * 1. Descarga la clave privada desde Firebase Console:
 *    - Ve a Configuración del proyecto → Cuentas de servicio
 *    - Clic en "Generar nueva clave privada"
 *    - Guarda el archivo como "serviceAccountKey.json" en esta carpeta (functions/)
 * 
 * 2. Instala dependencias (solo la primera vez):
 *    npm install firebase-admin
 * 
 * 3. Ejecutar:
 *    node migrate_firestore.js
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Buscar el archivo de clave de servicio
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
    console.error(`
❌ ERROR: No se encontró el archivo de clave de servicio.

Por favor:
1. Ve a Firebase Console → Configuración del proyecto → Cuentas de servicio
2. Haz clic en "Generar nueva clave privada"
3. Guarda el archivo descargado como "serviceAccountKey.json" en:
   ${__dirname}

Luego ejecuta este script nuevamente.
    `);
    process.exit(1);
}

const serviceAccount = require('./serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateToConsolidated() {
    try {
        console.log('🔄 Iniciando migración completa...\n');

        // Leer TODOS los documentos existentes
        console.log('📖 Leyendo documentos existentes...');
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

        console.log(`📊 Encontrados ${ratesArray.length} registros para consolidar`);
        console.log(`🗑️  Se eliminarán ${docsToDelete.length} documentos antiguos\n`);

        // Confirmar antes de proceder
        console.log('⚠️  IMPORTANTE: Esta operación:');
        console.log('   - Creará/actualizará el documento "consolidated"');
        console.log(`   - Eliminará ${docsToDelete.length} documentos individuales`);
        console.log('   - Esta acción NO se puede deshacer\n');

        // Ordenar por fecha
        ratesArray.sort((a, b) => a.rate_date.localeCompare(b.rate_date));

        // Guardar en documento consolidado
        console.log('💾 Guardando documento consolidado...');
        await db.collection('historial_tasas').doc('consolidated').set({
            rates: ratesArray,
            last_updated: admin.firestore.FieldValue.serverTimestamp(),
            total_records: ratesArray.length,
            migration_date: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`✅ Documento consolidado creado con ${ratesArray.length} registros\n`);

        // Eliminar documentos antiguos en lotes de 500
        console.log('🗑️  Eliminando documentos antiguos...');
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
╔════════════════════════════════════════════════════════════╗
║          ✅ ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!            ║
╚════════════════════════════════════════════════════════════╝

📊 Registros consolidados: ${ratesArray.length}
🗑️  Documentos antiguos eliminados: ${deletedCount}
📅 Rango de fechas: ${ratesArray[0]?.rate_date} → ${ratesArray[ratesArray.length - 1]?.rate_date}

Ahora solo existe el documento 'consolidated' con todo el historial.

PRÓXIMOS PASOS:
1. Verifica en Firebase Console que el documento 'consolidated' existe
2. Despliega las Cloud Functions actualizadas
3. Actualiza la app Flutter para usar el nuevo servicio
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
