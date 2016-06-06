/* 3-crcl.p
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
*/

/* 3-crcl.p
   опция "Клиент" в п.5-2-1 и 5-3-6 
   изменения от 21.09.00  
             от 13.06.01 
   17.03.03 - sasco - обработка полочек x-pref,x-name
*/

   
def var acode like crc.code.
def var bcode like crc.code.    
def shared var s-remtrz like remtrz.remtrz.
def shared frame remtrz.  
def var v-date as date.
def buffer tgl for gl.
def var ourbank as cha.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var ts1 as char format "x(60)".
def var ts2 as char format "x(60)".
def var dtt1 as char format "x(60)".
def var dtt2 as char format "x(60)".            
def var rez as char format "x(1)".
def var sec like sub-cod.ccode.
def var vpoint like ppoint.point.
def var vdep   like ppoint.dep.
def var acc90 like aaa.aaa init ''.
def var v-name as char.
{lgps.i}
{rmz.f}
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   display " Нет записи OURBNK в sysc файле !".
   pause .
   undo .
   return .
end.
ourbank = sysc.chval.

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if available remtrz and (remtrz.rsub = "cif" or remtrz.rsub = "x-pref" or remtrz.rsub = "x-name" or remtrz.rsub = "valcon") 
                    and ( remtrz.rbank = ourbank  or remtrz.rcbank = ourbank )
   then do :
     if remtrz.rsub = "cif" or  remtrz.rsub = "valcon" then
        find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
     else 
        find aaa where aaa.aaa = remtrz.ba no-lock no-error.
     if not avail aaa and (remtrz.rsub = "x-name" or remtrz.rsub = "x-pref") then
        find aaa where aaa.aaa = remtrz.racc no-lock no-error.
     if available aaa then do :
        find cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
           
           v-name = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
           tt1 = substring(v-name,1,60).
           tt2 = substring(v-name,61,60).

           v-name = trim(trim(cif.prefix) + ' ' + trim(cif.sname)).
           ts1 = substring(v-name,1,60).
           ts2 = substring(v-name,61,60).
           
           rez = if substr(cif.geo,3,1) = '1' then '1' else '2'.
           find sub-cod where sub = 'cln' and sub-cod.acc = cif.cif 
                          and d-cod = 'secek' no-lock no-error.
           if avail sub-cod then sec = sub-cod.ccode.               
           dtt1  = trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2]).
           dtt2  = trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]).
           if dtt1  begins remtrz.racc  then
              dtt1 = substr(dtt1,length(remtrz.racc) + 2 )  .
           dtt2  = trim(substr(dtt1,61,10)) + ' ' +  dtt2.
           vpoint = integer(cif.jame) / 1000 - 0.5.
           vdep = integer(cif.jame) - vpoint * 1000.
           find ppoint where ppoint.point = vpoint 
                         and ppoint.dep = vdep
                         no-lock no-error.
           find first aaa where substr(aaa,4,3) = '090' 
                            and aaa.cif = cif.cif
                            and aaa.crc = remtrz.tcrc 
                            and aaa.sta <> 'C'
                            no-lock no-error.
           if avail aaa then acc90 = aaa.aaa.                  
           form
            ppoint.name  label  "ДЕПАРТАМЕНТ   " format "x(60)"
            cif.prefix label  "ФОРМА СОБСТВ. " format "x(60)"
            tt1        label  "ПОЛНОЕ        " 
            tt2        label  "      НАЗВАНИЕ"  
            ts1        label  "КРАТКОЕ       " 
            ts2        label  "      НАЗВАНИЕ"  
            cif.jss    label  "РНН           "  format "x(13)"
            rez        label  "РЕЗИДЕНТ      "
            sec        label  "СЕКТ.ЭКОНОМИКИ"
            dtt1       label  "ДЕТАЛИ ПЛАТ-1 "  
            dtt2       label  "ДЕТАЛИ ПЛАТ-2 "          
            acc90       label  "ТРАНЗ.СЧЕТ    "
            with  overlay  1 columns column 1 row 2 frame  eee.
           disp  ppoint.name 
                 cif.prefix 
                 tt1 tt2 
                 ts1 ts2
                 cif.jss  
                 rez sec           
                 dtt1 dtt2  
                 acc90 with no-label frame eee.
           pause .
        end.
        else do :
          Message " Клиент в CIF файле не существует .".
          pause .
        end.
     end.
end.
hide frame eee no-pause.
