/* new-ock.p
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

/* new-ock.p
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def var answer as log.
def shared var rtn as log initial yes.

{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

main:
do transaction on error undo, return:

            create ock.
            ock.ock = jl.acc.
            ock.rdt = g-today.
            ock.who = g-ofc.
            ock.gl = gl.gl.
            ock.crc = jl.crc.
            
            if jh.cif ne "" then do:
              find cif where cif.cif eq jh.cif.
              ock.payee = trim(trim(cif.prefix) + " " + trim(cif.name)).
            end.
            else ock.payee = jh.party.
            update ock.payee
                   ock.ref
                   ock.amt
                   ock.duedt  label "НАЧ.ДАТА" format "99/99/99"
                   ock.geo    format "x(3)" label "GEO"
                      validate(can-find(geo where geo.geo eq geo), "")
                   ock.zalog  label "ЗАЛОГ ?"
                   ock.lonsec label "ОБЕСП." 
                      validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
                      or ock.lonsec eq 0,"")
                   ock.risk   label "РИСК"
                      validate(can-find(risk where risk.risk eq risk) 
                      or ock.risk eq 0,"")
                   ock.penny  label "ШТРАФ,%" validate(penny <= 100, "") 
                   with centered row 9 3 col frame ock
                             title " Official Check " overlay.
             hide frame ock.
             pause 0.
end.

rtn = no.
