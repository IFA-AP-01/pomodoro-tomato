# Báo cáo Yêu cầu Nghiệp vụ (BRD) - Ứng dụng Quản lý Thời gian (Pomodoro)

Tài liệu này là đặc tả yêu cầu nghiệp vụ đầy đủ để đội ngũ Phát triển (Dev) tiến hành xây dựng ứng dụng trên các nền tảng. Tài liệu quy định rõ **Giao diện (UI)**, **Luồng nghiệp vụ (Business Logic)** và **Thuật toán cốt lõi (Algorithms & Edge Cases)** cho từng màn hình.

---

## 0. Tổng quan về Phương pháp Pomodoro
Pomodoro là một phương pháp quản lý thời gian sử dụng bộ đếm để chia nhỏ công việc thành các khoảng thời gian ngắn (thường là 25 phút làm việc), xen kẽ bởi những khoảng nghỉ ngắn (thường là 5 phút).
**Nguyên lý vận hành cốt lõi:**
1. **Sự tập trung tuyệt đối:** Xuyên suốt 1 phiên Pomodoro, chỉ làm 1 việc duy nhất.
2. **Nghỉ ngơi bắt buộc:** Hết phiên phải nghỉ ngơi để tránh kiệt sức.
3. **Phần thưởng dài hạn:** Cứ sau 4 phiên làm việc liên tiếp sẽ có một phiên nghỉ dài hơn (15-30 phút).
Ứng dụng được sinh ra để tự động hóa vòng lặp này.

---

## 1. Yêu cầu Màn hình Chính: Bộ Đếm (Timer Screen)

Đây là màn hình trọng tâm nhất của ứng dụng, nơi người dùng theo dõi và điều khiển các phiên làm việc.

### 1.1 Khung Giao diện (UI Layout)
- **Top Bar**: Hiển thị Tiêu đề ứng dụng hoặc Trạng thái hiện tại (Focus, Short Break, Long Break).
- **Vòng tròn Tiến trình (Progress Indicator)**:
    - Khi ở chế độ Tập trung (Focus): Sử dụng vòng tròn nét đứt hoặc nét liền mạch, màu sắc nổi bật (Primary).
    - Khi ở chế độ Nghỉ (Break): Sử dụng vòng tròn dạng lượn sóng (Wavy) hoặc màu sắc dịu (Tertiary) để phân biệt thị giác.
- **Đồng hồ số (Digital Clock)**: Ở giữa vòng tròn, hiển thị định dạng `mm:ss`. *UX Rule*: Tính năng tự động thu nhỏ kích thước chữ nếu thời gian vượt quá 100 phút để tránh vỡ UI.
- **Thông tin Phiên tiếp theo (Up Next)**: Dòng chữ phụ nhỏ nằm dưới đồng hồ/vòng tròn, báo trước cho người dùng chế độ và thời lượng của phiên sắp tới.
- **Cụm Nút Điều khiển (Controls)**: Nút Play/Pause cỡ lớn (Nổi bật nhất), 1 nút Reset và 1 nút Skip (Bỏ qua).
- **Thanh Timeline Chu kỳ (Session List)**: (Chỉ hiện rõ ở màn hình lớn hoặc Tablet) Liệt kê chuỗi các phiên trong 1 chu kỳ để biết tiến độ tổng quan.

### 1.2 Nghiệp vụ Các nút (User Actions & Edge Cases)
- **Start / Pause**: Kích hoạt đếm ngược hoặc tạm dừng. Khi bấm sẽ kèm theo Haptic Feedback (rung phản hồi).
- **Reset**: Đưa thời gian phiên hiện tại về mốc ban đầu.
    - *Undo Reset (Hoàn tác)*: Ngay sau khi bấm Reset, màn hình đẩy ra một Snackbar cảnh báo có nút "Hoàn tác". Bấm nút này sẽ phục hồi toàn bộ thời gian đang đếm dở y như cũ.
- **Skip (Bỏ qua)**: Chuyển thẳng sang phiên kế tiếp trong chu kỳ mà không cần quan tâm phiên hiện tại đã đếm hết hay chưa.

### 1.3 Thuật toán Xử lý Lõi (Core Algorithms)
1. **Kiểm soát Thời gian thực (Real-time Tracking)**
    - *Yêu cầu*: Bộ đếm không được sai lệch dù thiết bị khóa hay app bị đưa vào chế độ ngủ (Doze mode).
    - *Thuật toán*: Lấy System Timestamp: `Thời_gian_còn_lại = Bắt_đầu + Độ_dài_phiên + Thời_điểm_hiện_tại - Tổng_thời_gian_tạm_dừng`. Trạng thái "Hết giờ" (Finish Trigger) được gọi ngay khi kiểm tra `Thời_gian_còn_lại <= 0`.
2. **Quản lý Chu kỳ (Cycle Logic)**
    - Dùng biến `cycles % (SessionLength * 2)`. Nếu Modulo ra số chẵn -> Focus. Số lẻ -> Break. Số lẻ lớn nhất chu kỳ -> Long Break.

---

## 2. Hệ thống Thông báo Động & Màn hình Kín (Live Noti & AOD)

Người dùng hiếm khi mở app suốt thời gian làm việc, do đó việc truyền đạt trạng thái ra ngoài OS là cực kỳ quan trọng.

### 2.1 Thông báo Hệ thống (Live Notifications)
- **UI Yêu cầu**: Một Notification ghim cố định hiển thị thời gian theo từng giây, chế độ hiện hành, nút Play/Pause/Skip trực tiếp trên Noti.
- **Đồ thị Lộ trình (Multi-segment Progress)**:
    - Thay vì vẽ 1 thanh % của phiên hiện tại, vẽ 1 thanh thể hiện phần trăm trên *toàn bộ chu kỳ*.
    - *Thuật toán*: `Tiến_trình_Tổng_thông_báo = Số_giây_đã_chạy_phiên_này + Tổng_số_giây_Focus_trước_đó + Tổng_số_giây_Break_trước_đó`.
- **Cảnh báo (Alarm Edge Case)**:
    - Khi đếm lùi về 0, rung và kêu liên tục.
    - Bắt buộc phải có **Auto-stop (Tự hủy) sau đúng 60 giây** nếu không ai chạm vào để không làm chai pin thiết bị. Nếu Auto-stop chạy, tính năng "Tự động nhảy sang phiên tiếp theo" sẽ bị hủy nhằm chờ người sử dụng quay lại xác nhận.

### 2.2 Màn hình Chờ (Always-On-Display - AOD)
- **UI Yêu cầu**: Màn hình tối đen 100% (Pure black), chỉ nổi bật bộ đếm thời gian.
- **Nghiệp vụ Chống lưu ảnh (Burn-in) & Bảo vệ (Secure)**:
    - *Thuật toán chống chạy chữ*: Cộng/trừ ngẫu nhiên tọa độ X,Y của cụm đồng hồ sau mỗi phút.
    - Mở tính năng "Bảo mật", UI sẽ tự động ẩn lịch trình kế tiếp đi, bảo vệ riêng tư khi để điện thoại trên bàn.

---

## 3. Yêu cầu Màn hình Thống kê (Stats Screen)

Màn hình dùng để người dùng theo dõi và đánh giá hiệu năng bản thân thông qua biểu đồ dữ liệu.

### 3.1 Khung Giao diện (UI Layout) theo Tab
- **Hôm nay (Today)**: Biểu đồ tròn tiến độ so với Mục tiêu Ngày.
- **Tuần này (Last Week)**: Biểu đồ Cột (Column Chart) của 7 ngày gần nhất, với thông tin trung bình theo khung giờ.
- **Tháng này (Last Month)**: Biểu đồ Cột và một Lịch thu nhỏ (Calendar Grid) 31 ngày. Yêu cầu: Ngày đầu tuần trên lịch luôn ở cột Thứ Hai (Monday).
- **Năm nay (Last Year)**: Biểu đồ Đường (Line Chart) theo 12 tháng và một Bản đồ nhiệt (Activity Heatmap) tương tự Github.
- **Tất cả (Lifetime)**: Con số vinh danh tổng thời lượng tập trung đã đạt được.

### 3.2 Thuật toán Lưu trữ và Tổng hợp (Data Sync & Aggregation)
1. **Lưu chốt phiên (Commit Focus Edge Case)**
    - Hệ thống định kỳ quét: Cứ đếm được `60 giây` thời gian thực (Lấy Thời lượng ban đầu - Thời gian còn lại trừ đi mốc Đã lưu trước đó) thì `Insert/Update` vào cơ sở dữ liệu.
    - Nếu có tương tác cắt ngang (Stop, Skip, Bấm nút Trở về 0), phần số giây lẻ chưa đủ 1 phút ngay lập tức bị ép vào lệnh SQL để đảm bảo không thất thoát 1 giây nào.
2. **Khung giờ thống kê (Quarters)**
    - Chia 24 tiếng làm 4 mốc thời điểm (Đêm, Sáng, Chiều, Tối). Cụ thể hệ thống tính tổng số giây trong ngày (với mốc Max 86.400s), đem chia 4 để tống vào các ngăn tương ứng (`0 -> 21600s`, `21600 -> 43200s`...).

---

## 4. Yêu cầu Màn hình Cài đặt (Settings Screen)

Đây là nơi cấu hình lại các hằng số thuật toán cho toàn bộ ứng dụng. Cần chia nhóm rõ ràng:

### 4.1 Danh sách Cấu hình (Config List)
- **Timer (Bộ đếm)**: Thời gian Focus, Nghỉ Ngắn, Nghỉ Dài, và Độ dài chu kỳ (Session Length).
- **Nghiệp vụ tự động (Automations)**:
    - Tự động bắt đầu phiên kế tiếp.
    - Cấp quyền Tự động bật chế độ "Không làm phiền" (DND Interaction) khi bước vào thời gian Focus và hạ xuống bình thường lúc Nghỉ.
- **Ngoại hình & Chuông (Appearance/Alarm)**:
    - Bật/tắt Dark Mode tuyệt đối. Đổi màu chủ đạo (Primary color scheme).
    - Đổi nhạc báo thức. Cầm trịch mức rung điện thoại (Thời gian sóng rung/nhịp nghỉ). Tắt/bật AOD.
- **Dữ liệu**: Bật mức Mục tiêu Focus trong ngày. Export/Import dữ liệu. Delete All Data.

### 4.2 Edge Case: Thay đổi cấu hình khi đang chạy (Runtime Setting Change)
- *Câu hỏi*: Chuyện gì xảy ra nếu đang đếm lùi 25 phút dở dang thì người dùng vào Settings đổi Focus còn 15 phút?
- *Quy tắc xử lý*: Bắt buộc ứng dụng phải gọi cơ chế **Hard Reset/Reload**. Tức là ngay khi Save cấu hình mới, phiên đang đếm hoặc chu kỳ đang chạy phải bị hủy, sau đó được cấp vòng chạy mới từ đầu để bộ đếm thuật toán không bị lỗi bộ nhớ hay tính toán vòng lập.
