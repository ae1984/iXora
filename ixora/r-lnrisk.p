/* r-lnrisk.p
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
        20/07/2004 madiar - увеличил extent массивов w-lonp и w-lonpold с 21 до 27
*/

/* Расчет рисков кредитного портфеля 
   14.10.02 */


{global.i}
def var v-dat like bal_cif.rdt.
def var v-data like bal_cif.rdt.
def var v-datold like bal_cif.rdt.
def var stitle as char format "x(25)".
def var sum1 like bal_cif.amount.
def var sum2 like bal_cif.amount.
def var sumtot like bal_cif.amount init 0. 
def var v-srok as int init 0.
def var v-cif like cif.cif init ''.
def var sum1sum2 like bal_cif.amount.
def var k4 as deci.
def var k5 as deci.
def var bilance as decimal format '->,>>>,>>9.99'.
def var vint as decimal format '->,>>>,>>9.99'.
def var vint1 like jl.dam.

v-dat = g-today.
v-data = g-today.

def var vk1 as deci.
def var vk2 as deci.
def var vk3 as deci.
def var vk4 as deci.
def var vk5 as deci.
define buffer lon2 for lon.

define var w-lona like bal_cif.amount extent 27.
define var w-lonp like bal_cif.amount extent 27.
define var w-lond like bal_cif.amount extent 17.

define var w-lonaold like bal_cif.amount extent 27.
define var w-lonpold like bal_cif.amount extent 27.

def var i as integer.

display
   v-data with row 8 centered  side-labels frame opt title " Введите дату: " .
   update v-data label "Дата" with frame opt.

define stream s1.
output stream s1 to rpt.img.

put stream s1 skip(3).
put stream s1
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------' skip.
put stream s1 
'  Счет     Вал.        Сумма      Ставка      Начисл%      Задолженность   Степень   Корр-ка    Общая        Risk free          Risk free             Risk' skip.
put stream s1 
'                                                                           финанс.     от     надежность                          (тенге)            (тенге)' skip.
put stream s1                                 
'                                                                           надежн.  скоринга      ' skip.
put stream s1 
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------' skip(1).

for each lon break by lon.cif:

 if lon.cif ne v-cif then do:

    v-cif = lon.cif.

    find last bal_cif where bal_cif.cif = v-cif and bal_cif.nom begins 'a' 
            use-index rdt no-lock no-error.
      if not avail bal_cif then next.

    v-dat = bal_cif.rdt.
    v-datold = bal_cif.rdt.
      
    find first cif where cif.cif = v-cif no-lock no-error.
      
      do i = 1 to extent(w-lona):
         w-lona[i] = 0.
      end.
      do i = 1 to extent(w-lonp):
         w-lonp[i] = 0.
      end.
      do i = 1 to extent(w-lond):
         w-lond[i] = 0.
      end.
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.


      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'a' use-index nom:
          w-lona[i] = bal_cif.amount.
          i = i + 1.
      end.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonp[i] = bal_cif.amount.
          i = i + 1.
      end.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'd' use-index nom:
          w-lond[i] = bal_cif.amount.
          i = i + 1.
      end.


   /* Коэффициент текущей ликвидности */

   sum1 = w-lona[11] + w-lona[12] + w-lona[13] 
        + w-lona[14] + w-lona[15]
        + w-lona[16] + w-lona[17] + w-lona[18] 
        + w-lona[19] + w-lona[20] + w-lona[21] 
        + w-lona[22] + w-lona[23] + w-lona[24] 
        + w-lona[25] + w-lona[26] + w-lona[27].

   sum2 = w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
     + w-lonp[15] + w-lonp[16] + w-lonp[17]
     + w-lonp[18] + w-lonp[19] + w-lonp[20]
     + w-lonp[21].

find first bal_spr where bal_spr.nom = 'K1'.
if not avail bal_spr then do:
  message 'Нет коэффициента К1'.
  pause 5.
  return.
end.

 if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk1 = 1 * dec(bal_spr.rem[2]).
    else if (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk1 = 0.
         else vk1 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).


/* Коэффициент быстрой ликвидности */

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21] 
     + w-lona[22] + w-lona[23] + w-lona[24] 
     + w-lona[25] + w-lona[26].

find first bal_spr where bal_spr.nom = 'K2'.
if not avail bal_spr then do:
  message 'Нет коэффициента К2'.
  pause 5.
  return.
end.

 if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk2 = 1 * dec(bal_spr.rem[2]).
    else if  (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk2 = 0.
         else vk2 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).


/* Коэффициент кредитоспособности  */

sum1 = w-lonp[8] + w-lonp[9] + w-lonp[10]
     + w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
     + w-lonp[15] + w-lonp[16] + w-lonp[17]
     + w-lonp[18] + w-lonp[19] + w-lonp[20]
     + w-lonp[21].

sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
     + w-lonp[4] + w-lonp[5].

find first bal_spr where bal_spr.nom = 'K3'.
if not avail bal_spr then do:
  message 'Нет коэффициента К3'.
  pause 5.
  return.
end.


  if (sum2 / sum1) / dec(bal_spr.rem[1]) > 1 then vk3 = 1 * dec(bal_spr.rem[2]).
     else if  (sum2 / sum1) / dec(bal_spr.rem[1]) < 0 then vk3 = 0.
          else vk3 = (sum2 / sum1) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).



find last bal_cif where bal_cif.cif = v-cif and bal_cif.rdt < v-dat 
          and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.
    if avail bal_cif then do:
      v-datold = bal_cif.rdt.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'a' use-index nom:
          w-lonaold[i] = bal_cif.amount.
          i = i + 1.
      end.

/*      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonpold[i] = bal_cif.amount.
          i = i + 1.
      end.
*/
    end.
    else do:
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
/*      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.*/
    end.



/* Коэффициет оборачиваемости т.м.з.   */

sum1 = w-lona[11] + w-lona[12] + w-lona[13] + w-lona[14] + w-lona[15]
     + w-lonaold[11] + w-lonaold[12] + w-lonaold[13] + w-lonaold[14] + w-lonaold[15].
 

find first bal_spr where bal_spr.nom = 'K4'.
if not avail bal_spr then do:
  message 'Нет коэффициента К4'.
  pause 5.
  return.
end.

k4 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[2] / (sum1 / 2)) / k4 > 1 then vk4 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[2] / (sum1 / 2)) / k4 < 0 then vk4 = 0.
           else vk4 = (w-lond[2] / (sum1 / 2)) / k4 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk4 = 1 * dec(bal_spr.rem[2]).

/* Коэффициент оборач-ти дебит. задолж-ти   */

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21]
     + w-lona[22]    + w-lonaold[16] + w-lonaold[17] 
     + w-lonaold[18] + w-lonaold[19] + w-lonaold[20] 
     + w-lonaold[21] + w-lonaold[22]. 


find first bal_spr where bal_spr.nom = 'K5'.
if not avail bal_spr then do:
  message 'Нет коэффициента К5'.
  pause 5.
  return.
end.

k5 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[1] / (sum1 / 2)) / k5 > 1 then vk5 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[1] / (sum1 / 2)) / k5 < 0 then vk5 = 0.
           else vk5 = (w-lond[1] / (sum1 / 2)) / k5 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk5 = 1 * dec(bal_spr.rem[2]).

/*put stream s1 v-datold skip.
put stream s1 'k1     ' vk1 skip.
put stream s1 'k2     ' vk2 skip.
put stream s1 'k3     ' vk3 skip.
put stream s1 'k4     ' vk4 skip.
put stream s1 'k5     ' vk5 skip.
put stream s1 'K      ' vk1 + vk2 + vk3 + vk4 + vk5 skip.
*/
sum1 = 0.
  for each bal_cif where bal_cif.cif = v-cif and bal_cif.nom begins 's'. 
    sum1 = sum1 + bal_cif.amount.
  end.

sum1sum2 = vk1 + vk2 + vk3 + vk4 + vk5 + sum1.
if sum1sum2 > 100 then sum1sum2 = 100.

/*
put stream s1 'Scores ' sum1 format '->>,>>9.99' skip.
put stream s1 'Total  ' vk1 + vk2 + vk3 + vk4 + vk5 + sum1 skip.
put stream s1 '------------------------' skip(1).*/

/******************************/
    put stream s1 skip v-dat '   ' v-datold '  ' lon.cif '  ' cif.name skip.

    for each lon2 where lon2.cif = v-cif break by lon2.crc:

        run atl-dat(lon2.lon,v-data,output bilance). /* остаток  ОД*/                        
        run atl-prcl(lon2.lon,v-data - 1, output vint, output vint1, output vint1).  /* остаток % */
        if bilance <> 0 or vint <> 0 then do:
        find last crchis where crchis.crc = lon2.crc and crchis.regdt le v-data no-lock no-error.

        put stream s1 lon2.lon ' ' 
                      crchis.code ' '
                      bilance format '->,>>>,>>>,>>9.99'
                      lon2.prem format 'zzzz9.99'
                      vint  format '->>>,>>>,>>9.99'
                      bilance + vint  format '->,>>>,>>>,>>9.99'
                      vk1 + vk2 + vk3 + vk4 + vk5         
                      sum1 format '->>,>>9.99'
                      sum1sum2 format '->>,>>9.99'
                      (bilance + vint) / 100 * (sum1sum2) format '->,>>>,>>>,>>9.99'
                      ((bilance + vint) / 100 * (sum1sum2)) * crchis.rate[1] format '->,>>>,>>>,>>>,>>9.99'
                      ((bilance + vint) - ((bilance + vint) / 100 * (sum1sum2))) * crchis.rate[1] format '->,>>>,>>>,>>>,>>9.99'
                      skip.
        sumtot = sumtot + ((bilance + vint) / 100 * (sum1sum2)) * crchis.rate[1].
        end.
        
    end.
put stream s1 skip(3).
/*****************************/
end.
end.
put stream s1 '________________________________________________________________________________________________________________________________________________' skip.
put stream s1 '------------------------------------------------------------------------------------------------------------------------------------------------' skip(1).

put stream s1 'Итого  ' space(112) sumtot format '->,>>>,>>>,>>>,>>9.99' skip(3).

output stream s1 close.
run menu-prt('rpt.img').

