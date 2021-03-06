﻿/* psror.f
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
        17.11.09 marinav счет as cha format "x(20)"
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        03.09.2012 evseev - иин/бин
*/


form
     v-ref                   label " Nr.пл.пор"
     v-priory                label " Приоритет" at 27 skip
     remtrz.remtrz           label "    Платеж"
     remtrz.cover            label "     Трнсп" at 27 skip
     remtrz.rdt              label "  Рег.дата"
     remtrz.jh1              label "     1Пров" at 27 skip
     remtrz.fcrc             label "     Вал.Д"
     acode                   label ""
     remtrz.amt              label "    СуммаК" at 27 skip
     remtrz.tcrc             label "     Вал.К"
     crc.code                label ""
     remtrz.payment          label "    СуммаД" at 27 skip
     " ------------  Клиент-отправитель перевода    ------------ " skip
     remtrz.outcode          label "   Тип опл"
     v-pnp                   label " Nr. счета" at 27 skip
     remtrz.ord              label "      Отпр" format "x(60)" skip
     /*v-reg5                  label "       РНН" format "x(12)" skip*/
     v-bin5                  label "  ИИН/БИН " format "x(12)" skip(2)
     " ------------  Комиссионные за перевод   ----------------- " skip
     remtrz.svcrc            label "   Вал.ком"
     bcode                   label "" help "F2-список  " skip
     remtrz.svccgr           label "     Тариф" help "F2-список  "
     pakal                   label "Наим.тариф" format "x(26)" at 27 skip
     remtrz.svca             label " Сумма Ком"
     remtrz.svccgl           label "СГККом"
     help "F2 - saraksts" format "ZZZZZ9" skip
     v-chg                   label "   Тип Опл"
     remtrz.svcaaa           label "    СчОКом" format "x(21)" at 27 skip(1)
     "Детали платежа:" skip
     remtrz.detpay[1] no-label at 2
     remtrz.detpay[2] no-label
     remtrz.detpay[3] no-label at 2
     remtrz.detpay[4] no-label
     with frame remtrz row 3 centered side-labels.

/***/

