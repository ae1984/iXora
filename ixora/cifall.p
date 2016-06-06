/* cifall.p
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

/* cifall.p
   Создание файла - полного списка клиентов для сетевой GCVPek1

   ...   создан неизвестно кем
   24.07.2003 nadejda - поставила копирование файла на локальную машину через логическое имя машины, а не IP-адрес
                        поменяла перевод в DOS - теперь через скрипт un-dos
*/

{mainhead.i}

def var hostmy   as char format "x(15)".
def var dirc     as char format "x(15)".
def var ipaddr   as char format "x(15)".
def var i        as inte init 1.
def var v-ans as char.
def var v-name as char.

dirc = "c:/gcvpek1".
 
update dirc label " Ваш директорий с ПФ "
              with centered side-label row 5 frame opt.
hide frame opt no-pause.
         
input through askhost.
   repeat:
       import hostmy.
   end.
input close.

displ " А теперь чуточку подождите, идет запись счета N " + string(i, "99999")         
      format "x(48)" with frame aa centered no-label row 5.

def temp-table t-aaa
  field aaa like aaa.aaa
  field cif like cif.cif
  field name as char
  index main is primary unique aaa.

for each aaa use-index aaa no-lock:
  if aaa.crc <> 1 or aaa.sta = "c" or aaa.lgr begins "5" then next.

  i = i + 1.
  display string(i, "99999") with frame aa.
  
  find t-aaa where t-aaa.cif = aaa.cif no-error.
  if avail t-aaa then v-name = t-aaa.name.
  else do:
    find cif where cif.cif = aaa.cif no-lock no-error.
    v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
  end.

  create t-aaa.
  assign t-aaa.aaa = aaa.aaa
         t-aaa.cif = aaa.cif
         t-aaa.name = v-name.
end.

def stream allcl.
output stream allcl to allclien.txt.

put stream allcl unformatted "000076928 T99999 ФИЗИЧЕСКИЕ ЛИЦА" skip.
for each t-aaa:
  put stream allcl unformatted t-aaa.aaa " " t-aaa.cif " " t-aaa.name skip.
end.
output stream allcl close.

unix silent un-dos allclien.txt allclien.dos.

input through value("rcp allclien.dos " + hostmy + ":" + dirc + ";echo $?").
repeat:
  import v-ans.
end.
input close.

hide frame aa no-pause.

if v-ans = "0" then
  MESSAGE skip " Сформирован файл счетов. Можно заходить в ПФ !!!" skip(1)
                    VIEW-AS ALERT-BOX BUTTONS OK title "".
else 
  MESSAGE skip " Произошла ошибка при копировании файла !!!" skip(1) v-ans skip(1)
                    VIEW-AS ALERT-BOX BUTTONS OK title "".

