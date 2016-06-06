/* setprm.p
 * MODULE
        МСПД
 * DESCRIPTION
        Заказ наличной валюты для филиалов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.9.1
 * AUTHOR
        15/03/04 tsoy
 * CHANGES
        09.04.04 tsoy Добавил тип текущего дня и следующего дня.
        27.07.05 kanat - поменял руководство
        20.02.06 u00571 - доюавлен вызов формы для выбора филиала. Данные выбираются из справочника spr_branch.
        28.02.06 u00571 - поменяла код MSPD: для Алматы -150, для филиалов - 250.
        02.03.06 u00571 - поменяла код MSPD везде на 150 (оказывается везде так надо было)
        09.06.06 sasco  - убрал case для выбора филиала
        17.07.09  marinav - изменение подписей
        22/07/2011 madiyar - для ЦО просто название банка
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        22.05.2012 aigul - поменяла ФИО буха
*/

{mainhead.i}
{nbankBik.i}
def new shared var v-text as cha format "x(78)" .

def var exitcod  as cha initial "" no-undo.
def var v-unidir as cha no-undo.
def var v-eksdir as cha no-undo.
def var v-ekscop as cha no-undo.
def var v-ekshst as cha no-undo.
def var v-result as cha no-undo.
def var v-bic      as cha no-undo.
def var v-acc      as int no-undo.
def var fname      as cha no-undo.
def var v-tnum     as cha no-undo.
def var v-bankname as cha no-undo.
def var v-ref as cha no-undo.
def var v-cmd as cha init "SET" no-undo.
/*def var v-filials as char.*/
def var v-select as integer no-undo.
def var f_77    as int no-undo.
def var f_nm    as char no-undo.
def var f_bikf  as char no-undo.
def var f_biknb as int no-undo.

def var v-amt as deci format "zzz,zzz,zzz.99" label "Сумма      " no-undo.
def var v-vdt as date format "99/99/99"       label "Дата Валютирования   " no-undo.

def var v-type as char label "Запрос     " initial "SET"
            view-as radio-set vertical
            radio-buttons "Текущий", "UPD", "Следующий", "SET".

def stream main.
output stream main to mt998400P1.eks.

/*for each txb where txb.consolid no-lock:
  if v-filials <> "" then v-filials = v-filials + " | ".
  v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
end.*/

v-select = 0.

run sel_br (" ВЫБЕРИТЕ ФИЛИАЛ БАНКА ", /*v-filials,*/ output v-select).

if v-select = 0 then return.

find spr_branch where id = v-select no-lock no-error.
if not avail spr_branch then return.

v-acc = spr_branch.bik.
if spr_branch.txb = "TXB00" then v-bankname = v-nbankru.
else v-bankname = spr_branch.name + " " + v-nbankru.
f_biknb = spr_branch.bik_nb.

define frame dframe v-amt
                        help "Cумма денежных средств, используемых для осуществления платежей в МСПД" skip
                    v-type
             WITH  SIDE-LABELS TITLE "Запрос на установку параметра счета ".
on "return" of v-type in frame dframe apply "go" to frame dframe.

v-vdt = g-today.

update v-amt  v-type with centered overlay side-labels row 8 frame dframe.
hide frame dframe.

if v-type = "SET" then
    v-cmd = "SET".
else
    v-cmd = "UPD".

find sysc where sysc.sysc = "lbHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
   message v-text .
end.
v-ekshst = sysc.chval .

find sysc where sysc.sysc = "lbeks" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:

v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
  message v-text .
end.
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
/*v-acc  = trim(sysc.chval).                     */
/* 190501914 */

/*find first cmp no-lock no-error.
v-bankname = caps(cmp.name).*/

v-ref= "MKB" + string(g-today,'99999999') + string(time).

put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                            "\{2:I998SDVR00000000U3003" + "\}" skip
skip "\{4:" skip
      ":20:" v-ref skip
      ":12:400" skip
      ":77E:GOVERNMENT MSPD " 150 skip
      "/DATE/"  substr(string(year(v-vdt)),3,2) string(month(v-vdt),"99") + string(day(v-vdt),"99") skip
      "/52B/470" skip
      "/53C/125/"v-bic skip
      "/NAME/"v-acc skip
      v-bankname skip
      "/FM/Милютина" skip
      "/NM/Ирина" skip
      "/FT/Борисовна" skip
      "/CT/000297926" skip
      "/P1/" v-cmd "/KZT" replace(trim(string(v-amt, ">>>>>>>>>>>>9.99")),".",",")  skip
      "/56B/"f_biknb skip
      "/CHIEF/Андроникашвили Г." skip
      "/MAINBK/Оспанова Г. А." skip
      "-}" skip.
output stream main close.


fname = 'mt998400P1.' + string(time).

unix silent un-dos mt998400P1.eks value(fname).
/*unix silent cptwin mt998400P1.eks winword.*/

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

v-unidir = v-ekshst + ":" + v-ekscop.
message v-unidir. pause .
input through value ("scp -q " + fname + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.


v-unidir = v-ekshst + ":" + v-eksdir.
message v-unidir. pause .
input through value ("scp -q " + fname + " " + v-unidir + " ;echo $?" ).
repeat:
  import v-result.
end.
pause 0.

if v-result <> "0" then do:
  message skip " Произошла ошибка при копировании файла mt998400P1d.eks в каталог" v-unidir "!"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.
else do:
      message "Запрос МТ 998 Успешно сформирован и импортирован в терминал" view-as alert-box.
      create rrr.
      assign
          rrr.rrr = v-ref.
          rrr.vdt = v-vdt.
          rrr.amt = v-amt.
end.

/*
unix silent value("rm mt998400P1d.eks mt998400P1.eks").
*/

