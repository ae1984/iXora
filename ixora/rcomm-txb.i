/* rcomm-txb.i
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
        28/11/03 sasco добавил обработку филиалов
                (чтобы тоже заполняли 103 макет при создании платежа)
*/


/* состояние TXB00 & RKO */
def var RKO_OUT as log.
def var RKO_LOGI as log.

/* очередь = 3G или нет */
def var QUE_3G as log initial false.
define variable QUE_TXB as log initial false.

if avail que then
do:
     if que.pid = '3G' then QUE_3G = true.
end.
     else QUE_3G = false.

if not avail que and m_pid = '3G' then QUE_3G = true.

find sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message 'Отсутствует запись OURBNK в таблице SYSC!'.
  pause.
  undo,return.
end.

if sysc.chval <> 'TXB00' then QUE_TXB = true.

/*
  RKO_VALUT  = валютный или нет
  RKO_LOGI   = source <> "RKOTXB"
  RKO_OUT    = филиал или СПФ
  RKO_VALOUT = RKO_LOGI & RKO_OUT () & RKO_VALUT
*/

/* валютный платеж или нет */
function RKO_VALUT returns logical.
   if avail remtrz then
   do:
       if remtrz.tcrc = 1 then return false.
                          else return true.
   end.
   else return ?.
end.

if (get-dep (g-ofc, g-today) <> 1 and sysc.chval = 'TXB00') or (sysc.chval <> 'TXB00')
            then RKO_OUT = true.
            else RKO_OUT = false.

if remtrz.source <> "RKOTXB" then RKO_LOGI = yes. /* RKO    | SWIFT  */
                             else RKO_LOGI = no.  /* RKOTXB | Branch */

/* TXB00 & RKO & NOT_KZT */
function RKO_VALOUT returns logical.

if RKO_LOGI = no /* платеж на филиал -> никаких свифтов */ then return false.
else do:

   if RKO_OUT then
   do:
     if remtrz.source = "RKOTXB" then return false.
     case RKO_VALUT () :
          when true
               then return true.
          when false
               then return false.
          otherwise
               return ?.
      end.
   end.
   else return false.

end.

end.
