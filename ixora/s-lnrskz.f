/* s-lnrskr.f
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
      01/12/2005 madiar - бизнес-кредиты - очередные изменения в форме ввода
*/

/**/
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
    "   Доход от реализации продукции             " w-lonrsk[1]     skip
    "   Себестоимость реализованной продукции     " w-lonrsk[2]     skip
    "   Валовый доход                             " w-lonrsk[3]     skip
    "   Расходы периода - всего:                  " w-lonrsk[4]     skip
    "   в том числе - общие и администр. расходы  " w-lonrsk[5]     skip
    "               - расходы по реализации       " w-lonrsk[6]     skip
    "               - расходы по процентам        " w-lonrsk[7]     skip
    "   Доход от основной деятельности            " w-lonrsk[8]     skip
    "   Доход (убыток) от неосновной деятельности " w-lonrsk[9]     skip
    "   Доход до налогообложения                  " w-lonrsk[10]     skip
    "   Расходы по подоходному налогу             " w-lonrsk[11]     skip
    "   Доход после налогообложения               " w-lonrsk[12]     skip
    "   Убыток от чрезвычайных ситуаций           " w-lonrsk[13]     skip
    "   ЧИСТЫЙ ДОХОД (NI)                         " w-lonrsk[14]     skip(1)
    "Занести баланс в базу (Yes/No) ?      " vans
with centered
     overlay  row 5 no-label frame lonrsk.


form
    "   Выручка от реализации продукции           " w-lonrsk[1]     skip
    "   Себестоимость реализованной продукции     " w-lonrsk[2]     skip
    "   Маржа %%                                  "      skip
    "   Валовый доход                             "      skip
    "   Расходы всего                             " w-lonrsk[3]     skip
    "   Расходы по выплате корп. подох. налога    " w-lonrsk[4]     skip
    "   ЧИСТАЯ ПРИБЫЛЬ                            "      skip
    "   Взнос по кредиту                          " w-lonrsk[5]     skip
    "   ЧИСТЫЙ ОСТАТОК                            "      skip(1)
    "Занести баланс в базу (Yes/No) ?      " vans
with centered
     overlay  row 5 no-label frame lonrsk_b.
