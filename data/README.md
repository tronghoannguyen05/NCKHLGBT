# data/ — không commit

- `raw/`: tệp xuất từ KoboToolbox (khai tên trong `config/settings.do`) hoặc `synthetic.csv` sinh bởi `tests/make_synthetic_data.py`.
- `derived/`: tệp `.dta` do pipeline tạo ra.

Toàn bộ thư mục này bị `.gitignore` chặn. Dữ liệu chứa thông tin nhạy cảm (xu hướng tính dục, sức khỏe), nên không sao chép nó lên dịch vụ đám mây hay vào cuộc trò chuyện với AI.
