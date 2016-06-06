/* rmzmont1.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        rmzmon1.p, clrrmzm.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        15.10.2003 nadejda  - собрала вместе rmzmont1.i и rmzmont2.i
        12.02.2004 nadejda  - ограничила для РКО просмотр очередей - только свои платежи
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        27.04.2005 suchkov  - добавил разбивку по сканированым платежам
        05/10/2005 rundoll - проверка по справочнику о срочности платежа.
*/

def input parameter QQ as char. 
def new shared var mesgdt as char.

def var deptmp as char.
def var i as int.      
def var c as char.
def var v-dep as integer.
def var s-remtrz like remtrz.remtrz.

def var v-fname as character format "x(16)".
def var v-name like cif.fname.
def var v-sub as int.

def var priz as int.


define temp-table rep
  field cdep as char format "x(25)" label "Подразделение"
  field depnamelong as char format "x(25)"
  field depnameshort as char format "x(14)"
  field lb-cnt as int init 0 format "9999" label "к-во"
  field lb-sum as deci format ">>>,>>>,>>9.99" init 0.0 label "LB:  сумма"
  field lbg-cnt as int init 0 format "9999" label "к-во"
  field lbg-sum as deci format ">>>,>>>,>>9.99" init 0.0 label "LBG: сумма"
  index cdep is unique primary cdep.

define new shared temp-table clrrep
  field cdep as char format "x(25)"
  field depnamelong as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)".

v-fname = "rpt.htm".


for each rep: delete rep. end.

find ofc where ofc.ofc = g-ofc no-lock no-error.
v-dep = ofc.regno mod 1000.

for each ppoint no-lock:
  if v-dep <> 1 and v-dep <> ppoint.depart then next.

  create rep.
  assign rep.cdep = string(ppoint.depart)
         rep.depnamelong = ppoint.name
         rep.depnameshort = ppoint.name.
end.

if v-dep = 1 then do:
  for each bankl where bankl.bank begins "TXB" and bankl.bank <> "TXB00" no-lock:
      c = trim(bankl.name).
      i = index(c, "АО").
      c = substring(c, 1, i - 1) + substring(c, i + 17).

      create rep.
      assign rep.cdep = bankl.bank
             rep.depnamelong = c.

      i = index(c, "г.").
      c = substring(c, 1, i - 1) + substring(c, i + 2).
      assign rep.depnameshort = c.
  end.
end.
      
for each codfr where codfr.codfr = "depsibh" no-lock:
  if v-dep <> 1 then do:
    if not codfr.code begins "i" and not codfr.code begins "s" then next.
    c = substr (codfr.code, 2).
    i = integer (c) no-error.
    if error-status:error or i <> v-dep then next.
  end.

  create rep.
  assign rep.cdep = codfr.code
         rep.depnamelong = entry(1, codfr.name[1], "/")
         rep.depnameshort = entry(2, codfr.name[1], "/").
end.


for each codfr where codfr.codfr = "urgency" and codfr.code = "s" no-lock:
    create rep.
           rep.cdep = codfr.code.
           rep.depnamelong = entry (1,codfr.name[1], "/").
           rep.depnameshort = entry (1,codfr.name[1], "/").
end.