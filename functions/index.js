const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { user } = require('firebase-functions/v1/auth');
// admin.initializeApp();

var serviceAccount = require("./servicekey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://packageguard-d517e-default-rtdb.asia-southeast1.firebasedatabase.app"
});

// exports.updateAlarmStatus = functions.database.ref('devices/SN8124DF9D4/alerts/ALARM_SCALEREMOVED')
//     .onWrite(async (change, context) => {
//         const newValue = change.after.val();
        
//         // Check if Alarm_status is true
//         if (newValue === true) {
//             // Get the isAlarm value to avoid unnecessary updates
//             const isAlarmSnapshot = await admin.database().ref('status/SN8124DF9D4/alerts/alarm').once('value');
//             const isAlarmValue = isAlarmSnapshot.val();

//             // Only proceed if isAlarm is false to avoid unnecessary updates
//             if (isAlarmValue === false || isAlarmValue === undefined) {
//                 // Update isAlarm to true
//                 await admin.database().ref('status/SN8124DF9D4/alerts/alarm').set(true);

//                 // Send FCM notification or perform other actions as needed
//                 // const message = {
//                 //     notification: {
//                 //         title: 'Alarm Notification',
//                 //         body: 'Alarm is triggered!',
//                 //     },
//                 // };
//                 // await admin.messaging().sendToTopic('your_topic', message); // Send to a specific topic

//                 // You can also perform other actions here
//             }
//         } else {
//             // If Alarm_status is not true, you might want to handle it here
//             console.log("waiting for alarm");
//         }
//     });


    exports.updateAlarmStatus = functions.database.ref('devices/{deviceId}')
    .onWrite(async (change, context) => { const deviceId = context.params.deviceId;
        const alertsPath = `devices/${deviceId}/alerts/ALARM_SCALEREMOVED`;
        console.log(deviceId)
        // Get the new value of ALARM_SCALEREMOVED
        const newValue = change.after.child('alerts').child('ALARM_SCALEREMOVED').val();

        // Check if ALARM_SCALEREMOVED is true
        if (newValue === true) {
            // Get the isAlarm value to avoid unnecessary updates
            const isAlarmSnapshot = await admin.database().ref(`status/${deviceId}/alerts/alarm`).once('value');
            const isAlarmValue = isAlarmSnapshot.val();
            console.log("Alerts Taken")

            // Only proceed if isAlarm is false to avoid unnecessary updates
            if (isAlarmValue === false || isAlarmValue === undefined) {
                // Update isAlarm to true
                await admin.database().ref(`status/${deviceId}/alerts/alarm`).set(true);
                const userId = await getUserIdForDevice(deviceId);
                const deviceToken = await getDeviceToken(userId);
                console.log("Device token is: ",deviceToken);

                // Send FCM notification
                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Alarm Notification',
                        body: `Alarm is triggered for device ${deviceId}!`,
                    },
                };
                await admin.messaging().send(message);
                // Store the device ID or perform other actions as needed
                console.log(`ALARM_SCALEREMOVED is true for device ${deviceId}`);

                // You can also send FCM notification or perform other actions here
                
            }
        } else {
            // If ALARM_SCALEREMOVED is not true, you might want to handle it here
            console.log(`Waiting for alarm on device ${deviceId}`);
        }
    });

    // Function to get the device token for a given user ID
async function getDeviceToken(userId) {

    console.log("Inside get Device");
    if (!userId) {
        return null;
    }

    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (userDoc.exists) {
       
        const userData = userDoc.data();
        console.log("Document Exists: ", userData);
        return userData.deviceToken;
    }

    return null;
}

async function getUserIdForDevice(deviceId) {
    const usersCollection = admin.firestore().collection('users');
    const querySnapshot = await usersCollection.where('devices', 'array-contains', deviceId).get();

    if (!querySnapshot.empty) {
        console.log("Got User ID:  ", querySnapshot.docs[0].id);
        return querySnapshot.docs[0].id;
        
    }

    return null;
}