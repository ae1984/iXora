/* dsrlist.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        просмотр досье
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * BASES
        BANK COMM
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
        16.03.2005 marinav - возможность выбрать документ для просмотра, 
                             если нет акцепта, то док-т не показывать в досье.  
        15.06.05 marinav - добавила параметр p-accept ( 1 -надо проверять акцепт на документах, 0 - не надо)
        23.06.2010 marinav - если клиент не найден то вообще ничего не выводить 
*/

{global.i}

def input parameter p-cif as char.
def input parameter p-doc as char.
def input parameter p-accept as inte.

find first dsr where dsr.cif = p-cif no-lock no-error.
if not avail dsr then do:
  message skip 
    " Нет карточки клиента" p-cif "для отображения!" skip(1)
    view-as alert-box button ok title " ОШИБКА ! ".

  run newview (p-cif, "no_card").
  return.
end.
else do:
    if dsr.bdt ne ? then do:
    message skip  " Досье заблокировано для отображения!" skip(1)
    view-as alert-box button ok title " ОШИБКА ! ".

    run newview (p-cif, "block").
    return.
    end.
end.

{dsr.i}
def var v-files as char.
def var v as char.
def var v-num as inte.
def var i as inte.
def var v-cod as char.

if p-doc = '' then do:
  pause 0.
  run uni_book ("sgndoc", "*", output v-cod).
  v-num = num-entries(v-cod).
  
  do i = 1 to v-num:
     find first dsr where dsr.cif = p-cif and dsr.docs = entry(i, v-cod) no-error.
        if avail dsr then do:
            if dsr.adt = ? and p-accept = 1 then 
               message skip  " На документе " dsr.docs " нет акцепта менеджера!" skip(1)
               view-as alert-box button ok title " ОШИБКА ! ".
            else do:
               if v-files <> "" then v-files = v-files + ",".
               v-files = v-files + s-dsrpath + trim(string(dsr.docs)) + "-" + dsr.cif.
               v-files = v-files + s-fileext.
            end.
        end.
  end.
end.
else do:
  for each dsr where dsr.cif = p-cif and dsr.docs = p-doc  no-lock:
          if v-files <> "" then v-files = v-files + ",".
          v-files = v-files + s-dsrpath + trim(string(dsr.docs)) + "-" + dsr.cif.
          v-files = v-files + s-fileext.
  end.
end.

if v-files = '' then return.

v-files = lc(v-files).

/*
message v-files.
pause 100.
*/
input through sgnput value(s-tmppath + " " + v-files + ";echo $?").
repeat:
  import v.
end.
input close.
if v <> "0" then do:
  message skip 
    " Произошла ошибка при поиске файлов клиента" p-cif "!" skip(1)
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
  "<P><b>ЭЛЕКТРОННОЕ ДОСЬЕ КЛИЕНТА</b></P>" skip
  "<P>Код клиента : " p-cif "<br>" skip.
if avail cif then
put stream r-view unformatted 
  "Наименование клиента : " trim(trim(cif.prefix) + " " + trim(cif.name)) "</P>" skip.

v-files = "".
for each comm-dir:
  if v-files <> "" then v-files = v-files + ",".
  v-files = v-files + s-tmppath + comm-dir.fname.
  put stream r-view unformatted 
    "<img src=""" comm-dir.fullname """><P>&nbsp;</P>" skip.
end.

{html-end.i "stream r-view"}
output stream r-view close.

           def var exitcod  as cha initial "" no-undo. 
           output to sendtest.
              put "Ok".
           output close .
         
           input through value("scp -q sendtest Administrator@$`askhost`:c:\tmp\tmpdsr\";echo $?" ). 
           repeat :
               import exitcod .
           end .

           if exitcod <> "0" then do :
               unix silent  value("ssh Administrator@`askhost` mkdir c:\\\\tmp\\\\tmpdsr").
           end .

input through cptwin sgnview.html iexplore value(v-files).
repeat:
  import v.
end.
input close.
pause 0.

unix silent rm -rf value(s-tmppath).

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
    create dsrview.
    assign dsrview.bank = sysc.chval
           dsrview.cif = vp-cif
           dsrview.who = g-ofc
           dsrview.dt = g-today
           dsrview.tim = time
           dsrview.host = s-hostmy
           dsrview.location = v-place
           dsrview.result = vp-result.

  end.
end.

