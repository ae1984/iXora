/* pmppflt.p
 * MODULE
        Социальные платежи
 * DESCRIPTION
        Формирование писем возврата социальных платежей клиенту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
     5.9.14.5
 * AUTHOR
     31/03/2003 kanat
 * CHANGES
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
update dat label "Введите дату" with centered side-label frame fdat.
hide frame fdat.

define variable v-letnum as character.
define variable v-header as character.
define variable v-footer as character.
define variable v-letter as integer.

find sysc where sysc.sysc = "GCVPLC" no-lock no-error.
if not available sysc then v-letter = 0.
else v-letter = sysc.inval.

define temp-table tmp like commonpl
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
        tmp.sum format ">>>>>>>>9.99" label "Сумма"
        tmp.comsum format ">>>>>9.99" label "Ком"
        tmp.sum + tmp.comsum format ">>>>>>>>9.99" label
        "Всего"                
         with 14 down title "Платежи" no-labels. 

DEFINE BUTTON bedt LABEL "См./Изм.".        
DEFINE BUTTON blet LABEL "Письмо-Возврат".

define variable pf-name as character.
define variable pl-name as character.

define frame sf 
               tmp.rnn     label "РНН" format "x(12)" skip
               tmp.fio     label "ФИО/Наименование" format "x(50)" skip
               tmp.addr    label "Адрес" format "x(50)" skip
               tmp.kol     label "Кол-во писем" format "x(2)" skip
               "--------------------------------------------------" skip(1)
               tmp.rnnbn   label "РНН П/Фонда (F2 - выбор)" format "x(12)" skip
               tmp.pf-name no-label format 'x(50)' view-as text skip
               "--------------------------------------------------" skip(1)
               tmp.sum     label "Сумма" format ">>>>>>9.99" 
               tmp.z       label "Кол-во" 
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
         tmp.fio
         tmp.addr
         tmp.kol
         tmp.pf-name
         tmp.rnnbn
         tmp.sum
         tmp.z
         with frame sf.
   pause.

   hide frame sf. pause 0.
    
end.


ON CHOOSE OF blet in frame f1
do:
   if not available tmp then leave.
   if not yes-no ('', 'Вывести письмо?') then leave.

   v-header = 'Отправитель денег: <b>' + REPLACE (tmp.fio, "ТР СЧ ", "") + ' </b><br>' +
              'РНН : <b> ' + tmp.rnn + ' </b> <br>' +
              'Адрес: <b> ' + tmp.addr + ' </b> <br>'.

   v-footer = "Некорректный реестр социальных отчислений или неправильные реквизиты получателя".

   run savelog ("pmpletter", "Формирование письма для tmp N " + string(tmp.dnum) + " / " + string(tmp.date) + tmp.rnnbn).

   v-letter = v-letter + 1.
   v-letnum = "РР1-" + TRIM(STRING(v-letter, "zzzzzzzz9")) + "-" + TRIM(string(tmp.dnum, "zzzzzzzz9")) + "-" + 
                       STRING(DAY(tmp.date), "99")  + "-" + 
                       STRING(MONTH(tmp.date), "99")  + "-" + 
                       STRING(YEAR(tmp.date), "9999").

   run pmpletter (v-letnum, v-header, v-footer, "&nbsp;").

   create letters.
   assign letters.rwho = g-ofc
          letters.rdt = g-today
          letters.who = userid ("bank")
          letters.whn = today
          letters.bank = ourbnk
          letters.ref = string (tmp.dnum)
          letters.refdt = tmp.date
          letters.docnum = v-letnum
          letters.type = "pmpcas"
          letters.info[2] = tmp.info2
          letters.addr[10] = tmp.addr.

   run SET-SYSC-INT ("GCVPLC", v-letter).

   if tmp.kol = "" then tmp.kol = "1".
   else tmp.kol = STRING(INTEGER(tmp.kol) + 1).

   browse b1:refresh().

end.
    
for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.deluid = ? and commonpl.grp = 15 no-lock:

   create tmp.
   buffer-copy commonpl to tmp.

   find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and commonls.type = commonpl.type and 
                             commonls.arp = commonpl.arp no-lock no-error.
   if avail commonls then tmp.pf-name = commonls.bn.
                     else tmp.pf-name = ' '.

   for each letters where letters.ref = string(tmp.dnum) and letters.refdt = tmp.date and letters.type = "pmpcas" no-lock:
       accumulate letters.ref (count).
   end.
   tmp.kol = STRING (accum count (letters.ref)).
   if tmp.kol = '0' then tmp.kol = ''.

   tmp.fio = trim(tmp.fio).
   tmp.addr = tmp.adr.
   tmp.info2 = tmp.fio.
   if num-entries (tmp.fio, " ") = 3 then 
      assign tmp.info2 = entry (1, tmp.fio, " ") + "," + entry (2, tmp.fio, " ") + "," + entry (3, tmp.fio, " ").
   else
   if num-entries (tmp.fio, " ") = 2 then 
      assign tmp.info2 = entry (1, tmp.fio, " ") + "," + entry (2, tmp.fio, " ") + ", ".


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


   if tmp.fio = '' or tmp.fio = ? then do:
     find first rnn where rnn.trn = tmp.rnn no-lock no-error.
     if available rnn then do:
        if tmp.fio = '' then assign tmp.fio = CAPS (GTrim(rnn.lname + " " + rnn.fname + " " + rnn.mname))
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
           if tmp.fio = '' then assign tmp.fio = CAPS (GTrim(rnnu.fil + " " + rnnu.busname))
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

/*
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
   end.*/ /* name = '' */

   if trim(tmp.chval[4]) <> "" then
   tmp.addr = tmp.addr + ", тел: " + tmp.chval[4].

end.


open query q1 for each tmp by tmp.dnum.

ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.








