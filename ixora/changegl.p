/* changegl.p
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
       25/07/2007 madiyar - убрал ссылки на удаленные таблицы
*/

/* changegl.p */

def new shared temp-table tempmk
    field ngl     like gl.gl
    field ngl1    like gl.gl1
    field nrevgl  like gl.revgl
    field nautogl like gl.autogl
    field ntotgl like gl.totgl
    field nibfgl  like gl.ibfgl
    field ogl like gl.gl
    field ogl1    like gl.gl1
    field orevgl  like gl.revgl
    field oautogl like gl.autogl
    field ototgl like gl.totgl
    field oibfgl  like gl.ibfgl.

input from cgl.dat.
repeat:
  create tempmk.
  set ogl ototgl ogl1 oautogl orevgl oibfgl
      ngl ntotgl ngl1 nautogl nrevgl nibfgl.
end.
input close.

do transaction:

for each gl:
  find first tempmk where tempmk.ogl eq gl.gl no-lock no-error.
  if available tempmk then do:
    gl.gl = tempmk.ngl.
    gl.gl1 = tempmk.ngl1.
    gl.revgl = tempmk.nrevgl.
    gl.autogl = tempmk.nautogl.
    gl.totgl = tempmk.ntotgl.
    gl.ibfgl = tempmk.nibfgl.
  end.
end.
/*
for each tempmk:
  find gl where gl.gl eq tempmk.ogl.
  if availble gl then do:
     gl.gl = tempmk.ngl.
     gl.gl1 = tempmk.ngl1.
     gl.revgl = tempmk.nrevgl.
     gl.autogl = tempmk.nautogl.
     gl.totgl = tempmk.ntotgl.
     gl.ibfgl = tempmk.nibfgl.
  end.
end.
*/
for each glday:
  find first tempmk where tempmk.ogl eq glday.gl no-lock no-error.
  if available tempmk then glday.gl = tempmk.ngl.
  end.

for each gltot:
  find first tempmk where tempmk.ogl eq gltot.gl no-lock no-error.
  if available tempmk then gltot.gl = tempmk.ngl.
  end.

for each aaa:
  find first tempmk where tempmk.ogl eq aaa.gl no-lock no-error.
  if available tempmk then aaa.gl = tempmk.ngl.
  end.

for each ast:
  find first tempmk where tempmk.ogl eq ast.gl no-lock no-error.
  if available tempmk then ast.gl = tempmk.ngl.
  end.

for each bank:
  find first tempmk where tempmk.ogl eq bank.gl no-lock no-error.
  if available tempmk then bank.gl = tempmk.ngl.
  end.

for each bill:
  find first tempmk where tempmk.ogl eq bill.gl no-lock no-error.
  if available tempmk then bill.gl = tempmk.ngl.
  end.

for each dfb:
  find first tempmk where tempmk.ogl eq dfb.gl no-lock no-error.
  if available tempmk then dfb.gl = tempmk.ngl.
  end.

for each eck:
  find first tempmk where tempmk.ogl eq eck.gl no-lock no-error.
  if available tempmk then eck.gl = tempmk.ngl.
  end.

for each eps:
  find first tempmk where tempmk.ogl eq eps.gl no-lock no-error.
  if available tempmk then eps.gl = tempmk.ngl.
  end.

for each fun:
  find first tempmk where tempmk.ogl eq fun.gl no-lock no-error.
  if available tempmk then fun.gl = tempmk.ngl.
  end.

for each iof:
  find first tempmk where tempmk.ogl eq iof.gl no-lock no-error.
  if available tempmk then iof.gl = tempmk.ngl.
  end.

for each jl:
  find first tempmk where tempmk.ogl eq jl.gl no-lock no-error.
  if available tempmk then jl.gl = tempmk.ngl.
  end.

/*
for each lat:
  find first tempmk where tempmk.ogl eq lat.gl no-lock no-error.
  if available tempmk then lat.gl = tempmk.ngl.
  end.
*/

for each lcr:
  find first tempmk where tempmk.ogl eq lcr.gl no-lock no-error.
  if available tempmk then lcr.gl = tempmk.ngl.
  end.

for each lgr:
  find first tempmk where tempmk.ogl eq lgr.gl no-lock no-error.
  if available tempmk then lgr.gl = tempmk.ngl.
  end.

for each lon:
  find first tempmk where tempmk.ogl eq lon.gl no-lock no-error.
  if available tempmk then lon.gl = tempmk.ngl.
  end.

for each ock:
  find first tempmk where tempmk.ogl eq ock.gl no-lock no-error.
  if available tempmk then ock.gl = tempmk.ngl.
  end.

/*
for each plexp:
  find first tempmk where tempmk.ogl eq plexp.gl no-lock no-error.
  if available tempmk then plexp.gl = tempmk.ngl.
  end.
*/

for each rpay:
  find first tempmk where tempmk.ogl eq rpay.gl no-lock no-error.
  if available tempmk then rpay.gl = tempmk.ngl.
  end.

end.
