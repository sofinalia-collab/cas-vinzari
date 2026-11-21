# Casa de vânzări (prototip)

Aplicație web pentru vânzări pe telefon și calculator: scanezi codul de bare (camera telefonului sau scaner USB), produsul intră în coș cu reducerea lui, iar vânzarea se înregistrează.

**Două moduri de lucru:**
- **Fără bază centrală** (`config.js` gol): prototip, iar datele stau doar în browserul fiecărui dispozitiv.
- **Cu bază centrală Supabase** (`config.js` completat): nomenclatorul se încarcă o singură dată, de administrator, și îl primesc toate telefoanele. Verificarea prețului merge fără login. Vânzările, rapoartele și istoricul cer utilizator și parolă. Configurarea e descrisă în [SUPABASE.md](SUPABASE.md).

Prețurile și vânzările nu se salvează niciodată în acest repository public.

## Funcții
- **Preț** (fără login): scanezi și vezi denumirea, articolul, prețul și prețul cu reducere.
- Login pentru vânzători și rol de administrator. Vânzările făcute fără internet se păstrează pe telefon și se trimit automat când revine conexiunea.
- Scanare: cameră (BarcodeDetector sau ZXing) și scaner USB (Enter, Tab sau fără terminator; prinde codul și când focusul nu e în câmp).
- Import nomenclator din Excel (.xlsx/.xls) sau CSV: Articol, Denumire, Cod de bare, Preț, Reducere (%). Antetele se recunosc și în rusă.
- Coș: sumă fără reducere, reducere, sumă cu reducere; plată numerar/card.
- Raport zilnic pe fiecare zi, cu export Excel (Rezumat, Pe produse, Bonuri). Istoric și export CSV.

## Construire
`python3 build.py` inserează bibliotecile din `vendor/` în `src/app.html` și scrie `index.html` (un singur fișier, merge și offline).

## Presupuneri de confirmat
- Reducerea este în procente.
- Unde se salvează vânzările în versiunea reală (1C, Google Sheets sau server propriu).
- Bonul fiscal (casa de marcat) nu este acoperit.

Biblioteci incluse: [@zxing/library](https://github.com/zxing-js/library) 0.21.3 și [SheetJS](https://sheetjs.com) 0.18.5 (Apache-2.0), [supabase-js](https://github.com/supabase/supabase-js) 2.118.0 (MIT); licențele sunt în `vendor/`.
