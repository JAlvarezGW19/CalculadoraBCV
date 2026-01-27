/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();

// Configuración de la API
const API_URL = "https://api.dolarvzla.com/public/exchange-rate";
// TU API KEY OFICIAL:
const API_KEY = "798f19b1e6a96e1a58ad864348abaf4b9b429d354c3a26e855d91181fb8eacfc";

// 1. ROBOT AUTOMÁTICO (Cada 30 min)
export const updateBcvRate = onSchedule(
    {
        schedule: "every 30 minutes",
        timeoutSeconds: 60,
        region: "us-central1",
    },
    async (event) => {
        logger.info("Iniciando actualización de tasas BCV...");

        // Intentar usar la API Oficial (CON TU KEY)
        try {
            const response = await axios.get(API_URL, {
                headers: { "x-dolarvzla-key": API_KEY },
            });

            if (response.status === 200) {
                const data = processApiResponse(response.data);
                await saveToFirestore(data);
                logger.info("Actualizado vía API Exitosamente: ", data);
                return;
            }
        } catch (error) {
            logger.error("Error API Key, intentando scraping como fallback...", error);
        }

        // Fallback: Web Scraping del sitio BCV
        try {
            const response = await axios.get("http://www.bcv.org.ve/", {
                headers: {
                    "User-Agent":
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
                },
                timeout: 15000
            });

            if (response.status === 200) {
                const html = response.data;
                const data = parseBcvHtml(html);
                await saveToFirestore(data);
                logger.info("Actualizado vía Scraping Exitosamente");
            }
        } catch (error) {
            logger.error("Error haciendo Scraping al BCV", error);
        }
    }
);

// 2. FUNCIÓN PARA IMPORTAR HISTORIAL COMPLETO DESDE LA API
export const syncHistory = onRequest(async (req, res) => {
    if (!API_KEY) {
        res.status(400).send("Falta la API Key en la configuración.");
        return;
    }

    try {
        // Pedimos la lista completa a la API
        const response = await axios.get("https://api.dolarvzla.com/public/exchange-rate/list", {
            headers: { "x-dolarvzla-key": API_KEY },
        });

        const payload = response.data;
        const historyList = Array.isArray(payload) ? payload : payload.rates;

        if (response.status === 200 && Array.isArray(historyList)) {
            const db = admin.firestore();

            // Preparar el array de tasas para el documento consolidado
            const ratesArray = historyList
                .filter((item: any) => item.date && item.usd)
                .map((item: any) => ({
                    rate_date: (item.date as string).split("T")[0], // YYYY-MM-DD
                    usd: parseFloat(item.usd),
                    eur: parseFloat(item.eur || item.usd), // Fallback si no hay EUR
                    source: 'api_history_import'
                }))
                .sort((a: any, b: any) => a.rate_date.localeCompare(b.rate_date)); // Ordenar por fecha

            // Guardar en un solo documento consolidado
            await db.collection("historial_tasas").doc("consolidated").set({
                rates: ratesArray,
                last_updated: admin.firestore.FieldValue.serverTimestamp(),
                total_records: ratesArray.length
            });

            res.status(200).send(`✅ ¡Éxito! Se importaron ${ratesArray.length} registros históricos en el documento consolidado.`);
        } else {
            res.status(500).send("La API no devolvió una lista válida.");
        }
    } catch (error) {
        logger.error(error);
        res.status(500).send("Error importando historial: " + error);
    }
});

// 3. FUNCIÓN PARA MIGRAR TODOS LOS DOCUMENTOS EXISTENTES Y ELIMINAR LOS ANTIGUOS
export const migrateToConsolidated = onRequest(async (req, res) => {
    try {
        const db = admin.firestore();

        logger.info("🔄 Iniciando migración completa...");

        // Leer TODOS los documentos existentes (sin límite)
        const snapshot = await db.collection("historial_tasas")
            .orderBy("rate_date")
            .get();

        const ratesArray: any[] = [];
        const docsToDelete: string[] = [];

        snapshot.docs.forEach(doc => {
            // Saltar el documento consolidado si ya existe
            if (doc.id === "consolidated") {
                logger.info("⏭️ Saltando documento consolidado existente");
                return;
            }

            const data = doc.data();
            if (data.rate_date && data.usd) {
                ratesArray.push({
                    rate_date: data.rate_date.split("T")[0],
                    usd: parseFloat(data.usd),
                    eur: parseFloat(data.eur || data.usd),
                    source: data.source || 'migration'
                });

                // Marcar para eliminar
                docsToDelete.push(doc.id);
            }
        });

        logger.info(`📊 Encontrados ${ratesArray.length} registros para consolidar`);

        // Ordenar por fecha
        ratesArray.sort((a, b) => a.rate_date.localeCompare(b.rate_date));

        // Guardar en documento consolidado
        await db.collection("historial_tasas").doc("consolidated").set({
            rates: ratesArray,
            last_updated: admin.firestore.FieldValue.serverTimestamp(),
            total_records: ratesArray.length,
            migration_date: admin.firestore.FieldValue.serverTimestamp()
        });

        logger.info(`✅ Documento consolidado creado con ${ratesArray.length} registros`);

        // Eliminar documentos antiguos en lotes de 500 (límite de Firestore)
        let deletedCount = 0;
        const batchSize = 500;

        for (let i = 0; i < docsToDelete.length; i += batchSize) {
            const batch = db.batch();
            const chunk = docsToDelete.slice(i, i + batchSize);

            chunk.forEach(docId => {
                const docRef = db.collection("historial_tasas").doc(docId);
                batch.delete(docRef);
            });

            await batch.commit();
            deletedCount += chunk.length;
            logger.info(`🗑️ Eliminados ${deletedCount}/${docsToDelete.length} documentos antiguos`);
        }

        const message = `
✅ ¡Migración completada exitosamente!

📊 Registros consolidados: ${ratesArray.length}
🗑️ Documentos antiguos eliminados: ${deletedCount}
📅 Rango de fechas: ${ratesArray[0]?.rate_date} → ${ratesArray[ratesArray.length - 1]?.rate_date}

Ahora solo existe el documento 'consolidated' con todo el historial.
        `;

        logger.info(message);
        res.status(200).send(message);

    } catch (error) {
        logger.error("❌ Error en migración:", error);
        res.status(500).send("Error en migración: " + error);
    }
});


// --- Funciones de Ayuda ---

function parseBcvHtml(html: string) {
    // Regex compatible
    const usdRegex = /id="dolar"[\s\S]*?<strong>\s*([\d,]+)\s*<\/strong>/;
    const eurRegex = /id="euro"[\s\S]*?<strong>\s*([\d,]+)\s*<\/strong>/;

    const usdMatch = html.match(usdRegex);
    const eurMatch = html.match(eurRegex);

    if (!usdMatch || !eurMatch) {
        throw new Error("No se pudieron encontrar las tasas en el HTML");
    }

    const usd = parseFloat(usdMatch[1].replace(",", "."));
    const eur = parseFloat(eurMatch[1].replace(",", "."));
    const now = new Date();
    const hour = new Date().getUTCHours() - 4;
    const isLate = hour >= 16;

    return {
        usd: usd,
        eur: eur,
        date: now.toISOString(),
        has_tomorrow: isLate,
        rate_date: now.toISOString(),
        source: 'scraping'
    };
}

function processApiResponse(data: any) {
    const current = data.current;

    const now = new Date();
    // Ajustar a VET
    const vetNow = new Date(now.toLocaleString("en-US", { timeZone: "America/Caracas" }));
    const todayStr = vetNow.toISOString().split('T')[0];

    // Fecha de la tasa que viene de la API
    const rateDate = new Date(current.date);
    const rateDateStr = rateDate.toISOString().split('T')[0];

    const hasTomorrow = rateDateStr > todayStr;

    return {
        usd: parseFloat(current.usd),
        eur: parseFloat(current.eur),
        date: new Date().toISOString(),
        has_tomorrow: hasTomorrow,
        rate_date: current.date,
        source: 'api_key'
    };
}

async function saveToFirestore(data: any) {
    const db = admin.firestore();

    // 1. Guardar la tasa actual
    await db.collection("tasa_oficial").doc("bcv").set(data, { merge: true });

    // 2. Guardar en Historial CONSOLIDADO
    if (data.rate_date) {
        const dateId = data.rate_date.split("T")[0]; // YYYY-MM-DD

        // Agregar o actualizar la tasa en el array del documento consolidado
        const consolidatedRef = db.collection("historial_tasas").doc("consolidated");

        try {
            await db.runTransaction(async (transaction) => {
                const doc = await transaction.get(consolidatedRef);

                let ratesArray: any[] = [];
                if (doc.exists) {
                    ratesArray = doc.data()?.rates || [];
                }

                // Buscar si ya existe una entrada para esta fecha
                const existingIndex = ratesArray.findIndex((r: any) => r.rate_date === dateId);

                const newEntry = {
                    rate_date: dateId,
                    usd: data.usd,
                    eur: data.eur,
                    source: data.source
                };

                if (existingIndex >= 0) {
                    // Actualizar entrada existente
                    ratesArray[existingIndex] = newEntry;
                } else {
                    // Agregar nueva entrada
                    ratesArray.push(newEntry);
                }

                // Ordenar por fecha
                ratesArray.sort((a: any, b: any) => a.rate_date.localeCompare(b.rate_date));

                // NO limitamos el historial - guardamos todo desde 2023

                transaction.set(consolidatedRef, {
                    rates: ratesArray,
                    last_updated: admin.firestore.FieldValue.serverTimestamp(),
                    total_records: ratesArray.length
                }, { merge: true });
            });

            logger.info(`✅ Historial consolidado actualizado para ${dateId}`);
        } catch (error) {
            logger.error("❌ Error actualizando historial consolidado:", error);
        }
    }
}
