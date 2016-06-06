/* cods2.i
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
        20/04/06 nataly ®ЇБЁ¬Ё§ЁЮ®ў «  ЇЮ®ўҐЮЄЦ Ї® cods

*/

/*ў®§ўЮ И Ґ¬ ­ АБЮ®©ЄЁ cods ®ЎЮ Б­®*/

/*   find first cods where cods.gl  = v-gl and cods.arc = no  no-error.
   if avail cods  then do:
   	cods.lookaaa = no.
	release cods.
   end.*/
  
/*ЇҐЮҐЇЮЁАў Ёў Ґ¬ §­ ГҐ­ЁО trxcods*/

    find first tarif2 where tarif2.num + tarif2.kod = v-tarif and tarif2.sta =  'r' no-lock no-error.
    if avail tarif2 then v-gl = tarif2.kont.

for each bjl where  bjl.jh = s-jh and  bjl.gl = v-gl no-lock .
	find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = bjl.ln and  trxcods.codfr = 'cods' no-error. 
	if not avail trxcods then next.
	find first cods where cods.gl  = v-gl and cods.arc = no and cods.acc = v-tarif no-lock no-error.
	if avail cods then 
	do: 
		v-code = cods.code.   
		v-dep = substr(trxcods.code,8,3).  
	end.
	if v-code <> ""  then  
		trxcods.code = v-code + v-dep.
	release trxcods.
end.