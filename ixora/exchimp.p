/* exchimp.p
 * MODULE
        Импорт и зачисление выдач в подотчет и обменных операций
 * DESCRIPTION
        Импорт и зачисление выдач в подотчет и зачисление обменных операций 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
	3.2.10.15.2 Импорт и зачисление обменных операций.        
 * AUTHOR
        28/04/2004 kanat
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

def new shared var v-pen-jh as integer.
def new shared var v-atv-jh as integer.

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

update v-date label "Введите дату проведенных обменных операций" format '99/99/99' skip
with side-label row 5 centered frame dataa .

do while v-choice:

      v-choice = false.

   run SHOW-MSG-BOX ("Выдача в подотчет для обменных операций").
   run vydsofp(v-date,v-handler).
   run HIDE-MSG-BOX.	

   run SHOW-MSG-BOX ("Обменные операции кассира").
   run excsofp(v-date,v-handler).
   run HIDE-MSG-BOX.

end.

