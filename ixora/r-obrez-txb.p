/* r-obrez.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * BASES
          BANK TXB 
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
       16/12/05 marinav
*/

/* r-obrez.p
   Обороты по счетам ГК за период с выделением резидентов/нерезидентов,
   счета только группы 220000
   изменения от 05.05.2000 */

define shared var g-today  as date.
define shared variable g-batch  as log initial false.
def shared var g-ofc as char.

define shared variable fdate as date.
define shared  variable tdate as date.
define shared variable v-gl like txb.jl.gl.
def shared var v-d as date.
def var dsum as decimal extent 2 format "zzz,zzz,zzz,zz9.99".
def var csum as decimal extent 2 format "zzz,zzz,zzz,zz9.99".
define variable v-acc like txb.jl.acc.
define variable v-rez as deci format "9".
define variable v-crc as char format "x(3)".
define variable v-subled as character.
define buffer jla for txb.jl.
define buffer b-gl for txb.gl.
define buffer b-aaa for txb.aaa.
define buffer b-arp for txb.arp.
define temp-table w-rab
    field    rez      as deci format "9" init 0
    field    crc      as char format "x(2)"
    field    code     like txb.crc.code
    field    damt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    camt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    damtt    as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    camtt    as decimal   format "zzz,zzz,zzz,zz9.99" init 0.0
    field    gl1      like txb.aaa.gl
    field    pr       as char format "x" init ' '
    field    jh       like txb.jl.jh.


/*{functions-def.i}*/




FUNCTION FirstLine RETURNS char ( input nLine as decimal, input nLen as decimal ).
DEF VAR cLine AS CHAR.

    find first txb.cmp no-lock no-error.
    find first bank.ofc where bank.ofc.ofc = g-ofc no-lock no-error.
    IF nLine = 1
    THEN
        cLine = string( today, "99/99/9999" ) + ", " +
        string( time, "HH:MM:SS" ) + ", " +
        trim( txb.cmp.name ).
    ELSE
        cLine = "Исполнитель: " + bank.ofc.name.
    RETURN cLine.

END FUNCTION.
/***/







for each w-rab:
    delete w-rab.
end.

for each txb.aaa  where txb.aaa.gl = v-gl  no-lock.      /* 1 - по каждому счету */

    find txb.cif of txb.aaa no-lock no-error.             /* клиент */

     if length(txb.cif.geo) gt 0 then                 /* резидентство */
      if substring(txb.cif.geo,length(txb.cif.geo),1) eq "1" then v-rez = 1.
      else v-rez = 2.

   find txb.crc of txb.aaa no-lock no-error.              /* валюта */

/*16/12/05 marinav*/
   for each txb.jl where txb.jl.acc eq txb.aaa.aaa and txb.jl.gl = v-gl
       and txb.jl.jdt ge fdate and txb.jl.jdt le tdate  use-index acc
       no-lock :                               /* 2 - транзакции по счету */
   create w-rab.
   if length(string(txb.crc.crc)) = 1 then w-rab.crc = '0' + string(txb.crc.crc).
   else w-rab.crc = string(txb.crc.crc).
   w-rab.code = txb.crc.code.
   w-rab.rez = v-rez.
   w-rab.pr = ' '.
   w-rab.jh = txb.jl.jh.
   find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt le txb.jl.whn
        no-lock no-error.                         /*  последн.курс вал. */

    find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.    /* заголовок транзакции */
    v-acc = "".
    if txb.jl.dc = "D" then do:
       for each txb.jla where txb.jla.jh = txb.jh.jh and txb.jla.dc = "C" and
                txb.jla.crc = txb.jl.crc and txb.jla.cam = txb.jl.dam no-lock .
           v-subled = txb.jla.subled.
           v-acc = txb.jla.acc.
           if v-acc = "" then
              v-acc = string(txb.jla.gl,"999999").
           else do:
                if txb.jla.subled = "ARP"
                   then do:
                   find txb.arp where txb.arp.arp = v-acc no-lock no-error.
                   v-acc = string(txb.arp.gl,"999999").
                   end.
                   else if txb.jla.subled = "CIF"
                   then do:
                   find b-aaa where b-aaa.aaa = v-acc no-lock no-error.
                   v-acc = string(b-aaa.gl,"999999").
                   find cif of b-aaa no-lock no-error.
                   if length(txb.cif.geo) gt 0 then
                      if substring(txb.cif.geo,length(txb.cif.geo),1) eq "1"
                      then w-rab.pr = 'р'.
                      else w-rab.pr = 'н'.
                   end.
                   else if txb.jla.subled = "DFB"
                   then do:
                   find txb.dfb where txb.dfb.dfb = v-acc no-lock no-error.
                   v-acc = string(txb.dfb.gl,"999999").
                   end.
                   else if txb.jla.subled = "EPS"
                   then do:
                   find txb.eps where txb.eps.eps = v-acc no-lock no-error.
                   v-acc = string(txb.eps.gl,"999999").
                   end.
                   else if txb.jla.subled = "AST"
                   then do:
                   find txb.ast where txb.ast.ast = v-acc no-lock no-error.
                   v-acc = string(txb.ast.gl,"999999").
                   end.
                   else if txb.jla.subled = "LON"
                   then do:
                   find txb.lon where txb.lon.lon = v-acc no-lock no-error.
                   v-acc = string(txb.lon.gl,"999999").
                   end.
          end.
          leave.
          end.
       end.
          else do:
           for each txb.jla where txb.jla.jh = txb.jh.jh and txb.jla.dc = "D" and
               txb.jla.crc = txb.jl.crc and txb.jla.dam = txb.jl.cam no-lock.
               v-subled = txb.jla.subled.
               v-acc = txb.jla.acc.
               if v-acc = ""
               then v-acc = string(txb.jla.gl,"999999").
               else do:
               if txb.jla.subled = "ARP"
               then do:
                find txb.arp where txb.arp.arp = v-acc no-lock no-error.
                v-acc = string(txb.arp.gl,"999999").
                end.
               else if txb.jla.subled = "CIF"
                then do:
                 find b-aaa where b-aaa.aaa = v-acc no-lock no-error.
                 v-acc = string(b-aaa.gl,"999999").
                 find txb.cif of b-aaa no-lock no-error.
                 if length(txb.cif.geo) gt 0 then
                    if substring(txb.cif.geo,length(txb.cif.geo),1) eq '1'
                    then w-rab.pr = 'р'.
                    else w-rab.pr = 'н'.
                 end.
               else if txb.jla.subled = "DFB"
                then do:
                 find txb.dfb where txb.dfb.dfb = v-acc no-lock no-error.
                 v-acc = string(txb.dfb.gl,"999999").
                 end.
               else if txb.jla.subled = "EPS"
                then do:
                 find txb.eps where txb.eps.eps = v-acc no-lock no-error.
                 v-acc = string(txb.eps.gl,"999999").
                 end.
               else if txb.jla.subled = "AST"
                then do:
                 find txb.ast where txb.ast.ast = v-acc no-lock no-error.
                 v-acc = string(txb.ast.gl,"999999").
                end.
               else if txb.jla.subled = "LON"
               then do:
               find txb.lon where txb.lon.lon = v-acc no-lock no-error.
               v-acc = string(txb.lon.gl,"999999").
               end.
       end.
     leave.
     end.
   end.
   w-rab.gl1 = decimal(v-acc).

   if txb.jl.dc eq "D" then do:
      w-rab.damt = txb.jl.dam.
      w-rab.damtt = txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
      w-rab.camt = 0.
      w-rab.camtt = 0.
   end.
   else do:
      w-rab.damt = 0.
      w-rab.damtt = 0.
      w-rab.camt = txb.jl.cam.
      w-rab.camtt = txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
   end.
   dsum[1] = dsum[1] + w-rab.damt.
   csum[1] = csum[1] + w-rab.camt.
   dsum[2] = dsum[2] + w-rab.damtt.
   csum[2] = csum[2] + w-rab.camtt.
   end.
   end.

/* вывод */
def stream m-out.
output stream m-out to rpt.img append.
put stream m-out
FirstLine( 1, 1 ) format 'x(80)' skip(1)
'                      '
'ОБОРОТЫ ПО СЧЕТУ ' string(v-gl,"999999") skip
'                      '
'за период с ' string(fdate)  ' по '  string(tdate) skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
put stream m-out
'Вал. '
'Счет ГК '
'        Дебет     '
'       Кредит    '
'  Дебет(тенге)  '
'  Кредит(тенге)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1).
find first w-rab no-lock no-error.
if not available w-rab then
   put stream m-out  'Движения по счету за выбранный период времени не было'
   at 5 skip.
else do:
find first w-rab where w-rab.gl1 = 0 no-lock no-error.
if avail w-rab then do:
   put stream m-out  'Неопознанные транзакции (счет ГК = 0)' skip(1).
   put stream m-out 'Вал. ' ' Транз.' '           Дебет ' '          Кредит'               skip.
   for each w-rab where w-rab.gl1 = 0 break by w-rab.crc by w-rab.jh .
       accum w-rab.damt  (total by w-rab.crc).
       accum w-rab.camt  (total by w-rab.crc).
       put stream m-out w-rab.code ' '
                        w-rab.jh
                        w-rab.damt format "z,zzz,zzz,zz9.99"
                        w-rab.camt format "zz,zzz,zzz,zz9.99" skip.
       if last-of(w-rab.crc) then do:
          put stream m-out 'Итого:  ' w-rab.code
              accum total by w-rab.crc w-rab.damt  format "zz,zzz,zzz,zz9.99"
              accum total by w-rab.crc w-rab.camt  format "zz,zzz,zzz,zz9.99"               skip.
       end.
   end.
end.
for each w-rab break by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr:
  accum w-rab.damt  (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.camt  (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.damtt (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.camtt (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
if first-of(w-rab.rez) then do:
   if w-rab.rez = 1 then put stream m-out skip(1) "Резиденты." at 5 skip(1).
   else put stream m-out "Нерезиденты." at 5 skip(1).
end.
if last-of(w-rab.pr)  then do:
   put stream m-out   w-rab.code '  ' w-rab.gl1.
   if w-rab.pr <> ' ' then
      put stream m-out  w-rab.pr
      (accum total by w-rab.pr w-rab.damt) format "z,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.camt) format "zz,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.damtt) format "zz,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.camtt) format "zz,zzz,zzz,zz9.99" skip.
   else
      put stream m-out
      (accum total by w-rab.pr w-rab.damt) format "zz,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.camt) format "zz,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.damtt) format "zz,zzz,zzz,zz9.99"
      (accum total by w-rab.pr w-rab.camtt) format "zz,zzz,zzz,zz9.99" skip.
end.
if last-of(w-rab.crc) then do:
   put stream m-out 'Итого:  ' w-rab.code
       (accum total by  w-rab.crc w-rab.damt)  format "zz,zzz,zzz,zz9.99"
       (accum total by  w-rab.crc w-rab.camt)  format "zz,zzz,zzz,zz9.99"
       (accum total by  w-rab.crc w-rab.damtt) format "zz,zzz,zzz,zz9.99"
       (accum total by  w-rab.crc w-rab.camtt) format                         "zz,zzz,zzz,zz9.99"skip(1).
end.
if last-of(w-rab.rez) then do:
   put stream m-out 'Итого: '.
   if w-rab.rez = 1 then put stream m-out 'рез.'.
      else put stream m-out 'н/р.'.
   if w-rab.code = "KZT" then put stream m-out
     (accum total  by w-rab.rez w-rab.damt ) format "zz,zzz,zzz,zz9.99"
     (accum total  by w-rab.rez w-rab.camt ) format "zz,zzz,zzz,zz9.99".
   else put stream m-out space(34).
   put stream m-out
  (accum total  by w-rab.rez w-rab.damtt ) format "zz,zzz,zzz,zz9.99"
  (accum total  by w-rab.rez w-rab.camtt ) format "zz,zzz,zzz,zz9.99" skip(1).
end.
end.
   put stream m-out 'Всего:  '.
   if w-rab.code = "KZT" then put stream m-out space(3)
     dsum[1] format "zz,zzz,zzz,zz9.99"
     csum[1] format "zz,zzz,zzz,zz9.99".
   else put stream m-out space(37).
   put stream m-out
       dsum[2] format "zz,zzz,zzz,zz9.99"
       csum[2] format "zz,zzz,zzz,zz9.99" skip(1).
put stream m-out  fill( '-', 80 ) format 'x(80)' skip(2).
end.
output stream m-out close.
/*
if  not g-batch then do:
    pause 0 before-hide.
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
*/

/*{functions-end.i}*/

return.








