/* r-lnrsk10.p
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

/*******/

{global.i}
def input parameter v-cif like bal_cif.cif.
def input parameter v-dat like bal_cif.rdt.


def var v-datold like bal_cif.rdt.
def var sum1 like bal_cif.amount.
def var sum2 like bal_cif.amount.
def var sum3 like bal_cif.amount.
def var sum1sum2 like bal_cif.amount.

def var sumold1 like bal_cif.amount.
def var sumold2 like bal_cif.amount.
def var sumold3 like bal_cif.amount.
def var sum1sum2old like bal_cif.amount.

v-datold = 01/01/01.

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

put stream s1 '             Балансовый отчет ' cif.name skip(1).
put stream s1 '                                                          тыс.тенге' skip.
put stream s1 '---------------------------------------------------------------------------' skip.
put stream s1 '               Актив                          ' v-datold '         ' v-dat skip.   
put stream s1 '' skip.
put stream s1 '---------------------------------------------------------------------------' skip.
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


put stream s1    "  I.ДОЛГОСРОЧНЫЕ АКТИВЫ" skip.
put stream s1    "  Нематериальные активы: " skip.
put stream s1    "    первоначальная ст-ть           " w-lonold[1]  w-lon[1]     skip.
put stream s1    "    амортизация                    " w-lonold[2]  w-lon[2]     skip. 
put stream s1    "    остаточная ст-ть               " w-lonold[3]  w-lon[3]     skip.        
put stream s1    "  Основные средства:"                       skip.
put stream s1    "    первоначальная ст-ть           " w-lonold[4]  w-lon[4]     skip.        
put stream s1    "    амортизация                    " w-lonold[5]  w-lon[5]     skip.
put stream s1    "    остаточная ст-ть               " w-lonold[6]  w-lon[6]     skip.
put stream s1    "  Инвестиции                       " w-lonold[7]  w-lon[7]     skip.
put stream s1    "  Долгоср. деб. задолж-ть          " w-lonold[8]  w-lon[8]     skip. 
put stream s1    "  Незавершенное строит-во          " w-lonold[9]  w-lon[9]     skip.
put stream s1    "  Расх. будущих периодов           " w-lonold[10]  w-lon[10]     skip.
sumold1 = w-lonold[3] + w-lonold[6] + w-lonold[7] 
     + w-lonold[8] + w-lonold[9] + w-lonold[10].
sum1 = w-lon[3] + w-lon[6] + w-lon[7] 
     + w-lon[8] + w-lon[9] + w-lon[10].
put stream s1    "  ИТОГО                            " sumold1 sum1 skip(1).

put stream s1    "  II.ТЕКУЩИЕ АКТИВЫ " skip.
put stream s1    "  Товарно-матер. запасы            " skip.
put stream s1    "  Материалы                        " w-lonold[11]  w-lon[11]     skip.
put stream s1    "  Незавершенное произ-во           " w-lonold[12]  w-lon[12]     skip.
put stream s1    "  Готовая продукция                " w-lonold[13]  w-lon[13]     skip.
put stream s1    "  Товары                           " w-lonold[14]  w-lon[14]     skip.
put stream s1    "  Прочие                           " w-lonold[15]  w-lon[15]     skip.
put stream s1    "  Дебиторская задолженность   " skip.      
put stream s1    "  Задолженность покупателей        " w-lonold[16]  w-lon[16]     skip.
put stream s1    "  Счета к получению                " w-lonold[17]  w-lon[17]     skip.
put stream s1    "  НДС                              " w-lonold[18]  w-lon[18]     skip.
put stream s1    "  Расх. будущих периодов           " w-lonold[19]  w-lon[19]     skip.
put stream s1    "  Авансы выданные                  " w-lonold[20]  w-lon[20]     skip.
put stream s1    "  Прочая деб. задолженность        " w-lonold[21]  w-lon[21]     skip.
put stream s1    "  Финансовые инвестиции            " w-lonold[22]  w-lon[22]     skip.
put stream s1    "  Денежные средства                " skip.   
put stream s1    "  - касса                          " w-lonold[23]  w-lon[23]     skip.
put stream s1    "  - денежные средства на р/сч      " w-lonold[24]  w-lon[24]     skip.
put stream s1    "  - денежные средства на вал.счете " w-lonold[25]  w-lon[25]     skip.
put stream s1    "  - денежные переводы в пути       " w-lonold[26]  w-lon[26]     skip.
put stream s1    "  Прочие текущие активы            " w-lonold[27]  w-lon[27]     skip.
   sumold2 = w-lonold[11] + w-lonold[12] + w-lonold[13] 
        + w-lonold[14] + w-lonold[15] + w-lonold[16]
        + w-lonold[17] + w-lonold[18] + w-lonold[19]
        + w-lonold[20] + w-lonold[21] + w-lonold[22]
        + w-lonold[23] + w-lonold[24] + w-lonold[25]
        + w-lonold[26] + w-lonold[27].
   sum1sum2old = sumold1 + sumold2.
   sum2 = w-lon[11] + w-lon[12] + w-lon[13] 
        + w-lon[14] + w-lon[15] + w-lon[16]
        + w-lon[17] + w-lon[18] + w-lon[19]
        + w-lon[20] + w-lon[21] + w-lon[22]
        + w-lon[23] + w-lon[24] + w-lon[25]
        + w-lon[26] + w-lon[27].
   sum1sum2 = sum1 + sum2.
put stream s1    "ИТОГО                              " sumold2 sum2 skip(1).
put stream s1    "ВСЕГО                              " sum1sum2old sum1sum2 skip(8).



put stream s1 '-----------------------------------------------------------------------------' skip.
put stream s1 '               Пассив                          ' v-datold '         ' v-dat  skip.   
put stream s1 '' skip.                            
put stream s1 '-----------------------------------------------------------------------------' skip.
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

put stream s1    "  I.СОБСТВЕННЫЙ КАПИТАЛ" skip.
put stream s1    "    Уставный капитал                  " w-lonold[1] w-lon[1]     skip.
put stream s1    "    Дополнит.оплаченный капитал       " w-lonold[2] w-lon[2]     skip. 
put stream s1    "    Дополнит.неоплаченный капитал     " w-lonold[3] w-lon[3]     skip.        
put stream s1    "    Резервный капитал                 " w-lonold[4] w-lon[4]     skip.        
put stream s1    "    Нераспределенный доход            " w-lonold[5] w-lon[5]     skip.
put stream s1    "      - отчетного года                " w-lonold[6] w-lon[6]     skip.
put stream s1    "      - предыдущих лет                " w-lonold[7] w-lon[7]     skip.
sumold1 = w-lonold[1] + w-lonold[2] + w-lonold[3]                                       
     + w-lonold[4] + w-lonold[5].                                                 
sum1 = w-lon[1] + w-lon[2] + w-lon[3]                                       
     + w-lon[4] + w-lon[5].                                                 
put stream s1    "  ИТОГО                               " sumold1 sum1 skip(1).
put stream s1    "  II.ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА       " skip.      
put stream s1    "    Долгосрочные кредиты              " w-lonold[8] w-lon[8]     skip. 
put stream s1    "    Долгосроч. кредиторская  задол-ть " w-lonold[9] w-lon[9]     skip.
put stream s1    "    Отсроченные налоги                " w-lonold[10] w-lon[10]     skip.
sumold2 = w-lonold[8] + w-lonold[9] + w-lonold[10].                                     
sum2 = w-lon[8] + w-lon[9] + w-lon[10].                                     
put stream s1    "  ИТОГО                               " sumold2 sum2 skip(1).
put stream s1    "  III.ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА " skip.                       
put stream s1    "    Краткосрочные кредиты             " w-lonold[11] w-lon[11]skip.
put stream s1    "    Расчеты с бюджетом                " w-lonold[12] w-lon[12]     skip.
put stream s1    "    Прочие налоги                     " w-lonold[13] w-lon[13]     skip.
put stream s1    "    НДС                               " w-lonold[14] w-lon[14]     skip.
put stream s1    "    Кредитор. задол-ть дочерним       " skip.       
put stream s1    "       зависимым товариществам        " w-lonold[15] w-lon[15]     skip.
put stream s1    "    Авансы полученные                 " w-lonold[16] w-lon[16]     skip.
put stream s1    "    Расчеты с поставщиками и подрядчик" w-lonold[17] w-lon[17]     skip.
put stream s1    "    Расчеты с персоналом по опл. труда" w-lonold[18] w-lon[18]     skip.
put stream s1    "    Арендные обязательства            " w-lonold[19] w-lon[19]     skip.
put stream s1    "    Расчеты по внебюджетным платежам  " w-lonold[20] w-lon[20]     skip.
put stream s1    "    Прочая кредиторская задолж-ть     " w-lonold[21] w-lon[21]     skip.
sumold3 = w-lonold[11] + w-lonold[12] + w-lonold[13] 
     + w-lonold[14] + w-lonold[15] + w-lonold[16]
     + w-lonold[17] + w-lonold[18] + w-lonold[19]
     + w-lonold[20] + w-lonold[21].
sum1sum2old = sumold1 + sumold2 + sumold3.
sum3 = w-lon[11] + w-lon[12] + w-lon[13] 
     + w-lon[14] + w-lon[15] + w-lon[16]
     + w-lon[17] + w-lon[18] + w-lon[19]
     + w-lon[20] + w-lon[21].
sum1sum2 = sum1 + sum2 + sum3.
put stream s1    "  ИТОГО                               " sumold3 sum3 skip(1).
put stream s1    "ВСЕГО                                 " sum1sum2old sum1sum2 skip(10).


