/* grupa.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{global.i}
def var m-sa as logical.
def var v-lgr like lgr.lgr.
def var i as int.
def var j as int.
def stream m-out.
def var m-d like glbal.bal.
def var m-c like glbal.bal.

def var m-limit as dec.
def var m-atl like glbal.bal.
def var m-atl10000 like glbal.bal.
def var m-count10000 as int.
def var m-rate as decimal.

def var dest as char.
def var vprint as log .
def var vappend as log .




dest = "prit".
{grupa.f}
update vappend vprint dest with frame image1.

if vprint then do:
    if vappend then output stream m-out to rpt.img append.
    else
    output stream m-out to rpt.img.
    {grupa1.f}
    view stream m-out frame bab.
    hide frame bab.
end.
else output stream m-out to terminal.

{grupa3.f}

if not m-sa then do:
    view frame bc.
    pause 0.
    update v-lgr  validate (can-find(lgr where v-lgr = lgr.lgr),"")
    with frame bc1 row 12 column 48 no-label no-box.
    hide frame bc1.
    hide frame bc.
end.

hide frame image1.
hide frame b.


view frame d1.
pause 0.
form header  i with frame d no-label no-box row 2 column 63 overlay.

if m-sa then do:

    for each aaa
    where aaa.sta <> "C"
    no-lock  break by lgr :
        if first-of(lgr) then do:
            m-atl10000 = 0.
            m-count10000 = 0.
            find crc where crc.crc = aaa.crc no-lock no-error.
            if available crc then m-rate = crc.rate[1] / crc.rate [9] .
            else m-rate = 0.
        end.
        m-atl = ( aaa.cr[1] - dr[1] ) * m-rate.
        if m-atl > m-limit then do:
            m-atl10000 = m-atl10000 + (aaa.cr[1] - aaa.dr[1]).
            m-count10000 = m-count10000 + 1.
        end.
        accumulate aaa.cr[1] (total by lgr).
        accumulate dr[1] (total count by lgr ).
        if last-of(lgr) then do:
                m-c =  accum total by lgr aaa.cr[1] .
                m-d =  accum total by lgr dr[1] .
                find crc where crc.crc = aaa.crc no-lock no-error.
                {grupa4.f}
        end.
        if i = j then do:
            hide frame d no-pause.
            view frame d.
            pause 0.
            j = j + 100.
        end.
        i = i + 1.
    end.
end.
else do:

    for each aaa where aaa.lgr = v-lgr and  aaa.sta <> "C"
    no-lock  break by lgr:
        if first-of(lgr) then do:
            m-atl10000 = 0.
            m-count10000 = 0.
            find crc where crc.crc = aaa.crc no-lock no-error.
            if available crc then m-rate = crc.rate[1] / crc.rate [9] .
            else m-rate = 0.
        end.
        m-atl = ( aaa.cr[1] - dr[1] ) * m-rate.
        if m-atl > m-limit then do:
            m-atl10000 = m-atl10000 + (aaa.cr[1] - aaa.dr[1]).
            m-count10000 = m-count10000 + 1.
        end.

        accumulate aaa.cr[1] (total by lgr).
        accumulate dr[1] (total count by lgr ).
        if last-of(lgr) then do:
                m-c =  accum total by lgr aaa.cr[1] .
                m-d =  accum total by lgr dr[1] .
                find crc where crc.crc = aaa.crc no-lock no-error.
                {grupa41.f}
        end.
        if i = j then do:
            hide frame d no-pause.
            view frame d .
            pause 0.
            j = j + 100.
        end.

        i = i + 1.
    end.
end.


output stream m-out close.
if vprint then unix silent value(trim(dest)) rpt.img.
else pause.
