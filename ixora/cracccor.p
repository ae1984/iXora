/* cracccor.p
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

{global.i}
{lgps.i }

def shared var s-remtrz like remtrz.remtrz .
def shared frame remtrz.
def buffer  tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var dtt1 as char format "x(60)".
def var dtt2 as char format "x(60)".
def var rez as char format "x(1)".
def var sec like sub-cod.ccode.
def var vpoint like ppoint.point.
def var vdep   like ppoint.dep.
def var acc90 like aaa.aaa init ''.
def var ourbank as cha.

{ps-prmt.i}

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Нет записи OURBNK в sysc файле !".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

do  transaction:
  find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive no-error.

{rmz.f}
  find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

 if avail remtrz and remtrz.rsub = "cif" and
  ( remtrz.rbank = ourbank  or remtrz.rcbank = ourbank ) then 
 do on error undo, retry:
  update remtrz.cracc with frame remtrz.
  
  find aaa where aaa.aaa = remtrz.cracc and aaa.sta ne 'C' no-lock no-error.
  if available aaa then do :
   if aaa.crc ne remtrz.tcrc then do :
      Message "Счет не соответствует валюте платежа". pause.
      undo, retry.
   end.
   else do :
     remtrz.crgl = aaa.gl.
     find cif where cif.cif = aaa.cif no-lock no-error.
       if avail cif then do.
          tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
          tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
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
            tt1         label  "ПОЛНОЕ        "
            tt2        label  "НАЗВАНИЕ      "
            cif.jss    label  "РНН           "  format "x(13)"
            rez        label  "РЕЗИДЕНТ      "
            sec        label  "СЕКТ.ЭКОНОМИКИ"
            dtt1       label  "ДЕТАЛИ ПЛАТ-1 "
            dtt2       label  "ДЕТАЛИ ПЛАТ-2 "
            acc90       label  "ТРАНЗ.СЧЕТ    "
            with  overlay  1 columns column 1 row 7 frame  eee.
          disp  ppoint.name tt1 tt2
                cif.jss
                rez sec
                dtt1 dtt2
                acc90 with no-label frame eee.
          pause .
       end.
   end.  
  end.
  else do :
     message "Внимание! Счет не существует или закрыт! ". pause.
     remtrz.cracc = "".
     remtrz.crgl = 0.
  end.
 end. 
  find first que  where que.remtrz = s-remtrz exclusive-lock no-error.
  if avail que then do:
   que.dp = today.
   que.tp = time.
    v-text  = remtrz.remtrz + 
    ' ПОЛЯ : К.Сч. КСГК Сч.П изменены, ТИП  = '  + que.ptype .
     run lgps. 
   release que.
  end. 
  disp remtrz.rbank remtrz.rcbank remtrz.cracc remtrz.crgl remtrz.racc
  remtrz.rsub remtrz.ptype with frame remtrz.
   release remtrz.
end .
