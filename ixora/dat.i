/* dat.i
 * MODULE
        ЋБГҐБ Ї® Є®¤ ¬ ¤®Е®¤®ў/Ю АЕ®¤®ў ®ЇҐЮ ФЁ©
 * DESCRIPTION
        ЋБГҐБ Ї® Є®¤ ¬ ¤®Е®¤®ў/Ю АЕ®¤®ў ®ЇҐЮ ФЁ©
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        04/02/06 nataly
 * CHANGES
        22.06.2006 nataly ЎК« ¤®ў ў«Ґ­  ®ЎЮ Ў®БЄ  АЄ« ¤ , ЏЮЁ«®¦ 12,13,14.
        04/08/2006 nataly ЎК«  ¤®Ў ў«Ґ­  ®ЎЮ Ў®БЄ  АГҐБ  4608
*/
   if t-cods.dep = '000' and  string(t-cods.gl) begins '4601' /*and (t-cods.who = 'bankadm' or t-cods.who = 'superman')*/ 
    then do:
      v-code = substr(trxcods.code,1,7). 
      v-dep =  substr(trxcods.code,8,3). 
     find txb.remtrz where remtrz.remtrz = substr(t-cods.rem,index(t-cods.rem,'rmz'),10) no-lock no-error.
     if avail txb.remtrz then do:

              /*   v-tarif = string(remtrz.svccgr).
              	find first txb.cods where cods.gl  = t-cods.gl  and cods.acc = v-tarif no-lock no-error.
        	if avail txb.cods then v-code = cods.code.   */

		find txb.aaa where aaa.aaa = remtrz.sacc no-lock no-error.
		 if avail txb.aaa then do: 
                   find txb.cif where cif.cif = aaa.cif no-lock no-error.
                   if avail txb.cif then v-dep = getdep(txb.cif.cif). 
/*                  message t-cods.code t-cods.dep v-code v-dep t-cods.jh.*/
                end.
		else v-dep = substr(trxcods.code,8,3).  
     end.
           t-cods.code = v-code . t-cods.dep =  v-dep.
           if t-cods.dep =  '000' then message  'ЌЦ«Ґў®© ¤ҐЇ ЮБ ¬Ґ­Б! ' t-cods.code t-cods.dep t-cods.jh.
   end.

/*Ї« АБЁЄ®ўКҐ Є ЮБК*/
   if t-cods.dep = '000' and  t-cods.gl = 460813  
    then do:
      v-code = substr(trxcods.code,1,7). 
      v-dep =  '212'. /*Ї« БҐ¦­КҐ Є ЮБК*/ 
           t-cods.code = v-code . t-cods.dep =  v-dep.
           if t-cods.dep =  '000' then message 'ЌЦ«Ґў®© ¤ҐЇ ЮБ ¬Ґ­Б! ' t-cods.code t-cods.dep t-cods.jh.
  end.

 /*Ќ„‘*/
/*if t-cods.dep = '000' then  message t-cods.dep t-cods.gl  t-cods.code t-cods.rem.*/
   if t-cods.dep = '000' and  (string(t-cods.gl) begins '4607' or string(t-cods.gl) begins '4608' or 
           string(t-cods.gl) begins '492') 
                       /* and t-cods.rem matches '*Ќ„‘*'*/ 
       then do:
      v-code = substr(trxcods.code,1,7). 
      v-dep =  '215'.  /*Ќ «®ё®ўК© ¤ҐЇ ЮБ ¬Ґ­Б*/
           t-cods.code = v-code . t-cods.dep =  v-dep.
           if t-cods.dep =  '000' then message 'ЌЦ«Ґў®© ¤ҐЇ ЮБ ¬Ґ­Б! ' t-cods.code t-cods.dep t-cods.jh.
    end.

  /*06/06/06 */
/*ЇҐЮҐ®ФҐ­Є  Ё­ ў «НБК*/
   if t-cods.dep = '000' and  t-cods.gl = 570310  
    then do:
      v-code = substr(trxcods.code,1,7). 
      v-dep =  '209'. /*Є §­ ГҐ©АБў®*/ 
           t-cods.code = v-code . t-cods.dep =  v-dep.
           if t-cods.dep =  '000' then message 'ЌЦ«Ґў®© ¤ҐЇ ЮБ ¬Ґ­Б! ' t-cods.code t-cods.dep t-cods.jh.
   end.
