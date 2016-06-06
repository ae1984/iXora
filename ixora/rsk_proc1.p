/* rsk_proc.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Вычисление коэффициентов для матрицы рисков
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
        24/09/2004 madiar
 * CHANGES
*/

def input parameter s-lon like cif.cif.
def shared var g-today as date.

def shared var coeff as deci extent 6.

def var dt_over as date.
def var bb as deci.
def var bilance as deci.
def var prc as deci.

/* 2. Срок до погашения */

find first lon where lon.lon = s-lon no-lock no-error.
dt_over = lon.duedt.
if lon.ddt[5] <> ? /* and txb.lon.ddt[5] < dat */ then dt_over = lon.ddt[5].
if lon.cdt[5] <> ? /* and txb.lon.cdt[5] < dat */ then dt_over = lon.cdt[5].

if dt_over - g-today >= 0 and dt_over - g-today <= 30 then coeff[2] = 70.
if dt_over - g-today > 30 and dt_over - g-today <= 360 then coeff[2] = 60.
if dt_over - g-today > 360 and dt_over - g-today <= 1080 then coeff[2] = 50.
if dt_over - g-today > 1080 then coeff[2] = 30.

/* 4. Покрытие ОД и начисл. вознаграждения залоговым обеспечением */

def var sum_obesp as deci.
def var sum_obesp3 as deci.

run lonbal('lon', s-lon, g-today, '2,9,10,22,23', yes, output prc).
run lonbal('lon', s-lon, g-today, '1,7,8,20,21', yes, output bilance).

sum_obesp = 0. sum_obesp3 = 0.
for each lonsec1 where lonsec1.lon = lon.lon no-lock:
  find first crc where crc.crc = lonsec1.crc no-lock no-error.
  if lonsec1.lonsec = 3 then sum_obesp3 = sum_obesp3 + lonsec1.secamt * crc.rate[1].
  else sum_obesp = sum_obesp + lonsec1.secamt * crc.rate[1].
end.

find first crc where crc.crc = lon.crc no-lock no-error.
bb = sum_obesp / ((bilance + prc) * crc.rate[1] - sum_obesp3) * 100.

if bb >= 100 then coeff[4] = 100.
if bb >= 90 and bb < 100 then coeff[4] = 80.
if bb >= 75 and bb < 90 then coeff[4] = 40.
if bb >= 50 and bb < 75 then coeff[4] = 20.
if bb < 50 then coeff[4] = 0.

/* 5. Кредитная история */

def var prosr_od as deci.
def var prosr_prc as deci.
def var dayc1 as int.
def var dayc2 as int.
def var daymax as int.
def var tempdt as date.
def var tempost as deci.
def var tempgrp as int.
def var bb1 as deci.

/* просрочка ОД */
run lonbal('lon', s-lon, g-today, "7,21", yes, output prosr_od).
/* просрочка %% */
run lonbal('lon', s-lon, g-today, "9,23", yes, output prosr_prc).
/* дней просрочки */
dayc1 = 0. dayc2 = 0.
   
if prosr_prc > 0 then do:
   tempdt = g-today.
   tempost = 0.
   repeat:
     find last lnsci where lnsci.lni = lon.lon and lnsci.idat < tempdt and lnsci.f0 > 0 no-lock no-error.
     if avail lnsci then do:
       tempost = tempost + lnsci.iv-sc.
       if prosr_prc <= tempost then do:
           dayc2 = g-today - lnsci.idat.
           leave.
       end.
       tempdt = lnsci.idat.
     end.
     else leave.
   end.
end.

if prosr_od > 0 then do:
   tempdt = g-today.
   tempost = 0.
   repeat:
     find last lnsch where lnsch.lnn = lon.lon and lnsch.stdat < tempdt and lnsch.f0 > 0 no-lock no-error.
     if avail lnsch then do:
        tempost = tempost + lnsch.stval.
        if prosr_od <= tempost then do:
           dayc1 = g-today - lnsch.stdat.
           leave.
        end.   
        tempdt = lnsch.stdat.
     end.
     else leave.
  end.
end.

find last cls where cls.del and cls.whn < g-today no-lock no-error. /* последний рабочий день перед сегодня */
tempgrp = g-today - 1 - cls.whn.
/* надо учесть выходные - в понедельник для тех, у кого выпало погашение на субботу - dayc=2, на воскресенье - dayc=1 */
if tempgrp > 0 and (dayc1 <= tempgrp) and (dayc2 <= tempgrp) then assign dayc1 = 0 dayc2 = 0.

if dayc1 > dayc2 then daymax = dayc1. else daymax = dayc2.

if daymax <= 0 then bb = 100.
if daymax > 0 and daymax <= 30 then bb = 70.
if daymax > 30 and bb <= 60 then bb = 50.
if daymax > 60 and daymax <= 90 then bb = 25.
if daymax > 90 then bb = 0.

if lon.ddt[5] <> ? or lon.cdt[5] <> ? then bb1 = 0. else bb1 = 100.

coeff[5] = 0.4 * bb + 0.6 * bb1.

