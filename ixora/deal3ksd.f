/* deal3ksd.p
 * MODULE
        Модуль ЦБ
 * DESCRIPTION
        Открытие и редактирование сделок по ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        11-9-2
 * BASES
        BANK
 * AUTHOR
        11/07/08 id00209
 * CHANGES

*/

form v-deal      label "Номер сделки..." format "x(9)"     space(31)            v-scugrp    label "Группа..............." format "zz9"                      skip
     v-cif       label "Код клиента...." format "x(8)"     space(32)			v-lsch      label "Лиц. счет............" format "x(20)"                    skip
     v-nin       label "НИН............" format "x(16)"    space(24)            v-ccrc      label "Чистая цена(%)......." format ">,>>9.9999<<<<"           skip
     v-cbname    label "Наименование ЦБ" format "x(20)"    space(20)			v-crc       label "Валюта цены.........." format ">9"                       skip
     v-atval     label "Эмитент........" format "x(20)"    space(20)			v-col       label "Количество..........." format ">>>,>>>,>>9"              skip
     v-type      label "Тип Эмитента..." format "x(3)"     space(37)			v-nomsum    label "Номинальная стоимость" format ">>>,>>>,>>>,>>>,>>9.99"   skip
     v-sort      label "Вид Эмитента..." format "x(3)"     space(37)			v-nkd       label "Купонный доход......." format ">>>,>>>,>>>,>>>,>>9.99"   skip
     v-ncrc      label "Номинал ЦБ....." format "->,>>>,>>9.99" space(27)       v-ccrcsum   label "Чистая стоимость....." format ">>>,>>>,>>>,>>>,>>9.99"   skip
     v-intrate   label "Купон(%)......." format ">>>>>>9.9999<<<<<<"  space(28)	v-dealsum   label "Сумма сделки........." format ">>>,>>>,>>>,>>>,>>9.99"   skip
     v-cbcrc     label "Валюта........." format ">9"       space(38)            v-yield     label "Эффективная ставка(%)" format ">>>,>>9.9999<<<<<<"       skip
     v-base      label "База..........." format "x(10)"    space(30)            v-regdt     label "Дата открытия........" format "99/99/9999"               skip
     v-inttype   label "Тип ЦБ........." format "x(3)"     space(37)			v-valdt     label "Дата валютирования..." format "99/99/9999"               skip
     v-issuedt   label "Дата выпуска ЦБ" format "99/99/9999" space(30)		                                                                                skip
     v-maturedt  label "Дата погашен ЦБ" format "99/99/9999" space(30)			                                                                            skip
     v-dval2     label "Дней до погашения..." format ">>,>>9" space(29)          v-kontr     label "Брокер..............." format "x(23)"                   skip
     v-geo       label "Признак резиденства." format "x(23)"                                                                                                skip
     v-sector    label "Сектор экономики...." format "x(23)"                                                                                                skip


with frame deal row 5 side-label centered   width 110.






