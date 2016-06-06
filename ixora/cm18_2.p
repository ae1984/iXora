/* cm18_2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
*/


{cm18.i}

def input param v-safe as char.
def input param v-side as char.
def input-output param v-Amount as decimal extent 10.
def var rez as int.
def var data as char.
def var choice as log.
def var SafeName as char.
 SafeName = v-safe.

  MESSAGE "Положите деньги в приемный слот~n  И нажмите 'OK'" VIEW-AS ALERT-BOX MESSAGE BUTTONS OK-CANCEL TITLE "Пересчет банкнот сейф " + SafeName UPDATE choice.
  if choice = ? or choice = no then do:  return. end.


  REPEAT on ENDKEY UNDO ,leave :
   displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.
   run cm18_trx(GetSafeIP(v-safe),v-side,"SafeCount","",output data,output rez).
   hide frame f-mess.
   if rez <> 101 then do:
    MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Пересчет банкнот" UPDATE choice.
    if choice = ? or choice = no then leave.
   end.
   else leave.
  END.

  if rez <> 101 then return.
  run GetNoteCount(data,"Depo"). /*таблица Result*/

  find first result no-lock no-error.
  if not avail result then do:
    message "Нет данных!" view-as alert-box.
    return.
  end.

    v-Amount[1] = v-Amount[1] + GetSummValRes("KZT").
    v-Amount[2] = v-Amount[2] + GetSummValRes("USD").
    v-Amount[3] = v-Amount[3] + GetSummValRes("EUR").
    v-Amount[4] = v-Amount[4] + GetSummValRes("RUR").
/*
  if v-Amount[1] = - 1 then do:
    v-Amount[1] = GetSummValRes("KZT").
    v-Amount[2] = GetSummValRes("USD").
    v-Amount[3] = GetSummValRes("EUR").
    v-Amount[4] = GetSummValRes("RUR").
  end.
  else do:
    run cm18_Result("Результат пересчета сейф " + SafeName).
  end.

  */
  ClearResult().
