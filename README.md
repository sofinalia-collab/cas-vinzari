# Casa de vânzări (prototip)

Aplicație web pentru vânzări pe telefon și calculator: scanezi codul de bare (camera telefonului sau scaner USB), produsul intră în coș cu reducerea lui, iar vânzarea se înregistrează.

**Stare: prototip.** Datele (nomenclator, vânzări) se salvează doar în browserul fiecărui dispozitiv (localStorage). Nu ajung pe server și nici pe GitHub.

## Funcții
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

Biblioteci incluse: [@zxing/library](https://github.com/zxing-js/library) 0.21.3 și [SheetJS](https://sheetjs.com) 0.18.5, ambele sub licența Apache-2.0 (vezi `vendor/`).
