/* l-prt.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Печать Ваучера , верхнее меню -  2lon
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
	5-9-3
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
	19.03.2003 sasco - ордер не печатается для полочек x-name, x-pref  если была вторая проводка на тот же счет, который указан в REMTRZ
        12/08/04 kanat убрал печать ордеров в ваучере для филиала в г. Уральск
        26/08/04 kanat переделал запрос по г. Уральск
	21/10/04 u00121 перекомпиляция в связи с добавлением коментария в том месте, где kanat вносил изменения от 12/08/04
    12.03.2012 damir - добавил формирование операционных ордеров в WORD,printvouord...
*/

{comm-txb.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def new shared  var s-jh like jh.jh .
def shared var s-remtrz like remtrz.remtrz .
def var ans as log format "да/нет".
def var vcash as log.
def var seltxb as int.

seltxb = comm-cod().

find first remtrz where remtrz.remtrz = s-remtrz no-lock .

Message " Вы уверены ? " update ans.

if ans then do transaction :
    find first remtrz where remtrz.remtrz = s-remtrz no-lock .

    s-jh = remtrz.jh2.

    /* если мы не на полочке x-name, x-pref, то печать ордера  */
    /*(u00121 21/10/04) 12/08/04 kanat убрал печать ордеров в ваучере для филиала в г. Уральск  seltxb <> 2 (код Уральска в Прагме)*/

    if  remtrz.rsub <> "x-name" and remtrz.rsub <> "x-pref" then do:
        if v-noord = no then run x-jlvou2.
        else run printvouord(2).
    end.
    else do:
        /* если зачислили не на счет из платежки, или это филиал, то печать ордера */
        if v-noord = no then run x-jlvou2.
        else run printvouord(2).
    end.

    find first jh where jh.jh = remtrz.jh2 no-error.

    find sysc where sysc.sysc = "CASHGL" no-lock no-error.
    vcash = false .

    for each jl of jh :
        if jl.gl = sysc.inval then vcash = true.
    end.

    if vcash then do :
        for each jl of jh exclusive-lock .
            jl.sts = 5 .
        end .
        jh.sts = 5.
    end .
    else do:
        for each jl of jh exclusive-lock .
            jl.sts = 6 .
        end .
        jh.sts = 6.
    end.
end.
