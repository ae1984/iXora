/* vcrep1718.p
 * MODULE
        Название Программного Модуля
        Валютный контроль 
 * DESCRIPTION
        Назначение программы, описание процедур и функций
           Приложение 17, 18 - все платежи за месяц по контрактам по экспорту и/или импорту
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
   18.03.2003 nadejda - перенесен кусок из vcrepk17.p
   24.05.2003 nadejda - убраны параметры -H -S из коннекта 
   30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-type as char.
def input parameter p-option as char.
def input parameter p-bank as char.
def input parameter p-depart as integer.

def new shared var s-vcourbank as char.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.

def var v-name as char.
def var v-depname as char.
def var i as integer.
def var v-ncrccod like ncrc.code.
def var v-sum like vcdocs.sum.

def new shared temp-table t-docs 
  field dndate as date
  field sum as decimal
  field payret as logical
  field docs as integer
  field paykind as char
  field cif as char
  field prefix as char
  field name as char
  field okpo as char
  field clnsts as char
  field region as char
  field addr as char
  field ctnum as char
  field ctdate as date
  field cttype as char
  field partnprefix as char
  field partner as char
  field codval as char
  field info as char
  field strsum as char
  field bank as char
  field depart as char
  index main is primary cttype dndate payret sum docs.

s-vcourbank = comm-txb().

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

update skip(1) 
   v-month label "     Месяц " skip 
   v-god label   "       Год " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then i = 31.
  when 4 or when 6 or when 9 or when 11 then i = 30.
  when 2 then do:
    if v-god mod 4 = 0 then i = 29.
    else i = 28.
  end.
end case.
v-dte = date(v-month, i, v-god).

if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
  p-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = p-depart no-lock no-error.
  v-depname = ppoint.name.
end.
v-name = "".

/* коннект к нужному банку */
if connected ("txb") then disconnect "txb".
for each txb where txb.consolid = true and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
  connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
  do i = 1 to num-entries(p-type):
    run vctst1718dat (entry(i, p-type), txb.bank, p-depart).
  end.
  if p-bank <> "all" then v-name = txb.name.
  disconnect "txb".
end.

hide message no-pause.

/*
if p-option = "rep" then
  run vctst1718out.p (entry(1, p-type), "vcrep1718" + entry(1, p-type) + ".htm", 
                    (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true).
else*/
  run vctst1718msg.

hide all no-pause.

pause 0.


