/* r-ostrko.p
 * MODULE
        Отчеты по клиентам
 * DESCRIPTION
        остатки по текущим счетам клиентов 
        + карточки по 287051 для СПФ-1
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        22.11.2000 pragma
 * CHANGES
        31.10.2002 nadejda - наименование клиента заменено на форма собств + наименование   
        17.02.2004 nadejda - поиск по счетам ГК заменен на список групп текущих счетов
        02.12.2004 saltanat - Офицер ЦО может получать данные любого СПФ.
*/


{mainhead.i}
{functions-def.i}

def stream m-out.
def var    v-dat    as   date.
def var    v-point  like ofchis.point.
def var    v-dep    like ofchis.dep.
def var    v-ost    as   deci decimals 2.
def var    depart   like ppoint.depart.
def buffer b-aaa for aaa.
def temp-table temp
    field  cif   like cif.cif
    field  name  like cif.sname
    field  aaa   like aaa.aaa
    field  pr    as log init false
    field  crc   like aaa.crc
    field  code  like crc.code
    field  ost   as deci decimals 2 format "zzz,zzz,zzz,zzz,zz9.99-"
    index main is primary pr crc cif aaa.

v-dat = g-today.

find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
find first ppoint where ppoint.depart = ofchis.depart no-lock no-error.

if ofchis.depart = 1 then do:
update depart label " Укажите подразделение " help ' F2 - список подразделении' 
            validate(can-find (ppoint where ppoint.depart = depart no-lock), ' Ошибочный код - повторите ! ') skip
       v-dat label " Укажите дату " format "99/99/9999"
       validate(v-dat ge 12/19/1999 and v-dat le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame fr .
if depart > 1 then find first ppoint where ppoint.depart = depart no-lock no-error.
end.
else
update v-dat label " Укажите дату " format "99/99/9999"
       validate(v-dat ge 12/19/1999 and v-dat le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame dat .

display "   Ждите...   "  with row 5 frame ww centered .

output stream m-out to rpt.img.
put stream m-out
FirstLine( 1, 1 ) format "x(80)" skip(1)
"                          "
"ТЕКУЩИЕ СЧЕТА КЛИЕНТОВ "  skip
"Департамент: " ppoint.name format "x(60)" skip
"(остатки на "  string(v-dat) ")" skip(1)
FirstLine( 2, 1 ) format "x(80)" skip.
put stream m-out  fill( "-", 80 ) format "x(80)"  skip.
put stream m-out
" Код "
"   Клиент                "
"           Счет    "
" Вал "
"              Остаток      " skip.
put stream m-out  fill( "-", 80 ) format "x(80)"  skip.

/* список групп текущих счетов */
def var v-lgrs as char init "151".
find sysc where sysc.sysc = "vc-agr" no-lock no-error.
if avail sysc then v-lgrs = sysc.chval.
 
for each aaa where aaa.regdt <= v-dat no-lock:

    if lookup(aaa.lgr, v-lgrs) = 0 or aaa.sta = "c" then next.

    find cif where cif.cif = aaa.cif no-lock no-error.
    v-point = round(integer(cif.jame) / 1000, 0).
    v-dep = integer(cif.jame) mod 1000.
    if v-point  = ofchis.point and v-dep = ppoint.depart /*ofchis.dep*/ then do:  
       if v-dat = g-today then do. 
          v-ost = cbal.
          find b-aaa where b-aaa.aaa = aaa.craccnt no-lock no-error.
          if avail b-aaa then v-ost = v-ost + b-aaa.cbal. 
       end.   
       else do.
          find last aab where aab.aaa = aaa.aaa
                          and aab.fdt le v-dat no-lock no-error.
          if avail aab then v-ost = aab.avl.
             else v-ost = 0.
          find last aab where aab.aaa = aaa.craccnt
          and aab.fdt le v-dat no-lock no-error.
          if avail aab then v-ost = v-ost + aab.avl.
       end.
       create temp.
          temp.cif = cif.cif.
          temp.name = trim(trim(cif.prefix) + " " + trim(cif.sname)).
          temp.aaa = aaa.aaa.
          temp.crc = aaa.crc.
          find crc where crc.crc = aaa.crc no-lock no-error.
          if avail crc then
          temp.code = crc.code.
          temp.ost = v-ost.
    end. 
end.

/* для СПФ-1 инкассированная выручка клиентов на карточках ARP 287051 */
if v-dat = g-today and ofchis.point = 1 and ofchis.dep > 1 then do.
   for each arp where arp.gl = 287051 no-lock,
       each cif where cif.cif = arp.cif no-lock.
       v-point = round(integer(cif.jame) / 1000, 0).
       v-dep = integer(cif.jame) mod 1000.
       if v-point  = ofchis.point and v-dep = ofchis.dep then do.
            create temp.
            temp.cif = cif.cif.
            temp.name = trim(trim(cif.prefix) + " " + trim(cif.sname)).
            temp.aaa = arp.arp.
            temp.pr = true.
            temp.crc = arp.crc.
            find crc where crc.crc = arp.crc no-lock no-error.
            if avail crc then
               temp.code = crc.code.
            temp.ost = arp.cam[1] - arp.dam[1].
       end.
    end.
end.    

find first temp no-lock no-error.
  if avail temp then do.
     for each temp break by temp.pr by temp.crc by temp.cif by temp.aaa.
         accum temp.ost (total by temp.crc).
         put stream m-out " " temp.cif " " 
                              temp.name format "x(30)" " " 
                              temp.aaa " " 
                              temp.code " " 
                              temp.ost 
                              skip.
         if last-of(temp.crc) then
            put stream m-out "        Итого: "
                             space(39)
                             accum total by temp.crc temp.ost
                             format "zzz,zzz,zzz,zzz,zz9.99-" 
                             skip.              
     end.
  end.
put stream m-out  fill( "-", 80 ) format "x(80)"  skip.
output stream m-out close.

if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt( "rpt.img" ).
    pause before-hide.
end.
{functions-end.i}
