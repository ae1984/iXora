/* r-obrezd.p
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

/* r-obrezd.p
   Обороты по счетам ГК за период с выделением резидентов/нерезидентов,
   счета DFB 105210 105220 
   изменения от 19.07.2000 */

define variable fdate as date.
define variable tdate as date.  
define variable v-gl like jl.gl.
def var v-d as date.
def var dsum as decimal extent 2 format "zzz,zzz,zzz,zz9.99".
def var csum as decimal extent 2 format "zzz,zzz,zzz,zz9.99".
define variable v-acc like jl.acc.
define variable v-rez as deci format "9".
define variable v-crc as char format "x(3)".
define variable v-subled as character.
define buffer jla for jl.
define buffer b-gl for gl.
define buffer b-aaa for aaa.
define buffer b-dfb for dfb.
define buffer b-arp for arp.
define temp-table w-rab
    field    rez      as deci format "9" init 0
    field    crc      as char format "x(2)"
    field    code     like crc.code
    field    damt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    camt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    damtt    as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    camtt    as decimal   format "zzz,zzz,zzz,zz9.99" init 0.0
    field    gl1      like aaa.gl
    field    pr       as char format "x" init ' '.
   
{mainhead.i}
{functions-def.i}
fdate = g-today.
tdate = g-today.

display v-gl label "Счет Г/К"
        fdate label " с "
        tdate label " по "
        with row 8 centered  side-labels frame opt title "Введите :".

update v-gl validate (v-gl ne 0 and can-find(gl where gl.gl = v-gl)  
            ,
            "Не существует счет ") with frame opt. 
                               
update fdate
       validate(fdate <= g-today,"За завтра невозможно получить отчет !")
       with frame opt.
              
update tdate validate(tdate >= fdate and tdate <= g-today,
       "Должно быть: Начало <= Конец <= Сегодня")
        with frame opt.

hide frame opt.
display '   Ждите...   '  with row 5 frame ww centered .
    
for each w-rab:
    delete w-rab.
end.

for each dfb  where dfb.gl = v-gl  no-lock.      /* 1 - по каждому счету */

    find bankl where bankl.bank = dfb.bank no-lock no-error.   /* банк */

     if bankl.frbno <> 'KZ' then                 /* резидентство */
       v-rez = 2. 
      else v-rez = 1.
                                                 
   find crc of dfb no-lock no-error.              /* валюта */
   
   for each jl where jl.acc eq dfb.dfb 
       and jl.jdt ge fdate and jl.jdt le tdate and jl.lev = 1 use-index acc
       no-lock :                               /* 2 - транзакции по счету */
   create w-rab.
   if length(string(crc.crc)) = 1 then w-rab.crc = '0' + string(crc.crc).
   else w-rab.crc = string(crc.crc).
   w-rab.code = crc.code.
   w-rab.rez = v-rez.
   w-rab.pr = ' '.
   find last crchis where crchis.crc = dfb.crc and crchis.rdt le jl.whn
        no-lock no-error.                         /*  последн.курс вал. */

    find jh where jh.jh = jl.jh no-lock no-error.    /* заголовок транзакции */
    v-acc = "".
    if jl.dc = "D" then do:
       for each jla where jla.jh = jh.jh and jla.dc = "C" and 
                jla.crc = jl.crc and jla.cam = jl.dam no-lock .
           v-subled = jla.subled. 
           v-acc = jla.acc.
           if v-acc = "" then 
              v-acc = string(jla.gl,"999999").
           else do:
                if jla.subled = "ARP"
                   then do:
                   find arp where arp.arp = v-acc no-lock no-error.
                   v-acc = string(arp.gl,"999999").
                   end.
                   else if jla.subled = "CIF"
                   then do:
                   find b-aaa where b-aaa.aaa = v-acc no-lock no-error.
                   v-acc = string(b-aaa.gl,"999999").
                   find cif of b-aaa no-lock no-error.    
                   if length(cif.geo) gt 0 then   
                      if substring(cif.geo,length(cif.geo),1) eq "1" 
                      then w-rab.pr = 'р'.
                      else w-rab.pr = 'н'.
                   end.
                   else if jla.subled = "DFB"
                   then do:
                   find b-dfb where b-dfb.dfb = v-acc no-lock no-error.
                   v-acc = string(b-dfb.gl,"999999").  
                   end.
                   else if jla.subled = "EPS"
                   then do:
                   find eps where eps.eps = v-acc no-lock no-error.
                   v-acc = string(eps.gl,"999999").
                   end.
                   else if jla.subled = "AST"
                   then do:
                   find ast where ast.ast = v-acc no-lock no-error.
                   v-acc = string(ast.gl,"999999").
                   end.
                   else if jla.subled = "LON"
                   then do:
                   find lon where lon.lon = v-acc no-lock no-error.
                   v-acc = string(lon.gl,"999999").
                   end.
          end. 
          leave.
          end. 
       end. 
          else do:
           for each jla where jla.jh = jh.jh and jla.dc = "D" and
               jla.crc = jl.crc and jla.dam = jl.cam no-lock.
               v-subled = jla.subled.
               v-acc = jla.acc.
               if v-acc = ""
               then v-acc = string(jla.gl,"999999").
               else do:
               if jla.subled = "ARP"
               then do:
                find arp where arp.arp = v-acc no-lock no-error.
                v-acc = string(arp.gl,"999999").
                end.
               else if jla.subled = "CIF"
                then do:
                 find b-aaa where b-aaa.aaa = v-acc no-lock no-error.
                 v-acc = string(b-aaa.gl,"999999").
                 find cif of b-aaa no-lock no-error.
                 if length(cif.geo) gt 0 then
                    if substring(cif.geo,length(cif.geo),1) eq '1'
                    then w-rab.pr = 'р'.
                    else w-rab.pr = 'н'.
                 end.
               else if jla.subled = "DFB"
                then do:
                 find b-dfb where b-dfb.dfb = v-acc no-lock no-error.
                 v-acc = string(b-dfb.gl,"999999").
                 end.
               else if jla.subled = "EPS"
                then do:
                 find eps where eps.eps = v-acc no-lock no-error.
                 v-acc = string(eps.gl,"999999").
                 end.
               else if jla.subled = "AST"
                then do:
                 find ast where ast.ast = v-acc no-lock no-error.
                 v-acc = string(ast.gl,"999999").
                end.
               else if jla.subled = "LON"
               then do:
               find lon where lon.lon = v-acc no-lock no-error.
               v-acc = string(lon.gl,"999999").
               end.
       end.
     leave.
     end.
   end.  
   w-rab.gl1 = decimal(v-acc).        
   
   if jl.dc eq "D" then do:
      w-rab.damt = jl.dam.
      w-rab.damtt = jl.dam * crchis.rate[1] / crchis.rate[9].
      w-rab.camt = 0.
      w-rab.camtt = 0.
   end.
   else do:
      w-rab.damt = 0.
      w-rab.damtt = 0.
      w-rab.camt = jl.cam.
      w-rab.camtt = jl.cam * crchis.rate[1] / crchis.rate[9].
   end.
   dsum[1] = dsum[1] + w-rab.damt.
   csum[1] = csum[1] + w-rab.camt.
   dsum[2] = dsum[2] + w-rab.damtt.
   csum[2] = csum[2] + w-rab.camtt.
   end.
   end.   

/* вывод */
def stream m-out.
output stream m-out to rpt.img. 
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
for each w-rab break by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr:
  accum w-rab.damt  (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.camt  (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.damtt (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
  accum w-rab.camtt (total by w-rab.rez by w-rab.crc by w-rab.gl1 by w-rab.pr).
    
if first-of(w-rab.rez) then do:
   if w-rab.rez = 1 then put stream m-out "Резиденты." at 5 skip(1).
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
if  not g-batch then do:
    pause 0.                            
    run menu-prt( 'rpt.img' ).
end.
{functions-end.i}
return.                         
