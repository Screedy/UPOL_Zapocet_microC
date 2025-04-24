{ print("\n");

  b=0; a=1; print("%10i",b); print("%10i",a); n=2;

  do { c=a+b; b=a; a=c;
       if (n%10==0) print("\n"); print("%10i",a); } while (++n<40);

   print("\n\n"); }
