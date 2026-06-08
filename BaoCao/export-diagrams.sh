#!/bin/bash
# Tự xuất tất cả khối ```mermaid``` trong BaoCao/*.md → PNG vào BaoCao/images/
# Yêu cầu: Node.js. Lần đầu chạy sẽ tự cài @mermaid-js/mermaid-cli (~150MB).
# Usage: ./export-diagrams.sh

set -e
cd "$(dirname "$0")"
mkdir -p images

# Trích các khối mermaid từ mọi file .md → file .mmd
python3 <<'PY'
import re, pathlib
out_dir = pathlib.Path('images')
out_dir.mkdir(exist_ok=True)
counter = {}
for md in sorted(pathlib.Path('.').glob('*.md')):
    text = md.read_text(encoding='utf-8')
    blocks = re.findall(r'```mermaid\n(.*?)```', text, re.DOTALL)
    for i, block in enumerate(blocks, 1):
        name = f"{md.stem}-{i:02d}"
        (out_dir / f"{name}.mmd").write_text(block, encoding='utf-8')
        counter[md.stem] = counter.get(md.stem, 0) + 1
print(f"Tổng cộng tìm thấy {sum(counter.values())} sơ đồ mermaid:")
for k, v in counter.items():
    print(f"  {k}: {v} diagram(s)")
PY

# Render từng .mmd → PNG (1600px wide, scale 2x cho in báo cáo)
echo ""
echo "Đang render PNG (lần đầu sẽ tải mermaid-cli, khoảng 1-2 phút)..."
for mmd in images/*.mmd; do
  out="${mmd%.mmd}.png"
  if [ -f "$out" ] && [ "$out" -nt "$mmd" ]; then
    continue
  fi
  echo "  → $out"
  npx -y -p @mermaid-js/mermaid-cli mmdc -i "$mmd" -o "$out" -w 1600 -s 2 -b white 2>&1 | tail -1
done

# Dọn file tạm .mmd
rm -f images/*.mmd

echo ""
echo "✅ Xong! PNG ở: $(pwd)/images/"
ls -la images/*.png 2>/dev/null | awk '{print "  " $NF " (" $5 " bytes)"}'
