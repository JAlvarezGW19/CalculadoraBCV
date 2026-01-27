/**
 * Script local para migrar historial a documento consolidado
 * Ejecutar con: node migrate_local.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../android/app/google-services.json');

// Inicializar Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert({
        projectId: serviceAccount.project_info.project_id,
        clientEmail: `firebase-adminsdk@${serviceAccount.project_info.project_id}.iam.gserviceaccount.com`,
        privateKey: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n" // Necesitarás obtener esto de Firebase Console
    })
});

const db = admin.firestore();

async function migrateToConsolidated() {
    try {
        console.log('🔄 Iniciando migración completa...');

        // Leer TODOS los documentos existentes
        const snapshot = await db.collection('historial_tasas')
            .orderBy('rate_date')
            .get();

        const ratesArray = [];
        const docsToDelete = [];

        snapshot.docs.forEach(doc => {
            // Saltar el documento consolidado si ya existe
            if (doc.id === 'consolidated') {
                console.log('⏭️ Saltando documento consolidado existente');
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

        // Ordenar por fecha
        ratesArray.sort((a, b) => a.rate_date.localeCompare(b.rate_date));

        // Guardar en documento consolidado
        await db.collection('historial_tasas').doc('consolidated').set({
            rates: ratesArray,
            last_updated: admin.firestore.FieldValue.serverTimestamp(),
            total_records: ratesArray.length,
            migration_date: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`✅ Documento consolidado creado con ${ratesArray.length} registros`);

        // Eliminar documentos antiguos en lotes de 500
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
            console.log(`🗑️ Eliminados ${deletedCount}/${docsToDelete.length} documentos antiguos`);
        }

        console.log(`
✅ ¡Migración completada exitosamente!

📊 Registros consolidados: ${ratesArray.length}
🗑️ Documentos antiguos eliminados: ${deletedCount}
📅 Rango de fechas: ${ratesArray[0]?.rate_date} → ${ratesArray[ratesArray.length - 1]?.rate_date}

Ahora solo existe el documento 'consolidated' con todo el historial.
    `);

        process.exit(0);

    } catch (error) {
        console.error('❌ Error en migración:', error);
        process.exit(1);
    }
}

migrateToConsolidated();
