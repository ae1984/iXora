/* compens_accept
 * MODULE
        Название модуля
 * DESCRIPTION
        Управление программой начисления вознаграждения
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        20.07.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
        12.08.2013 evseev - tz-1836

*/

{mainhead.i}

def var acc-list  as char.                           /* Список ИИК */
def var acc-list1 as char.                           /* Список ИИК */




function GetClientName returns char (input v-acc as char).
    find first aaa where  aaa.aaa = v-acc no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if not available cif then
        do:
          message "Не найден клиент " aaa.cif "в таблице CIF"  view-as alert-box.
          return "".
        end.
        else return  trim(trim(cif.prefix) + " " + trim(cif.name)).
    end.
    else return "".
end function.

function GetClientCif returns char (input v-acc as char).
    find first aaa where  aaa.aaa = v-acc no-lock no-error.
    if avail aaa then return  aaa.cif. else return "".
end function.

function getAccept returns char (input v-acc as char).
   find first sysc where sysc.sysc = "vip-com" no-lock no-error.
   if avail sysc then acc-list = sysc.chval. else acc-list = "".
   if acc-list matches "*" + v-acc + "*" then return "Да". else return "Нет".
end function.

define query q_list for compens_data .
def var v-cif as char.
def var v-aaa as char.
def var v-i as int.
define browse b_list query q_list no-lock
   display
   GetClientCif(compens_data.acc)   label "Cif" format "x(6)"
   /*GetClientName(compens_data.acc)   label "Наименование  " format "x(30)"*/
   compens_data.acc       label     "Счет " format "x(20)"
   compens_data.rate      label     "%" format ">9.99"
   compens_data.paydates  label     "Выплата вознаграждения" format "x(20)"
   compens_data.minbal    label     "Несниж.ост." format ">>>>>>>>>9.99"
   compens_data.cappay    label     "Кап."
   compens_data.tax       label     "Подох.налог"
   getAccept(compens_data.acc) label "Акцепт"  format "x(3)"
   with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

DEFINE BUTTON btnexit LABEL "Выход".
DEFINE BUTTON btnadd LABEL "Включить".
DEFINE BUTTON btnedt LABEL "Отключить".
DEFINE BUTTON btndel LABEL "Удалить".

DEFINE FRAME MainFrame skip(1) b_list skip space(26) btnadd btnedt btndel btnexit WITH SIDE-LABELS centered  row 4 WIDTH 105 TITLE "Список счетов" .


def frame form1
        v-cif format "x(50)"                            label     "Код-клиента.           " skip
        v-aaa            format "x(20)"                 label     "Номер счета.           " skip
        compens_data.rate format ">9.99"                label     "% ставка.              " skip
        compens_data.paydates format "x(40)"            label     "Выплата вознаграждения." skip
        compens_data.minbal format ">>>>>>>>>>>9.99"    label     "Неснижаемый остаток.   " skip
        compens_data.tax                                label     "Подоходный налог.      " skip
        compens_data.cappay                             label     "Капитализация.         " skip
        compens_data.accpay  format "x(20)"             label     "Счет выплаты           " skip
        with side-labels centered row 6.



ON RETURN OF b_list  in  frame MainFrame DO:
   find first aaa where aaa.aaa = compens_data.acc no-lock no-error.
   if avail aaa then do:
      find first cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then v-cif = cif.cif. else v-cif = "".
      v-aaa = compens_data.acc.
      displ v-cif v-aaa compens_data.rate compens_data.paydates compens_data.minbal compens_data.tax compens_data.cappay compens_data.accpay with frame form1.
      pause.
      hide frame form1.
   end.
END.

ON CHOOSE OF btndel DO:
do transaction:
   if acc-list matches "*" + compens_data.acc + "*" then do:
      acc-list1 = "".
      do v-i = 1 to num-entries(acc-list):
         if entry(v-i,acc-list) <> compens_data.acc then do:
             if acc-list1 <> "" then acc-list1 = acc-list1 + ",".
             acc-list1 = acc-list1 + entry(v-i,acc-list).
         end.
      end.
      find current sysc exclusive-lock.
      sysc.chval = acc-list1.
      find current sysc no-lock.
   end. else do:
   end.
   find current compens_data exclusive-lock.
   delete compens_data.
   message "Счет удален!" view-as alert-box.
   find current compens_data no-lock no-error.
   OPEN QUERY q_list FOR EACH compens_data.
   b_list:refresh().
   acc-list = sysc.chval.
end.
END.

ON CHOOSE OF btnadd DO:
do transaction:
   if acc-list matches "*" + compens_data.acc + "*" then do:
      message "Счет уже был акцептован!" view-as alert-box.
   end. else do:
      find current sysc exclusive-lock.
      if sysc.chval <> "" then sysc.chval = sysc.chval + "," + compens_data.acc. else sysc.chval = compens_data.acc.
      find current sysc no-lock.
      message "Счет акцептован!" view-as alert-box.
   end.
   OPEN QUERY q_list FOR EACH compens_data.
   b_list:refresh().
   acc-list = sysc.chval.
end.
END.
ON CHOOSE OF btnedt DO:
do transaction:
   if acc-list matches "*" + compens_data.acc + "*" then do:
      acc-list1 = "".
      do v-i = 1 to num-entries(acc-list):
         if entry(v-i,acc-list) <> compens_data.acc then do:
             if acc-list1 <> "" then acc-list1 = acc-list1 + ",".
             acc-list1 = acc-list1 + entry(v-i,acc-list).
         end.
      end.
      find current sysc exclusive-lock.
      sysc.chval = acc-list1.
      find current sysc no-lock.
      message "Акцепт со счета снят!" view-as alert-box.
   end. else do:
     message "Счет не был акцептован!" view-as alert-box.
   end.
   OPEN QUERY q_list FOR EACH compens_data.
   b_list:refresh().
   acc-list = sysc.chval.
end.
END.
ON CHOOSE OF btnexit DO:
   apply "endkey" to frame MainFrame.
   hide frame MainFrame.
END.

find first sysc where sysc.sysc = "vip-com" no-lock no-error.
if not avail sysc then do transaction:
   create sysc.
     sysc.sysc = "vip-com".
     sysc.des = "Счета для начисления вознаграж".
end.
find first sysc where sysc.sysc = "vip-com" no-lock no-error.

open query q_list for each compens_data .

enable b_list btnadd btnedt btndel btnexit WITH  FRAME MainFrame.
WAIT-FOR endkey of frame MainFrame.
hide frame MainFrame.