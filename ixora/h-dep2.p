/* h-dep2.p
 * MODULE
        Файл помощи по департаментам 
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
        21/01/05 tsoy Добавил все подразделения 
*/

{global.i}

def var v-depart as char.
find sysc where sysc.sysc = 'depart' no-lock no-error.
v-depart = sysc.chval.


define temp-table clrrep
  field cdep         as char 
  field depnamelong  as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)"
index cdep is unique primary cdep
index  depnamelong depnamelong.  


def var i as int.      
def var c as char.

def var v-dep as integer.

find ofc where ofc.ofc = g-ofc no-lock no-error.
v-dep = ofc.regno mod 1000.

for each ppoint no-lock:
  if ( v-dep <> 1 and v-dep <> ppoint.depart ) or lookup(string(ppoint.depart), v-depart) = 0 then next.

  create clrrep.
  assign clrrep.cdep = string(ppoint.depart)
         clrrep.depnamelong = ppoint.name
         clrrep.depnameshort = ppoint.name.
end.

if v-dep = 1 then do:
  for each bankl where bankl.bank begins "TXB" and bankl.bank <> "TXB00" no-lock:
      c = trim(bankl.name).
      i = index(c, "АО").
      c = substring(c, 1, i - 1) + substring(c, i + 17).

      create clrrep.
      assign clrrep.cdep = (bankl.bank)
             clrrep.depnamelong = c.

      i = index(c, "г.").
      c = substring(c, 1, i - 1) + substring(c, i + 2).
      assign clrrep.depnameshort = c.
  end.
end.
      
for each codfr where codfr.codfr = "depsibh" no-lock:
  if v-dep <> 1 then do:
    if not codfr.code begins "i" then next.
    c = substr (codfr.code, 2).
    i = integer (c) no-error.
    if error-status:error or i <> v-dep then next.
  end.

  create clrrep.
  assign clrrep.cdep = (codfr.code)
         clrrep.depnamelong = entry(1, codfr.name[1], "/")
         clrrep.depnameshort = entry(2, codfr.name[1], "/").
end.

create clrrep.
assign clrrep.cdep = "ALL"
       clrrep.depnamelong  = "Все подразделения"
       clrrep.depnameshort = "Все подразделения" .

{itemlist.i 
       &file    = "clrrep"
       &frame   = "row 4 centered scroll 1 12 down overlay "
       &where   = "true"
       &flddisp = "clrrep.cdep LABEL ""КОД ""
                   clrrep.depnamelong FORMAT ""x(50)"" LABEL ""НАИМЕНОВАНИЕ ДЕПАРТАМЕТА""" 
       &chkey   = "cdep"
       &chtype  = "string"
       &index   = "depnamelong" }
return frame-value.

                                