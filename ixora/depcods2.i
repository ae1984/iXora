/* depcods2.i
 * MODULE
        ЂўБ®¬ БЁ§ ФЁО ЇЮ®АБ ў«Ґ­ЁҐ Є®¤  ¤®Е-Ю АЕ®¤®ў        
 * DESCRIPTION
        ЂўБ®¬ БЁ§ ФЁО ЇЮ®АБ ў«Ґ­ЁҐ Є®¤  ¤®Е-Ю АЕ®¤®ў        
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        2.2.1
 * AUTHOR
        20/02/2006 nataly
 * CHANGES
	16/03/2006 u00121 - ¤®Ў ўЁ« release ¤«О Б Ў«ЁФ cods Ё trxcods

*/

/*ў®§ўЮ И Ґ¬ ­ АБЮ®©ЄЁ cods ®ЎЮ Б­®*/

   find first cods where cods.gl  = v-gl and cods.arc = no /*and cods.acc = v-tarif*/ no-error.
   if avail cods  then do:
   	cods.lookaaa = no.
	release cods.
   end.
  
