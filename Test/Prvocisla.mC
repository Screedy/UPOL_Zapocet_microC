{ print("\n    Prvocisla do 1000\n\n"); 

  cislo=2; print("%5i",cislo);
  pocet=1;
  ++cislo;

  do { prvocislo=true;
       for (delitel=3; delitel*delitel<=cislo; delitel+=2) { if (cislo%delitel==0) { prvocislo=false; break; } } 
       if (prvocislo) { print("%5i",cislo);
                        if (++pocet%10==0) print("\n");
                      }
     } while ((cislo+=2)<=1000);
  
  print("\n\n");          
}