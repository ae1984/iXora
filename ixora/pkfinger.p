/* pkfinger.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Снятие отпечатков пальцев перед выдачей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        11/04/2006 madiar
 * CHANGES
        12/04/2006 madiar - пока только в Алматы
        17/04/2006 madiar - временно отключаем биометрию
*/

{global.i}
{pk.i}

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
           pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

/* if s-ourbank <> "txb00" then */ return.

if pkanketa.sts <> '20' then do:
  message " Некорректный статус для операции! " view-as alert-box buttons ok title " Ошибка! ".
  return.
end.

def var s-cif as char.
def var v-sex as char.

find first cif where cif.cif = pkanketa.cif no-lock no-error.
if avail cif then do:
   if not cif.biom then do:
     find current cif exclusive-lock.
     cif.biom = yes.
     find current cif no-lock.
   end.
end.
else do:
   
   do transaction on error undo, retry:
       find nmbr where nmbr.code = "cif" exclusive-lock.
       s-cif = string(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
       nmbr.nmbr = nmbr.nmbr + 1.
       release nmbr.
       create cif.
       assign cif.cif = s-cif
              cif.regdt = g-today
              cif.who = g-ofc
              cif.whn = g-today
              cif.tim = time
              cif.ofc = g-ofc
              cif.type = "P".
       
       create crg.
       crg.crg = string(next-value(crgnum)).
       assign crg.des = s-cif
              crg.who = g-ofc
              crg.whn = g-today
              crg.stn = 1
              crg.tim = time
              crg.regdt = g-today.
       
       cif.crg = string(crg.crg).
       
       find last ofchis where ofchis.ofc = g-ofc no-lock.
       cif.jame = string(ofchis.point * 1000 + ofchis.dep).
       cif.name = pkanketa.name.
       
       run pkdefsfio (pkanketa.ln, output cif.sname).
       cif.geo = "021".
       cif.cgr = 501.
       cif.stn = 0.
       cif.fname = g-ofc.
       /**** biometry ****/
       cif.biom = yes.
       /**** biometry ****/
       
       find current pkanketa exclusive-lock.
       pkanketa.cif = cif.cif.
       find current pkanketa no-lock.
       
   end.
   
   for each sub-dic where sub-dic.sub = "cln" no-lock:
       find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = sub-dic.d-cod use-index dcod no-lock no-error.
       if not avail sub-cod then do:
          create sub-cod.
          sub-cod.acc = s-cif.
          sub-cod.sub = "cln".
          sub-cod.d-cod = sub-dic.d-cod .
          sub-cod.ccode = "msc" .
       end.
   end.
   
   find ofc where ofc.ofc = g-ofc no-lock no-error.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
        pkanketh.kritcod = "mf" no-lock no-error.
   if avail pkanketh and pkanketh.value1 <> "" then v-sex = trim(pkanketh.value1).
   
   {pk-sub-cod.i "'cln'" "'sproftcn'" s-cif ofc.titcd }
   {pk-sub-cod.i "'cln'" "'clnsts'"   s-cif "'1'"   }
   {pk-sub-cod.i "'cln'" "'ecdivis'"  s-cif "'98'"  }
   {pk-sub-cod.i "'cln'" "'secek'"    s-cif "'9'"  }
   {pk-sub-cod.i "'cln'" "'clnsex'"   s-cif v-sex }
   
end. /* not avail cif */


find last uplfnghst where uplfnghst.cif = cif.cif and uplfnghst.upl = "clnchf" and uplfnghst.sts no-lock no-error. /* проверим, снимались ли по нему отпечатки пальцев */
if not avail uplfnghst then /*если не снимались*/ run fingers(cif.cif,"clnchf").
else message " Сканирование отпечатков пальцев уже проводилось. " view-as alert-box buttons ok.


