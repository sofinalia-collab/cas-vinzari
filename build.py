"""Construiește index.html: inserează bibliotecile din vendor/ în src/app.html (un singur fișier, merge și offline)."""
from pathlib import Path
root = Path(__file__).parent
s = (root / "src/app.html").read_text(encoding="utf-8")
z = (root / "vendor/zxing-library-0.21.3.min.js").read_text(encoding="utf-8")
x = (root / "vendor/xlsx-0.18.5.full.min.js").read_text(encoding="utf-8")
s = s.replace("<script>/*ZXING*/</script>", "<script>" + z + "</script>", 1)
s = s.replace("<script>/*XLSX*/</script>", "<script>" + x + "</script>", 1)
assert "/*ZXING*/" not in s and "/*XLSX*/" not in s
(root / "index.html").write_text(s, encoding="utf-8")
print("index.html", len(s), "bytes")
