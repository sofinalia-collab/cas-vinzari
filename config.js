// Legătura cu baza centrală Supabase (Project Settings → API).
// Cheia „anon public” este făcută să fie publică: accesul e controlat de regulile din supabase/schema.sql.
// Dacă rămân goale, aplicația lucrează local (prototip, date doar pe dispozitiv).
window.CASA_CONFIG = {
  supabaseUrl: "",
  supabaseAnonKey: "",
  loginDomain: "vanzari.local"   // utilizatorul „ana” intră ca ana@vanzari.local
};
