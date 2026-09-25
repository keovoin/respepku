/// Store API keys for the Sastra Fitmeal mini e-commerce.
///
/// `anonKey` is the Supabase *publishable* (anon) key of the `sastra-store`
/// project — safe to ship inside the app: all real secrets (CutLuy key,
/// service role) live server-side in edge functions.
class StoreKeys {
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3eHBqeGR6a3dkaWxna2Jicm56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk5MDkyMDAsImV4cCI6MjEwNTQ4NTIwMH0.1DBukjcG_9ny3GBCL0kr3mMuzucBDeCrdhrJ_Wq2J0o';

  static const String shopUrl =
      'https://swxpjxdzkwdilgkbbrnz.supabase.co/functions/v1/meal-shop';
}
