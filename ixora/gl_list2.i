/* gl_list2.i
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
        28.10.10 marinav - добавили 8 класс
        26/07/2011 madiyar - добавили 9 класс
        30.11.2012 Lyubov - добавлена группа 185899 в список, ТЗ 1374 от 23/05/2012 «Изменение счета ГК 1858»
        04.12.2012 Lyubov - исправлена ошибка, для MAX_COL значение по умолчанию 12
*/

def buffer c-gl for gl.

def temp-table tlist
field type like gl.type
field child like gl.gl
field nm like gl.des
field parent like gl.gl
field lev as int
field used as int.

def var l as int init 0.
def var MAX_COL as int init 12.
def var i as int init 1.
def var strList as char init "199990,185899,299990,399990,499990,599990,649990,699990,749990,799990,899990,999990".
def buffer c2-gl for gl.

function GetList returns int (num as int) forward.

do while i <= MAX_COL:
    for each gl where gl.totgl = int(entry(i, strList)):

   find tlist where tlist.child =  gl.totgl no-lock no-error.
   if not available tlist then  do:
    find c2-gl where c2-gl.gl =  gl.totgl  no-lock no-error.
        create tlist.
        tlist.child = c2-gl.gl.
        tlist.nm = c2-gl.des.
        tlist.parent = c2-gl.totgl.
        tlist.lev = 0.

   end.
        create tlist.
        tlist.child = gl.gl.
        tlist.nm = gl.des.
        tlist.parent = gl.totgl.
        tlist.lev = 0.
        GetList(gl.gl).
    end.
    i = i + 1.
end.

function GetList returns int (num as int).
    def var c as int.
    for each c-gl where c-gl.totgl = num:
        create tlist.
        tlist.child = c-gl.gl.
        tlist.nm = c-gl.des.
        tlist.parent = c-gl.totgl.
        tlist.lev = c-gl.totlev.
        if c-gl.totlev = 1 then do:
            find first jl where jl.gl = c-gl.gl no-lock no-error.
            if available jl then do:
                tlist.used = 1.
            end.
        end.
        GetList(c-gl.gl).
    end.
    return 0.
end.

