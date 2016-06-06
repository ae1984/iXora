/* reqnull.p
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
        5.16.4
 * AUTHOR
        15/03/04 tsoy
 * CHANGES
        10/01/05 tsoy Изменил Дату 
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
def var v-bankname as cha .

def var v-amt as deci format "zzz,zzz,zzz.99" label "Сумма                ".
def var v-vdt as date format "99/99/99"       label "Дата Валютирования   ".
def var v-reqref as cha format "x(20)"        label "Референс             ".


def stream main.
output stream main to reqnull998.eks.

define frame dframe v-reqref         
                      help "Референс сообщения" 
                     validate(can-find(rrr where rrr.rrr = v-reqref), "Не существующий референс") skip
             WITH  SIDE-LABELS TITLE "Запрос на аннулировние параметра счета ".

v-vdt = today.

update v-reqref with centered overlay side-labels row 8 frame dframe.
hide frame dframe.

find rrr where rrr.rrr = v-reqref no-lock no-error .
if avail rrr then do:
    v-amt  = rrr.amt.
end.                          

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

find first cmp no-lock no-error.
v-bankname = caps(cmp.name).



put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                            "\{2:I998SDVR00000000U3003" + "\}" skip
                            "\{4:" skip
                            ":20:TXB" + string(g-today,'99999999') + string(time) skip
                            ":12:400" skip
                            ":77E:GOVERNMENT MSPD 250" skip
                            "/21/"  v-reqref skip 
                            "/DATE/"  substr(string(year(v-vdt)),3,2) string(month(v-vdt),"99") + string(day(v-vdt),"99") skip
                            "/52B/"v-acc skip
                            "/53C/190201125/"v-bic skip
                            "/NAME/"v-acc skip
                            v-bankname skip
                            "/P1/SET/KZT" replace(trim(string(v-amt, ">>>>>>>>>>>>9.99")),".",",")  skip
                            "/56B/190551138" skip
                            "-}" skip.
output stream main close.

unix silent un-dos reqnull998.eks reqnull998d.eks.

v-unidir = v-ekshst + ":" + v-eksdir. 
/*v-unidir = "Txb-a1283:C:\\\\Distr\\\\". */

input through value ("rcp " + "reqnull998d.eks" + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.

if v-result <> "0" then do:
  message skip " Произошла ошибка при копировании файла reqnull998d.eks в каталог" v-unidir "!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.
else
message "Запрос МТ 998 Успешно сфоримрован и импортирован в терминал" view-as alert-box.

unix silent value("rm reqnull998d.eks reqnull998.eks").
