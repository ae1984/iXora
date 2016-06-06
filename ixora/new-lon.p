/* new-lon.p
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
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* new-lon.p
*/

def shared var rtn as log initial yes.
def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def var answer as log.
def var fv as cha.
def var inc as int.
{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

main:
do transaction on error undo, return:
            create lon.
            lon.lon = s-acc.
            lon.rdt = g-today.
            lon.who = g-ofc.
            {subadd-pc.i  &sub = "lon"}
            lon.gl  = s-gl.
            lon.crc = jl.crc.
            if lon.crc eq 1 then lon.basedy = 365.
            else if lon.crc eq 2 then lon.basedy = 360.
            /* lon.basedy = g-basedy. */
            lon.acrdt = ?.
            if gl.grp ne 0
              then do:
                lon.grp = gl.grp.
                display lon.grp with frame loan.
              end.
              else update lon.grp with frame loan.
            if jh.cif ne ""
              then do:
                lon.cif = jh.cif.
                display lon.cif with frame loan.
              end.
              else update lon.cif with frame loan.
            /* vcif = lon.cif.  */
            update lon.lcr
                   lon.opnamt
                   lon.rdt
                   lon.duedt
                   lon.base lon.prem
                   lon.basedy
                   lon.apr lon.gua
                   lon.loncat
                   with centered row 7 1 col frame loan
                        title " LOAN LEDGER "
                   editing: {gethelp.i}  end.
end.

rtn = no.
