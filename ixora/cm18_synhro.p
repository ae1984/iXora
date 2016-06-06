/* cm18_synhro.p
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
        15/09/2012 k.gitalov
 * BASES
        TXB COMM
 * CHANGES
        19/09/2012 k.gitalov перекомпиляция
*/

def input param v-safe as char.
def input param R-Data as char.
def input param v-Amount as decimal extent 10.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

find first cslist where cslist.nomer = v-safe no-lock.
if avail cslist and cslist.bank = s-ourbank then do:

  find last txb.sm18data where txb.sm18data.safe = v-safe and (txb.sm18data.state = 0 or txb.sm18data.state = 1) use-index ind no-lock no-error.

          if txb.sm18data.after_summ[1] <> v-Amount[1] or txb.sm18data.after_summ[2] <> v-Amount[2] or
             txb.sm18data.after_summ[3] <> v-Amount[3] or txb.sm18data.after_summ[4] <> v-Amount[4] or
             txb.sm18data.Responce <> R-Data then
          do:
             message
                "KZT:" + string(v-Amount[1],">>>,>>>,>>9.99-") + "----->" + string(txb.sm18data.after_summ[1],">>>,>>>,>>9.99-") + "~n" +
                "USD:" + string(v-Amount[2],">>>,>>>,>>9.99-") + "----->" + string(txb.sm18data.after_summ[2],">>>,>>>,>>9.99-") + "~n" +
                "EUR:" + string(v-Amount[3],">>>,>>>,>>9.99-") + "----->" + string(txb.sm18data.after_summ[3],">>>,>>>,>>9.99-") + "~n" +
                "RUB:" + string(v-Amount[4],">>>,>>>,>>9.99-") + "----->" + string(txb.sm18data.after_summ[4],">>>,>>>,>>9.99-") + "~n"
             view-as alert-box title "Необходима синхронизация!".
             MESSAGE "Выполнить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS OK-CANCEL TITLE "Синхронизация данных" UPDATE choice2 AS LOGICAL.
             if choice2 = yes then do:
                find last txb.sm18data where txb.sm18data.safe = v-safe and (txb.sm18data.state = 0 or txb.sm18data.state = 1) use-index ind exclusive-lock no-error.
                txb.sm18data.after_summ[1] = v-Amount[1].
                txb.sm18data.after_summ[2] = v-Amount[2].
                txb.sm18data.after_summ[3] = v-Amount[3].
                txb.sm18data.after_summ[4] = v-Amount[4].
                txb.sm18data.Responce = R-Data.
                message "Синхронизация выполнена!" view-as alert-box.
             end.
          end.
          else message "Синхронизация не требуется!" view-as alert-box.

end.