/* s-lonsub.f
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
        24/07/2010 madiyar - фрейм updvans
        27/07/2010 madiyar - явно прописал ширину фрейма updvans
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        26/01/2011 madiyar - история остатка КЛ
        07/07/2011 madiyar - выписки по процентам
        22/07/2011 kapar  - ТЗ 1134
        25/06/2012 kapar - ТЗ ASTANA-BONUS
        11/10/2012 kapar - ТЗ ASTANA-BONUS(исправление)
*/

form        "Кредит....." lon.lon skip
            "Бал.счет..." lon.gl gl.sname "(" lon.grp format "zz9" ")" skip
            "Клиент....." lon.cif cif.name lon.loncat skip
            "Статус....." v-stat format "9" "            "
            "Накопл.стат" v-stat0 format "z" skip
            "Фин.рез...." finrez format "->>,>>>,>>9.99"
            "Дата......." f-dat format "99/99/9999" skip
            "Рег.дата..." lon.rdt format  "99/99/9999" space(5)
            "Срок......." lon.duedt format "99/99/9999" skip
            "Кредит.вал." v-code format "xxx           "
            "Вал.провиз." v-code1 format "xxx" skip
            "% ставка..." lon.base lon.prem format "zzzz.9999" v-bil
            format "x(26)" skip
            "% долг    :" vint2mon " на " mon2 skip
            "           " vint1mon " на " mon1 skip
            "           " vintcmon " на " monc skip
            "           " vinttday " на " g-today skip
            "% сумма на " vtarget vint
            with frame lon row 3 centered no-label no-box.

form f-dat1 format "99/99/9999"      label "Дата  "
     f-deb  format "->>>,>>>,>>9.99" label "Дебет "
     f-kred format "->>>,>>>,>>9.99" label "Кредит"
     f-jh   format "zzzzzzzz"        label "Транзакц."
     f-who                           label "Исполнит."
     with frame jl down centered row 2.

define variable v-db like jl.dam.
define variable v-cr like jl.cam.
define variable v-dt as character format "x(10)".
define variable v-jh like jh.jh.
define variable dn1  as integer.
define variable dn2  as decimal.

form v-dt label "Дата  "
     v-db label "Дебет  "
     v-cr label "Кредит "
     v-jh label "Транзакц."
     lonres.who label "Исполн."
     with frame res down centered row 2.
form v-dt label "Дата  "
     v-db format ">>>,>>>,>>9.99" label "Дебет "
     v-cr format ">>>,>>>,>>9.99" label "Кредит"
     crc.code format "xxx" label "Вал."
     v-jh label "Транзакц."
     lonres.who label "Исп."
     lonres.gl column-label "Счет ГК"
     with frame rs down centered row 2.
form /* i         format "zzz" label "NN" */
     w-amk.fdt format "99/99/99" label "С...."
     w-amk.tdt format "99/99/9999" label "По....."
     w-prn     format "x(13)" label "Сумма"
     w-rate    format "x(7)"  label "% ставка"
     w-amt1    format "x(10)" label "Нач. %"
     w-amk.dt  format "99/99/9999" label "Дата"
     w-amt2    format "x(10)" label "Опл. %"
     with frame w-amk down centered row 2.
form v-dt label "Дата"
     v-db format ">>>,>>>,>>9.99" label "Дебет "
     v-cr format ">>>,>>>,>>9.99" label "Кредит"
     v-jh label "Транзакц."
     fagra.who label "Исполн."
     with frame fagra down centered row 2.

form "1)ОД 2)Получ% 3)КомиссКЛ 4)Прогноз% 5)ПросрочОД 6)Просроч% 7)Провизии 8)Штрафы 9)Карточка% 10)СписОД" skip
     "11)Спис% 12)ИндОД 13)Инд% 14)КомиссКр 15)Пеня 5ур 16)СписПеня 17)КомиссСотр 18)ОстатокКЛ" skip
     "19) Выписка 2ур 20) Выписка 9ур 21) Корректировки провизий 22) Провизия АФН"
     "23)Карточка%ДАМУ 24)Получ%ДАМУ 25)Просроч%ДАМУ 26)Выписка нач.%ДАМУ 27)Выписка просроч.%ДАМУ" skip
     "28)Карточка%ASTANA 29)Получ%ASTANA 30)Просроч%ASTANA 31)Выписка нач.%ASTANA 32)Выписка просроч.%ASTANA"
     vans
     with row 32 overlay no-labels no-box width 110 frame updvans.
