/* r-deprko.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        остатки по срочным счетам клиентов 
        для РКО
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-1-3
 * AUTHOR
        19.01.2001 pragma
 * CHANGES
        02.12.2003 nadejda - изменения в связи с переходом на новые счета ГК
        02.12.2004 saltanat - Офицер ЦО может получать данные любого РКО.
*/


{mainhead.i}
{functions-def.i}

def stream m-out.
def var    v-dat    as   date.
def var    v-point  like ofchis.point.
def var    v-dep    like ofchis.dep.
def var    v-ost    as   deci decimals 2.
def var    v-gls    as char init "2206,2207,2208,2215,2217,2219".
def var    depart   like ppoint.depart.

def buffer b-aaa for aaa.
def temp-table temp
    field  cif   like cif.cif
    field  name  like cif.sname
    field  aaa   like aaa.aaa
    field  expdt like aaa.expdt
    field  crc   like aaa.crc
    field  code  like crc.code
    field  ost   as deci decimals 2 format "zzz,zzz,zz9.99-"
    field  sts   as char
    index main is primary unique crc name cif aaa.

v-dat = g-today.

find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
find first ppoint where ppoint.depart = ofchis.depart no-lock no-error.

if ofchis.depart = 1 then do:
update depart label " Укажите подразделение " help ' F2 - список подразделении' 
            validate(can-find (ppoint where ppoint.depart = depart no-lock), ' Ошибочный код - повторите ! ') skip
       v-dat  label " Укажите дату          " format "99/99/9999"
       validate(v-dat >= 12/19/1999 and v-dat <= g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame fr.
if depart > 1 then find first ppoint where ppoint.depart = depart no-lock no-error.
end.
else
update v-dat label " Укажите дату " format "99/99/9999"
       validate(v-dat >= 12/19/1999 and v-dat <= g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame dat .

display "   Ждите...   "  with row 5 frame ww centered .

output stream m-out to rpt.img.
put stream m-out
FirstLine( 1, 1 ) format "x(80)" skip(1)
  "                          СРОЧНЫЕ СЧЕТА КЛИЕНТОВ (ФИЗЛИЦА) "  skip(1)
  "  Департамент: " ppoint.name format "x(60)" skip
  "  Остатки на : " v-dat format "99/99/9999"  skip(1)
  "  " FirstLine( 2, 1 ) format "x(80)" skip(1)
  fill( "-", 80 ) format "x(80)"  skip
  " Код    Клиент                           Счет     Вал Дата оконч.     Остаток Ст" skip
  fill( "-", 80 ) format "x(80)"  skip.


for each gl no-lock:
  if lookup(substr(string(gl.gl), 1, 4), v-gls) = 0 then next.

  for each aaa where aaa.gl = gl.gl no-lock:
      if aaa.regdt > v-dat then next.

      /* только физлица */
      find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
      if sub-cod.ccode = "0" then next.
      
      find cif where cif.cif = aaa.cif no-lock no-error.

      v-point = integer(cif.jame) / 1000 - 0.5  .
      v-dep = integer(cif.jame) - v-point * 1000.

      /* только департамент офицера */
      if depart = 0 then do: if not (v-point = ofchis.point and v-dep = ofchis.dep) then next. end.
      /* 02.12.2004 saltanat - Если офицер ЦО, то берем данные по выбранному стр.подразделению */
      else do: if not (v-point = ofchis.point and v-dep = depart) then next. end.
      
      if v-dat = g-today then do. 
         v-ost = cbal.
      end.   
      else do.
         find last aab where aab.aaa = aaa.aaa and aab.fdt <= v-dat no-lock no-error.
         if avail aab then v-ost = aab.avl.
                      else v-ost = 0.
      end.

      if v-ost = 0 then next.

      find crc where crc.crc = aaa.crc no-lock no-error.

      create temp.
      assign temp.cif = cif.cif
             temp.name = trim(trim(cif.prefix) + " " + trim(cif.sname))
             temp.aaa = aaa.aaa
             temp.expdt = aaa.expdt
             temp.crc = aaa.crc
             temp.code = if avail crc then crc.code else ""
             temp.ost = v-ost
             temp.sts = aaa.sta.
  end. /* for each aaa */
end. /* for each gl */


find first temp no-lock no-error.
if avail temp then do.
   for each temp break by temp.crc by temp.name by temp.cif by temp.aaa:
       accum temp.ost (total by temp.crc).
       put stream m-out " " temp.cif " " 
                            temp.name format "x(30)" " " 
                            temp.aaa " " 
                            temp.code "  " 
                            temp.expdt
                            temp.ost 
                            temp.sts format "x(2)"
                            skip.
       if last-of(temp.crc) then
          put stream m-out fill( "-", 80 ) format "x(80)" skip
                           "        Итого: "
                           space(4)
                           accum total by temp.crc temp.ost
                           format "zzz,zzz,zzz,zzz,zz9.99-" 
                           skip(1).
   end.
end.

put stream m-out fill( "-", 80 ) format "x(80)" skip.
output stream m-out close.

if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt("rpt.img").
    pause before-hide.
end.

{functions-end.i}
