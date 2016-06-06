/* psrorlon.f
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

/* psrorlon.f
   форма для заполнения реквизитов исходящего платежа из кредитного модуля
   изменения от 13.013.2001
   - переведены и добавлены метки на русском языке
*/   
form v-ref              label  "Плат.поруч"  skip
     remtrz.remtrz      label  'Платеж' 
     remtrz.cover       label  'Трнсп'       skip
     remtrz.rdt         label  'Рег.дата'
     remtrz.jh1         label  '1Пров'       skip
     remtrz.fcrc        label  "Вал.Д"
     acode              label  "" 
     remtrz.amt         label  "Сумма Д"     skip
     remtrz.tcrc        label  "Вал.К"
     crc.code           label  "" 
     remtrz.payment     label  "Сумма К"     skip
     " ------------ Клиент - отправитель перевода ------------ " skip
     remtrz.outcode     label  "Тип опл."  format ">9"  
     v-pnp              label  "NR счета"                  skip
     remtrz.ord         label  "Отправ. " format "x(60)"   skip
     v-reg5             label  "РНН     " format "x(13)"   skip
     dfb.name           label  "НостроСЧ"  format "x(26)"  skip 
     " ------------ Комиссионные за перевод ----------------- " skip
     remtrz.svcrc       label  'Вал.ком'  
     bcode              label  "" help "F2-справочник"     skip
     remtrz.svccgr      label  "Код ком" help "F2-справочник"
     pakal              label  "Назв.ком." format "x(26)"  skip
     remtrz.svca        label  "Сумма ком."
     remtrz.svccgl      label  "СГКком" help "F2 - справочник" 
                               format "ZZZZZ9"             skip
     v-chg              label  "Тип опл." 
     remtrz.svcaaa      label  "СчОком "                   skip
     remtrz.detpay[1]   label  "Примечание" 
     remtrz.detpay[2]   label  ""
     with frame remtrz 4 col row 3 centered .
