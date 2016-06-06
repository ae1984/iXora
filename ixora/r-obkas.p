/* r-obkas.p
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
       02.02.2012 lyubov - добавила в выборку сим.касспл. условие "cashpl.act"
*/

/* r-obkas.p
   Распределение оборотов по символам касплана за период
   только счета группы 2200
   13.04.2000 */

define variable fdate as date.
define variable tdate as date.
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def buffer bjl for jl .
def var m-cashgl like jl.gl.
def temp-table w-rab
    field    aaa      like aaa.aaa
    field    cif      like cif.cif
    field    rez      as deci format "9" init 0
    field    damt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    camt     as decimal  format "zzz,zzz,zzz,zz9.99" init 0.0
    field    gl       as char format "x(6)"
    field    sim      like cashpl.sim
    field    des      like cashpl.des
    field    d        like jl.whn.

{mainhead.i}
{functions-def.i}
fdate = g-today.
tdate = g-today.

display
        fdate label " с "
        tdate label " по "
        with row 8 centered  side-labels frame opt title "Введите период    :" .

update fdate
       validate(fdate <= g-today,"Должно быть: Начало <= Сегодня")
       with frame opt.

update tdate validate(tdate >= fdate and tdate <= g-today,
       "Должно быть: Начало <= Конец <= Сегодня")
       with frame opt.

hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
   m-cashgl = inval.

find first jl where jl.jdt ge fdate and jl.jdt le tdate  no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt ge fdate and jl.jdt le tdate no-lock ,
    each jlsach where jlsach.jh = jl.jh and jlsach.ln = jl.ln no-lock ,
    each cashpl where cashpl.sim = jlsach.sim and cashpl.act no-lock:
      if jl.gl = m-cashgl then do :
         if jl.dc eq "D" then do:
            find first  bjl where bjl.jh = jl.jh and bjl.cam = jl.dam and
                 bjl.crc = jl.crc no-lock no-error .
            if avail bjl then do:
               if bjl.acc ne "" and  substr(string(bjl.gl,"999999"),1,2) = '22'
                  then do:
                     create w-rab.
                     w-rab.aaa = bjl.acc .
                     w-rab.gl = string(bjl.gl,"999999").
                     w-rab.damt = jlsach.amt.
                     w-rab.camt = 0.
                     w-rab.sim = jlsach.sim.
                     w-rab.des = cashpl.des.
                     m-sumd = m-sumd + w-rab.damt.
                     find aaa where aaa.aaa = bjl.acc no-lock no-error.
                     if avail aaa then do:
                        find cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif and  length(cif.geo) gt 0 then do:
                           w-rab.cif = cif.cif.
                           if substring(cif.geo,length(cif.geo),1) eq "1"
                            then w-rab.rez = 1.
                            else w-rab.rez = 2.
                        end.
                     end.
               end.
            end.
         end.
         else do:
              find first  bjl where bjl.jh = jl.jh and bjl.dam = jl.cam and
                 bjl.crc = jl.crc no-lock no-error .
              if avail bjl then do:
              if bjl.acc ne "" and substr(string(bjl.gl,"999999"),1,2) = '22'
                 then do:
                     create w-rab.
                     w-rab.aaa = bjl.acc .
                     w-rab.gl = string(bjl.gl,"999999").
                     w-rab.camt = jlsach.amt.
                     w-rab.damt = 0.
                     w-rab.sim = jlsach.sim.
                     w-rab.des = cashpl.des.
                     m-sumk = m-sumk + w-rab.camt.
                     find aaa where aaa.aaa = bjl.acc no-lock no-error.
                     if avail aaa then do:
                        find cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif and  length(cif.geo) gt 0 then do:
                           w-rab.cif = cif.cif.
                           if substring(cif.geo,length(cif.geo),1) eq "1"
                            then w-rab.rez = 1.
                            else w-rab.rez = 2.
                        end.
                     end.
                 end.
              end.
         end.
      end.
   end.
end.
end.
def stream m-out.
output stream m-out to rpt.img.
put stream m-out
FirstLine( 1, 1 ) format 'x(80)' skip(1)
'                 '
'РАСПРЕДЕЛЕНИЕ ОБОРОТОВ ПО СИМВОЛАМ КАСПЛАНА '  skip
'                      '
'за период с ' string(fdate)  ' по '  string(tdate) skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.
put stream m-out
' Счет ГК '
'   Символ кассового плана'
'                  Дебет     '
'       Кредит    '
 skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip(1).

find first w-rab no-lock no-error.
if not available w-rab then
   put stream m-out  'Движения по кассе за выбранный период времени не было'
   at 5 skip.
else do:
for each w-rab  break by w-rab.rez by w-rab.gl by w-rab.sim:
   accumulate w-rab.damt  (total by w-rab.rez by  w-rab.gl by w-rab.sim).
   accumulate w-rab.camt (total by w-rab.rez by  w-rab.gl by w-rab.sim).

if first-of(w-rab.rez) then do:
   if w-rab.rez = 1 then put stream m-out "Резиденты" at 2 skip(1).
   else put stream m-out "Нерезиденты" at 2 skip(1).
end.
if first-of(w-rab.gl) then put stream m-out w-rab.gl at 2 skip .
if last-of(w-rab.sim)
   then put stream m-out  '        ' w-rab.sim ' ' w-rab.des format 'x(30)'(ACCUM TOTAL BY w-rab.sim  w-rab.damt )  format "zzz,zzz,zzz,zz9.99"
(ACCUM TOTAL BY w-rab.sim  w-rab.camt )  format "zzz,zzz,zzz,zz9.99" skip.

if last-of(w-rab.gl)
   then put stream m-out  ' Итого: '
   fill (' ',34) format
   'x(34)'
   (ACCUM TOTAL BY w-rab.gl  w-rab.damt )  format "zzz,zzz,zzz,zz9.99"
   (ACCUM TOTAL BY w-rab.gl  w-rab.camt )  format "zzz,zzz,zzz,zz9.99" skip(1).
if last-of(w-rab.rez)
   then do:
      put stream m-out  ' Всего: '
      fill (' ',34) format 'x(34)'
      (ACCUM TOTAL BY w-rab.rez  w-rab.damt )  format "zzz,zzz,zzz,zz9.99"
      (ACCUM TOTAL BY w-rab.rez  w-rab.camt )  format "zzz,zzz,zzz,zz9.99"       skip.
      put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.
    end.
end.
put stream m-out  fill (' ',42) format 'x(42)'
    m-sumd format "zzz,zzz,zzz,zz9.99"
    m-sumk format "zzz,zzz,zzz,zz9.99" skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'.
end.
output stream m-out close.
if  not g-batch then do:
    pause 0.
    run menu-prt( 'rpt.img' ).
end.
{functions-end.i}
for each w-rab:
    delete w-rab.
end.
return.


