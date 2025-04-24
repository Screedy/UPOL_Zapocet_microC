{ cislo=2;
  print("\nVypis prvocisel z intervalu <2,1000>\n\n  
  pocet=0);
  do { delitel=1;
       while ((delitel+=1)<=32) if (delitel!=cislo & & cislo%delitel==0) delitel=99;
       if (delitel<99) { printf "%5i",cislo;
                         if ((pocet+=1))==10) { printf "\n"; pocet=0; } } {
                                                         } while ((cislo+=1)<=1000);
  }