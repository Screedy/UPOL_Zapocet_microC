{ print("Zadej nezaporne cislo: ");
  scan(a);
  if (a<0) print("\nChybne cislo");
  else { print("Zadej zaklad ciselne soustavy 2..36: ");
         scan(z);
         if (z<2 || 36<z) print("\nChybny zaklad soustavy");
         else { print("\n    Zapis cisla v soustave %i: ",z);
                u=1; for (v=a;v>=z;v/=z) u*=z;
                do { b=a/u; a%=u; u/=z; if (b<10) print("%c",b|'0'); else  print("%c",b+('A'-10)); } while (u); } }
  print("\n\n"); }