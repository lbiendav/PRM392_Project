# MODULE 5: KHUYẾN MÃI, ĐIỂM THƯỞNG & CÀI ĐẶT HỆ THỐNG

> **Phụ trách:** Thành viên 5
> **Vị trí code:** `lib/views/rewards_settings/`
> **Kiến trúc:** MVVM — View (Widget) + Riverpod (ViewModel/State) + Firestore/SharedPreferences (Data)

---

## 1. Mục tiêu nghiệp vụ

Module 5 phụ trách nhóm tính năng giữ chân khách hàng (retention) và cá nhân hóa trải nghiệm:

- Quản lý **voucher khuyến mãi** khách hàng đang sở hữu.
- Quản lý **điểm thưởng tích lũy** và hạng thành viên.
- Tổng hợp **thông báo** liên quan đến đơn hàng và khuyến mãi.
- Cho phép người dùng **tùy chỉnh cài đặt** ứng dụng (giao diện, ngôn ngữ, thông báo).
- Cung cấp kênh **hỗ trợ/FAQ** và tiếp nhận phản hồi người dùng.

---

## 2. Danh sách màn hình & luồng xử lý

### 2.1. `VoucherWalletScreen` — Ví Khuyến Mãi

**Nghiệp vụ:** Hiển thị toàn bộ voucher mà người dùng đang có, phân biệt theo loại giảm giá.

**Model:** `VoucherModel` (`lib/models/voucher_model.dart`)
| Field | Ý nghĩa |
|---|---|
| `discountType` | `'freeship'` \| `'percentage'` \| `'fixed'` — quyết định icon và cách tính giảm giá |
| `discountValue` | % giảm hoặc số tiền giảm cố định |
| `minOrderAmount` | Đơn tối thiểu để áp dụng |
| `maxDiscount` | Trần giảm giá (áp dụng cho loại `percentage`) |
| `expiryDate` | Hạn sử dụng, hiển thị dạng `HSD: dd/MM/yyyy` |

**Luồng xử lý:**
1. Màn hình nhận tham số `isSelectMode` (mặc định `false`):
   - `false`: màn xem ví voucher thông thường, nút hiển thị "Dùng".
   - `true`: được mở từ `CheckoutScreen` (Member 4) để **chọn** voucher áp vào đơn hàng, nút hiển thị "Chọn".
2. Bấm nút:
   - Luôn copy mã voucher vào Clipboard (`Clipboard.setData`) + hiện snackbar xác nhận → tiện cho người dùng dán mã ở nơi khác.
   - Nếu đang ở `isSelectMode == true`, gọi `Navigator.pop(context, voucher)` để trả `VoucherModel` đã chọn về `CheckoutScreen`.
3. Hiện tại dữ liệu voucher đang là **mock cứng trong State** — theo thiết kế gốc cần thay bằng `StreamBuilder`/Riverpod đọc collection `vouchers` trên Firestore (lọc theo voucher người dùng đang sở hữu).

---

### 2.2. `LoyaltyRewardsScreen` — Thẻ Thành Viên & Điểm Thưởng

**Nghiệp vụ:** Hiển thị hạng thành viên dựa trên điểm tích lũy, tiến độ lên hạng, và danh sách quà đổi điểm.

**Nguồn dữ liệu:** `authNotifierProvider` (Riverpod) → `UserModel.loyaltyPoints` (đọc từ Firestore `users/{uid}`, được nạp sẵn bởi Module 1 — Auth).

**Luồng xử lý:**
1. Đọc `points = user?.loyaltyPoints ?? 50` (giá trị mặc định 50 khi chưa đăng nhập, dùng để demo UI).
2. Tính hạng thành viên theo ngưỡng điểm (hard-code trong `_getTierName` / `_getTierColor`):

   | Điểm | Hạng | Màu |
   |---|---|---|
   | ≥ 500 | Kim Cương 💎 | `#0077B6` |
   | ≥ 200 | Vàng 👑 | `#D4AF37` |
   | ≥ 100 | Bạc 🥈 | `#C0C0C0` |
   | < 100 | Đồng 🥉 | `#CD7F32` |

3. Thẻ ảo VIP đổi màu gradient theo hạng tương ứng (`_getTierColor`).
4. Thanh tiến độ: `progress = (points / nextMilestone).clamp(0.0, 1.0)` với `nextMilestone = 100` (mốc cố định lên hạng Bạc — **giới hạn hiện tại**: công thức chưa tổng quát hóa cho tất cả các hạng, mới chỉ tính mốc 100).
5. Danh sách quà đổi điểm (`_buildRewardItem`): mỗi mục có `cost` cố định, nút "Đổi" chỉ **enable** khi `userPoints >= cost`. Bấm "Đổi" hiện tại chỉ show snackbar thành công — **chưa trừ điểm thật trên Firestore** (cần bổ sung transaction cập nhật `loyaltyPoints` khi tích hợp backend thật).

---

### 2.3. `NotificationCenterScreen` — Trung Tâm Thông Báo

**Nghiệp vụ:** Liệt kê thông báo hệ thống (cập nhật đơn hàng, khuyến mãi), phân biệt đã đọc/chưa đọc.

**Model:** `NotificationItemModel` (`lib/models/notification_model.dart`) — có `type` (`'order'`, `'promo'`, `'system'`), `targetId` (dùng để điều hướng sâu — deep link — tới đơn hàng/voucher liên quan), `isRead`.

**Luồng xử lý:**
1. Danh sách thông báo hiện là mock cứng trong State (2 mẫu: 1 đơn hàng, 1 khuyến mãi).
2. Card nền nhạt màu `AppColors.primary.withValues(alpha: 0.08)` khi `isRead == false`, có chấm tròn nhỏ ở `trailing` đánh dấu chưa đọc.
3. Icon + màu avatar đổi theo `type` (`order` → xe giao hàng, còn lại → icon ưu đãi).
4. Nút "Đã đọc tất cả" **đã hoạt động**: duyệt toàn bộ `_notifications`, gọi `NotificationItemModel.copyWith(isRead: true)` cho từng phần tử (method `copyWith` đã bổ sung vào model).
5. **Còn thiếu / cần hoàn thiện:**
   - Chưa có xử lý `onTap` từng thông báo để điều hướng tới `targetId` tương ứng (đơn hàng → `OrderTrackingScreen` của Member 4, voucher → `VoucherWalletScreen`).
   - Chưa kết nối Firestore/FCM thật — cần `StreamBuilder` lắng nghe collection thông báo theo `userId`.

---

### 2.4. `SettingsScreen` — Cài Đặt Hệ Thống

**Nghiệp vụ:** Trung tâm tùy chỉnh trải nghiệm ứng dụng.

**Luồng xử lý:**
1. **Dark/Light Mode:** đọc `ref.watch(themeProvider)` để biết `ThemeMode` hiện tại; `SwitchListTile` gọi `ref.read(themeProvider.notifier).toggleTheme()` khi bấm — provider này tự lưu lựa chọn vào `SharedPrefsService` và áp dụng theme toàn app ngay lập tức (không cần restart) vì `MaterialApp.themeMode` ở `main.dart` cũng đang watch cùng provider.
2. **Thông báo đẩy (FCM):** state cục bộ `_notificationsEnabled`, hiện **chưa persist** (mất khi thoát app) và **chưa gọi API bật/tắt FCM topic thật** — cần bổ sung lưu SharedPreferences + gọi `FirebaseMessaging.subscribeToTopic/unsubscribeFromTopic`.
3. **Ngôn ngữ:** dropdown chọn Tiếng Việt/English, state cục bộ `_selectedLanguage` — **chưa có cơ chế đa ngôn ngữ thật** (chưa tích hợp `intl`/`easy_localization`), hiện chỉ đổi giá trị hiển thị trên dropdown.
4. **Điều hướng:** mục "Trợ giúp & FAQ" push sang `HelpAndFAQScreen`.

---

### 2.5. `HelpAndFAQScreen` — Trợ Giúp & Góp Ý

**Nghiệp vụ:** Cung cấp FAQ dạng accordion và kênh gửi phản hồi/báo lỗi.

**Luồng xử lý:**
1. FAQ là danh sách tĩnh (`List<Map<String, String>>`) hiển thị qua `ExpansionTile` — mở/đóng độc lập từng mục, không giới hạn mở nhiều câu cùng lúc.
2. Form góp ý:
   - `_submitFeedback()`: validate rỗng (`text.isEmpty` → return sớm, không gửi).
   - Set `_isSubmitting = true` để khóa nút + hiện loading indicator, tránh bấm gửi trùng lặp.
   - Ghi thẳng vào Firestore collection `feedbacks` với `content` + `createdAt` (dùng `FieldValue.serverTimestamp()` để đồng bộ giờ server, tránh sai lệch giờ thiết bị).
   - Thành công: clear ô nhập + snackbar xanh. Lỗi: snackbar đỏ kèm message exception.
   - Document feedback **đã gắn `userId`** (đọc từ `ref.read(authNotifierProvider).userModel?.id`, chuyển sang `ConsumerStatefulWidget`) — nếu người dùng chưa đăng nhập thì `userId` ghi `null`.

---

## 3. Tài nguyên dùng chung (không tự ý sửa)

| Tài nguyên | Vai trò trong Module 5 |
|---|---|
| `providers/theme_provider.dart` | Nguồn chân lý duy nhất cho Dark/Light mode toàn app |
| `providers/auth_provider.dart` | Cung cấp `UserModel` (điểm thưởng, tên hiển thị) cho `LoyaltyRewardsScreen` |
| `core/services/shared_prefs_service.dart` | Lưu trạng thái theme cục bộ |
| `core/constants/app_colors.dart` | Bảng màu thương hiệu dùng xuyên suốt 5 màn hình |

---

## 4. Việc còn tồn đọng (chưa hoàn thiện backend thật)

- [ ] `VoucherWalletScreen`: thay mock data bằng Stream Firestore `vouchers` theo user.
- [ ] `LoyaltyRewardsScreen`: tổng quát hóa công thức tính mốc lên hạng cho cả 4 hạng; trừ điểm thật khi đổi quà (transaction Firestore).
- [ ] `NotificationCenterScreen`: điều hướng theo `targetId`, kết nối Firestore/FCM thật.
- [ ] `SettingsScreen`: persist trạng thái bật/tắt thông báo; tích hợp đa ngôn ngữ thật; gọi FCM subscribe/unsubscribe topic.
- [x] ~~`NotificationCenterScreen`: cài logic "đã đọc tất cả"~~ — đã hoàn thiện.
- [x] ~~`HelpAndFAQScreen`: gắn `userId` vào document feedback~~ — đã hoàn thiện.
