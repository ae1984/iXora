/* fs_kc.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


{global.i}

def var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-srok as int init 0.
def var v-summa as char format "x(10)".
def var i as int.
define variable v-dt     as date format "99/99/9999".
define variable v-dtn     as date format "99/99/9999".
def var crlf as char.
def var coun as int init 1.
def var var1 as char.
def var var2 as char.
def var balance as deci.

v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

v-dtn = date('01/01' + substring(string(v-dt),6)).

def new shared temp-table t_kci
             field nn as int 
             field kc10 as decimal format 'z,zzz,zzz,zz9-'
             field kc20 as decimal format 'z,zzz,zzz,zz9-'
             field kc30 as decimal format 'z,zzz,zzz,zz9-'
             field kc40 as decimal format 'z,zzz,zzz,zz9-'
             field kc50 as decimal format 'z,zzz,zzz,zz9-'
             field kc60 as decimal format 'z,zzz,zzz,zz9-'
             field kc70 as decimal format 'z,zzz,zzz,zz9-'
             field kc80 as decimal format 'z,zzz,zzz,zz9-'
             field kc90 as decimal format 'z,zzz,zzz,zz9-'
             field kc95 as decimal format 'z,zzz,zzz,zz9-'
             field kcr10 as decimal format 'z,zzz,zzz,zz9-'
             field kcr20 as decimal format 'z,zzz,zzz,zz9-'
             field kcr30 as decimal format 'z,zzz,zzz,zz9-'
             field kcr40 as decimal format 'z,zzz,zzz,zz9-'
             field kcr50 as decimal format 'z,zzz,zzz,zz9-'
             field kcr60 as decimal format 'z,zzz,zzz,zz9-'
             field kcr70 as decimal format 'z,zzz,zzz,zz9-'
             field kcr80 as decimal format 'z,zzz,zzz,zz9-'
             field kcr90 as decimal format 'z,zzz,zzz,zz9-'
             field kcr95 as decimal format 'z,zzz,zzz,zz9-'.

define new shared stream m-out.
output stream m-out to rptfs.html.
define stream m-out1.
output stream m-out1 to rpt.img.

put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 crlf.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf. 


i = 1.
repeat :
  create t_kci.
  nn  = i. 
  kc10 = 0.
  kc20 = 0.
  kc30 = 0.
  kc40 = 0.
  kc50 = 0.
  kc60 = 0.
  kc70 = 0.
  kc80 = 0.
  kc90 = 0.
  kc95 = 0.
  kcr10 = 0.
  kcr20 = 0.
  kcr30 = 0.
  kcr40 = 0.
  kcr50 = 0.
  kcr60 = 0.
  kcr70 = 0.
  kcr80 = 0.
  kcr90 = 0.
  kcr95 = 0.
  i = i + 1.
  if i = 7 then leave.
end.


for each lon where lon.crc = 1.

        v-srok = lon.duedt - lon.rdt.      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
    for each lnscg where lnscg.lng = lon.lon and
             lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0 
             and lnscg.stdat ge v-dtn and lnscg.stdat le v-dt no-lock:
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lnscg.stdat
             no-lock no-error.
          balance = lnscg.paid.
          run fs_kcp (sub-cod.ccode).

  /*     find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name lnscg.stdat balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.
  */
    end.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
    if lon.ddt[5] <> ? and lon.duedt le v-dt and lon.duedt ge v-dtn then do:
        v-srok = lon.ddt[5] - lon.duedt.      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
        run atl-dat1(lon.lon,lon.duedt,3,output balance).
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lon.duedt
             no-lock no-error.
          run fs_kcp (sub-cod.ccode).

       find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name lon.crc lon.duedt balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.

    end.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
    if lon.cdt[5] <> ? and lon.ddt[5] le v-dt and lon.ddt[5] ge v-dtn then do:
        v-srok = lon.cdt[5] - lon.ddt[5].      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
        run atl-dat1(lon.lon,lon.ddt[5],3,output balance).
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lon.ddt[5]
             no-lock no-error.
          run fs_kcp (sub-cod.ccode).

       find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name lon.crc lon.ddt[5] balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.
  
    end.
  
end.

put stream m-out "<tr align=""center""><td><h3>ФС/КЦ(Т) за " string(v-dt)
                 "</h3></td></tr><br><br>"
                 crlf crlf.

run fs_kcr.p.


for each t_kci.
  kc10 = 0.
  kc20 = 0.
  kc30 = 0.
  kc40 = 0.
  kc50 = 0.
  kc60 = 0.
  kc70 = 0.
  kc80 = 0.
  kc90 = 0.
  kc95 = 0.
  kcr10 = 0.
  kcr20 = 0.
  kcr30 = 0.
  kcr40 = 0.
  kcr50 = 0.
  kcr60 = 0.
  kcr70 = 0.
  kcr80 = 0.
  kcr90 = 0.
  kcr95 = 0.
end.


for each lon where lon.crc > 1.

        v-srok = lon.duedt - lon.rdt.      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
    for each lnscg where lnscg.lng = lon.lon and
             lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0 
             and lnscg.stdat ge v-dtn and lnscg.stdat le v-dt no-lock:
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lnscg.stdat
             no-lock no-error.
        find last crchis where crchis.crc = lon.crc and crchis.regdt le lnscg.stdat no-error.
          balance = lnscg.paid * crchis.rate[1].
          run fs_kcp (sub-cod.ccode).

   /*    find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name  lnscg.stdat balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.
    */
    end.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
    if lon.ddt[5] <> ? and lon.duedt le v-dt and lon.duedt ge v-dtn then do:
        v-srok = lon.ddt[5] - lon.duedt.      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
        run atl-dat1(lon.lon,lon.duedt,3,output balance).
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lon.duedt
             no-lock no-error.
        find last crchis where crchis.crc = lon.crc and crchis.regdt le lon.duedt no-error.
          balance = balance * crchis.rate[1].
          run fs_kcp (sub-cod.ccode).

       find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name lon.crc lon.duedt balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.
    
    end.

        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lngrp' no-lock no-error.
    if lon.cdt[5] <> ? and lon.ddt[5] le v-dt and lon.ddt[5] ge v-dtn then do:
        v-srok = lon.cdt[5] - lon.ddt[5].      
        v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
        run atl-dat1(lon.lon,lon.ddt[5],3,output balance).
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= lon.ddt[5]
             no-lock no-error.
        find last crchis where crchis.crc = lon.crc and crchis.regdt le lon.ddt[5] no-error.
          balance = balance * crchis.rate[1].
          run fs_kcp (sub-cod.ccode).

       find first cif where cif.cif = lon.cif no-lock.
     put stream m-out1 lon.lon cif.name lon.crc lon.ddt[5] balance format '->>>>>>>>>>>9.99' ' ' v-srok ' ' sub-cod.ccode.
        find first sub-cod where sub-cod.sub = 'lon' and  sub-cod.acc = lon.lon 
             and sub-cod.d-cod = 'lneko' no-lock no-error.
     put stream m-out1 sub-cod.ccode skip.
    
    end.
    
end.

put stream m-out "<tr align=""center""><td><h3>ФС/КЦ(И) за " string(v-dt)
                 "</h3></td></tr><br><br>"
                 crlf crlf.

run fs_kcr.p.

put stream m-out "</table>" crlf.

output stream m-out close.

unix silent cptwin rptfs.html excel.exe. 


procedure fs_kcp.
  def input param v-code as char.
  
  if v-code = '10' then do: {fs_kc.i t_kci.kc10 t_kci.kcr10 } end.
  if v-code = '20' then do: {fs_kc.i t_kci.kc20 t_kci.kcr20 } end.
  if v-code = '30' then do: {fs_kc.i t_kci.kc30 t_kci.kcr30 } end.
  if v-code = '40' then do: {fs_kc.i t_kci.kc40 t_kci.kcr40 } end.
  if v-code = '50' then do: {fs_kc.i t_kci.kc50 t_kci.kcr50 } end.
  if v-code = '60' then do: {fs_kc.i t_kci.kc60 t_kci.kcr60 } end.
  if v-code = '70' then do: {fs_kc.i t_kci.kc70 t_kci.kcr70 } end.
  if v-code = '80' then do: {fs_kc.i t_kci.kc80 t_kci.kcr80 } end.
  if v-code = '90' then do: {fs_kc.i t_kci.kc90 t_kci.kcr90 } end.
  if v-code = '95' then do: {fs_kc.i t_kci.kc95 t_kci.kcr95 } end.

end.









