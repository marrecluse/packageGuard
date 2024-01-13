const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();





exports.updateAlarmStatus = functions.database.ref('packageGuard/{userId}/devices/{deviceId}')
    .onWrite(async (change, context) => {
        const deviceId = context.params.deviceId;
        const userId = context.params.userId;

        const userDocRef = admin.firestore().collection('users').doc(userId);
        const userDoc = await userDocRef.get();
        const alertsPath = `devices/${deviceId}/alerts/ALARM_SCALEREMOVED`;
        const newValue = change.after.child('alerts').child('ALARM_SCALEREMOVED').val();


        // Fetch timestamp from the alert node
        const alertSnapshot = change.after.child('alerts');
        const timeStamp = alertSnapshot.child('timeStamp').val();


        if (userDoc.exists) {
            const userData = userDoc.data();
            const devicesArray = userData.devices || [];

            if (!devicesArray.includes(deviceId)) {
                devicesArray.push(deviceId);
                await userDocRef.update({ devices: devicesArray });
            }
        } else {
            console.log(`User document for userID: ${userId} does not exist.`);
        }


        const deviceStatus = admin.database().ref(`status/${deviceId}`);
        const statusSnapshot = await deviceStatus.once('value');
        const statusExists = statusSnapshot.exists();

        if (!statusExists) {
            const alerts = {
                alarm: false,
                alertBattery: false,
                alertPGMoved: false,
                alertScaleAdded: false,
                alertScaleRemoved: false
                // Add more alerts as needed
            };

            const initialStatus = {
                armed: true,
                alerts: alerts
            };

            await deviceStatus.set(initialStatus);

        }



        const statusRef = admin.database().ref(`status/${deviceId}/alerts/alarm`);
        const isAlarmSnapshot = await statusRef.once('value');
        if (newValue === true) {



            // Logging alarm status to Firestore
            const alarmLogRef = admin.firestore().collection('alarmLogs').doc(userId).collection('alarmLogs');
            const logData = {
                userId: userId,
                deviceId: deviceId,
                alarming: newValue,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            };

            // Adding the alarm log to Firestore
            await alarmLogRef.add(logData);








            if (!isAlarmSnapshot.exists()) {
                const isAlarmValue = isAlarmSnapshot.val();

                await statusRef.set(true);

                const deviceToken = await getDeviceToken(userId);
                if (deviceToken) {
                    const message = {
                        token: deviceToken,
                        notification: {
                            title: 'Theft Alert Notification',
                            body: `The device ${deviceId} is alarming becuase package has been removed without disarming the device.`,
                        },
                    };
                    await admin.messaging().send(message);
                }
            }
            
            else {

                const isAlarmValue = isAlarmSnapshot.val();
                if (isAlarmValue === false || isAlarmValue === undefined) {
                    await admin.database().ref(`status/${deviceId}/alerts/alarm`).set(true);
                    const deviceToken = await getDeviceToken(userId);
                    if (deviceToken) {
                        const message = {
                            token: deviceToken,
                            notification: {
                                title: 'Alarm Notification',
                                body: `Alarm is triggered for device ${deviceId}!`,
                            },
                        };
                        await admin.messaging().send(message);
                    }

                }

            }

        }

    });




exports.storeAlertsAndNotify = functions.database.ref('packageGuard/{userId}/devices/{deviceId}/alerts/{alertType}')
    .onUpdate(async (change, context) => {
        const userId = context.params.userId;
        const deviceId = context.params.deviceId;
        const alertType = context.params.alertType;

        const newValue = change.after.val();
        const previousValue = change.before.val();

        console.log(`Device ID: ${deviceId}, Alert Type: ${alertType}, New Value: ${newValue}, Previous Value: ${previousValue}`);

        if (newValue !== previousValue && newValue === true) {
            const alertMessage = getAlertMessage(alertType, deviceId);

            console.log(`Alert triggered: ${alertType}`);

            // Store alert in Firestore collection
            await admin.firestore().collection('alerts').doc(userId).collection('alertsLog').add({
                deviceId: deviceId,
                alertType: alertType,
                alertValue: newValue,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            });
            console.log(`Alert stored in Firestore`);


            // Update status node to set alerts to false
            // Update alerts to false except for "ALARM_SCALEREMOVED"


            // Map alert types to corresponding status keys
            const statusKeyMap = {
                ALERT_BATTERY: 'alertBattery',
                ALERT_PGMOVED: 'alertPGMoved',
                ALERT_SCALEADDED: 'alertScaleAdded',
                ALERT_SCALEREMOVED: 'alertScaleRemoved',
                // Add more mappings as needed
            };

            const statusKey = statusKeyMap[alertType];
            if (statusKey) {
                await admin.database().ref(`status/${deviceId}/alerts/${statusKey}`).set(false);
                console.log(`Status updated for ${statusKey}`);
            }



            // Send push notification
            if (alertType !== 'ALARM_SCALEREMOVED') {


                const deviceToken = await getDeviceToken(userId);
                if (deviceToken) {
                    const message = {
                        token: deviceToken,
                        notification: {
                            title: `Alert Notification for ${deviceId}`,
                            body: alertMessage,
                        },
                    };
                    await admin.messaging().send(message);
                    console.log(`Push notification sent to device`);
                } else {
                    console.log(`Device token not found for device: ${deviceId}`);
                }


            }
        }
    });




exports.checkDeviceStatus = functions.database.ref('packageGuard/{userId}/devices/{deviceId}')
    .onUpdate(async (change, context) => {
        const deviceId = context.params.deviceId;
        const userId = context.params.userId;

        console.log(`Device update detected for userId: ${userId}, deviceId: ${deviceId}`);

        const deviceRef = admin.database().ref(`packageGuard/${userId}/devices/${deviceId}`);
        const deviceSnapshot = await deviceRef.once('value');
        const lastDeviceTimeStamp = deviceSnapshot.child('deviceTimeStamp').val();

        const currentTime = Date.now();
        const twoMinutes = 2 * 60 * 1000; // 2 minutes in milliseconds

        console.log(`Last Device TimeStamp: ${lastDeviceTimeStamp}, Current Time: ${currentTime}`);
        if (lastDeviceTimeStamp && (currentTime - lastDeviceTimeStamp) >= twoMinutes) {
            console.log(`Device ${deviceId} is offline`);

            // Update status to 'offline'
            const onlineAlertsRef = admin.firestore().collection('devices').doc(deviceId);
            await onlineAlertsRef.set({
                userId: userId,
                deviceId: deviceId,
                status: 'offline',
                onlineTimestamp: currentTime // Set the online timestamp as current time
            });

            console.log(`Offline status updated for device ${deviceId}`);
        } else {
            console.log(`Device ${deviceId} is online`);

            // Update status to 'online'
            const offlineAlertsRef = admin.firestore().collection('devices').doc(deviceId);
            await offlineAlertsRef.set({
                userId: userId,
                deviceId: deviceId,
                status: 'online',
                offlineTimestamp: currentTime // Set the offline timestamp as current time
            });

            console.log(`Online status updated for device ${deviceId}`);
        }







    });







// Function to get alert message based on type
function getAlertMessage(alertType, deviceId) {
    switch (alertType) {
        case 'ALERT_SCALEADDED':
            return `Package has been added`;
        case 'ALERT_SCALEREMOVED':
            return `Package has been removed from device!`;
        case 'ALERT_PGMOVED':
            return `Package has been moved from device!`;
        case 'ALERT_BATTERY':
            return `${deviceId} battery is low.`;

    }
}



async function getDeviceToken(userId) {
    if (!userId) {
        return null;
    }

    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (userDoc.exists) {
        const userData = userDoc.data();
        return userData.deviceToken;
    }

    return null;
}





















// /// WORKING 

// const functions = require('firebase-functions');
// const admin = require('firebase-admin');

// admin.initializeApp();

// exports.updateAlarmStatus = functions.database.ref('packageGuard/{userId}/devices/{deviceId}')
//     .onWrite(async (change, context) => {
//         const deviceId = context.params.deviceId;
//         const userId = context.params.userId;

//         const alertsPath = `devices/${deviceId}/alerts/ALARM_SCALEREMOVED`;
//         const newValue = change.after.child('alerts').child('ALARM_SCALEREMOVED').val();

//         if (newValue === true) {
//             const isAlarmSnapshot = await admin.database().ref(`status/${deviceId}/alerts/alarm`).once('value');
//             const isAlarmValue = isAlarmSnapshot.val();

//             if (isAlarmValue === false || isAlarmValue === undefined) {
//                 await admin.database().ref(`status/${deviceId}/alerts/alarm`).set(true);

//                 const userDocRef = admin.firestore().collection('users').doc(userId);
//                 const userDoc = await userDocRef.get();

//                 if (userDoc.exists) {
//                     const userData = userDoc.data();
//                     const devicesArray = userData.devices || [];

//                     if (!devicesArray.includes(deviceId)) {
//                         devicesArray.push(deviceId);
//                         await userDocRef.update({ devices: devicesArray });
//                     }

//                     const deviceToken = await getDeviceToken(userId);
//                     if (deviceToken) {
//                         const message = {
//                             token: deviceToken,
//                             notification: {
//                                 title: 'Alarm Notification',
//                                 body: `Alarm is triggered for device ${deviceId}!`,
//                             },
//                         };
//                         await admin.messaging().send(message);
//                     }
//                 }
//             }
//         }
//     });

// async function getDeviceToken(userId) {
//     if (!userId) {
//         return null;
//     }

//     const userDoc = await admin.firestore().collection('users').doc(userId).get();
//     if (userDoc.exists) {
//         const userData = userDoc.data();
//         return userData.deviceToken;
//     }

//     return null;
// }
