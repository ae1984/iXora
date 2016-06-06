/* r-blok.p
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

/* r-blok.p
   блокированные (картотека или предписание) счета клиентов с остатками на    текущую дату
   изменения от 06.06.2000

   18.03.2003 nadejda - теперь остаток берется просто на текущий момент, а не по aab
   24/06/03 nataly добавлена сортировка при выводе сначала по серединке,
   потом по хвостику  - по заявке Демидовой Т.

   08/07/03 sasco добавил поиск по АРЕСТУ в кнопке Предписание
   27.07.05 dpuchkov поправил поиск по картотеке
        27.01.10 marinav - расширение поля счета до 20 знаков
   02.07.2013 yerganat - tz1889, добавление вывода счета ГК
*/

{global.i}
{functions-def.i}
{name2sort.i}

def stream m-out.
def var v-dat as date.
def var v-ofc like ofc.ofc.
def var ii as integer initial 0.
def var pr as integer.
def var v-type as integer init 1.
def var text1 as char format "x(20)".


def var v-payee as char extent 2 init
  ["K2,K-2,К2,К-2",
   "ПРЕДП,АРЕСТ"].

def temp-table temp
    field aaa  like aaa.aaa
    field middl as char
    field cif  like aaa.cif
    field name like aaa.name
    field sort as char
    field bal  as decimal
    field gl  like aaa.gl
    index main is primary sort cif middl aaa.

v-dat = g-today.
v-ofc = g-ofc.

update " Введите логин менеджера: " v-ofc no-label skip
       " 1) по менеджеру счета 2) по автору специнструкции: " v-type no-label format "9".

def button btn-k  label " Картотека   ".
def button btn-p  label " Предписание ".
def frame frame1
    skip(1) btn-k btn-p with centered title "Сделайте выбор:" row 5 .
    on choose of btn-k,btn-p do:
    if self:label = "Картотека" then do:
       pr = 1.
       text1 = "(КАРТОТЕКА)".
    end.
    else do:
       pr = 2.
       text1 = "(ПРЕДПИСАНИЕ, АРЕСТ)".
    end.
    end.
enable all with frame frame1.
wait-for choose of btn-k, btn-p.

display "   Ждите...   "  with row 5 frame ww centered .

def temp-table t-vars
  field name as char
  index main is primary name.

do ii = 1 to num-entries(v-payee[pr]) :
  create t-vars.
  t-vars.name = caps(entry(ii, v-payee[pr])).
end.

case v-type :
  when 1 then do:
    for each cif where trim(substr(cif.fname, 1, 8)) = v-ofc no-lock,
        each aaa of cif no-lock:
      for each aas where aas.aaa = aaa.aaa no-lock break by aas.aaa:
         if ((aas.sta = 0) and can-find(first t-vars where index(caps(aas.payee), t-vars.name) > 0)) or (pr = 1 and (aas.sta = 4 or aas.sta = 9 or aas.sta = 15 or aas.sta = 5 )) or (pr = 2 and aas.sta <> 4 and aas.sta <> 0 and aas.sta <> 9 and aas.sta <> 15 and aas.sta <> 5) then do:



           find temp where temp.cif = cif.cif and temp.aaa = aaa.aaa no-lock no-error.
           if not avail temp then do:
             create temp.
             assign temp.aaa  = aaa.aaa
                    temp.middl = substr(aaa.aaa, 4, 3)
                    temp.cif  = aaa.cif
                    temp.name = trim(trim(cif.prefix) + " " + trim(cif.name))
                    temp.bal = aaa.cr[1] - aaa.dr[1].
                    temp.gl = aaa.gl.
             temp.sort = name2sort(temp.name).

             find gl where gl.gl = aaa.gl no-lock no-error.
             if gl.type = "a" or gl.type = "e" then temp.bal = - temp.bal.
           end.
         end.
      end.
    end.
  end.
  when 2 then do:
    for each aas where aas.who = v-ofc no-lock break by aas.aaa:
       if ((aas.sta = 0) and can-find(first t-vars where index(caps(aas.payee), t-vars.name) > 0))  or (pr = 1 and (aas.sta = 4 or aas.sta = 9 or aas.sta = 15 or aas.sta = 5)) or (pr = 2 and aas.sta <> 4 and aas.sta <> 0 and aas.sta <> 9 and aas.sta <> 15 and aas.sta <> 5) then do:
         find aaa where aaa.aaa = aas.aaa no-lock no-error.

         if not avail aaa then next.
         else do:
           find temp where temp.cif = aaa.cif and temp.aaa = aaa.aaa no-lock no-error.
           if not avail temp then do:
             find cif where cif.cif = aaa.cif no-lock no-error.
             create temp.
             assign temp.aaa  = aaa.aaa
                    temp.middl = substr(aaa.aaa, 4, 3)
                    temp.cif  = aaa.cif
                    temp.name = trim(trim(cif.prefix) + " " + trim(cif.name))
                    temp.bal = aaa.cr[1] - aaa.dr[1].
                    temp.gl = aaa.gl.
             temp.sort = name2sort(temp.name).

             find gl where gl.gl = aaa.gl no-lock no-error.
             if gl.type = "a" or gl.type = "e" then temp.bal = - temp.bal.
           end.
         end.
       end.
    end.
  end.
end.


output stream m-out to rpt.img.
put stream m-out skip " "
FirstLine( 1, 1 ) format "x(79)" skip(1)
"              "
"СПИСОК ЗАБЛОКИРОВАННЫХ СЧЕТОВ КЛИЕНТОВ на " v-dat format "99/99/9999" " г."
 skip
"                             " + text1  format "x(80)" skip(1)
FirstLine( 2, 1 ) format "x(79)" skip.
put stream m-out " " fill( "-", 95 ) format "x(95)" skip.
put stream m-out
" N пп  "
" Счет                "
"Счет ГК "
"Клиент           "
"Наименование                       "
"Остаток" skip.
put stream m-out " " fill( "-", 95 ) format "x(95)" skip.

ii = 0.
for each temp break by temp.middl by substr(temp.aaa,8,2):
 ii = ii + 1.
 put stream m-out
     ii format ">>>9" ". "
     temp.aaa  " "
     temp.gl "  "
     temp.cif "   "
     temp.name " "
     temp.bal format "zzz,zzz,zzz,zz9.99-"
     skip.
end.
put stream m-out " " fill( "-", 95 ) format "x(95)" skip(2).
output stream m-out close.

if not g-batch then do:
  pause 0.
  run menu-prt( "rpt.img" ).
  pause 0 no-message.
end.

{functions-end.i}


