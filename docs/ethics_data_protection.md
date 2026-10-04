# Đạo đức nghiên cứu và bảo vệ dữ liệu

## Tình trạng (theo đề cương mục 9.2)

- Dữ liệu được thu từ 24/7 đến 28/9/2026 trên KoboToolbox, **chưa có** phê duyệt hoặc xác nhận miễn xét duyệt của hội đồng đạo đức.
- Người tham gia đọc trang thông tin và thể hiện đồng ý bằng cách tiếp tục trả lời. Tệp dữ liệu không có trường ghi nhận đồng thuận riêng.
- Bảng hỏi không cung cấp thông tin về nguồn hỗ trợ tâm lý.
- Bảng hỏi không thu họ tên, số điện thoại, thư điện tử, nơi cư trú hay tên đơn vị công tác. Dù vậy, tổ hợp các đặc điểm (nhóm SOGIE, tuổi, địa bàn, ngành, quy mô nơi làm việc) vẫn có thể làm lộ danh tính trong các ô nhỏ.
- Dữ liệu chứa xu hướng tính dục và tình trạng sức khỏe. Đây là dữ liệu cá nhân nhạy cảm theo Luật Bảo vệ dữ liệu cá nhân số 91/2025/QH15 (hiệu lực từ 01/01/2026) và Nghị định 356/2025/NĐ-CP.

## Hồ sơ đề nghị xét duyệt (đề cương mục 9.3)

- [ ] Xác định đơn vị có thẩm quyền xét duyệt tại Học viện Ngân hàng (qua bộ phận quản lý khoa học).
- [ ] Đề cương.
- [ ] Bảng hỏi nguyên văn, kèm trang thông tin cho người tham gia.
- [ ] Mô tả các kênh tuyển chọn.
- [ ] Đánh giá rủi ro và lợi ích.
- [ ] Kế hoạch bảo vệ dữ liệu (mục dưới), có tham chiếu Luật 91/2025/QH15 và Nghị định 356/2025/NĐ-CP.
- [ ] Các biện pháp khắc phục: công bố thông tin nguồn hỗ trợ tâm lý trên trang dự án; quy tắc ẩn ô nhỏ; không công bố dữ liệu thô.

## Kế hoạch bảo vệ dữ liệu (điền)

| Mục | Nội dung |
|---|---|
| Người chịu trách nhiệm | … |
| Nơi lưu bản gốc | … (máy tính nào, có mã hóa ổ đĩa không) |
| Bản sao trên KoboToolbox | còn giữ hay đã xóa; ngày xóa |
| Ai được truy cập | … |
| Thời hạn lưu và cách hủy | … |
| Chia sẻ | Chỉ mã, bảng mã hóa và thống kê tổng hợp đã ẩn ô < 10. Không chia sẻ dữ liệu cấp cá nhân. |

## Quy tắc kỹ thuật trong repo

- `data/` bị `.gitignore` chặn toàn bộ. `tests/check_no_data.sh` báo lỗi nếu có tệp dữ liệu nằm trong danh sách được git theo dõi.
- Không dán dữ liệu cấp cá nhân vào cuộc trò chuyện với AI. Khi cần hỏi về lỗi, dùng dữ liệu giả lập (`tests/make_synthetic_data.py`) hoặc chỉ dán thống kê tổng hợp.
- Bảng xuất ra phải đi qua `small_cell_guard` (ngưỡng `MIN_CELL` = 10 trong `config/settings.do`).
