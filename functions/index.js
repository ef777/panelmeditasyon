/* eslint-disable require-jsdoc */
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

function getMonthNumber(date) {
  return date.getMonth() + 1;
}

async function updateSt(docRef, st) {
  try {
    await docRef.set(st, {merge: true});
  } catch (error) {
    throw new Error(`Doküman kaydedilirken bir hata oluştu: ${error}`);
  }
}

exports.updateCurrentDocument = functions.pubsub
    .schedule("0 0 * * *")
    .onRun(async (context) => {
      try {
        const now = new Date();
        const year = now.getFullYear();
        const month = getMonthNumber(now);
        const day = now.getDate();
        const docId = `${day}-${month}-${year}`;

        const dailyStDocRef =
          admin.firestore().collection("statistics").doc(docId);

        const dailySt = {
          date: admin.firestore.Timestamp.now(),
          dailyTotalRevenue: 0,
          dailyNewUsers: 0,
          dailyNewsub: 0,
          dailyUniqueListeners: 0,
          dailyMdListens: 0,
          dailyMdPlays: 0,
          monthlyTotalRevenue: 0,
          monthlyNewUsers: 0,
          monthlyNewsub: 0,
          monthlyUniqueListeners: 0,
          monthlyMdListens: 0,
          monthlyMdPlays: 0,
          yearlyTotalRevenue: 0,
          yearlyNewUsers: 0,
          yearlyNewsub: 0,
          yearlyUniqueListeners: 0,
          yearlyMdListens: 0,
          yearlyMdPlays: 0,
        };

        const dataCollectionRef = admin.firestore().collection("data");
        const referenceDoc = dataCollectionRef.doc("reference");
        await referenceDoc.set({daily: docId});

        const prevDate = new Date(now);
        prevDate.setDate(prevDate.getDate() - 1);
        const prevDay = prevDate.getDate();
        const prevMonth = getMonthNumber(prevDate);
        const prevYear = prevDate.getFullYear();
        const prevDocId = `${prevDay}-${prevMonth}-${prevYear}`;

        const prevStDocRef =
          admin.firestore().collection("statistics").doc(prevDocId);
        const prevStDoc = await prevStDocRef.get();

        if (prevStDoc.exists) {
          const prevStData = prevStDoc.data();
          const updatedSt = {...dailySt};

          updatedSt.dailyTotalRevenue += prevStData.dailyTotalRevenue;
          updatedSt.dailyNewUsers += prevStData.dailyNewUsers;
          updatedSt.dailyNewsub += prevStData.dailyNewsub;
          updatedSt.dailyUniqueListeners += prevStData.dailyUniqueListeners;
          updatedSt.dailyMdListens += prevStData.dailyMdListens;
          updatedSt.dailyMdPlays += prevStData.dailyMdPlays;

          if (prevStData.date.toDate().getFullYear() === year &&
            prevStData.date.toDate().getMonth() + 1 === month) {
            updatedSt.monthlyTotalRevenue += prevStData.dailyTotalRevenue;
            updatedSt.monthlyNewUsers += prevStData.dailyNewUsers;
            updatedSt.monthlyNewsub += prevStData.dailyNewsub;
            updatedSt.monthlyUniqueListeners += prevStData.dailyUniqueListeners;
            updatedSt.monthlyMdListens += prevStData.dailyMdListens;
            updatedSt.monthlyMdPlays += prevStData.dailyMdPlays;
          }

          updatedSt.yearlyTotalRevenue += prevStData.dailyTotalRevenue;
          updatedSt.yearlyNewUsers += prevStData.dailyNewUsers;
          updatedSt.yearlyNewsub += prevStData.dailyNewsub;
          updatedSt.yearlyUniqueListeners += prevStData.dailyUniqueListeners;
          updatedSt.yearlyMdListens += prevStData.dailyMdListens;
          updatedSt.yearlyMdPlays += prevStData.dailyMdPlays;

          await updateSt(dailyStDocRef, updatedSt);
        } else {
          await updateSt(dailyStDocRef, dailySt);
        }
      } catch (error) {
        console.error(error);
        // E-mail send functionality is required here
        throw new functions.https.HttpsError("internal", "hata");
      }
    });
