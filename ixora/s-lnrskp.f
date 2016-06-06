/* s-lnrskp.f
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
      30.09.2005 marinav - изменения для бизнес-кредитов
*/

/*----------------------------------------------------------------------------

----------------------------------------------------------------------------*/
form
    stitle at 10 skip
    "Клиент" v-cif 
    help "Код клиента; F2-код; F4-выход; F1-далее"
    "Дата" at 30 v-dat skip  
    cif.sname  skip
    with centered row 0 no-label frame f-cif.

form
    stitle at 5 skip (1)
    "Дата" at 10 v-dat skip  
    with centered row 0 no-label frame f-cif1.

form               
    "  I.СОБСТВЕННЫЙ КАПИТАЛ" skip
    "    Уставный капитал                  " w-lonrsk[1]     skip
    "    Дополнит.оплаченный капитал       " w-lonrsk[2]     skip 
    "    Дополнит.неоплаченный капитал     " w-lonrsk[3]     skip        
    "    Резервный капитал                 " w-lonrsk[4]     skip        
    "    Нераспределенный доход            " w-lonrsk[5]     skip
    "      - отчетного года                " w-lonrsk[6]     skip
    "      - предыдущих лет                " w-lonrsk[7]     skip
    "  ИТОГО                               " sum1 skip(1)
    "  II.ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА       " skip
    "    Долгосрочные кредиты              " w-lonrsk[8]     skip 
    "    Долгосроч. кредиторская  задол-ть " w-lonrsk[9]     skip
    "    Отсроченные налоги                " w-lonrsk[10]     skip
    "  ИТОГО                               " sum2 skip(1)
    "  III.ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА " skip
    "    Краткосрочные кредиты             " w-lonrsk[11]skip
    "    Расчеты с бюджетом                " w-lonrsk[12]     skip
    "    Прочие налоги                     " w-lonrsk[13]     skip
    "    НДС                               " w-lonrsk[14]     skip
    "    Кредитор. задол-ть дочерним       " skip
    "       зависимым товариществам        " w-lonrsk[15]     skip
    "    Авансы полученные                 " w-lonrsk[16]     skip
    "    Расчеты с поставщиками и подрядчик" w-lonrsk[17]     skip
    "    Товарный кредит                   " w-lonrsk[22]     skip
    "    Расчеты с персоналом по опл. труда" w-lonrsk[18]     skip
    "    Арендные обязательства            " w-lonrsk[19]     skip
    "    Расчеты по внебюджетным платежам  " w-lonrsk[20]     skip
    "    Прочая кредиторская задолж-ть     " w-lonrsk[21]     skip
    "  ИТОГО                               " sum3 skip(1)
    "ВСЕГО                                 " sum1sum2 skip(1)
    "Занести баланс в базу (Yes/No) ?      " vans
with centered 
     overlay  row 5 no-label frame lonrsk.


form               
    "  I.ТЕКУЩИЕ ОБЯЗАТЕЛЬСТВА " skip

    "  Кредиторская задолженность       " w-lonrsk[1]     skip
    "  Краткосрочные кредиты банка      " w-lonrsk[2]     skip

    "  II.ДОЛГОСРОЧНЫЕ ОБЯЗАТЕЛЬСТВА    " skip
    "  Кредиторская задолженность       " w-lonrsk[3]
    "  Долгосрочные кредиты банка       " w-lonrsk[4]     skip
    "  Собственный капитал              " w-lonrsk[5]     skip

    "ВСЕГО                              " sum1sum2 skip(2)
    "Занести баланс в базу (Yes/No) ?   " vans
with centered 
     overlay  row 5 no-label frame lonrsk_b.

