/* pkblackch0.p
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

/* pkblackch.p Потребкредиты
   Поиск данных новой анкеты в Черном списке

   08.04.2003 nadejda 
*/

{global.i}
{pk.i}

/**
s-credtype = "2".
s-pkankln = 1.
**/

def shared temp-table t-badank like pkbadlst.

def output parameter p-black as logical.
def output parameter p-rowid as char.

def var v-lname as char.
def var v-fname as char.
def var v-mname as char.
def var v-bdt as date.

p-black = false.

find first t-badank no-lock no-error.

/* поищем негодяя по РНН */
if not p-black and t-badank.rnn <> "" then do:
  find first pkbadlst where pkbadlst.sts = "A" and pkbadlst.rnn = t-badank.rnn no-lock no-error.
  p-black = avail pkbadlst.
end.

/* поищем негодяя по номеру удостоверения */
if not p-black and t-badank.docnum <> "" then do:
  find first pkbadlst where pkbadlst.sts = "A" and pkbadlst.docnum = t-badank.docnum no-lock no-error.
  p-black = avail pkbadlst.
end.

/* поищем негодяя по полному имени и дате рождения */
if not p-black then do:
  v-lname = caps(trim(t-badank.lname)).
  v-fname = caps(trim(t-badank.fname)).
  v-mname = caps(trim(t-badank.mname)).
  v-bdt = t-badank.bdt.

  find first pkbadlst where pkbadlst.sts = "A" and pkbadlst.lname = v-lname and pkbadlst.fname = v-fname and pkbadlst.mname = v-mname and
       pkbadlst.bdt = v-bdt no-lock no-error.
  p-black = avail pkbadlst.

  /* поищем негодяя по полному имени и ГОДУ рождения */
  if not p-black then do:
    find first pkbadlst where pkbadlst.sts = "A" and pkbadlst.lname = v-lname and pkbadlst.fname = v-fname and pkbadlst.mname = v-mname and
         pkbadlst.ybdt = year(v-bdt) no-lock no-error.
    p-black = avail pkbadlst.
  end.
end.


if p-black then p-rowid = string(rowid (pkbadlst)).
           else p-rowid = "".


