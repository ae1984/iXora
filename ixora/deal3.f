/* deal3.p
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

form v-deal      label "Номер сделки" space (16)					v-scugrp    label "Группа......" format "zz9" skip
     v-cif       label "Код клиента." format "x(8)" space(4)				v-lsch      label "Лиц. счет..." format "x(20)" skip
     v-nin       label "НИН........." format "x(16)" space(10)                          v-ccrc      label "Чистая цена.." format "->,>>>,>>>,>>9.99<<<<<<" skip
     v-cbname    label "Наим-ие ЦБ.." format "x(20)" space(6)				v-col       label "Количество..." format "->>,>>>,>>9" skip
     v-atval     label "Эмитент....." format "x(20)" space(6)				v-bcrc      label "Цена открытия" format "->,>>>,>>>,>>9.99<<<<<<" skip
     v-type      label "ТипЭмит....." format "x(3)" space(23)				v-dealsum   label "Сумма открыт." format "->,>>>,>>>,>>9.99<<<<<<" skip
     v-sort      label "ВидЭмит....." format "x(3)" space(23)				v-profit    label "Доходность..." format "->,>>>,>>>,>>9.99<<<<<<" skip
     v-ncrc      label "Номинал ЦБ.." format ">>,>>>,>>>,>>9" space(12)			skip
     v-intrate   label "Купон......." format ">>9.999999" space(16)			v-regdt     label "Дата открытия" format "99/99/9999" skip
     v-crc       label "Валюта......" format ">9" space(24)                             v-valdt     label "Дата валютир." format "99/99/9999" skip
     v-base      label "База........" space(18)                                         skip 
     v-inttype   label "Тип ЦБ......" format "x(3)" space(23)			       v-closeprice label "Цена закрытия" format "->,>>>,>>>,>>9.99<<<<<<" skip	
     v-issuedt   label "Дата выпуска" format "99/99/9999" space(16)		        v-closesum  label "Сумма закрыт." format "->,>>>,>>>,>>9.99<<<<<<" skip
     v-maturedt  label "Дата погашен" format "99/99/9999" space(16)			v-paydt     label "Дата закрытия" format "99/99/9999" skip
     v-dval2     label "Дней до погашения......" format ">>>,>>>,>>9" space(4)          v-kontr     label "Брокер......." format "x(23)" skip
     v-geo       label "Признак резиденства...." format "x(23)" skip
     v-sector    label "Сектор экономики......." format "x(23)" skip
     

with frame deal row 5 side-label centered   width 80.






