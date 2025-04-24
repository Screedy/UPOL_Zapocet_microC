{ print("Zadej 2 prirozena cisla: ");
  scan(a); scan(b);

  if (a<1 || b<1) print("\n\nChybna cisla");

  else { do { zbytek=a%b; a=b; b=zbytek; } while (zbytek!=0);
         print("\nNejvetsi spolecny delitel: %i",a);
       }
  print("\n\n");
}