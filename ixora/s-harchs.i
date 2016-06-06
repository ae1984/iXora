/* s-harchs.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
       25/03/2009 galina - добавила поле Поручитель
       23.04.2009 galina - убираем поле поручитель
*/

/*----------------------------------
  #3.Izvёle aprakst–
----------------------------------*/
s-longrp = lon.grp.
grp-name = "".
crc-code = "".
cat-des = "".
if lon.grp > 0
then do:
     find longrp where longrp.longrp = lon.grp no-lock.
     grp-name = " " + longrp.des.
end.
if lon.crc > 0
then do:
     find crc where crc.crc = lon.crc no-lock.
     crc-code = crc.code.
end.
if lon.loncat > 0
then do:
     find loncat where loncat.loncat = lon.loncat no-lock.
     cat-des = " " + loncat.des.
end.
find last lonhar where lonhar.lon = s-lon and lonhar.fdt < s-dt
     no-lock no-error.
if not available lonhar
then do:
     s-stat0 = ?.
     s-dts1 = s-dt.
     s-kuzk0 = ?.
     s-dtu1 = s-dt.
end.
else do:
     s-stat0 = lonhar.lonstat.
     s-dts1 = lonhar.fdt.
     s-kuzk0 = lonhar.rez-dec[1].
     s-dtu1 = lonhar.fdt.
end.
laiks = time.
run nokavets(lon.lon,s-dt,1,input-output s-sk,output s-dk).
run prc-kav(lon.lon,s-dt,output s-sp,output s-dp).
s-pk = 0.
s-dtk = ?.
v-dt = ?.
for each ln%his where ln%his.lon = lon.lon and ln%his.stdat < s-dt no-lock:
    if v-dt <> ln%his.duedt
    then do:
         v-dt = ln%his.duedt.
         s-pk = s-pk + 1.
         s-dtk = ln%his.stdat.
    end.
end.
if s-pk > 0
then s-pk = s-pk - 1.
s-pp = 0.
s-dtp = ?.
v-dt = ?.
r = loncon.rez-char[6].
repeat while index(r,"&") > 0:
   k = index(r,"&") - 10.
   r1 = substring(r,k,2).
   i = integer(r1).
   r1 = substring(r,k + 3,2).
   j = integer(r1).
   r1 = substring(r,k + 6,4).
   r = substring(r,k + 11).
   k = integer(r1).
   v-dt1 = date(j,i,k).
   if v-dt1 < s-dt
   then do:
        s-pp = s-pp + 1.
        if v-dt = ?
        then v-dt = v-dt1.
        else if v-dt1 > v-dt
        then v-dt = v-dt1.
   end.
   if s-pp > 0
   then s-dtp = v-dt.
end.
find last sechis where sechis.lon = lon.lon and sechis.chdt < s-dt
     no-lock no-error.
if not available sechis
then do:
     find last crchis where crchis.crc = lon.crc and crchis.rdt < s-dt no-lock.
     run atl-dat(lon.lon,s-dt,output s-atln).
     s-atll = s-atln * crchis.rate[1] / crchis.rate[9].
     s-sec = 0.
     if s-atll > 0
     then for each lonsec1 where lonsec1.lon = lon.lon and
          lonsec1.fdt <= s-dt and lonsec1.tdt >= s-dt no-lock:
          if lonsec1.crc <> 1 and lonsec1.secamt > 0
          then do:
               find last crchis where crchis.crc = lonsec1.crc and
                    crchis.rdt < s-dt no-lock.
               s-sec = s-sec + lonsec1.secamt * crchis.rate[1] / crchis.rate[9].
          end.
          else s-sec = s-sec + lonsec1.secamt.
     end.
     if s-atll = 0
     then s-prc = 100.
     else s-prc = s-sec / s-atll * 100.
end.
else do:
     s-sec = 0.
     v-dt = sechis.chdt.
     find last crchis where crchis.crc = lon.crc and crchis.rdt < v-dt no-lock.
     run atl-dat(lon.lon,v-dt,output s-atln).
     s-atll = s-atln * crchis.rate[1] / crchis.rate[9].
     if s-atll > 0
     then for each sechis where sechis.lon = lon.lon and sechis.chdt = v-dt and
          sechis.fdt <= s-dt and sechis.tdt >= s-dt no-lock:
          if sechis.crc <> 1 and sechis.rez-dec[1] > 0
          then do:
               find last crchis where crchis.crc = sechis.crc and
                    crchis.rdt < sechis.chdt no-lock.
               s-sec = s-sec + sechis.rez-dec[1] *
                       crchis.rate[1] / crchis.rate[9].
          end.
          else s-sec = s-sec + sechis.rez-dec[1].
     end.
     if s-atll = 0
     then s-prc = 100.
     else s-prc = s-sec / s-atll * 100.
end.
run atl-dat(lon.lon,s-dt,output dam1-cam1).
find last ln%his where ln%his.lon = lon.lon and ln%his.stdat < s-dt
     no-lock no-error.
if not available ln%his
then find first ln%his where ln%his.lon = lon.lon no-lock.
v-uno = lon.prnmos.
display v-cif
        v-lcnt
        loncon.lon
        s-longrp
        v-uno
        lon.crc
        crc-code
        loncon.objekts
        ln%his.rdt
        ln%his.duedt
        ln%his.opnamt
        dam1-cam1
        ln%his.intrate
        /*v-guarantor*/
        s-stat0
        s-dts1
        s-kuzk0
        s-dtu1
        s-sk
        s-dk
        s-sp
        s-dp
        s-pk
        s-dtk
        s-pp
        s-dtp
        s-sec
        s-prc
        with frame lon.
        color display input dam1-cam1 with frame lon.
        display v-vards with frame cif.
