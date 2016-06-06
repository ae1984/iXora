/* nostroac.p
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

/* nostroac.p */

{mainhead.i}

define variable fromd as date.
define variable tod as date.
define variable ggr like gl.gl.
define variable i as integer.
define variable sumd like jl.dam.
define variable sumc like jl.cam.
define variable vrate like aaa.rate.
define variable cifpss as character format "x(10)".
define buffer blgr for lgr.
define buffer baaa for aaa.
define buffer bsysc for sysc.

define variable tit  as character.
define variable lnum as integer.
define variable sub  as integer.

{image1.i rpt.img}

form ggr label "СчГК" fromd label "С " tod label " ПО " 
    with frame f no-box centered side-labels row 10.

find bsysc where bsysc.sysc eq "nostac" no-lock no-error.
    if not available bsysc then do:
        message "sysc.sysc = nostac  nav atrasts!" view-as alert-box.
        return.
    end.
find sysc where sysc.sysc eq "BEGDAY" no-lock.

again:
repeat:
    message bsysc.chval.
    update ggr with frame f.
    do i = 1 to num-entries(bsysc.chval):     
        if ggr eq integer (entry (i, bsysc.chval)) or ggr eq 0 then leave again.
    end.
end.    

if ggr eq 0 then do:
    sub  = 1.
    lnum = num-entries (bsysc.chval).
end.
else do:
    sub  = lookup (string (ggr), bsysc.chval).
    lnum = 1.
end.

update fromd validate (fromd ge sysc.daval, "Inform–cija b–zё no  " + 
    string(sysc.daval)) with frame f.
tod = g-today - 1.
update tod validate (tod ge fromd and tod lt g-today, "") with frame f.

{image2.i}
{notpage.i}
{report2.i 90}

tit = "СЧЕТ      НАИМЕНОВАНИЕ                  ВАЛЮТА                
ДЕБЕТ             КРЕДИТ". 
put tit format "x(120)" skip(1).

put substitute("С &1  ПО &2", string(fromd), string(tod)) format "x(30)"
    skip.

do i = 1 to lnum: 
    find gl where gl.gl eq integer (entry (sub ,bsysc.chval)) no-lock no-error.
        
        if not available gl then leave.
    put skip(2) entry (sub, bsysc.chval) "  " gl.des skip(1). 

    for each dfb where dfb.gl eq integer (entry (sub, bsysc.chval)) no-lock:
        find crc where crc.crc eq dfb.crc no-lock.
       /*
        find bank where bank.bank eq dfb.dfb no-lock no-error.
            if not available bank then next.
       */

        for each jl where jl.acc eq dfb.dfb and 
            (jl.jdt ge fromd and jl.jdt le tod) no-lock:

                if jl.dc eq "D" then sumd = sumd + jl.dam.
                else if jl.dc eq "C" then sumc = sumc + jl.cam.
        end.

        put dfb.dfb " " dfb.name " " crc.code "     " sumd " "
            sumc " " skip.
        sumd = 0.   sumc = 0.
    end.

    sub = sub + 1.
end.

{report3.i}
{image3.i}
/*output stream sloro close.*/
