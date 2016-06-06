/* pkbadimp.p
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

/* pkbadimp.p Потребкредиты
   Импорт файла с дополнительным "Черным списком"
   Файл лежит по адресу в переменной sysc = "PKBADD"

   07.04.2003 nadejda
*/

{global.i}
{pk.i}

def var v-ipaddr as char.
def var v-file0 as char init "badlst-win.txt".
def var v-file as char init "badlst.txt".
def var v-res as char.
def var v-filename as char.

message " Загрузка списка...".

find sysc where sysc.sysc = "pkbadd" no-lock no-error.
if not avail sysc then do:
  message skip " Не найден параметр PKBADD!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-filename = sysc.chval.

v-ipaddr = "ntmain.texakabank.kz".
input through value("rcp " + v-ipaddr + ":" + v-filename + " " + v-file0 + ";echo $?").
repeat:
  import v-res.
end.
input close.
pause 0.

unix silent value("cat " + v-file0 + "| win2koi > " + v-file).
unix silent value("rm -f " + v-file0).

def temp-table t-bads
  field nom as integer format ">>>>9"
  field lname as char format "x(25)"
  field fname as char format "x(15)"
  field mname as char format "x(25)"
  field ybdt as integer format "9999"
  field docnum as char format "x(10)"
  field rnn as char format "x(12)"
  field load as char init "" format "x(30)"
  index nom is primary nom.


input from value(v-file).
repeat:
  create t-bads.
  import delimiter ";" t-bads except t-bads.load.
end.
input close.

for each t-bads where t-bads.nom = 0. delete t-bads. end.


def stream errs.
output stream errs to errs.txt.
put stream errs 
    "Ошибки при загрузке дополнительного списка" skip(1)
    "Потребительское кредитование" skip(1)
    fill("-", 70) format "x(70)" skip.

/* отбросить неполные и уже загруженные данные */
for each t-bads:
  t-bads.lname = caps(trim(t-bads.lname)).
  if length(t-bads.lname) <= 1 then do:
    if t-bads.load <> "" then t-bads.load = t-bads.load + ", ".
    t-bads.load = t-bads.load + "нет фамилии".
  end.

  t-bads.fname = caps(trim(t-bads.fname)).
  if length(t-bads.fname) <= 1 then do:
    if t-bads.load <> "" then t-bads.load = t-bads.load + ", ".
    t-bads.load = t-bads.load + "нет имени".
  end.

  t-bads.mname = caps(trim(t-bads.mname)).
  if length(t-bads.mname) <= 1 then do:
    if t-bads.load <> "" then t-bads.load = t-bads.load + ", ".
    t-bads.load = t-bads.load + "нет отчества".
  end.

  if t-bads.ybdt = 0 then do:
    if t-bads.load <> "" then t-bads.load = t-bads.load + ", ".
    t-bads.load = t-bads.load + "нет года рождения".
  end.

  find first pkbadlst where pkbadlst.lname = t-bads.lname and pkbadlst.fname = t-bads.fname and 
       pkbadlst.mname = t-bads.mname and pkbadlst.ybdt = t-bads.ybdt no-lock no-error.
  if avail pkbadlst and pkbadlst.sts = "A" then do:
    if t-bads.load <> "" then t-bads.load = t-bads.load + ", ".
    t-bads.load = t-bads.load + "запись уже внесена в список".
  end.


  if t-bads.load <> "" then do:
    put stream errs 
        t-bads.nom   " "
        t-bads.lname at 8 " "
        t-bads.fname " "
        t-bads.mname " "
        t-bads.ybdt  " "
        t-bads.docnum " "
        t-bads.rnn skip
        "      " t-bads.load skip.
  end.
end.

output stream errs close.

/* загрузить в таблицу */
for each t-bads where t-bads.load = "":
  find first pkbadlst where pkbadlst.lname = t-bads.lname and pkbadlst.fname = t-bads.fname and 
       pkbadlst.mname = t-bads.mname and pkbadlst.ybdt = t-bads.ybdt no-lock no-error.
  if not avail pkbadlst then do:
    create pkbadlst.
    buffer-copy t-bads to pkbadlst.
    assign pkbadlst.source = "ext"
           pkbadlst.bank = s-ourbank
           pkbadlst.rdt = today
           pkbadlst.rwho = g-ofc.

  end.
  assign pkbadlst.sts = "A"
         pkbadlst.udt = today
         pkbadlst.uwho = g-ofc.

end.

hide message no-pause.

/* показать протокол ошибок */
find first t-bads where t-bads.load <> "" no-error.
if avail t-bads then run menu-prt ("errs.txt").
else message skip " Все записи успешно внесены!" skip(1) view-as alert-box button ok title "".

unix silent value("rm -f " + v-file).
unix silent rm -f errs.txt.

