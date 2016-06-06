/* s-lnrska.f
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
    "  I.ДОЛГОСРОЧНЫЕ АКТИВЫ" skip
    "  Нематериальные активы: " skip
    "    первоначальная ст-ть           " w-lonrsk[1]     skip
    "    амортизация                    " w-lonrsk[2]     skip 
    "    остаточная ст-ть               " w-lonrsk[3]     skip        
    "  Основные средства:"                       skip
    "    первоначальная ст-ть           " w-lonrsk[4]     skip        
    "    амортизация                    " w-lonrsk[5]     skip
    "    остаточная ст-ть               " w-lonrsk[6]     skip
    "  Инвестиции                       " w-lonrsk[7]     skip
    "  Долгоср. деб. задолж-ть          " w-lonrsk[8]     skip 
    "  Незавершенное строит-во          " w-lonrsk[9]     skip
    "  Расх. будущих периодов           " w-lonrsk[10]     skip
    "  ИТОГО                            " sum1 skip
    "  II.ТЕКУЩИЕ АКТИВЫ " skip
    "  Товарно-матер. запасы            " skip
    "  Материалы                        " w-lonrsk[11]     skip
    "  Незавершенное произ-во           " w-lonrsk[12]     skip
    "  Готовая продукция                " w-lonrsk[13]     skip
    "  Товары                           " w-lonrsk[14]     skip
    "  Товары в пути (Прочие)           " w-lonrsk[15]     skip
    "  Дебиторская задолженность   " skip
    "  Задолженность покупателей        " w-lonrsk[16]     skip
    "  Счета к получению                " w-lonrsk[17]     skip
    "  НДС                              " w-lonrsk[18]     skip
    "  Расх. будущих периодов           " w-lonrsk[19]     skip
    "  Авансы выданные                  " w-lonrsk[20]     skip
    "  Прочая деб. задолженность        " w-lonrsk[21]     skip
    "  Финансовые инвестиции            " w-lonrsk[22]     skip
    "  Денежные средства                " skip    
    "  - касса                          " w-lonrsk[23]     skip
    "  - денежные средства на р/сч      " w-lonrsk[24]     skip
    "  - денежные средства на вал.счете " w-lonrsk[25]     skip
    "  - денежные переводы в пути       " w-lonrsk[26]     skip
    "  Прочие текущие активы            " w-lonrsk[27]     skip
    "ИТОГО                              " sum2 skip(1)
    "ВСЕГО                              " sum1sum2 skip(2)
    "Занести баланс в базу (Yes/No) ?   " vans
with centered 
     overlay  row 5 no-label frame lonrsk.


form               
    "  I.ТЕКУЩИЕ АКТИВЫ " skip

    "  Денежные средства                " w-lonrsk[1]     skip
    "  Дебиторская задолженность        " w-lonrsk[2]     skip
    "  ТМЗ                              " w-lonrsk[3]     skip 
    "  Товары в пути                    " w-lonrsk[4]     skip        
    "  Прочее                           " w-lonrsk[5]     skip        

    "  II.ДОЛГОСРОЧНЫЕ АКТИВЫ " skip
    "  Основные средства                " w-lonrsk[6]     skip 
    "  Инвестиции                       " w-lonrsk[7]     skip
    "  Долгосроч. дебит. задолж-ть      " w-lonrsk[8]     skip
    "  Прочие                           " w-lonrsk[9]     skip

    "ВСЕГО                              " sum1sum2 skip(2)
    "Занести баланс в базу (Yes/No) ?   " vans
with centered 
     overlay  row 5 no-label frame lonrsk_b.

