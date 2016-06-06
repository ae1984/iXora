/* acltoda2.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       23.03.2005 sasco поменял поиск даты закрытия счета вместо aab на histrxbal
       04/05/2010 madiyar - перекомпиляция
*/

{global.i}
def var i as int.
def var j as int.
def var v-index as int.
def stream m-out.
def var dest as char.
def buffer b-aab for aab.

def var v-first as log.
def var v-type as log.
def var s-type as char.
def var v-okey as log.
def var v-dbeg as date.
def var v-dend as date.
def var v-name as char.

def var v-zakr as char.
def var v-valut as char.
def var v-sum as char.
def var v-expdt as char format 'x(9)'.
def var v-ofic as char.

def temp-table otl
    field str as char format "x(120)".
v-dbeg = g-today.
v-dend = g-today.

dest = "prit".
{acltoday.f}
/*
def var vappend as log format "Turpin–t/No jauna".
form "Turpin–t (T) vai No jauna (N) ?" vappend
format "Turpin–t/No jauna"
skip
     "Drukas komanda " dest format "x(40)" skip
     with row 4 no-box no-label centered frame image1.
*/


update vappend dest with frame image1.
{acltoday0.f}
/*
repeat :
display "Дата...  с " v-dbeg "  по " v-dend with frame cc row 14
column 30 no-label no-box.
update   v-dbeg v-dend with frame cc.
if v-dbeg <= v-dend and v-dend <= g-today then leave.
end.
*/
find ofc where ofc.ofc = g-ofc no-lock no-error.

    if vappend then output stream m-out to rpt.img append.
    else
    output stream m-out to rpt.img.
    {acltoday1.f}
    view stream m-out frame bab.
    hide frame bab.
{acltoday3.f}

for each cif where (s-type = " " or cif.type = s-type)
    no-lock break by cif.type by cif.cif:
    if first-of(cif.type) then do:
        v-type = no.
        v-okey = no.
        find ofc where ofc.ofc = g-ofc no-lock no-error.
        if ofc.expr[5] matches ( "*" + trim(cif.type) + "*") then v-okey = yes .
    end.
    if v-okey then do:
    v-first = yes.
    for each aaa where aaa.cif = cif.cif  no-lock :
        if aaa.sta = "C" and
        aaa.cltdt >= v-dbeg and aaa.cltdt <= v-dend and
        aaa.expdt > aaa.cltdt then do:
            if v-first then do:
                for each otl :
                    delete otl.
                end.
                v-first = no.
            end.
            create otl .
            find crc where crc.crc = aaa.crc no-lock no-error.
            otl.str = aaa.aaa.

            if aaa.cltdt = g-today then v-zakr  = string(aaa.cltdt).
            else do:
                 /* find last b-aab where b-aab.aaa = aaa.aaa
                    and b-aab.bal = 0  no-lock no-error. */
                 find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = aaa.aaa and histrxbal.lev = 1 no-lock no-error.
                 /* if available b-aab then v-zakr  = string(b-aab.fdt). */
                 /* if not avail histrxbal then next. */
                 if histrxbal.dam - histrxbal.cam = 0 then v-zakr = string (histrxbal.dt).
                                                      else v-zakr  = string (aaa.cltdt).
            end.
            v-expdt  = string(aaa.expdt).
            v-ofic  = substring(aaa.who,1,10).
            v-valut  = crc.code.
            /* find last aab where aab.aaa = aaa.aaa and aab.bal <> 0 no-lock no-error. */
            find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = aaa.aaa and histrxbal.lev = 1
                                      and histrxbal.dam <> histrxbal.cam no-lock no-error.
            /* v-sum = string(aab.bal). */
            v-sum = STRING (ABS (histrxbal.dam - histrxbal.cam)).
        end.
    end.
    if not v-first then do :
        v-type = yes.
        v-index = 0.
        for each otl :
            if v-index = 0 then do:
                v-name = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,61).
                otl.str =
                cif.cif + fill(" ",7 - length(cif.cif))
                + v-name + fill(" ",52 - length(v-name))
                + '   ' + substring(cif.type,1,1)
                + fill(" ",1 - length(cif.type)) + '   '
                + otl.str +     '        ' + v-valut
                + fill(" ",10 - length(v-sum))
                + '' + v-sum +  '   ' + v-zakr + '  '  + v-expdt.
            end.
            else do:
                if v-index <= 3 then do:
                    v-name = substring(trim(cif.addr[v-index]),1,61).
                    otl.str = fill(" ",7)
                    + v-name + fill(" ",52 - length(v-name))
                    + '   ' + substring(cif.type,1,1)
                    + fill(" ",1 - length(cif.type)) + '   '
                    + otl.str + '        ' + v-valut
                    + fill(" ",10 - length(v-sum))
                    + '' + v-sum + '   ' + v-zakr + '  ' + v-expdt.
                end.
                else otl.str = fill(" ",69)
                + '   ' + substring(cif.type,1,1)
                + fill(" ",1 - length(cif.type)) + '   '
                + otl.str +     '        ' + v-valut
                + fill(" ",10 - length(v-sum))
                + '' + v-sum + '   ' + v-zakr + '  ' + v-expdt.
            end.
            v-index = v-index + 1.
        end.
        repeat while v-index <= 3 :
            if cif.addr[v-index] = "" then leave .
            else do:
                create otl.
                otl.str = fill(" ",7) + cif.addr[v-index] .
            end.
            v-index = v-index + 1.
        end.
        for each otl :
            display stream m-out otl.str with no-label no-box width 132.
        end.
    end.
    if last-of(cif.type) and v-type
    then display stream m-out fill("-",120) format "x(120)"
    skip(5) with no-label no-box width 132.
    end.


    if i = j then do:
        display v-mess i with frame d no-label row 1 column 40.
        j = j + 100.
    end.
    i = i + 1.
    pause 0.
end.

output stream m-out close.
unix silent value(trim(dest)) rpt.img.
