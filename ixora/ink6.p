/* ink6.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Регистрация инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.6.2.6
 * BASES
        BANK COMM
 * AUTHOR
        11/10/2004 dpuchkov
 * CHANGES
        08.08.2005 dpuchkov запретил контроль менеджером удаляемых им же специнструкций
        01.12.05   dpuchkov добавил поиск по счету
        27.01.10 marinav - расширение поля счета до 20 знаков
        21/06/2010 galina - выводим информацию по полному приостновлению как по остальным РПРО
        20.06.2012 evseev - отструктурировал код
*/


{yes-no.i}
{mainhead.i CFSIENT}

/* блок объявления переменных ->*/
    def var ch_acc as char.
    def buffer buf for aas.

    DEF QUERY q1 FOR aas.

    DEF BUTTON bedt LABEL "Контроль".
    DEF BUTTON bdecl LABEL "Отказ".
    DEF BUTTON bsvs LABEL "Свойства".
    DEF BUTTON bext LABEL "Выход".

    def browse b1 query q1 displ
          aas.aaa  format "x(20)"   label "Счет"
          aas.payee /*aas.docprim*/  label "Примечание" format 'x(45)'
          aas.contr label "Контроль"
          with 7 down title "Контроль" overlay.

    def frame aacc
       ch_acc label "Счет" format "x(20)" /* validate(ch_acc <> "", "Введите номер счета ") */
       with side-labels centered row 8.
    def frame getother1
       aas.fnum label    "Номер ИР                     " skip
       aas.docnum1 label  "Номер док для снятия огранич " skip
       aas.docdat1 label  "Дата  док для снятия огранич " skip
       aas.docprim1 format "x(40)" label "Примечание                  " skip
       with side-labels centered row 8.
    def frame getother4
       aas.docprim1 format "x(40)" label "Примечание " skip
       with side-labels centered row 8.
    def frame getother3 /*полная блокировка счета*/
       aas.aaa format "x(20)" label                                 "Номер счета                  " skip
       aas.docnum1 label                              "Номер док для снятия огранич " skip
       aas.docdat1 label                              "Дата док. для снятия огранич " skip
       aas.docprim1 format "x(40)" label              "Примечание                   " skip
       with side-labels centered row 8.
    def frame fr1 b1 skip bedt bdecl bsvs bext with centered overlay row 5 width 100 top-only.

/* <-блок объявления переменных*/

message "Для поиска по всем счетам номер указывать НЕ ОБЯЗАТЕЛЬНО!"  .
update ch_acc with frame aacc.
ON CHOOSE OF bext IN FRAME fr1 do:
   hide frame getlist1.
   hide frame getlist2.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bsvs IN FRAME fr1 do:
   hide frame getlist1.
   hide frame getlist2.
   if aas.fnum <> "" then do:
      if aas.docnum1 = "" and string(aas.docdat1) = ?  then
         displ aas.docprim1 with frame getother4.
      else
         displ aas.fnum aas.docnum1 aas.docdat1 aas.docprim1 with frame getother1.
   end. else do:
      displ aas.aaa aas.docnum1 aas.docdat1 aas.docprim1 with frame getother3.
   end.
   hide frame getlist1.
   hide frame getlist2.
end.

ON CHOOSE OF bedt IN FRAME fr1 do:
   find buf where rowid (aas) = rowid (buf) exclusive-lock.
   if yes-no ("Внимание!", "Контролировать?") then do:
         if aas.contr = True then do:
            message " Контроль невозможен. Спец. инструкция уже проконтролирована.".
            pause 3.
            message "".
         end. else do:
            if aas.who1 = g-ofc then do:
               message "Вы не можете контролировать уделяемую вами специнструкцию!!".
               pause.
               return.
            end.
            aas.contr = True.
            aas.contrwho = g-ofc.
            message "Спец. инструкция проконтролирована!!".
            pause.
            release buf.
            release aaa.
         end.
   end.
   close query q1.
   if ch_acc <> "" then do:
      open query q1 for each aas where aas.aaa = ch_acc and aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
   end. else do:
      open query q1 for each aas where aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
   end.
end.

ON CHOOSE OF bdecl IN FRAME fr1 do:
   find buf where rowid (aas) = rowid (buf) exclusive-lock.
   if yes-no ("Внимание!", "Отказать?") then do:
        if aas.who1 = g-ofc then do:
           message "Вы не можете подтвердить отказ уделяемой вами специнструкции!".
           pause.
           return.
        end.
        aas.activ = True.
        aas.contr = False.
        aas.docnum1 = "".
        aas.docdat1 = ?.
        aas.docprim1 = "".
        message "В удалении специнструкции отказано!".
        pause.
        release buf.
        release aaa.
   end.
   close query q1.
   if ch_acc <> "" then do:
      open query q1 for each aas where aas.aaa = "ch_acc" and aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
   end. else do:
      open query q1 for each aas where aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
   end.
end.

if ch_acc <> "" then do:
   open query q1 for each aas where aas.aaa = ch_acc and aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
end. else do:
   open query q1 for each aas where aas.sta <> 0 and /*aas.aaa = aaa.aaa and*/ aas.activ = False and  aas.contr = False and aas.ln <> 7777777 .
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1 centered overlay top-only.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR WINDOW-CLOSE of frame fr1.
hide frame fr1.














