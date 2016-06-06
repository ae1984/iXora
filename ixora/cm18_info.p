/* cm18_info.p
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
{cm18_abs.i}

def input param v-safe as char.
def input param v-side as char.
def output param v-data as char.
def output param v-Amount as decimal extent 10.
def shared var SafeFault as log.
def var i as int.
def var rez as int.
def var data as char.
def var SafeName as char.
SafeName = v-safe.


  REPEAT on ENDKEY UNDO ,leave :
   run cm18_trx(GetSafeIP(v-safe),v-side,"SafeData","",output data,output rez).
   if rez <> 101 then do:
    MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS OK-CANCEL TITLE "Запрос конфигурации" UPDATE choice AS LOGICAL.
    if choice = ? or choice = no then  leave.
   end.
   else leave.
  end.
  if rez = 1002 then SafeFault = true.
  if rez <> 101 then return.

  run DecodeSafeData(data).
  v-data = data.

   find first wrk no-lock no-error.
   find first wrk_ext no-lock no-error.
   if not avail wrk and not avail wrk_ext then do:
    message "Нет данных о конфигурации сейфа!" view-as alert-box.
    return.
   end.

  repeat i = 1 to 10:
    v-Amount[i] = GetSummVal(GetCRC(i)).
  end.






