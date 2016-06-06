/* kddosna.p

 * MODULE
        Электронное кредитное досье
 * DESCRIPTION
        Просмотр непринятых досье и принятие на рассмотрение в ГБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-9-1
 * AUTHOR
        30/04.2004 madiar
 * CHANGES
        18/05/2004 madiar - Одновременный доступ к данным - теперь kdlon лочится только в момент сохранения данных

    05/09/06   marinav - добавление индексов
*/

{mainhead.i}
{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

def var cust-list as character view-as selection-list single size 60 by 10 label "  Принятие досье с филиалов".
define variable ok-status as logical.
def var data as char extent 999.
def var ar as int init 0.
def var bstring as char init "".

display "   nn   Филиал                    Код кл  Досье    Принято" with frame sel-frame.

form
  cust-list
  with frame sel-frame.

on default-action of cust-list
   do:
      if substring(cust-list:screen-value,length(cust-list:screen-value, "CHARACTER"),1) <> "x" then
        message "Принять досье?"
              view-as alert-box question buttons yes-no-cancel
                      title "" update choice as logical.
      else return.
      case choice:
         when true then /* yes */
          DO:
            ar = integer(substring(cust-list:screen-value,1,index(cust-list:screen-value , ". "))).
            find kdlon where kdlon.kdcif = entry(1,data[ar]) and kdlon.kdlon = entry(2,data[ar]) no-lock no-error.
            find current kdlon exclusive-lock no-error.
            kdlon.sts = "25".
            kdlon.resdat[1] = g-today.
            find current kdlon no-lock no-error.
            message "досье принято." view-as alert-box information buttons ok.
            cust-list:replace(cust-list:screen-value + "  x", cust-list:lookup(cust-list:screen-value)).
          end.
         when false then /* no */
          do:
             message "Досье не принято."
                    view-as alert-box information buttons ok.
             return no-apply.
          end.
         end case.
   end.

find first kdlon where kdlon.bank <> s-ourbank and kdlon.sts = "20" no-lock no-error.
if not avail kdlon then do:
  message skip " Нет непринятых досье " skip(1)
    view-as alert-box buttons ok title " Сообщение: ".
  pause.
  return.
end.

for each kdlon where kdlon.bank <> s-ourbank and kdlon.sts = "20" no-lock:
  ar = ar + 1.
  find first txb where txb.bank = kdlon.bank and txb.is_branch = yes and txb.consolid = yes no-lock no-error.
  bstring = kdlon.kdlon.
  if length(bstring) < 7 then do:
    repeat while length(bstring, "CHARACTER") < 7 :
      bstring = bstring + " ".
    end.
  end.
  ok-status = cust-list:add-last(string(ar, "999") + ". " + txb.name + "  " + kdlon.kdcif + "  " + bstring).
  data[ar] = kdlon.kdcif + "," + kdlon.kdlon.
end. /* for each kdlon */

enable cust-list with frame sel-frame.

wait-for window-close of current-window.