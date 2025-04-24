{ print("Zadej cislo: ");
  scan(a);
  p=0; b=1;
   
  do { if (a&b) p^=1; } while (b<<=1);
  if (p==0) print("\n  suda parita \n\n"); else print("\n  licha parita\n\n"); }
  
