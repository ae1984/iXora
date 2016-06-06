/* sgnlistr.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Хранилище карточек подписей
        Просмотр файлов в хранилище
 * RUN
        
 * CALLER
        sgncif.p, sgnimp.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-1, 1-13-3
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
        19.04.2004 nadejda - добавлен параметр вызова - стирать/не стирать временный каталог
*/

{global.i}

def input parameter p-cif as char.
def input parameter p-del as logical.

find first sgn where sgn.cif = p-cif no-lock no-error.
if not avail sgn then do:
  message skip 
    " Нет карточки клиента" p-cif "для отображения!" skip(1)
    view-as alert-box button ok title " ОШИБКА ! ".

  run newview (p-cif, "no_card").
  return.
end.

{sgn.i}
def var v-files as char.
def var v as char.

for each sgn where sgn.cif = p-cif no-lock:
  if v-files <> "" then v-files = v-files + ",".
  v-files = v-files + s-sgnpath + sgn.cif.
  if sgn.num > 0 then v-files = v-files + "-" + trim(string(sgn.num)).
  v-files = v-files + s-fileext.
end.
v-files = lc(v-files).

input through sgnput value(s-tmppath + " " + v-files + ";echo $?").
repeat:
  import v.
end.
input close.
if v <> "0" then do:
  message skip 
    " Произошла ошибка при поиске файлов карточек клиента" p-cif "!" skip(1)
    view-as alert-box button ok title " ОШИБКА ! ".
  unix silent rm -rf value(s-tmppath).

  run newview (p-cif, "no_file").
  return.
end.

{comm-dir.i}
run comm-dir (s-tmppath, "", no).

def stream r-view.
output stream r-view to sgnview.html.
{html-title.i &stream = "stream r-view"}

find cif where cif.cif = p-cif no-lock no-error.
put stream r-view unformatted 
  "<P><b>КАРТОЧКИ ПОДПИСЕЙ КЛИЕНТА</b></P>" skip
  "<P>Код клиента : " p-cif "<br>" skip
  "Наименование клиента : " if avail cif then trim(trim(cif.prefix) + " " + trim(cif.name)) else "не найдено" "</P>" skip.

v-files = "".
for each comm-dir:
  if v-files <> "" then v-files = v-files + ",".
  v-files = v-files + s-tmppath + comm-dir.fname.
  put stream r-view unformatted 
    "<img src=""" comm-dir.fname """><P>&nbsp;</P>" skip.
end.

{html-end.i "stream r-view"}
output stream r-view close.

input through cptwin sgnview.html iexplore value(v-files).
repeat:
  import v.
end.
input close.
pause 0.

if p-del then unix silent rm -rf value(s-tmppath).

run newview (p-cif, if v = "0" then "success" else "err_view").



procedure newview.
  def input parameter vp-cif as char.
  def input parameter vp-result as char.
  def var v-place as char.
  def var i as integer.

  if s-hostmy begins "txb-" then do:
    i = index (s-hostmy, ".").
    v-place = substr (s-hostmy, 5, i - 5).
    find ast where ast.addr[2] = v-place no-lock no-error.
    if avail ast then v-place = ast.attn.
  end.

  find sysc where sysc.sysc = "ourbnk" no-lock no-error.
  do transaction:
    create sgnview.
    assign sgnview.bank = sysc.chval
           sgnview.cif = vp-cif
           sgnview.who = g-ofc
           sgnview.dt = g-today
           sgnview.tim = time
           sgnview.host = s-hostmy
           sgnview.location = v-place
           sgnview.result = vp-result.

  end.
end.

