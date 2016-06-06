/* r-lnkof10.p
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
        13/01/04 - suchkov - Исправлены мелкие баги 
*/

{global.i}
def input parameter v-cif like bal_cif.cif.
def input parameter v-dat like bal_cif.rdt.

def var v-datold like bal_cif.rdt.
def var stitle as char format "x(25)".
def var sum1 like bal_cif.amount.
def var sum2 like bal_cif.amount.
def var v-srok as int init 0.

def var sum1sum2 like bal_cif.amount.

define var w-lona like bal_cif.amount extent 27.
define var w-lonp like bal_cif.amount extent 22. /* suchkov добавил 1 */
define var w-lond like bal_cif.amount extent 17.

define var w-lonaold like bal_cif.amount extent 27.
define var w-lonpold like bal_cif.amount extent 22. /* suchkov добавил 1 */

def var i as integer.

find cif where cif.cif = v-cif no-lock no-error.

define shared stream s1.

put stream s1 '' skip.
put stream s1 '              Коэффициенты ' trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" skip(1).
put stream s1 '                                                          тыс.тенге' skip.
put stream s1 '-------------------------------------------------------------------' skip.
put stream s1 '         Наименование показателя                  ' v-dat skip.   
put stream s1 '' skip.
put stream s1 '-------------------------------------------------------------------' skip.
put stream s1 '' skip.

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

put stream s1 "     Коэффициенты ликвидности" skip(1).

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

put stream s1 " Коэффициент текущей ликвидности                    " sum1 / sum2  format '->>9.99' skip.

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21] 
     + w-lona[22] + w-lona[23] + w-lona[24] 
     + w-lona[25] + w-lona[26].

put stream s1 " Коэффициент быстрой ликвидности                    " sum1 / sum2  format '->>9.99' skip.

sum1 = w-lona[23] + w-lona[24] 
     + w-lona[25] + w-lona[26].

put stream s1 " Коэффициент абсолютной ликвидности                 " sum1 / sum2  format '->>9.99' skip(1).

put stream s1 "     Коэффициенты платежеспособности" skip(1).
                                                          
sum1 = w-lonp[8] + w-lonp[9] + w-lonp[10]
     + w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
     + w-lonp[15] + w-lonp[16] + w-lonp[17]
     + w-lonp[18] + w-lonp[19] + w-lonp[20]
     + w-lonp[21].

sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
     + w-lonp[4] + w-lonp[5].


put stream s1 " Коэф-т соотношения заемных и собственных средств   " sum1 / sum2  format '->>9.99' skip.
                                                                                  
put stream s1 " Долг/ активы                                       " sum1 / (sum1 + sum2) format '->>9.99' skip(1).

put stream s1 "     Коэффициенты рентабельности" skip(1).

sum1 = w-lond[13].

sum2 = w-lona[3] + w-lona[6] + w-lona[7] 
     + w-lona[8] + w-lona[9] + w-lona[10]
     + w-lona[11] + w-lona[12] + w-lona[13] 
     + w-lona[14] + w-lona[15]
     + w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21] 
     + w-lona[22] + w-lona[23] + w-lona[24] 
     + w-lona[25] + w-lona[26] + w-lona[27].


put stream s1 " Доходность (рентабельность) активов (ROA)          " sum1 / sum2 * 100 format '->>9.99' '%' skip.

put stream s1 " Коэффициент валовой прибыли                        " w-lond[3] / w-lond[1] * 100 format '->>9.99' '%' skip.

put stream s1 " Доля выплат по % в объеме продаж                   " w-lond[7] / w-lond[1] * 100 format '->>9.99' '%' skip.

put stream s1 " Коэфициент чистой  прибыли                         " w-lond[13] / w-lond[1] * 100 format '->>9.99' '%' skip.

sum1 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
     + w-lonp[4] + w-lonp[5].

put stream s1 " Доходность собственного капитала (ROE)             "  w-lond[13] / sum1 * 100 format '->>9.99' '%' skip(1).


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

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonpold[i] = bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.
    end.

v-srok = (round((v-dat - v-datold) * 12 / 365 , 0)) * 30.

put stream s1 "     Коэффициенты оборачиваемости" skip(1).


put stream s1 " Коэффициент оборач-ти счетов к получению           " w-lond[1] / ((w-lona[16] + w-lonaold[16]) / 2)  format '->>9.99' skip.
put stream s1 " Период оборач-ти счетов к получению                " v-srok / (w-lond[1] / ((w-lona[16] + w-lonaold[16]) / 2))  format '->>9.99' skip.

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21]
     + w-lona[22]    + w-lonaold[16] + w-lonaold[17] 
     + w-lonaold[18] + w-lonaold[19] + w-lonaold[20] 
     + w-lonaold[21] + w-lonaold[22]. 

put stream s1 " Коэффициент оборач-ти дебит. задолж-ти             " w-lond[1] / (sum1 / 2)  format '->>9.99' skip.
put stream s1 " Период оборачиваемости дебиторской задолженности   " v-srok / (w-lond[1] / (sum1 / 2))  format '->>9.99' skip.

sum1 = w-lonp[8] + w-lonp[9] + w-lonp[10]
     + w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
     + w-lonp[15] + w-lonp[16] + w-lonp[17]
     + w-lonp[18] + w-lonp[19] + w-lonp[20]
     + w-lonp[21].

sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
     + w-lonp[4] + w-lonp[5].

put stream s1 " Коэффициент кредитоспособности                     " sum2 / sum1 format '->>9.99' skip.
put stream s1 " Коэф. оборач-ти расчетов с поставщ. и подрядч.     " w-lond[2] / ((w-lonp[17] + w-lonpold[17]) / 2) format '->>9.99' skip.
put stream s1 " Период расчетов с поставщиками и подрядчиками      " v-srok / (w-lond[2] / ((w-lonp[17] + w-lonpold[17]) / 2)) format '->>9.99' skip.

sum1 = w-lonp[11] + w-lonp[12] + w-lonp[13] 
     + w-lonp[14] + w-lonp[15] + w-lonp[16]
     + w-lonp[17] + w-lonp[18] + w-lonp[19]
     + w-lonp[20] + w-lonp[21]
     + w-lonpold[11] + w-lonpold[12] + w-lonpold[13] 
     + w-lonpold[14] + w-lonpold[15] + w-lonpold[16] 
     + w-lonpold[17] + w-lonpold[18] + w-lonpold[19]
     + w-lonpold[20] + w-lonpold[21]. 

put stream s1 " Коэффициент оборач-ти кредиторской задолженности   " w-lond[2] / (sum1 / 2) format '->>9.99' skip.
put stream s1 " Период оборач-ти кредиторской задолженности        " v-srok / (w-lond[2] / (sum1 / 2)) format '->>9.99' skip.

sum1 = w-lona[11] + w-lona[12] + w-lona[13] + w-lona[14] + w-lona[15]
     + w-lonaold[11] + w-lonaold[12] + w-lonaold[13] + w-lonaold[14] + w-lonaold[15].
 
put stream s1 " Коэффициет оборачиваемости т.м.з.                  " w-lond[2] / (sum1 / 2) format '->>9.99' skip.
put stream s1 " Период оборачиваемости т.м.з.                      " v-srok / (w-lond[1] / (sum1 / 2)) format '->>9.99' skip.
put stream s1 " Разница между периодом оборачив. дебиторской и     " skip.
put stream s1 "    кредитоской задолженностями                     " skip(1).

sum1 = w-lona[11] + w-lona[12] + w-lona[13] 
     + w-lona[14] + w-lona[15]
     + w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21] 
     + w-lona[22] + w-lona[23] + w-lona[24] 
     + w-lona[25] + w-lona[26] + w-lona[27].

sum2 = w-lonp[11] + w-lonp[12] + w-lonp[13] 
     + w-lonp[14] + w-lonp[15] + w-lonp[16]
     + w-lonp[17] + w-lonp[18] + w-lonp[19]
     + w-lonp[20] + w-lonp[21].

put stream s1 "Cобственный оборотный капитал               " sum1 - sum2 format '->>>,>>>,>>9.99' skip.

sum1 = w-lona[3] + w-lona[6] + w-lona[7] 
     + w-lona[8] + w-lona[9] + w-lona[10].

sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
     + w-lonp[4] + w-lonp[5].

put stream s1 "Покрытие основных средств за счет собств. капитала  " sum2 / sum1  format '->>9.99' skip.
put stream s1 "Использование нового оборудования                   " w-lona[4] / w-lona[5] format '->>9.99' skip(10).

