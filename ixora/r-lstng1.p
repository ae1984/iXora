/* r-lstng1.p
 * MODULE
        Временная структура по депозитам на дату
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
        8-2-14-1
 * BASES
        BANK COMM
 * AUTHOR
        22/10/04 sasco

 * CHANGES
        11/02/05 marinav Сделан свод по филиалам в разбивке по срокам
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        15.07.08 marinav - добавились сроки 1-7 дней, 7-10 дней , 2-3 года, 3-5 лет
*/


define shared variable g-today as date.

define new shared variable v-dt as date.
define new shared variable v-dt0 as date.

define new shared temp-table depf 
           field gl like bank.gl.gl
           field des like bank.gl.des
           field fu as character 
           field v-name as character extent 11
           field v-name1 as character extent 11
           field v-name2 as character extent 11
           field v-name11 as character extent 11
           field v-name99 as character extent 11
           field v-summ1 as decimal extent 11
           field v-rate1 as decimal extent 11
           field v-summ1-cred as decimal extent 11
           field v-summ2 as decimal extent 11
           field v-rate2 as decimal extent 11
           field v-summ2-cred as decimal extent 11
           field v-summ11 as decimal extent 11
           field v-rate11 as decimal extent 11
           field v-summ11-cred as decimal extent 11
           field v-summ99 as decimal extent 11
           field v-rate99 as decimal extent 11
           field v-summ99-cred as decimal extent 11
           index idx_depf is primary gl.

v-dt = date(month(g-today), 1, year(g-today)).
if month(v-dt) = 1 then v-dt0 = date(12, 1, year(v-dt) - 1).
                   else v-dt0 = date(month(v-dt) - 1, 1, year(v-dt)).


update v-dt label  " Отчетная дата " 
  with side-label centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

unix silent value ("touch depos-crc-all.txt").
unix silent value ("touch depos-rate-all.txt").
unix silent value ("rm depos-crc-all.txt").
unix silent value ("rm depos-rate-all.txt").

for each comm.txb where comm.txb.consolid and comm.txb.visible no-lock:
    unix silent value ("touch depos" + comm.txb.bank + ".txt").
    unix silent value ("touch depos1" + comm.txb.bank + ".txt").
    unix silent value ("touch depos2" + comm.txb.bank + ".txt").
    unix silent value ("rm depos" + comm.txb.bank + ".txt").
    unix silent value ("rm depos1" + comm.txb.bank + ".txt").
    unix silent value ("rm depos2" + comm.txb.bank + ".txt").
end.

{r-brfilial.i &proc = "r-lstng1a"}

run r-lstng1b.
run r-lstng2.
