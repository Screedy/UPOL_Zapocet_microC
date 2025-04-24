{ print("Zadej cislo vetsi nez 1: ");
  scan(a);
  if (a<2) print("\nChybne cislo");
  else { print("\n"); 
         m=r=false;
		 n=0;
         for (;a%2==0;a/=2) ++n; 
		 if (n) { print(" 2"); if (n>1) { print("^%u",n); r=true; } m=true; }
         for (i=3;a>1;i+=2) { n=0;
		                      for (;a%i==0;a/=i) ++n;
		                      if (n) { if (m) print(" *"); print(" %u",i); 
							           if (n>1) { print("^%u",n); r=true; }
									   m=true; } }
         if (r) print("   .. ^ oznacuje mocninu"); }
  print("\n\n"); }