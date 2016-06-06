/* pkrefprc.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Автоматическое доначисление процентов при рефинансировании
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
        11/12/2006 madiyar
 * BASES
        bank
 * CHANGES
        23/04/2007 madiyar - добавил из новой библиотеки
        10/10/2008 madiyar - убрал все лишнее
        21/10/2008 madiyar - доначисляем %% за текущий месяц + два месяца вперед (если есть по графику)
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит lon0061
*/

{global.i}

def input parameter v-lon as char no-undo.
def output parameter v-errcode as integer no-undo.
def output parameter v-errmsg as char no-undo.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).


def new shared var s-jh like jh.jh.
def var v-param as char.
def var rcode as int.
def var rdes as char.
def var vdel as char initial "^".
def var v-rnn as char no-undo.
def var v-name as char no-undo.
def var v-spnpl as char no-undo.

v-errcode = 100.
v-errmsg = " Рефинансирование: недокументированная ошибка при доначислении процентов ".

find first lon where lon.lon = v-lon no-lock no-error.
if not avail lon then do:
    v-errcode = 1.
    v-errmsg = " Рефинансирование: ошибка при доначислении процентов ~n Не найден ссудный счет ".
    return.
end.

def var v-bal as deci no-undo.

run lonbalcrc('lon',lon.lon,g-today,"1,7,2,9,4,16,5",yes,lon.crc,output v-bal).
if v-bal <= 0 then do:
    v-errcode = 2.
    v-errmsg = " Рефинансирование: ошибка при доначислении процентов ~n Рефинансируемый кредит погашен ".
    return.
end.

run lonbalcrc('lon',lon.lon,g-today,"4,5,7,9,16,13,14,30",yes,lon.crc,output v-bal).
if v-bal > 0 then do:
    v-errcode = 3.
    v-errmsg = " Рефинансирование: ошибка при доначислении процентов ~n Рефинансируемый кредит имеет просрочки ".
    return.
end.

find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
if not avail lnsci then do:
    v-errcode = 6.
    v-errmsg = " Рефинансирование: ошибка при доначислении процентов ~n Отсутствуют или некорректные графики ".
    return.
end.

def var v-prc as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-dt as date no-undo.

def var dat_wrk as date no-undo.
find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

v-prc = 0.

find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.


/* %% за 3 месяца */
v-dt = ?.
find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
if avail lnsci then v-dt = lnsci.idat.
find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
if avail lnsci then v-dt = lnsci.idat.
find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
if avail lnsci then v-dt = lnsci.idat.

if v-dt = ? then do:
    v-errcode = 7.
    v-errmsg = " Рефинансирование: ошибка при доначислении процентов ~n Отсутствуют будущие платежи по графику %% ".
    return.
end.

for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= v-dt no-lock:
    v-prc = v-prc + lnsci.iv-sc.
end.
run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal).
v-prc = v-prc - v-bal.
for each lnsci where lnsci.lni = lon.lon and lnsci.flp > 0 no-lock:
    v-prc = v-prc - lnsci.paid.
end.


if v-prc < 0 then v-prc = 0.

if v-prc > 0 then do:

    v-rnn = ''. v-name = ''.
    find first cif where cif.cif = lon.cif no-lock no-error.
    if avail cif then assign v-rnn = trim(cif.jss) v-name = trim(cif.name).
    if lon.gl = 141120 then v-spnpl = "421". else v-spnpl = "423".
    /*v-param = string(v-prc) + vdel +
              lon.lon + vdel +
              "1" + vdel +
              "9" + vdel +
              v-spnpl + vdel +
              "Рефинансирование - доначисление %%, РНН " + v-rnn + " " + v-name + vdel +
              "" + vdel +
              "" + vdel +
              "" + vdel +
              "".*/
    if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel + "1" + vdel + "9" + vdel + v-spnpl + vdel +
          string(v-prc) + vdel + lon.lon + vdel + "Рефинансирование - доначисление %%, РНН " + v-rnn + " " + v-name + vdel +
          "" + vdel + "" + vdel + "" + vdel + "".
    else v-param = string(v-prc) + vdel + lon.lon + vdel + "1" + vdel + "9" + vdel + v-spnpl + vdel +
          "0" + vdel + lon.lon + vdel + "Рефинансирование - доначисление %%, РНН " + v-rnn + " " + v-name + vdel +
          "" + vdel + "" + vdel + "" + vdel + "".
    run trxgen ("lon0061", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        v-errcode = rcode.
        v-errmsg = rdes.
        message rdes.
        pause.
        undo, return.
    end.
    run lonresadd(s-jh).

end. /* if v-prc > 0 */

v-errcode = 0.
v-errmsg = ''.

