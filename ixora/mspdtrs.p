/* mspdtrs.p
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
        5.16.2 
 * AUTHOR
        15/03/04 tsoy
 * CHANGES
*/

{mainhead.i}

def new shared var v-text as cha format "x(78)" .

def var exitcod  as cha initial "" . 
def var v-unidir as cha .
def var v-eksdir as cha . 
def var v-ekscop as cha .
def var v-ekshst as cha .
def var v-result as cha .
def var v-bic      as cha .
def var v-acc      as cha .
def var v-tnum     as cha .
def var v-bankname as cha .
def var v-title    as cha .
def var fname      as cha no-undo.

def var v-amt as deci format "zzz,zzz,zzz.99" label "Сумма                ".
def var v-vdt as date format "99/99/99"       label "Дата Валютирования   ".

def stream main.
output stream main to mt998200trs.eks.

def var v-type as char label "Тип Клиентов" initial "C"
            view-as radio-set vertical
            radio-buttons "С кор.счета НБРК на счет в МСПД ", "C", "С счета в МСПД на кор.счет в НБРК", "D".

def frame fr_main
            v-type skip
            with width 60 row 15 side-labels centered title "Параметры запроса" .
on "return" of v-type in frame fr_main apply "go" to frame fr_main.

view frame fr_main.
   update v-type with frame fr_main.
hide frame fr_main.

if v-type = "C" then
    v-title = "С кор.счета НБРК на счет в МСПД".
else
    v-title = "С счета в МСПД на кор.счет в НБРК".


define frame dframe v-amt      
                      help "Cумма МСПД" skip
                    v-vdt
                      help "Дата      " 
             WITH  SIDE-LABELS TITLE v-title.

v-vdt = g-today.

update v-amt  v-vdt with centered overlay side-labels row 8 frame dframe.
hide frame dframe.

find sysc where sysc.sysc = "lbHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
   message v-text .
end.                          
v-ekshst = sysc.chval .
/* ntmain */


find sysc where sysc.sysc = "lbeks" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
  message v-text .
end.

/* L:/capital/develop/TERMINAL/ */


v-text = sysc.chval.
if substr(v-text, length(v-text), 1) <> "\/" then v-text = v-text + "/".

v-eksdir = v-text + "IN/" . 
v-ekscop = v-text + "TRANSIT/" + 
           substr(string(year(g-today),"9999"),3,2) + "-" + 
           string(month(g-today),"99") + "-" + 
           string(day(g-today),"99") + "/OUT/".

find first sysc where sysc.sysc = "lbterm" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи lbterm в файле sysc".
  message v-text .
end.
v-tnum = trim(sysc.chval).                     
/* F01K059140000000000000000 */

find first sysc where sysc.sysc = "BNKIIK" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи lbterm в файле sysc".
  message v-text .
end.
v-bic  = trim(sysc.chval).                     
/* 900161414  */

find first sysc where sysc.sysc = "CLECOD" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи lbterm в файле sysc".
  message v-text .
end.
v-acc  = trim(sysc.chval).                     
/* 190501914 */

find first cmp no-lock no-error.
v-bankname = caps(cmp.name).

put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                            "\{2:I998SDVR00000000U3003" + "\}" skip
      "\{4:" skip
      ":20:MKB" + string(g-today,'99999999') + string(time) skip
      ":12:200" skip
      ":77E:" skip
      "/DATE/" substr(string(year(v-vdt)),3,2) string(month(v-vdt),"99") + string(day(v-vdt),"99") + replace(string(time, "HH:MM"),":","") skip
      "/REQUESTER/NBRKKZKX/" + v-bic skip
      "/ACCOUNT/NBRKKZKX/KZ75125KZT1002100100"  skip
      "/P1/UPDATE/" v-type "KZT" replace(trim(string(v-amt, ">>>>>>>>>>>>9.99")),".",",")  skip
      "-}" skip.
output stream main close.

fname = 'mt998200trs.' + string(time).
unix silent un-dos mt998200trs.eks value(fname).

           output to sendtest.
              put "Ok".
           output close .
         
           Message " Send test ..... " .
           input through value("scp -q sendtest " + v-ekshst + ":" + v-ekscop + ";echo $?" ). 
           repeat :
               import exitcod .
           end .

           if exitcod <> "0" then do :
               unix silent  value("ssh " + v-ekshst + " mkdir"  +  " c:\\\\capital\\\\TERMINAL\\\\TRANSIT\\\\" + 
                          substr(string(year(g-today),"9999"),3,2) + "-" + 
                          string(month(g-today),"99") + "-" + 
                          string(day(g-today),"99") + "\\\\OUT").
           end .


v-unidir = v-ekshst + ":" + v-eksdir. 

input through value ("scp -q " + fname + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.


v-unidir = v-ekshst + ":" + v-ekscop. 

message v-unidir . pause.
input through value ("scp -q " + fname + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.


if v-result <> "0" then do:
  message skip " Произошла ошибка при копировании файла " fname " в каталог" v-unidir "!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.
else
message "Запрос МТ 998 Успешно сфоримрован и импортирован в терминал" view-as alert-box.


unix silent value("rm mt998200trs.eks " + fname).
  