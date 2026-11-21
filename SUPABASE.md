# Configurarea bazei centrale (Supabase)

Durează aproximativ 15 minute și se face o singură dată.

## 1. Creează proiectul
1. Intră pe https://supabase.com și apasă **Start your project**. Te poți înregistra cu contul GitHub.
2. **New project**:
   - Name: `casa-vanzari`
   - Database Password: alege o parolă și păstreaz-o. Nu trebuie trimisă nimănui.
   - Region: cea mai apropiată (de ex. Frankfurt / Central EU)
3. Apasă **Create new project** și așteaptă 1–2 minute.

## 2. Creează tabelele
1. În meniul din stânga: **SQL Editor**, apoi **New query**.
2. Deschide [supabase/schema.sql](supabase/schema.sql), apasă **Copy raw file**, lipește tot conținutul în editor și apasă **Run**.
3. Trebuie să apară „Success. No rows returned”.

## 3. Oprește înregistrarea liberă (important)
**Authentication → Sign In / Providers → Email**: dezactivează **Allow new users to sign up** și salvează.
Fără acest pas, oricine ar putea să-și facă singur cont de vânzător.

## 4. Creează utilizatorii
**Authentication → Users → Add user → Create new user**, pentru fiecare persoană:
- Email: `numele@vanzari.local` (de ex. `lilian@vanzari.local`, `ana@vanzari.local`)
- Password: parola persoanei
- bifează **Auto Confirm User**

În aplicație, persoana scrie doar `ana` și parola. Partea `@vanzari.local` se adaugă automat.
Dacă Supabase nu acceptă adresa `@vanzari.local`, folosește adresa de email reală a persoanei. În aplicație se poate scrie și emailul complet.

## 5. Fă-te administrator
**Table Editor → profiles**: la rândul tău schimbă `role` din `seller` în `admin`.
(Sau în SQL Editor: `update profiles set role = 'admin' where name = 'lilian';`)

Ca să oprești accesul unui vânzător, setezi `active` = `false` în același tabel.

## 6. Trimite cele două valori
**Project Settings → API Keys** (sau **Data API**):
- **Project URL**, de forma `https://xxxx.supabase.co`
- cheia **anon public**. Dacă nu o vezi, e în fila **Legacy API Keys**. Se poate folosi și **Publishable key** (`sb_publishable_...`).

Aceste două valori sunt făcute să fie publice: accesul e controlat de regulile din baza de date.
**Nu trimite niciodată** cheia `service_role` / `secret` și nici parola bazei de date.

## Cine ce poate face
| | Fără login | Vânzător | Administrator |
|---|---|---|---|
| Verificare preț (denumire, articol, preț) | da | da | da |
| Înregistrare vânzări | nu | da | da |
| Vede vânzările | nu | doar ale lui | toate |
| Încarcă / modifică nomenclatorul | nu | nu | da |
| Modifică sau șterge vânzări | nu | nu | nu (doar din Supabase) |
