/* compens_adm
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
        --/--/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        17.07.2012 evseev
        15.08.2012 evseev - изменения формата для даты
        28.03.2013 evseev - tz-1780
        12.08.2013 evseev - tz-1836
*/
{global.i}
/*{mainhead.i}*/
def var acc-list  as char.                           /* Список ИИК */
def var acc-list1 as char.                           /* Список ИИК */
def var v-i as int.
def var v-tempstr as char.
def var v-day as int.
def var v-month as int.
def var v-year as int.
def var v-ch as int.

function GetDaysOfMonth returns integer (input  mm as inte, input  yy as inte).
    /*if      mm = 0  then return 28.
    else */ if mm = 1  then return 31.
    else if mm = 2  then do: if yy <> 0 then do: if round((yy - 1900) / 4 , 0) = (yy - 1900) / 4 then return 29. else return 28. end. end.
    else if mm = 3  then return 31.
    else if mm = 4  then return 30.
    else if mm = 5  then return 31.
    else if mm = 6  then return 30.
    else if mm = 7  then return 31.
    else if mm = 8  then return 31.
    else if mm = 9  then return 30.
    else if mm = 10 then return 31.
    else if mm = 11 then return 30.
    else if mm = 12 then return 31.
end function.

function getAccept returns char (input v-acc as char).
   find first sysc where sysc.sysc = "vip-com" no-lock no-error.
   if avail sysc then acc-list = sysc.chval. else acc-list = "".
   if acc-list matches "*" + v-acc + "*" then return "Акцептован". else return "НЕ акцептован".
end function.

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

define query q_list for compens_data .
def var v-cif as char.
define browse b_list query q_list no-lock
   display compens_data.acc   label "Счет " format "x(20)"
   GetClientName(compens_data.acc)   label "Наименование  " format "x(30)"
   getAccept(compens_data.acc) label "Акцепт"  format "x(13)"
   with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

define query q_aaa for aaa .
define browse b_aaa query q_aaa no-lock
   display aaa.aaa   label "Счет " format "x(20)"
   with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

DEFINE BUTTON btnexit LABEL "Закрыть".
DEFINE BUTTON btnadd LABEL "Добавить".
DEFINE BUTTON btnedt LABEL "Изменить".

DEFINE FRAME MainFrame skip(1) b_list skip space(26) btnadd btnedt btnexit WITH SIDE-LABELS centered  row 4 WIDTH 75 TITLE "Список счетов" .
DEFINE FRAME MainFrameAaa skip(1) b_aaa WITH SIDE-LABELS centered  row 4 WIDTH 28 TITLE "Список счетов" .

def frame form1
        v-cif format "x(6)"                            label     "Код-клиента.           " skip
        compens_data.acc  format "x(20)"                 label     "Номер счета.           " skip
        compens_data.rate format ">9.99"                label     "% ставка.              " skip
        compens_data.paydates format "x(40)"            label     "Выплата вознаграждения." validate(v-ch > 0, "Через F2!!!") help "F2 - выбор выплаты вознаграждения" skip
        compens_data.minbal format ">>>,>>>,>>>,>>9.99"    label     "Неснижаемый остаток.   " skip
        compens_data.tax                                label     "Подоходный налог.      " skip
        compens_data.cappay                             label     "Капитализация.         " skip
        compens_data.accpay  format "x(20)"             label     "Счет выплаты           " skip
        with side-labels centered row 6.

def frame formday
        v-day format ">9" label "День выплаты." validate(v-day >= 1 and v-day <= 31, "Не верно указан день") skip
        with side-labels centered row 6 TITLE "Ежемесячно".

def frame formmonth
        v-day format ">9" label "День " validate(v-day >= 1 and v-day <= 31, "Не верно указан день") skip
        v-month format ">9" label "Месяц" validate(v-month >= 1 and v-month <= 12, "Не верно указан месяц") skip
        with side-labels centered row 6 TITLE "Ежегодно".

def frame formyear
        v-day format ">9"    label "День " validate(v-day >= 1 and v-day <= 31, "Не верно указан день") skip
        v-month format ">9"  label "Месяц" validate(v-month >= 1 and v-month <= 12, "Не верно указан месяц") skip
        v-year format ">>>9" label "Год  " validate(v-year >= 2012 and v-year <= 2100, "Не верно указан год") skip
        with side-labels centered row 6 TITLE "В конце срока".

def frame formquarter
        v-day format ">9" label "День " validate(v-day >= 1 and v-day <= 31, "Не верно указан день") skip
        v-month format ">9" label "Месяц" validate(v-month >= 1 and v-month <= 12, "Не верно указан месяц") skip
        with side-labels centered row 6 TITLE "Ежеквартально начиная с".

ON RETURN OF b_list  in  frame MainFrame DO:
   find first aaa where aaa.aaa = compens_data.acc no-lock no-error.
   if avail aaa then do:
      find first cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then v-cif = cif.cif. else v-cif = "".
      displ v-cif compens_data.acc compens_data.rate compens_data.paydates compens_data.minbal compens_data.tax compens_data.cappay compens_data.accpay with frame form1.
      pause.
      hide frame form1.
   end.
END.

ON help OF compens_data.paydates DO:
  def var i as int.
  v-day = 0.
  v-month = 0.
  v-year = 0.

  def var v-sel as int.
  v-ch = 1.
  run sel2 (" Выберите тип выплаты вознаграждения ",  "1. Ежемесячно |2. Ежеквартально |3. Раз в год |4. В конце срока", output v-sel).
  if (v-sel < 1) or (v-sel > 3) then do: v-ch = 0. leave. end.
  if v-sel = 1 then do:
     update v-day  with frame formday.
  end.
  if v-sel = 2 then do:
     update v-day v-month  with frame formquarter.
  end.
  if v-sel = 3 then do:
     update v-day v-month  with frame formmonth.
  end.
  if v-sel = 4 then do:
     update v-day v-month v-year with frame formyear.
  end.
  compens_data.paydates = "".
  if v-sel <> 2 then do:
      if v-day   <> 0 then compens_data.paydates = compens_data.paydates + string(v-day,"99").
      if v-month <> 0 then compens_data.paydates = compens_data.paydates + "." + string(v-month,"99").
      if v-year  <> 0 then compens_data.paydates = compens_data.paydates + "." + string(v-year,"9999").
  end. else do:
     do i = 1 to 4 :
        if compens_data.paydates <> "" then compens_data.paydates = compens_data.paydates + ";".
        compens_data.paydates = compens_data.paydates + string(v-day,"99") + "." + string(v-month,"99").
        v-month = v-month + 3.
        if v-month > 12 then v-month = v-month - 12.
     end.
  end.

  displ compens_data.paydates with frame form1.
end.


ON VALUE-CHANGED  OF compens_data.paydates DO:
  v-ch = 0.
end.

/*ON RETURN OF b_aaa  in  frame MainFrameAaa DO:
   compens_data.acc = aaa.aaa.
end.*/

ON help OF compens_data.acc DO:
  find first cif where cif.cif = v-cif no-lock no-error.
  if avail cif then do:
      open query q_aaa for each aaa where aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C"  and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0.
      enable all WITH  FRAME MainFrameAaa.
      WAIT-FOR ENTER of frame MainFrameAaa.
      compens_data.acc = aaa.aaa.
      displ compens_data.acc with frame form1.
  end.
end.

ON help OF compens_data.accpay DO:
  find first cif where cif.cif = v-cif no-lock no-error.
  if avail cif then do:
      open query q_aaa for each aaa where aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C"  and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0.
      enable all WITH  FRAME MainFrameAaa.
      WAIT-FOR ENTER of frame MainFrameAaa.
      compens_data.accpay = aaa.aaa.
      displ compens_data.accpay with frame form1.
  end.
end.

ON CHOOSE OF btnadd DO:
   def var str as char.
   do transaction:
     create compens_data.
     v-ch = 0.
     v-cif = "".
     displ compens_data.acc compens_data.rate  compens_data.paydates compens_data.minbal compens_data.tax compens_data.cappay compens_data.accpay with frame form1.
     update v-cif with frame form1.
     update compens_data.acc compens_data.rate  compens_data.paydates compens_data.minbal compens_data.tax compens_data.cappay compens_data.accpay with frame form1.
     find first aaa where aaa.aaa = compens_data.acc no-lock no-error.
     if not avail aaa then do:
        message "Не найден счет!" view-as alert-box error.
        undo.
     end.
     find first aaa where aaa.aaa = compens_data.accpay no-lock no-error.
     if not avail aaa then do:
        message "Не найден счет выплаты!" view-as alert-box error.
        undo.
     end.
     do v-i = 1 to num-entries(compens_data.paydates, ";"):
        str = entry(v-i,compens_data.paydates,";").
        v-day = 0.
        v-month = 0.
        v-year = 0.
        v-tempstr = "err". v-tempstr = entry(1,str,".") no-error.
        if v-tempstr <> "err" then v-day = int(v-tempstr) no-error.
        if not(v-day >= 1 and v-day <= 31) or v-tempstr = "err" then do:
           message "Не верно указан день!" view-as alert-box error.
           undo.
        end.
        v-tempstr = "err". v-tempstr = entry(2,str,".") no-error.
        if v-tempstr <> "err" then v-month = int(v-tempstr) no-error.
        if not(v-month >= 1 and v-month <= 12) and v-tempstr <> "err" then do:
           message "Не верно указан месяц!" view-as alert-box error.
           undo.
        end.
        v-tempstr = "err". v-tempstr = entry(3,str,".") no-error.
        if v-tempstr <> "err" then v-year = int(v-tempstr) no-error.
        if not(v-year >= 2012 and v-year <= 2100) and v-tempstr <> "err" then do:
           message "Не верно указан год!" view-as alert-box error.
           undo.
        end.
        /*if v-day > GetDaysOfMonth(v-month,v-year) then do:
           message "Не верно указана дата!" view-as alert-box error.
           undo.
        end.*/
     end.
   end.
   OPEN QUERY q_list FOR EACH compens_data.
   b_list:refresh().
END.
ON CHOOSE OF btnedt DO:
   def var str as char.
   find first aaa where aaa.aaa = compens_data.acc no-lock no-error.
   if avail aaa then do:
      find first sysc where sysc.sysc = "vip-com" no-lock no-error.
      if avail sysc then acc-list = sysc.chval. else acc-list = "".

      find first cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then v-cif = cif.cif. else v-cif = "".
      displ v-cif compens_data.acc  with frame form1.
      do transaction:
         find current compens_data exclusive-lock.
         v-ch = 1.
         update compens_data.rate  compens_data.paydates compens_data.minbal compens_data.tax compens_data.cappay compens_data.accpay with frame form1.
         if num-entries(compens_data.paydates, ";") = 0 then do:
            message "Неверно указан день!" view-as alert-box error.
            undo.
         end.
         find first aaa where aaa.aaa = compens_data.accpay no-lock no-error.
         if not avail aaa then do:
            message "Не найден счет выплаты!" view-as alert-box error.
            undo.
         end.
         do v-i = 1 to num-entries(compens_data.paydates, ";"):
            str = entry(v-i,compens_data.paydates,";").
            v-day = 0.
            v-month = 0.
            v-year = 0.
            v-tempstr = "err". v-tempstr = entry(1,str,".") no-error.
            if v-tempstr <> "err" then v-day = int(v-tempstr) no-error.
            if not(v-day >= 1 and v-day <= 31) or v-tempstr = "err" then do:
               message "Не верно указан день!" view-as alert-box error.
               undo.
            end.
            v-tempstr = "err". v-tempstr = entry(2,str,".") no-error.
            if v-tempstr <> "err" then v-month = int(v-tempstr) no-error.
            message v-tempstr. pause.
            if not(v-month >= 1 and v-month <= 12) and v-tempstr <> "err" then do:
               message "Не верно указан месяц!" view-as alert-box error.
               undo.
            end.
            v-tempstr = "err". v-tempstr = entry(3,str,".") no-error.
            if v-tempstr <> "err" then v-year = int(v-tempstr) no-error.
            if not(v-year >= 2012 and v-year <= 2100) and v-tempstr <> "err" then do:
               message "Не верно указан год!" view-as alert-box error.
               undo.
            end.
            /*if v-day > GetDaysOfMonth(v-month,v-year) then do:
               message "Не верно указана дата!" view-as alert-box error.
               undo.
            end.*/
         end.
         if acc-list matches "*" + compens_data.acc + "*" then do:
            acc-list1 = "".
            do v-i = 1 to num-entries(acc-list):
               if entry(v-i,acc-list) <> compens_data.acc then do:
                   if acc-list1 <> "" then acc-list1 = acc-list1 + ",".
                   acc-list1 = acc-list1 + entry(v-i,acc-list).
               end.
            end.
            find current sysc exclusive-lock no-error.
            if avail sysc then sysc.chval = acc-list1.
            find current sysc no-lock no-error.
            message "Акцепт со счета снят!" view-as alert-box error.
         end.
         OPEN QUERY q_list FOR EACH compens_data.
         b_list:refresh().
         if avail sysc then acc-list = sysc.chval. else  acc-list = "".
      end.
      find current compens_data no-lock.
      hide frame form1.
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

enable b_list btnadd btnedt btnexit WITH  FRAME MainFrame.
WAIT-FOR endkey of frame MainFrame.
hide frame MainFrame.