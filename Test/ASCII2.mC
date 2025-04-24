{ print("\n                        ASCII tabulka\n\n ");
  for (i=0; i<75; ++i) print("-");

  for (i=0x20; i<0x80; i+=8) { print("\n |");
                               for (j=i; j<i+8; ++j) { print(" %3i",j); print(" %X",j);
                                                       if (j<127) print(" %c",j);
                                                       else print("  "); } 
                               print(" |"); }

  print("\n ");
  for (i=0; i<75; ++i) print("-");
 
 print("\n\n");
}