const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.updateAlarmStatus = functions.database.ref('devices/SN8124DF9D4/alerts/ALARM_SCALERMOVED')
    .onWrite(async (change, context) => {
        const newValue = change.after.val();
        
        // Check if Alarm_status is true
        if (newValue === true) {
            // Get the isAlarm value to avoid unnecessary updates
            const isAlarmSnapshot = await admin.database().ref('devices/SN83C048DF9D4_status/alarm').once('value');
            const isAlarmValue = isAlarmSnapshot.val();

            // Only proceed if isAlarm is false to avoid unnecessary updates
            if (isAlarmValue === false || isAlarmValue === undefined) {
                // Update isAlarm to true
                await admin.database().ref('devices/SN83C048DF9D4_status/alarm').set(true);

                // Send FCM notification or perform other actions as needed
                // const message = {
                //     notification: {
                //         title: 'Alarm Notification',
                //         body: 'Alarm is triggered!',
                //     },
                // };
                // await admin.messaging().sendToTopic('your_topic', message); // Send to a specific topic

                // You can also perform other actions here
            }
        } else {
            // If Alarm_status is not true, you might want to handle it here
            console.log("waiting for alarm");
        }
    });