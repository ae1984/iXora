/* acctoday.p
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

{global.i}
def var m-sa as logical format "Все группы/Группа".
def var m-lgr like lgr.lgr.
def var i as int.
def var j as int.
def stream m-out.
def var m-d like glbal.bal.
def var m-c like glbal.bal.
def var dest as char.
def var vprint as log format "Да/Нет" init yes.
def var vappend as log format "Продолжать/Новый".
def var m-hslat like crchs.hs.
def var m-okey as log format "   /***".
def var m1-hs like crchs.hs.
m-hslat = "S". /* "твердость лата" */


dest = "prit".
{grupa.f}
update vappend vprint dest with frame image1.

if vprint then do:
    if vappend then output stream m-out to rpt.img append.
    else
    output stream m-out to rpt.img.
    {acctoday1.f}
    view stream m-out frame bab.
    hide frame bab.
end.
else output stream m-out to terminal.
{acctoday1.i}  
for each aaa no-lock:
    if aaa.regdt = g-today then do:
        m-okey = false.
        find cif where cif.cif = aaa.cif no-lock no-error.
        find crc where crc.crc = aaa.crc no-lock no-error.
        m1-hs = ?.
        find crchs where crc.crc = crchs.crc no-lock no-error.
        if available crchs then m1-hs = crchs.hs.
        if m1-hs = "L" then m1-hs = m-hslat.
        find first glbs where glbs.gl = aaa.gl and glbs.geo = cif.geo  and
        glbs.hs = m1-hs  no-lock no-error.
        if not available glbs then do:
            find first glbs where glbs.gl = aaa.gl and glbs.geo = cif.geo
            and glbs.hs = " " no-lock no-error.
                if available glbs then m-okey = true.
        end.
/*        else m-okey = true.  */
        
        display stream m-out aaa.aaa crc.code aaa.gl aaa.cif
        aaa.who aaa.sta with no-label no-box.
    end.
    if i = j then do:
        display "Обработка " i with frame d no-label row 1 column 50.
        j = j + 100.
    end.
    i = i + 1.
    pause 0.
end.

output stream m-out close.
if vprint then unix silent value(trim(dest)) rpt.img.
else pause.            
