---
name: convert-to-ai-md
description: Chuyển prompt thô của người dùng thành tài liệu Markdown có cấu trúc (Mục tiêu, Yêu cầu, Ràng buộc, Câu hỏi, Chưa rõ) rồi thực thi dựa trên bản đó thay vì đọc thẳng prompt gốc. Dùng khi prompt dài, nhiều ý, viết vội, sai chính tả hoặc trộn lẫn yêu cầu với câu hỏi.
---

# Convert Prompt Sang Markdown Cho AI

## Activation notice

Khi dùng skill này, bắt đầu phản hồi bằng:

`[ACTIVE SKILL: convert-to-ai-md]`

## Mục đích

Prompt người dùng thường viết theo văn nói: nhiều ý dồn một dòng, viết tắt, sai chính tả, yêu cầu lẫn với câu hỏi. Skill này bắt buộc **chuyển prompt thành tài liệu Markdown có cấu trúc trước**, rồi mới thực thi dựa trên tài liệu đó — không thao tác trực tiếp từ prompt gốc.

## Khi nào dùng

Dùng khi prompt có ít nhất một dấu hiệu:

- Chứa từ 2 yêu cầu trở lên trong cùng một tin nhắn.
- Viết vội, nhiều lỗi chính tả hoặc viết tắt.
- Trộn lẫn yêu cầu cần làm với câu hỏi cần trả lời.
- Có ý phủ định, ngoại lệ ("nhưng đừng...", "trừ...").

Bỏ qua khi prompt đã rõ ràng và chỉ có một yêu cầu ngắn.

## Cấu trúc bản Markdown

Chỉ viết những mục thực sự có nội dung, bỏ mục trống:

```markdown
## Mục tiêu
Một câu duy nhất: người dùng rốt cuộc muốn đạt được gì.

## Yêu cầu
1. Việc cụ thể cần làm.
2. Việc cụ thể cần làm.

## Ràng buộc
- Điều không được làm, hoặc bắt buộc phải tuân theo.

## Câu hỏi cần trả lời
- Câu hỏi người dùng đặt ra (khác với việc cần làm).

## Chưa rõ
- Điểm mơ hồ + phương án đã tự chọn và lý do.
```

## Quy tắc chuyển đổi

- **Không thêm** yêu cầu người dùng không hề nói. Không tự mở rộng phạm vi.
- **Không bỏ sót**: mỗi mệnh lệnh trong prompt phải thành một dòng trong "Yêu cầu".
- Sửa lỗi chính tả và viết tắt về dạng chuẩn, nhưng **giữ nguyên ý gốc**. Không hỏi lại những chỗ đã đoán được chắc chắn.
- **Tách câu hỏi ra khỏi việc cần làm.** Câu hỏi phải được trả lời, không được lặng lẽ biến thành hành động.
- Giữ nguyên văn tên file, đường dẫn, tên biến, tên hàm, tên công cụ — không dịch, không sửa.
- Chỗ mơ hồ: đưa vào "Chưa rõ", tự chọn phương án hợp lý nhất và **nói rõ đã chọn gì**, thay vì dừng lại hỏi.

## Cách hiển thị

Bản Markdown chuyển đổi là **tài liệu nội bộ để AI đọc hiểu** — không in nguyên văn ra cho người dùng. In ra chỉ là nói lại chính prompt họ vừa viết, vô ích và làm dài phản hồi.

Output cho người dùng chỉ gồm:

- **Kết quả**: đã làm được gì, sửa file nào.
- **Điểm chưa rõ** và phương án đã tự chọn (nếu có).
- **Trả lời câu hỏi** người dùng đã đặt (nếu có).

Không lặp lại các mục "Mục tiêu", "Yêu cầu", "Ràng buộc" đã trích ra.

## Ví dụ

Prompt gốc:

> sửa lại cái script cho chạy trên win luôn, với lại thêm log cho dễ debug, mà đừng có xoá file cũ nhé, à mà kilo nó đọc file nào vậy

Sau khi chuyển:

```markdown
## Mục tiêu
Mở rộng script đồng bộ để chạy được trên Windows.

## Yêu cầu
1. Sửa script chạy được trên Windows.
2. Thêm log để dễ debug.

## Ràng buộc
- Không xoá file cũ.

## Câu hỏi cần trả lời
- Kilo Code đọc file cấu hình nào?
```

## Ưu tiên

Bản Markdown là công cụ để hiểu đúng, không phải để khoe quy trình. Giữ nó ngắn, và tuân thủ quy tắc trả lời ngắn gọn của [vietnamese-short-answer](../vietnamese-short-answer/SKILL.md).
