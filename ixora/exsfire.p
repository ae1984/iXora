/* exsfire.p
 * MODULE
        Импорт и анализ платежей увольняемых кассиров
 * DESCRIPTION
        Импорт и анализ платежей увольняемых кассиров
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        09/11/2004 kanat
 * CHANGES
*/

{global.i}
{msg-box.i}
{comm-txb.i}

def var v-choice as log init true.
def var v-symbol as char.
def var v-handler as char.
def var v-choice-yes as char.
def var pathname as char.

def var seltxb as int.
def var v-state as logical.

def new shared var v-kofc as char.

def var v-date as date.

seltxb = comm-cod ().

   run sel ("Выберите тип носителяљ", "1. Дискета      |" +
                                      "2. Flash        |" + 
                                      "3. Выход         ").

   find first sysc where sysc.sysc = "flastp" no-lock no-error.
   if avail sysc then 
   v-symbol = sysc.chval.
   else
   message "Конфигурация для Flash диска отсутствует" view-as alert-box title "Ошибка".

       case return-value:
          when "1" then v-handler = "A:\\".
          when "2" then v-handler = v-symbol + ":\\".
          when "3" then return.
       end.

do while v-choice:

      v-choice = false.

   run SHOW-MSG-BOX ("Анализ работы кассира").
   run exchfin(v-handler).
   run HIDE-MSG-BOX.	

end.


