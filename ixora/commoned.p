/* commoned.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Настройка коммунальных платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        commonls.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        25.09.2003 sasco
 * CHANGES
        02.03.2004 sasco добавил в качестве параметра selgrp - номер и наименование группы
        10.09.2004 sasco редактирование наименования организации
        30.11.2005 suchkov - добавил 1 символ в формат
        11.05.2006 u00568 - исправил создание нового.
*/

{comm-txb.i}
{yes-no.i}

define input parameter selgrp as integer.
define input parameter selabel as character.

define variable seltxb as integer.
define query qt for commonls.

define temp-table tmp like commonls.
define buffer tls for commonls.
seltxb = comm-cod ().

define browse bt query qt
       displ commonls.visible label " " format ' /НЕ ПРИНИМАЕМ'
             commonls.type label "ТИП" format ">>>"
             commonls.bn label "Получатель"
             with 10 down centered no-label title "Список платежей".

define frame ft bt help "F8-вкл/выкл, F1-новый, ENTER-редактировать, F2-Копировать в новый"
             with row 1 overlay no-label no-box.

define frame fedit
             tmp.arp label "АРП" skip
             tmp.bn label "Получатель" skip
             tmp.rnnbn label "РНН" skip
             tmp.iik label "Расч.счет" skip
             tmp.bikbn label "БИК" skip
             tmp.sum label "Сумма по умолчанию" skip
             tmp.comsum label "Сумма комиссии по умолчанию" skip
             tmp.comprc label "Проценты (пример: 0,5% = 0.005)" skip
             tmp.kod label "КОД" skip
             tmp.kbe label "КБе" skip
             tmp.kbk label "КБК" skip
             tmp.knp label "КНП" skip
             tmp.symb label "Символ кас.плана" skip
             tmp.prcgl label "Г/К для доходов (%)" skip
             tmp.comgl label "Г/К для комиссии банка" skip
             tmp.que label "очередь в плат/системе" view-as text skip
             tmp.kolprn label "Кол-во квитанций на печать" skip
             tmp.bud label "Тип бюджета" skip
             with row 1 side-labels.
             
define frame fnpl tmp.npl format "x(300)" with overlay row 5 centered
                 top-only scrollable no-label title 'Укажите назначение платежа'.

define frame fstat
             "АРП:" commonls.arp skip
             "Платеж: " commonls.npl skip
             "Сумма: " commonls.sum
             with row 15 no-label.

define frame grpframe selabel label "ГРУППА" format "x(60)" with row 20 no-box side-labels.


on "clear" of bt in frame ft do:
   if not available commonls then leave.
   if visible then if not yes-no ("", "Сделать этот вид платежа неактивным??!") then leave.
   if not visible then if not yes-no ("", "Сделать этот вид платежа АКТИВНЫМ для всех??!") then leave.
   find tls where rowid(tls) = rowid(commonls) no-error.
   tls.visible = not tls.visible.
   browse bt:refresh().
end.

on "go" of bt in frame ft do:
   if not yes-no ("", "Создать новую запись?") then leave.
   find last tls where tls.txb = seltxb and tls.grp = selgrp no-lock no-error.
   create tmp.
   if available tls then buffer-copy tls to tmp.
       assign tmp.txb = seltxb
              tmp.grp = selgrp
              tmp.npl = ''
              tmp.bn = ''
              tmp.arp = ''
              tmp.iik = 0
              tmp.bikbn = 0
              tmp.rnnbn = ''
              tmp.sum = 0.0
              tmp.comsum = 0.0
              tmp.comprc = 0.0
              tmp.visible = yes
              tmp.que = 'SG'.

   if avail tls then tmp.type = tls.type + 1.
                else tmp.type = 1.

   update tmp.arp tmp.bn tmp.rnnbn tmp.iik tmp.bikbn with frame fedit.
   update tmp.npl with frame fnpl.
   hide frame fnpl.
   update tmp except tmp.arp tmp.bn tmp.rnnbn tmp.iik tmp.bikbn tmp.ftp tmp.info tmp.txb tmp.grp tmp.type tmp.visible tmp.typegrp tmp.email tmp.npl
          with frame fedit.

   message "Сохранить? " update choice as logical.
   if choice then do:
      create commonls.
      buffer-copy tmp to commonls.
      delete tmp.
      close query qt.
      open query qt for each commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock by commonls.bn.
      /*browse bt:refresh().*/
   end.
   if available tmp then delete tmp.
   hide frame fedit.
   apply "value-changed" to bt in frame ft.
end.

on "help" of bt in frame ft do:
   if not available commonls then leave.
   if not yes-no ("", "Скопировать эту запись в новую?") then leave.
   find last tls where tls.txb = seltxb and tls.grp = selgrp no-lock no-error.
   create tmp.
   buffer-copy commonls to tmp.
   assign tmp.txb = seltxb
          tmp.grp = selgrp
          tmp.type = tls.type + 1
          tmp.visible = yes.

   update tmp.arp tmp.bn tmp.rnnbn tmp.iik tmp.bikbn with frame fedit.
   update tmp.npl with frame fnpl.
   hide frame fnpl.
   update tmp except tmp.arp tmp.bn tmp.rnnbn tmp.iik tmp.bikbn tmp.ftp tmp.info tmp.txb tmp.grp tmp.type tmp.visible tmp.typegrp tmp.email tmp.npl
          with frame fedit.

   message "Сохранить? " update choice as logical.
   if choice then do:
      create commonls.
      buffer-copy tmp to commonls.
      delete tmp.
      close query qt.
      open query qt for each commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock by commonls.bn.
      browse bt:refresh().
   end.
   if available tmp then delete tmp.
   hide frame fedit.
   apply "value-changed" to bt in frame ft.
end.

on "return" of bt in frame ft do:
   if not available commonls then leave.
   find tls where rowid(tls) = rowid(commonls) no-error.
   create tmp.
   buffer-copy commonls to tmp.
   displ tmp.bn tmp.rnnbn with frame fedit.
   update tmp.arp tmp.bn /* tmp.rnnbn */ tmp.iik tmp.bikbn with frame fedit.
/*   update tmp.npl with frame fnpl.
   hide frame fnpl. */
   update tmp except tmp.arp tmp.bn tmp.rnnbn tmp.iik tmp.bikbn tmp.ftp tmp.info tmp.txb tmp.grp tmp.type tmp.visible tmp.typegrp tmp.email tmp.npl
          with frame fedit.
   message "Сохранить? " update choice as logical.
   if choice then do:
      buffer-copy tmp to tls.
      delete tmp.
      browse bt:refresh().
   end.
   if available tmp then delete tmp.
   hide frame fedit.
   apply "value-changed" to bt in frame ft.
end.

on "value-changed" of bt in frame ft do:
   for each tmp: delete tmp. end.
   if available commonls then displ commonls.arp commonls.npl commonls.sum with frame fstat.
                         else displ '' @ commonls.arp '' @ commonls.npl 0.00 @ commonls.sum with frame fstat.
   view frame grpframe.
end.

displ selabel with frame grpframe.

open query qt for each commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock by commonls.bn.
enable all with frame ft.
apply "value-changed" to bt in frame ft.
wait-for window-close of frame ft focus browse bt.

hide frame grpframe.
pause 0.
