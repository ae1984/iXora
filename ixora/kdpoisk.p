/* kdpoisk.p Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Поиск данных об учредителях и аффилированных компаниях
            в базах Залога и Опер департамента .
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
          17.01.2004  marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
    11.09.2008 galina - перекомпеляция в связи с измениями на форме kdcif.f

*/



{global.i}
{kd.i}
{kdcif.f}

if s-kdcif = '' then return.

find kdcif where kdcif.bank = s-ourbank and kdcif.kdcif = s-kdcif 
     no-lock no-error.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define input parameter v-poisk as inte.
define input parameter v-inchief as char.
define var i as inte.
define buffer b-sub-cod for sub-cod.
define var v-chief as char.

if v-poisk = 1 then do:

/*Поиск клиента в базе залогов и перенос в досье учредителей клиента*/
   find first zllon where zllon.cif = s-kdcif no-lock no-error.
   if avail zllon then do:
      for each zllon where zllon.cif = s-kdcif no-lock.
          repeat i = 1 to 10 :
            find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif
                    and kdaffil.name = zllon.stholder[i] no-lock no-error.
            if not avail kdaffil and zllon.stholder[i] ne '' then do:
               create kdaffil.
               assign kdaffil.bank = s-ourbank kdaffil.code = '01' kdaffil.kdcif = s-kdcif  
                      kdaffil.who = g-ofc kdaffil.whn = g-today kdaffil.name = zllon.stholder[i]
                      kdaffil.amount = zllon.hold[i].
            end.  
          end. 
      end.
   end.
   else do:
      find first cif where cif.name = kdcif.name no-lock no-error.
      if avail cif then do:
          for each zllon where zllon.cif = cif.cif no-lock.
              repeat i = 1 to 10 :
                find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif
                        and kdaffil.name = zllon.stholder[i] no-lock no-error.
                if not avail kdaffil and zllon.stholder[i] ne '' then do:
                   create kdaffil.
                   assign kdaffil.bank = s-ourbank kdaffil.code = '01' kdaffil.kdcif = s-kdcif  
                          kdaffil.who = g-ofc kdaffil.whn = g-today kdaffil.name = zllon.stholder[i]
                          kdaffil.amount = zllon.hold[i].
                end.  
              end. 
          end.
      end.
   end.
/**********/

end.

if v-poisk = 2 and trim(v-inchief) ne '' then do:

  /* Ищем в базе ОД руководителя как руководителя других компаний */
   for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc ne s-kdcif and sub-cod.d-cod = 'clnchf' 
                      and sub-cod.ccode = 'chief' 
                      and caps(sub-cod.rcode) = caps(v-inchief) no-lock. 
   find first cif where cif.cif = sub-cod.acc no-lock no-error.
   if avail cif then do:
       find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif                          
                          and caps(kdaffil.name) = caps(cif.cif) + ' ' + caps(cif.name)
                       no-lock no-error.
       if not avail kdaffil then do:
           find first b-sub-cod where b-sub-cod.sub = 'cln' and b-sub-cod.acc = cif.cif and 
                      b-sub-cod.d-cod = 'clnbk' and b-sub-cod.ccode = 'mainbk'  no-lock no-error.        
           if avail b-sub-cod then v-chief = b-sub-cod.rcode.
                              else v-chief = 'НЕ ПРЕДУСМОТРЕН'.
           create kdaffil.
           assign kdaffil.bank = s-ourbank kdaffil.code = '02' kdaffil.kdcif = s-kdcif  
                  kdaffil.who = g-ofc kdaffil.whn = g-today 
                  kdaffil.name = caps(cif.cif) + ' ' + caps(cif.name)
                  kdaffil.info[1] = cif.addr[1] + ' ; тел. ' + cif.tel + ' ; Руководитель: ' 
                  +  sub-cod.rcode  + ' ; Гл. бухгалтер: ' +  v-chief + ' ; Текущий счет в KZT: '.
           for each aaa where aaa.cif = cif.cif and aaa.lgr begins '1' and aaa.crc = 1 no-lock.
                  kdaffil.info[1] = kdaffil.info[1] + aaa.aaa + ','.
           end. 
       end.  
   end.
   end.

  /* Ищем в базе ОД руководителя как гл бухгалтера других компаний */
   for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc ne s-kdcif and sub-cod.d-cod = 'clnbk' 
                      and sub-cod.ccode = 'mainbk' 
                      and caps(sub-cod.rcode) = caps(v-inchief) no-lock. 
   find first cif where cif.cif = sub-cod.acc no-lock no-error.
   if avail cif then do:
       find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif                           
                          and caps(kdaffil.name) = caps(cif.cif) + ' ' + caps(cif.name)
                       no-lock no-error.
       if not avail kdaffil then do:
           find first b-sub-cod where b-sub-cod.sub = 'cln' and b-sub-cod.acc = cif.cif and 
                      b-sub-cod.d-cod = 'clnchf' and b-sub-cod.ccode = 'chief'  no-lock no-error.        
           if avail b-sub-cod then v-chief = b-sub-cod.rcode.
                              else v-chief = 'НЕ ПРЕДУСМОТРЕН'.
           create kdaffil.
           assign kdaffil.bank = s-ourbank kdaffil.code = '02' kdaffil.kdcif = s-kdcif  
                  kdaffil.who = g-ofc kdaffil.whn = g-today 
                  kdaffil.name = caps(cif.cif) + ' ' + caps(cif.name)
                  kdaffil.info[1] = cif.addr[1] + ' ; тел. ' + cif.tel + ' ; Руководитель: ' 
                  +  v-chief  + ' ; Гл. бухгалтер: ' +  sub-cod.rcode + ' ; Текущий счет в KZT: '.
           for each aaa where aaa.cif = cif.cif and aaa.lgr begins '1' and aaa.crc = 1 no-lock.
                  kdaffil.info[1] = kdaffil.info[1] + aaa.aaa + ','.
           end. 
       end.  
   end.
   end.
end.
/*
if v-poisk = 3 and trim(v-inchief) ne ''  then do:

  /* Ищем в базе ОД гл бухгалтера как гл бухгалтера других компаний */
   for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc ne s-kdcif and sub-cod.d-cod = 'clnbk' 
                      and sub-cod.ccode = 'mainbk' 
                      and caps(sub-cod.rcode) = caps(v-inchief) no-lock. 
   find first cif where cif.cif = sub-cod.acc no-lock no-error.
   if avail cif then do:
       find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif                           
                          and caps(kdaffil.name) = caps(cif.cif) + ' ' + caps(cif.name)
                       no-lock no-error.
       if not avail kdaffil then do:
           find first b-sub-cod where b-sub-cod.sub = 'cln' and b-sub-cod.acc = cif.cif and 
                      b-sub-cod.d-cod = 'clnchf' and b-sub-cod.ccode = 'chief'  no-lock no-error.        
           if avail b-sub-cod then v-chief = b-sub-cod.rcode.
                              else v-chief = 'НЕ ПРЕДУСМОТРЕН'.
           create kdaffil.
           assign kdaffil.bank = s-ourbank kdaffil.code = '02' kdaffil.kdcif = s-kdcif  
                  kdaffil.who = g-ofc kdaffil.whn = g-today 
                  kdaffil.name = caps(cif.cif) + ' ' + caps(cif.name)
                  kdaffil.info[1] = cif.addr[1] + ' ; тел. ' + cif.tel + ' ; Руководитель: ' 
                  +  v-chief  + ' ; Гл. бухгалтер: ' +  sub-cod.rcode + ' ; Текущий счет в KZT: '.
           for each aaa where aaa.cif = cif.cif and aaa.lgr begins '1' and aaa.crc = 1 no-lock.
                  kdaffil.info[1] = kdaffil.info[1] + aaa.aaa + ','.
           end. 
       end.  
   end.
   end.

  /* Ищем в базе ОД гл бухгалтера как руководителя других компаний */
   for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc ne s-kdcif and sub-cod.d-cod = 'clnchf' 
                      and sub-cod.ccode = 'chief' 
                      and caps(sub-cod.rcode) = caps(v-inchief) no-lock. 
   find first cif where cif.cif = sub-cod.acc no-lock no-error.
   if avail cif then do:
       find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '02' and kdaffil.kdcif = s-kdcif                           
                          and caps(kdaffil.name) = caps(cif.cif) + ' ' + caps(cif.name)
                       no-lock no-error.
       if not avail kdaffil then do:
           find first b-sub-cod where b-sub-cod.sub = 'cln' and b-sub-cod.acc = cif.cif and 
                      b-sub-cod.d-cod = 'clnbk' and b-sub-cod.ccode = 'mainbk'  no-lock no-error.        
           if avail b-sub-cod then v-chief = b-sub-cod.rcode.
                              else v-chief = 'НЕ ПРЕДУСМОТРЕН'.
           create kdaffil.
           assign kdaffil.bank = s-ourbank kdaffil.code = '02' kdaffil.kdcif = s-kdcif  
                  kdaffil.who = g-ofc kdaffil.whn = g-today 
                  kdaffil.name = caps(cif.cif) + ' ' + caps(cif.name)
                  kdaffil.info[1] = cif.addr[1] + ' ; тел. ' + cif.tel + ' ; Руководитель: ' 
                  +  sub-cod.rcode  + ' ; Гл. бухгалтер: ' +  v-chief + ' ; Текущий счет в KZT: '.
           for each aaa where aaa.cif = cif.cif and aaa.lgr begins '1' and aaa.crc = 1 no-lock.
                  kdaffil.info[1] = kdaffil.info[1] + aaa.aaa + ','.
           end. 
       end.  
   end.
   end.

end.
*/