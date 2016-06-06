/* cssiedt.p
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

/* cssiedt.p
   Modified by VLADL 21-07-97.

   06.08.03 marinav Не накладывать специнструкции на закрытый счет
   18.05.2011 ruslan - добавил переменную ch_acc и добавил функцию on help of
   20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д

*/



define new shared var s-aaa like aaa.aaa.
define var num-ln as integer.
define var vsele as char form "x(28)" extent 2
/*
 initial ["Uzlikt jaunu instrukciju", "SkatЁties visas instrukcijas"].
*/
 initial [" Добавить новую инструкцию ", " Просмотр всех инструкций "].

def var ch_acc as char.
{mainhead.i CFSIENT}  /*  SPECIAL INSTRUCTION MAINT  */

DEFINE VARIABLE phand AS handle.
DEFINE VARIABLE v-cif1 AS char.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.

define frame aaa
   ch_acc label "Поиск по счету" format "x(21)"
with side-labels centered row 7.

on help of ch_acc in frame aaa do:
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            ch_acc = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            ch_acc = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        end.
        displ  ch_acc with frame aaa.
    end.
    DELETE PROCEDURE phand.
end.

repeat:
  update ch_acc with frame aaa.

  find aaa where aaa.aaa = ch_acc no-error.
  if not available aaa then
   do:
      /*
      message "Konts neeksistё !".
      */

      message "Счет не найден".
      pause 3.
   end.
   else
   do:
     if aaa.sta = 'C' then do:
          message skip "Счет " + aaa.aaa + " закрыт !" skip
           "Добавление специнструкций невозможно !" skip(1)
           view-as alert-box button Ok title "Внимание!".
         return.
     end.
     s-aaa = aaa.aaa.
     num-ln = 0.
     for each aas where aas.aaa = s-aaa use-index aaaln no-lock:
        num-ln = num-ln + 1.
     end.
     if num-ln = 0 then
      do:
         /*
         display "Kontam " + s-aaa + " nav speci–lo instrukciju !"
            format "x(44)" with center row 7 frame bridin.
         */

         display "По счету " + s-aaa + " нет специальных инструкций !"
            format "x(44)" with center row 7 frame bridin.

         form vsele with 1 column centered row 10 no-label frame nnn.
         view frame nnn.
         display vsele with frame nnn.
         choose field vsele auto-return with frame nnn.

         hide frame bridin.
         hide frame nnn.
         if frame-index = 1 then
          do:
             run aaa-aasm.
          end.
             else
          do:
             run aasall.
          end.
      end.
         else
      do:
         run aaa-aasm.
     end.                                                              end.
end.
