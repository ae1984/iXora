/* mt111_1.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        отправка сообщения о переносе контракта из ЦО в Алм.фил.
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
        10/08/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        08/09/2010 galina - добавила "/" после ASFOUND и NRCOUNTRY
*/
{global.i}
def input parameter p-psnum as char.
def input parameter p-psdate as date.

def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".


/* путь к каталогу исходящих телеграмм */

find vcparams where vcparams.parcode = "mtpathou" no-lock no-error.
if not avail vcparams then do:
    message skip " Не найден параметр mtpathou !" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.
v-dir = vcparams.valchar.

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") + string(day(g-today), "99") + "/".
v-ipaddr = "Administrator@fs01.metrobank.kz".

/* проверка существования каталога за сегодняшнее число */
output to sendtest.
put "Ok".
output close .

input through value("scp -q sendtest " + v-ipaddr + ":" + v-dir + ";echo $?" ).
repeat :
    import v-exitcod.
end.

unix silent rm -f sendtest.


if v-exitcod <> "0" then do :
    message skip " Не найден каталог " + replace(v-dir, "/", "\\") skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

  /*находим ОКПО уполномоченного банка*/

{vcmsgparam_new.i &msg = "111"}
v-text = "/REPORTDATE/" + string(day(g-today),'99') + string(month(g-today),'99') + string(year(g-today),'9999').
put stream rpt unformatted v-text skip.

v-text = "/BANKOKPO/411511070002".
put stream rpt unformatted v-text skip.

v-text = "/OPER/2".
put stream rpt unformatted v-text skip.

v-text = "/PREVNUMBER/".
put stream rpt unformatted v-text skip.

v-text = "//PREVDATE/".
put stream rpt unformatted v-text skip.

v-text = "//PREVBANKOKPO/".
put stream rpt unformatted v-text skip.

v-text = "/PSNUMBER/" + p-psnum.
put stream rpt unformatted v-text skip.

v-text = "//PSDATE/" + string(day(p-psdate),'99') + string(month(p-psdate),'99') + string(year(p-psdate),'9999').
put stream rpt unformatted v-text skip.

v-text = "/NAME/".
put stream rpt unformatted v-text skip.

v-text = "/NAME/".
put stream rpt unformatted v-text skip.

v-text = "//OKPO/".
put stream rpt unformatted v-text skip.

v-text = "//RNN/".
put stream rpt unformatted v-text skip.

v-text = "//SIGN/".
put stream rpt unformatted v-text skip.

v-text = "//REGION/".
put stream rpt unformatted v-text skip.

v-text = "//PFORM/".
put stream rpt unformatted v-text skip.

v-text = "//EISIGN/".
put stream rpt unformatted v-text skip.

v-text = "/CONTRACT/".
put stream rpt unformatted v-text skip.

v-text = "//CDATE/".
put stream rpt unformatted v-text skip.

v-text = "//CURRENCY/".
put stream rpt unformatted v-text skip.

v-text = "//CSUMM/".
put stream rpt unformatted v-text skip.

v-text = "//CCURR/".
put stream rpt unformatted v-text skip.

v-text = "//CCLAUSE/".
put stream rpt unformatted v-text skip.

v-text = "//CCLAUSEDETAIL/".
put stream rpt unformatted v-text skip.

v-text = "//CLASTDATE/".
put stream rpt unformatted v-text skip.

v-text = "/NRNAME/".
put stream rpt unformatted v-text skip.

v-text = "//NRCOUNTRY/".
put stream rpt unformatted v-text skip.

v-text = "/TERM/".
put stream rpt unformatted v-text skip.

v-text = "/CODECALC/".
put stream rpt unformatted v-text skip.

v-text = "/ADDSHEET/".
put stream rpt unformatted v-text skip.

v-text = "//ASDATE/".
put stream rpt unformatted v-text skip.

v-text = "//ASFOUND/".
put stream rpt unformatted v-text skip.

v-text = "/CLOSEDATE/".
put stream rpt unformatted v-text skip.

v-text = "//CLOSEFOUND/".
put stream rpt unformatted v-text skip.

v-text = "/NOTE/".
put stream rpt unformatted v-text skip.
{vcmsgend.i &msg = "111"}

