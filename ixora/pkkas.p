/* pkkas.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Генерация проводки выдачи кредита в кассе
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
        24/04/2007 madiyar
 * BASES
        bank, comm
 * CHANGES
        11/10/2007 madiyar - все ордера попадают в один документ
        01.02.2012 lyubov - изменила символ кассплана (450 на 290)
*/

{global.i}
{pk.i}

define new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v-tmpl as char no-undo.
def var v-dog as char no-undo.
def var v-glrem as char no-undo.
def var v-file as char no-undo.
def new shared var v_doc as char.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

find first lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then return.

v-dog = ''.
find first loncon where loncon.lon = lon.lon no-lock no-error.
if avail loncon then v-dog = loncon.lcnt.

find first aaa where aaa.aaa = pkanketa.aaa no-lock no-error.
if not avail aaa then return.

if pkanketa.sumq <= 0 then return.

if aaa.cr[1] - aaa.dr[1] < pkanketa.sumq then return.

v-glrem = "Выплата по Договору займа N " + v-dog.

do transaction:
    v-tmpl = "jou0016".
    v-param = "" + vdel +
              string(pkanketa.sumq) + vdel +
              "1" + vdel + /* валюта */
              pkanketa.aaa + vdel +
              v-glrem + vdel +
              "321" + vdel + /* код назначения платежа */
              string(0) + vdel + /* сумма с 9го уровня */
              "1". /* валюта */.

    s-jh = 0.
    run trxgen (v-tmpl, vdel, v-param, "cif", pkanketa.aaa, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message rdes.
        pause 1000.
        next.
    end.

    run jou. /* создадим jou-документ */
    v_doc = return-value.
    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v_doc.

    if jh.sts < 5 then jh.sts = 5.
    for each jl of jh:
        if jl.sts < 5 then jl.sts = 5.
    end.
    find current jh no-lock.

    run setcsymb (s-jh, 290). /* проставим символ кассплана */
end. /* transaction */


def new shared var v-point like point.point.
find jh where jh.jh = s-jh no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.

run vou_bank_n(0).
v-file = "/var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/oporderp.htm".
unix silent value("echo '<pre>' >> " + v-file + ";cat vou.img >> " + v-file + ";echo '</pre>' >> " + v-file).
unix silent value("chmod 666 " + v-file).

