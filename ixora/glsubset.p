/* glsubset.p
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

/*

   glsetmain.p <-- glsubset.p
   Joon.  March 11, 1993
*/

{mainhead.i GLFILE}

def new shared var vtot like jl.dam extent 12.
def new shared var vavg like jl.dam extent 12.
def new shared var vttl  like jl.dam.
def new shared var vtavg like jl.dam.
def new shared var vyst  like jl.dam.
def new shared var vydr like vyst.
def new shared var vycr like vyst.
def new shared var vmst like vyst.
def new shared var vmdr like vyst.
def new shared var vmcr like vyst.
def new shared var vtst like vyst.
def new shared var vtdr like vyst.
def new shared var vtcr like vyst.
def new shared var vtbl like vyst.
def buffer b-gl for gl.

{main.i
 &option    = "GL"
 &head      = "gl"
 &headkey   = "gl"
 &framename = "gl"
 &formname  = "gl"
 &findcon   = "true"
 &addcon    = "true"
 &start     = " "
 &clearframe = " "
 &viewframe  = " "
 &prefind    = " "
 &postfind   = " "
 &numprg     = "prompt"
 &preadd     = " "
 &postadd    = " "
 &subprg     = "glsetsub"
 &end        = " "
}
