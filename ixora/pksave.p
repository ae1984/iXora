/* pksave.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Сохранение недозаполненной анкеты с отказом
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
        19/08/2005 madiar
 * BASES
        bank, comm
 * CHANGES
*/

{global.i}
{pk.i}

def input parameter v-refus as char.
def shared temp-table t-anket like pkanketh.
def shared var v-trnum as integer format "zzzzzzz9".

def var v-cif as char.
def var v-pkankln as integer.
def var v-name as char.

find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "ankln" no-lock.
if not avail pksysc then do:
   message skip " Параметр ANKLN не найден для данного вида кредита !" skip(1)
      view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
end.

find first t-anket where t-anket.kritcod = "rnn".
v-cif = "".

if t-anket.value1 <> "" then do:
  /* поиск существующего кода клиента - ищем только по нашим кредитам! */
  find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.rnn = t-anket.value1 and pkanketa.cif <> "" no-lock no-error.
  if avail pkanketa then v-cif = pkanketa.cif.
end.

do transaction:
   /* создаем новую анкету */
   find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "ankln" exclusive-lock.
   v-pkankln = pksysc.inval.
   pksysc.inval = pksysc.inval + 1.
   find current pksysc no-lock.
   
   for each t-anket:
       create pkanketh.
       pkanketh.ln = v-pkankln.
       buffer-copy t-anket except t-anket.ln to pkanketh.
   end.
   release pkanketh.
   
   create pkanketa.
   assign pkanketa.bank = s-ourbank
          pkanketa.credtype = s-credtype
          pkanketa.ln = v-pkankln
          pkanketa.rdt = today
          pkanketa.rwho = g-ofc
          pkanketa.acc = v-trnum.
   
   pkanketa.cif = v-cif.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
   if avail pkanketh then pkanketa.rnn = pkanketh.value1.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
   if avail pkanketh then pkanketa.sik = pkanketh.value1.

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
   if avail pkanketh then pkanketa.docnum = pkanketh.value1. 

   /* собрать полное имя по анкете */
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
   if avail pkanketh then v-name = caps(trim(pkanketh.value1)).

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "fname" no-lock no-error.
   if avail pkanketh then do: 
     if v-name <> "" then v-name = v-name + " ".
     v-name = v-name + caps(trim(pkanketh.value1)).
   end.

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "mname" no-lock no-error.
   if avail pkanketh then do:
     if v-name <> "" then v-name = v-name + " ".
     v-name = v-name + caps(trim(pkanketh.value1)).
   end.

   /* заменить казахские буквы на русские */
   run pkdeffio (input-output v-name).
   pkanketa.name = v-name.
   pkanketa.refusal = v-refus.

   release pkanketa.
end. /* transaction */

message v-pkankln view-as alert-box buttons ok.

s-pkankln = v-pkankln.


