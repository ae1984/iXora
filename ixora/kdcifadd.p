/*
 kdcifadd.p Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Завести клиента в базе Опер деп-та, если его там еще нет.
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
        26.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - При просмотре клиентов филиалов в ГБ - запретить заведение клиента в базе Опер. деп-та
        24.06.2004 nadejda - исправлено присваивание отметки о контроле клиента - номер записи для связки с данными о контроле
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}

if s-kdcif = '' then return.

find kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00")
     no-lock no-error.

if (kdcif.bank <> s-ourbank) then return.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


find first cif where cif.cif = s-kdcif no-lock no-error.
  if not avail cif then do transaction on error undo, retry:

     create cif.
     assign cif.cif = s-kdcif
            cif.regdt = g-today
            cif.who = g-ofc
            cif.whn = g-today
            cif.tim = time
            cif.ofc = g-ofc.

     find last ofchis where ofchis.ofc = g-ofc no-lock.
     cif.jame = string(ofchis.point * 1000 + ofchis.dep).
     cif.prefix = kdcif.prefix.
     cif.name = kdcif.name.
     cif.sname = kdcif.fname.
     if kdcif.ecdivis = '98' then cif.type = 'P'.
                             else cif.type = 'B'.
/*            
     if cif.type = "P" then do:
       create crg.
       crg.crg = string(next-value(crgnum)).
       assign
              crg.des = s-kdcif
              crg.who = g-ofc
              crg.whn = g-today
              crg.stn = 1
              crg.tim = time
              crg.regdt = g-today.
       cif.crg = string(crg.crg).
     end.
*/
     cif.addr[1] = kdcif.addr[1] .
     cif.addr[2] = kdcif.addr[2] .
     cif.jss = kdcif.rnn.
     cif.tel = kdcif.tel.
     cif.ref[8] = kdcif.regnom.
     cif.expdt = kdcif.urdt.
     cif.cust-since = kdcif.sotr.

     cif.stn = 0.
     cif.fname = g-ofc.   
 
     find ofc where ofc.ofc = g-ofc no-lock no-error.
     for each sub-dic where sub-dic.sub = "cln" no-lock .
     find first sub-cod where sub-cod.acc = s-kdcif 
          and sub-cod.sub = "cln" and sub-cod.d-cod = sub-dic.d-cod 
          use-index dcod  no-lock no-error . 
          if not avail sub-cod then do:
           create sub-cod. 
           sub-cod.acc = s-kdcif. 
           sub-cod.sub = "cln". 
           sub-cod.d-cod = sub-dic.d-cod . 
           sub-cod.ccode = "msc" . 
          end.
     end.
     {pk-sub-cod.i "'cln'" "'sproftcn'" s-kdcif ofc.titcd }
     {pk-sub-cod.i "'cln'" "'ecdivis'"  s-kdcif kdcif.ecdivis }

     find sub-cod where sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' and sub-cod.acc = s-kdcif no-error .
     if avail sub-cod and sub-cod.ccode = 'msc' then assign sub-cod.ccode = 'chief'
                                                            sub-cod.rcode = kdcif.chief[1] .
     find sub-cod where sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk' and sub-cod.acc = s-kdcif no-error .
     if avail sub-cod and sub-cod.ccode = 'msc' then assign sub-cod.ccode = 'mainbk'
                                                            sub-cod.rcode = kdcif.chief[2] .
     message skip " Клиент N " s-kdcif " заведен в базе Операционного департамента !" skip(1)
       view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  end.
  else do:
  message skip " Клиент N " s-kdcif " в базе Операционного департамента уже есть!" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
  end.
