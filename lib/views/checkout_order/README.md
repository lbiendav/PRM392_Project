# Checkout · Thành viên 4

Chạy module riêng trên Android với `flutter run -t lib/views/checkout_order/checkout_preview.dart`. Đăng nhập bằng tài khoản thử nghiệm rồi thêm sản phẩm từ Firestore. Bản chạy thử dùng Firebase đã cấu hình cho dự án và tạo đơn thật trong project đang kết nối. MoMo, ZaloPay và thẻ chỉ mô phỏng. Form thẻ chấp nhận số mẫu 4111 1111 1111 1111. Đơn hàng chỉ lưu mã phương thức thanh toán.

Khi ghép nhánh, mở `CheckoutScreen` từ giỏ hàng và `OrderHistoryScreen` từ tài khoản. Các màn hình dùng chung `cartProvider` và phiên đăng nhập hiện tại. Để bật push trong app chung, tạo `CheckoutNotifications(uid)` sau khi đăng nhập, gọi `start()` và gọi `close(unregister: true)` trước khi đăng xuất. Xử lý FCM payload `type=checkout_order_status` và `orderId` để mở `OrderTrackingScreen`; điểm chạy thử đã xử lý các luồng nhận thông báo này.

## Firestore

- `addresses/{uid}` giữ sổ địa chỉ và địa chỉ mặc định. Firestore là nguồn chính. ID mặc định được lưu thêm vào SharedPreferences theo UID.
- `vouchers` dùng model chung. Dùng mã viết hoa, loại `fixed`, `percentage` hoặc `freeship`. Checkout kiểm tra lại voucher khi gửi đơn.
- `orders` dùng schema chung. Tài xế hoặc cửa hàng có thể được gán qua `driverName`, `driverPhone`, `driverPlate`, `driverPhotoUrl`, `storeName` và `storePhone`. Tiến trình thay đổi khi người vận hành cập nhật `status` thành `preparing`, `delivering` (giao tận nơi) hoặc `ready` (lấy tại quán), rồi `completed` hoặc `cancelled`.
- `checkoutPushDevices/{uid}/devices/{installationId}` lưu đăng ký FCM theo thiết bị. Giới hạn quyền ghi và xóa cho đúng UID. Chỉ cho khách đọc địa chỉ và đơn của mình, và tạo đơn mới với `userId` của mình, trạng thái `pending`. Việc cập nhật trạng thái và thông tin tài xế thuộc về tài khoản vận hành hoặc backend.

## Push thông báo

Mã Cloud Function nằm trong `server/`, với cấu hình Firebase CLI riêng cho module. Quản trị viên cần kiểm tra quyền truy cập, thiết lập FCM trên thiết bị và triển khai function `notifyCheckoutStatus` vào đúng Firebase project. Firestore có thể giao lại sự kiện và FCM có thể giao thông báo trùng. Màn hình theo dõi luôn đọc trạng thái hiện tại từ Firestore.

Luồng kiểm thử trên thiết bị gồm thêm/sửa/xóa địa chỉ, chọn địa chỉ mặc định, đặt đơn giao tận nơi và lấy tại quán, kiểm tra giá sau voucher, đổi trạng thái đơn từ tài khoản vận hành, kiểm tra nút gọi với số thử nghiệm và đặt lại đơn từ lịch sử.
