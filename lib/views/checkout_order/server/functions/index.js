const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");

initializeApp();

const messages = {
  pending: "Quán đã tiếp nhận đơn hàng.",
  preparing: "Quán đang chuẩn bị đơn hàng.",
  ready: "Đơn hàng đã sẵn sàng để nhận tại quán.",
  delivering: "Đơn hàng đang được giao.",
  completed: "Đơn hàng đã hoàn tất.",
  cancelled: "Đơn hàng đã bị hủy.",
};

exports.notifyCheckoutStatus = onDocumentUpdated("orders/{orderId}", async (event) => {
  if (!event.data) return;
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status || !Object.hasOwn(messages, after.status)) return;
  if (typeof after.userId !== "string" || !after.userId || before.userId !== after.userId) return;

  const db = getFirestore();
  const registrations = await db.collection("checkoutPushDevices").doc(after.userId)
    .collection("devices").get();
  const byToken = new Map();
  for (const doc of registrations.docs) {
    const token = doc.get("token");
    if (typeof token !== "string" || !token) continue;
    const docs = byToken.get(token) ?? [];
    docs.push(doc);
    byToken.set(token, docs);
  }

  const tokens = [...byToken.keys()];
  for (let offset = 0; offset < tokens.length; offset += 500) {
    const batch = tokens.slice(offset, offset + 500);
    const result = await getMessaging().sendEachForMulticast({
      tokens: batch,
      notification: { title: "Cập nhật đơn hàng", body: messages[after.status] },
      data: { type: "checkout_order_status", orderId: event.params.orderId },
    });
    await Promise.all(result.responses.map(async (response, index) => {
      if (response.success) return;
      const code = response.error?.code;
      if (code !== "messaging/registration-token-not-registered" &&
          code !== "messaging/invalid-registration-token") {
        console.warn("Checkout FCM send failed", code);
        return;
      }
      const docs = byToken.get(batch[index]);
      await Promise.all(docs.map(async (doc) => {
        try {
          await doc.ref.delete({ lastUpdateTime: doc.updateTime });
        } catch (error) {
          if (error.code !== 5 && error.code !== 9) throw error;
        }
      }));
    }));
  }
});
