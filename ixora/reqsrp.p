/* reqsrp.p
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
     5.16.6
 * AUTHOR
        17/03/04 tsoy
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
def var fname      as cha .
def var v-tnum     as cha .
def var v-vdt as date format "99/99/99"       .
def stream main.
output stream main to req973srp.eks.

def var v-type as inte label "Тип Выписки" initial 970
            view-as radio-set vertical
            radio-buttons "МТ 970 ", 970, "МТ 971 ", 971, "МТ 974 ", 974.

def frame fr_main
            v-type skip
            with width 60 row 15 side-labels centered title "Тип запроса" .
on "return" of v-type in frame fr_main apply "go" to frame fr_main.


update v-type with frame fr_main.
hide frame fr_main.

v-vdt = g-today.

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
  v-text = "Нет записи BNKIIK в файле sysc".
  message v-text .
end.
v-bic  = trim(sysc.chval).                     
/* 900161414  */

find first sysc where sysc.sysc = "CLECOD" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи CLECOD в файле sysc".
  message v-text .
end.
v-acc  = trim(sysc.chval).                     
/* 190501914 */

put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                            "\{2:I973SCLEAR000000N2020" + "\}" skip
                            "\{4:" skip
                            ":20:TXB" + string(g-today,'99999999') + string(time) skip
                            ":12:" string (v-type)skip
                            ":25:190201125/" v-bic skip
                            "-}" skip.
output stream main close.

unix silent un-dos req973srp.eks req973srpd.eks.

v-unidir = v-ekshst + ":" + v-eksdir. 
/*v-unidir = "Txb-a1283:C:\\\\Distr\\\\". */

input through value ("rcp " + "req973srpd.eks" + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.

if v-result <> "0" then do:
  message skip " Произошла ошибка при копировании файла req973srp.eks в каталог" v-unidir "!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.
else
message "Запрос МТ 998 Успешно сфоримрован и импортирован в терминал" view-as alert-box.

unix silent value("rm req973srp.eks req973srpd.eks").
