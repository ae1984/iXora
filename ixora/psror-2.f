/* psror-2.f
 * MODULE
        Платежная система
 * DESCRIPTION
        Регистрация исход платежей в тенге (P)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        out_P_ps
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.06.2005 tsoy     - добавил помощь на срочность
       24.06.2005 saltanat - добавила помощь на отправителя.
       23.11.2005 suсhkov  - Детали платежа 412 символов
       24.01.2006 suсhkov  - исправлены ошибки
       06.04.2006 dpuchkov - добавил поле remtrz.own
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
     /*v-reg5                  label "      РНН " format "x(12)" skip*/
     v-bin5                  label "  ИИН/БИН " format "x(12)" validate((chk12_innbin(v-bin5)) ,'Неправильно введён БИН/ИИН') skip(2)
     " ------------  Комиссионные за перевод   ----------------- " skip
     remtrz.svcrc            label "   Вал.ком"
     bcode                   label "" help "F2-список  " skip
     remtrz.svccgr           label "     Тариф" help "F2-список  "
     pakal                   label "Наим.тариф" format "x(26)" at 27 skip
     remtrz.svca             label " Сумма Ком"
     remtrz.svccgl           label "СГККом"
     help "F2 - saraksts" format "ZZZZZ9" skip
     v-chg                   label "   Тип Опл"
     remtrz.svcaaa           label "    СчОКом" format "x(21)" at 27 skip
     with frame remtrz row 3 centered side-labels.

form
     remtrz.detpay[1] VIEW-AS EDITOR SIZE 68 by 6
     with frame detpay row 23 overlay centered title "Детали платежа" .


/* 07.06.2005 tsoy */
on help of v-priory in frame remtrz do:
                  run uni_help1("urgency",'*').
end.

/* 24.06.2005 saltanat */
on help of remtrz.ord in frame remtrz do:
                  run ord_help(s-cif, output s-rnn).
end.

