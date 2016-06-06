/* r-lnrsk20.p
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

/**/

{global.i}
def input parameter v-cif like bal_cif.cif.
def input parameter v-dat like bal_cif.rdt.


def var v-datold like bal_cif.rdt.
def var stitle as char format "x(25)".
def var sum1 like bal_cif.amount.
def var sum2 like bal_cif.amount.
def var sum3 like bal_cif.amount.
def var sum4 like bal_cif.amount.
def var sum5 like bal_cif.amount.
def var sum6 like bal_cif.amount.
def var sum1sum2 like bal_cif.amount.
def var sumold1 like bal_cif.amount.
def var sumold2 like bal_cif.amount.
def var sumold3 like bal_cif.amount.
def var sumold4 like bal_cif.amount.
def var sumold5 like bal_cif.amount.
def var sumold6 like bal_cif.amount.
def var sum1sum2old like bal_cif.amount.

define var w-lon like bal_cif.amount extent 27.
define var w-lonold like bal_cif.amount extent 27.
def var i as integer.

find last bal_cif where bal_cif.cif = v-cif and bal_cif.rdt < v-dat 
          and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.
    if avail bal_cif then do:
      v-datold = bal_cif.rdt.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'a' use-index nom:
          w-lonold[i] = bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonold):
         w-lonold[i] = 0.
      end.
    end.

find cif where cif.cif = v-cif no-lock no-error.

def shared stream s1.


put stream s1 '             Агрегированный баланс ' trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" skip(1).
put stream s1 '                                                          тыс.тенге' skip.
put stream s1 '--------------------------------------------------------------------------------' skip.
put stream s1 '               Актив                          ' v-datold '             ' v-dat skip.   
put stream s1 '' skip.
put stream s1 '--------------------------------------------------------------------------------' skip.
put stream s1 '' skip.


      do i = 1 to extent(w-lon):
         w-lon[i] = 0.
      end.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'a' use-index nom:
          w-lon[i] = bal_cif.amount.
          i = i + 1.
      end.

sum1 = w-lon[3] + w-lon[6] + w-lon[7] 
     + w-lon[8] + w-lon[9] + w-lon[10].
sum2 = w-lon[11] + w-lon[12] + w-lon[13] 
     + w-lon[14] + w-lon[15].
sum3 = w-lon[16] + w-lon[17] + w-lon[18] 
     + w-lon[19] + w-lon[20] + w-lon[21] + w-lon[22].
sum4 = w-lon[23] + w-lon[24] + w-lon[25] 
     + w-lon[26].
sum5 = w-lon[27].
sum1sum2 = sum1 + sum2 + sum3 + sum4 + sum5.

sumold1 = w-lonold[3] + w-lonold[6] + w-lonold[7] 
     + w-lonold[8] + w-lonold[9] + w-lonold[10].
sumold2 = w-lonold[11] + w-lonold[12] + w-lonold[13] 
     + w-lonold[14] + w-lonold[15].
sumold3 = w-lonold[16] + w-lonold[17] + w-lonold[18] 
     + w-lonold[19] + w-lonold[20] + w-lonold[21] + w-lonold[22].
sumold4 = w-lonold[23] + w-lonold[24] + w-lonold[25] 
     + w-lonold[26].
sumold5 = w-lonold[27].
sum1sum2old = sumold1 + sumold2 + sumold3 + sumold4 + sumold5.



put stream s1    "  ДОЛГОСРОЧНЫЕ АКТИВЫ          " sumold1 ' ' sumold1 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum1 ' ' sum1 / sum1sum2 * 100 format '>>9' '%' skip(1).
put stream s1    "  ТЕКУЩИЕ АКТИВЫ, в том числе  " (sumold5 + sumold2 + sumold3 + sumold4) format '->>>,>>>,>>>,>>9.99' ' '
                                                   (sumold5 + sumold2 + sumold3 + sumold4) / sum1sum2old * 100 format '>>9' '%' 
                                                   (sum5 + sum2 + sum3 + sum4) format '->>>,>>>,>>>,>>9.99' ' '
                                                   (sum5 + sum2 + sum3 + sum4) / sum1sum2 * 100 format '>>9' '%' skip.
put stream s1    "     Товарно-матер. запасы     " sumold2 ' ' sumold2 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum2 ' ' sum2 / sum1sum2 * 100 format '>>9' '%' skip.
put stream s1    "     Дебиторская задолженность " sumold3 ' ' sumold3 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum3 ' ' sum3 / sum1sum2 * 100 format '>>9' '%' skip.      
put stream s1    "     Денежные средства         " sumold4 ' ' sumold4 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum4 ' ' sum4 / sum1sum2 * 100 format '>>9' '%' skip.    
put stream s1    "     Прочие текущие активы     " sumold5 ' ' sumold5 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum5 ' ' sum5 / sum1sum2 * 100 format '>>9' '%' skip(1).  
put stream s1    "  ВСЕГО                        " sum1sum2old ' 100%' ' ' sum1sum2 ' 100%' skip(5).



put stream s1 '-------------------------------------------------------------------------------' skip.
put stream s1 '               Пассив                          ' v-datold '            ' v-dat skip.   
put stream s1 '' skip.
put stream s1 '-------------------------------------------------------------------------------' skip.
put stream s1 '' skip.

      do i = 1 to extent(w-lon):
         w-lon[i] = 0.
      end.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'p' use-index nom:
          w-lon[i] = bal_cif.amount.
          i = i + 1.
      end.

find last bal_cif where bal_cif.cif = v-cif and bal_cif.rdt < v-dat 
          and bal_cif.nom begins 'p' use-index cif-rdt no-lock no-error.
    if avail bal_cif then do:
      v-datold = bal_cif.rdt.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonold[i] = bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonold):
         w-lonold[i] = 0.
      end.
    end.

sum1 = w-lon[1] + w-lon[2] + w-lon[3] 
     + w-lon[4] + w-lon[5].
sum2 = w-lon[8] + w-lon[9] + w-lon[10]. 
sum3 = w-lon[11]. 
sum4 = w-lon[12] + w-lon[13] + w-lon[14]
     + w-lon[15] + w-lon[16] + w-lon[17]
     + w-lon[18] + w-lon[19] + w-lon[20]
     + w-lon[21].
sum1sum2 = sum1 + sum2 + sum3 + sum4.

sumold1 = w-lonold[1] + w-lonold[2] + w-lonold[3] 
     + w-lonold[4] + w-lonold[5].
sumold2 = w-lonold[8] + w-lonold[9] + w-lonold[10]. 
sumold3 = w-lonold[11]. 
sumold4 = w-lonold[12] + w-lonold[13] + w-lonold[14]
     + w-lonold[15] + w-lonold[16] + w-lonold[17]
     + w-lonold[18] + w-lonold[19] + w-lonold[20]
     + w-lonold[21].
sum1sum2old = sumold1 + sumold2 + sumold3 + sumold4.


put stream s1    "  I.СОБСТВЕННЫЙ КАПИТАЛ        " sumold1 ' ' sumold1 / sum1sum2old * 100 format '->>9' '%' 
                                                   sum1 ' ' sum1 / sum1sum2 * 100 format '->>9' '%' skip(1).
put stream s1    "  II.ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА" sumold2 ' ' sumold2 / sum1sum2old * 100 format '->>9' '%' 
                                                   sum2 ' ' sum2 / sum1sum2 * 100 format '>>9' '%' skip(1).
put stream s1    "  III.ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА    " sumold3 + sumold4 format '->>>,>>>,>>>,>>9.99' ' ' 
                                                   (sumold3 + sumold4) / sum1sum2old * 100 format '>>9' '%' 
                                                   sum3 + sum4 format '->>>,>>>,>>>,>>9.99' ' ' 
                                                   (sum3 + sum4) / sum1sum2 * 100 format '>>9' '%' skip.
put stream s1    "    Краткосрочные кредиты      " sumold3 ' ' sumold3 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum3 ' ' sum3 / sum1sum2 * 100 format '>>9' '%' skip.
put stream s1    "    Кредиторская задолженность " sumold4 ' ' sumold4 / sum1sum2old * 100 format '>>9' '%' 
                                                   sum4 ' ' sum4 / sum1sum2 * 100 format '>>9' '%' skip(1).
put stream s1    "  ВСЕГО                        " sum1sum2old  ' 100%' ' ' sum1sum2  ' 100%' skip(10).
                                                 
