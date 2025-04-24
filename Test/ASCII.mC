{ print("\n              ASCII tabulka\n\n    ");
  for (i=0; i<16; ++i) print(" %X",i);
  print("\n   ");
  for (i=0; i<35; ++i) print("-");

  for (i=0x20; i<0x80; i+=16) { print("\n %X|",i);
                                for (j=i; j<i+16; ++j) { if (j<127) print(" %c",j);
                                                        else print("  "); } 
                                print(" |"); }

  print("\n   ");
  for (i=0; i<35; ++i) print("-");
 
 print("\n\n");
}