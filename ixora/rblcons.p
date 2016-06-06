/* rblcons.p
 * MODULE
        Клиенты и счета
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
        1-4-2-13
 * AUTHOR
        23.07.2012 Lyubov
 * BASES
        BANK
 * CHANGES
        02.07.2013 yerganat - tz1889, добавление вывода счета ГК

*/

{functions-def.i}

def stream m-out.
def new shared var v-dat as date.
def new shared var v-ofc like ofc.ofc.
def new shared var ii as integer initial 0.
def new shared var pr as integer.
def new shared var v-type as integer init 1.
def new shared var text1 as char format "x(20)".
def var g-batch as logi init false.

def var v-payee as char extent 2 init
  ["K2,K-2,К2,К-2",
   "ПРЕДП,АРЕСТ"].

def new shared temp-table temp
    field aaa  like aaa.aaa
    field middl as char
    field cif  like aaa.cif
    field name like aaa.name
    field sort as char
    field bal  as decimal
    field gl  like aaa.gl
    index main is primary sort cif middl aaa.

find last cls no-lock no-error.
if available cls then v-dat = cls.cls + 1.

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

def new shared temp-table t-vars
  field name as char
  index main is primary name.

do ii = 1 to num-entries(v-payee[pr]) :
  create t-vars.
  t-vars.name = caps(entry(ii, v-payee[pr])).
end.

{r-brfilial.i &proc = "rblcons-k"}

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
for each temp break by substr(temp.aaa,19,2) by temp.middl by substr(temp.aaa,8,2):
 ii = ii + 1.
 put stream m-out
     ii format ">>>9" ". "
     temp.aaa  " "
     temp.gl "  "
     temp.cif "   "
     temp.name " "
     temp.bal format "zzz,zzz,zzz,zz9.99-" " "
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