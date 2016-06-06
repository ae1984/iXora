/* pnjpflt.p
 * MODULE
     Пенсионные платежи
 * DESCRIPTION
     Формирование писем возврата пенсионного платежа клиенту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
     5.9.13.5
 * AUTHOR
     12.12.2003 sasco
 * CHANGES
        18.12.2003 sasco добавил и-шку для перекомпиляции
        21.01.2004 sasco переделал поиск адреса
        23.01.2004 sasco переделал поиск адреса (обработка "?")
        30.01.2004 sasco Добавил запись ФИО и адреса в letters
        28.02.2004 kanat Добавил номера телефонов в письма
*/

{pnjcommon.i}

{comm-txb.i}
def var seltxb as int.
define variable ourbnk as char.
seltxb = comm-cod().
ourbnk = comm-txb().

{get-dep.i}
{sysc.i}
{yes-no.i}
{trim.i}

def shared var g-ofc as character.
def shared var g-today as date.

def var rid as rowid.
def var dat as date.

def var s_rid as char.

def var d_whole_sum as decimal init 0.

dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

define variable v-letnum as character.
define variable v-header as character.
define variable v-footer as character.
define variable v-letter as integer.

find sysc where sysc.sysc = "GCVPLT" no-lock no-error.
if not available sysc then v-letter = 0.
else v-letter = sysc.inval.


define temp-table tmp like p_f_payment
                  field kol as character
                  field pf-name as character
                  field addr as character
                  field info2 as character.


DEFINE QUERY q1 FOR tmp.
def browse b1 
    query q1 no-lock
    display DATE label "Дата" format "99/99/99"
        tmp.dnum label "No" format ">>>>>>9"
        tmp.rnn  label "РНН" format "999999999999" /*"x(12)"*/ 
        tmp.kol  label "Писем" format "x(2)"
        tmp.amt format ">>>>>>9.99" label "Сумма"
        if tmp.com then tmp.comiss else 0 format ">>>>9.99" label "Ком"
        if tmp.com then tmp.amt + tmp.comiss else tmp.amt format ">>>>>>9.99" label
        "Всего"                
         with 14 down title "Платежи в пенсионный фонд" no-labels. 

DEFINE BUTTON bedt LABEL "См./Изм.".        
DEFINE BUTTON blet LABEL "Письмо-Возврат".

define variable pf-name as character.
define variable pl-name as character.

define frame sf 
               tmp.rnn  label "РНН" format "x(12)" skip
               tmp.name label "ФИО/Наименование" format "x(50)" skip
               tmp.addr label "Адрес" format "x(50)" skip
               tmp.kol label "Кол-во писем" format "x(2)" skip
               "--------------------------------------------------" skip(1)
               tmp.distr label "РНН П/Фонда (F2 - выбор)" format "x(12)" skip
               tmp.pf-name no-label format 'x(50)' view-as text skip
               "--------------------------------------------------" skip(1)
               tmp.cod  label "Код [П.Ф(10).- 100, П.Ф.(19)-200, П.Ф.(13) - 300, Прочие-400]" skip
               tmp.amt  label "Сумма" format ">>>>>>9.99" 
               tmp.qty  label "Кол-во" 
               with side-labels centered view-as dialog-box.

def frame f1 
    b1                
    skip
    bedt
    space(2)
    blet.

ON CHOOSE OF bedt IN FRAME f1
do:
   if not available tmp then leave.
   
   displ tmp.rnn
         tmp.name 
         tmp.addr
         tmp.kol
         tmp.pf-name
         tmp.distr
         tmp.cod
         tmp.amt
         tmp.qty
         with frame sf.
   pause.

   hide frame sf. pause 0.
    
end.


ON CHOOSE OF blet in frame f1
do:
   if not available tmp then leave.
   if tmp.cod = 400 then leave.
   if not yes-no ('', 'Вывести письмо?') then leave.

   v-header = 'Отправитель денег: <b>' + REPLACE (tmp.name, "ТР СЧ ", "") + ' </b><br>' +
              'РНН : <b> ' + tmp.rnn + ' </b> <br>' +
              'Адрес: <b> ' + tmp.addr + ' </b> <br>'.

   v-footer = "Некорректный реестр пенсионных отчислений или неправильные реквизиты НПФ".

   run savelog ("pnjletter", "Формирование письма для tmp N " + string(tmp.dnum) + " / " + string(tmp.date) + tmp.distr).

   v-letter = v-letter + 1.
   v-letnum = "РР1-" + TRIM(STRING(v-letter, "zzzzzzzz9")) + "-" + TRIM(string(tmp.dnum, "zzzzzzzz9")) + "-" + 
                       STRING(DAY(tmp.date), "99")  + "-" + 
                       STRING(MONTH(tmp.date), "99")  + "-" + 
                       STRING(YEAR(tmp.date), "9999").

   run pnjletter (v-letnum, v-header, v-footer, "&nbsp;").

   create letters.
   assign letters.rwho = g-ofc
          letters.rdt = g-today
          letters.who = userid ("bank")
          letters.whn = today
          letters.bank = ourbnk
          letters.ref = string (tmp.dnum)
          letters.refdt = tmp.date
          letters.docnum = v-letnum
          letters.type = "pnjcas"
          letters.info[2] = tmp.info2
          letters.addr[10] = tmp.addr
          .

   run SET-SYSC-INT ("GCVPLT", v-letter).

   if tmp.kol = "" then tmp.kol = "1".
   else tmp.kol = STRING(INTEGER(tmp.kol) + 1).

   browse b1:refresh().

end.
    
for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = dat and p_f_payment.deluid = ? and
         p_f_payment.cod <> 400 no-lock:

   create tmp.
   buffer-copy p_f_payment to tmp.

   find first p_f_list where p_f_list.rnn = tmp.distr no-lock no-error.
   if avail p_f_list then tmp.pf-name = p_f_list.name.
                     else tmp.pf-name = ' '.

   for each letters where letters.ref = string(tmp.dnum) and letters.refdt = tmp.date and letters.type = "pnjcas" no-lock:
       accumulate letters.ref (count).
   end.
   tmp.kol = STRING (accum count (letters.ref)).
   if tmp.kol = '0' then tmp.kol = ''.

   tmp.name = trim(tmp.name).
   tmp.addr = tmp.chval[1].
   tmp.info2 = tmp.name.
   if num-entries (tmp.name, " ") = 3 then 
      assign tmp.info2 = entry (1, tmp.name, " ") + "," + entry (2, tmp.name, " ") + "," + entry (3, tmp.name, " ").
   else
   if num-entries (tmp.name, " ") = 2 then 
      assign tmp.info2 = entry (1, tmp.name, " ") + "," + entry (2, tmp.name, " ") + ", ".


   if length (trim (tmp.addr)) < 5 or tmp.addr = ? then do:
     find first rnn where rnn.trn = tmp.rnn no-lock no-error.
     if available rnn then do:
        tmp.addr = GTrim (
                   (if rnn.post1 = ? then "" else rnn.post1) + " " +
                   (if rnn.city1 = ? then "" else rnn.city1) + " " + 
                   (if rnn.street1 = ? then "" else rnn.street1) + " " +
                   (if rnn.housen1 = ? then "" else rnn.housen1) + " " +
                   (if rnn.apartn1 = ? then "" else rnn.apartn1)
                   ).
     end.          
     else do:      
        find first rnnu where rnnu.trn = tmp.rnn no-lock no-error.
        if available rnnu then do:
           tmp.addr = GTrim (
                   (if rnnu.post1 = ? then "" else rnnu.post1) + " " +
                   (if rnnu.city1 = ? then "" else rnnu.city1) + " " + 
                   (if rnnu.street1 = ? then "" else rnnu.street1) + " " +
                   (if rnnu.housen1 = ? then "" else rnnu.housen1) + " " +
                   (if rnnu.apartn1 = ? then "" else rnnu.apartn1)
                   ).
        end.          
     end.
   end.


   if tmp.name = '' or tmp.name = ? then do:
     find first rnn where rnn.trn = tmp.rnn no-lock no-error.
     if available rnn then do:
        if tmp.name = '' then assign tmp.name = CAPS (GTrim(rnn.lname + " " + rnn.fname + " " + rnn.mname))
                                     tmp.info2 = CAPS(GTrim(rnn.lname)) + "," + CAPS(GTrim(rnn.fname)) + "," + CAPS(GTrim(rnn.mname)).
        tmp.addr = GTrim (
                   (if rnn.post1 = ? then "" else rnn.post1) + " " +
                   (if rnn.city1 = ? then "" else rnn.city1) + " " + 
                   (if rnn.street1 = ? then "" else rnn.street1) + " " +
                   (if rnn.housen1 = ? then "" else rnn.housen1) + " " +
                   (if rnn.apartn1 = ? then "" else rnn.apartn1)
                   ).
     end.          
     else do:      
        find first rnnu where rnnu.trn = tmp.rnn no-lock no-error.
        if available rnnu then do:
           if tmp.name = '' then assign tmp.name = CAPS (GTrim(rnnu.fil + " " + rnnu.busname))
                                        tmp.info2 = REPLACE (CAPS (GTrim(rnnu.fil + " " + rnnu.busname)), ",", " ").
           tmp.addr = GTrim (
                   (if rnnu.post1 = ? then "" else rnnu.post1) + " " +
                   (if rnnu.city1 = ? then "" else rnnu.city1) + " " + 
                   (if rnnu.street1 = ? then "" else rnnu.street1) + " " +
                   (if rnnu.housen1 = ? then "" else rnnu.housen1) + " " +
                   (if rnnu.apartn1 = ? then "" else rnnu.apartn1)
                   ).
        end.          
     end.
   end. /* name = '' */

   if tmp.chval[1] = '' or tmp.chval[1] = ? then do:
     find first rnn where rnn.trn = tmp.rnn no-lock no-error.
     if available rnn then do:
        tmp.addr = GTrim (
                   (if rnn.post1 = ? then "" else rnn.post1) + " " +
                   (if rnn.city1 = ? then "" else rnn.city1) + " " + 
                   (if rnn.street1 = ? then "" else rnn.street1) + " " +
                   (if rnn.housen1 = ? then "" else rnn.housen1) + " " +
                   (if rnn.apartn1 = ? then "" else rnn.apartn1)
                   ).
     end.          
     else do:      
        find first rnnu where rnnu.trn = tmp.rnn no-lock no-error.
        if available rnnu then do:
           tmp.addr = GTrim (
                   (if rnnu.post1 = ? then "" else rnnu.post1) + " " +
                   (if rnnu.city1 = ? then "" else rnnu.city1) + " " + 
                   (if rnnu.street1 = ? then "" else rnnu.street1) + " " +
                   (if rnnu.housen1 = ? then "" else rnnu.housen1) + " " +
                   (if rnnu.apartn1 = ? then "" else rnnu.apartn1)
                   ).
        end.          
     end.
   end. /* name = '' */

   if trim(tmp.chval[2]) <> "" then
   tmp.addr = tmp.addr + ", тел: " + tmp.chval[2].

end.


open query q1 for each tmp by tmp.dnum.

ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.








