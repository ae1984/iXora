/* sgnimp.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление хранилищем карточек - импорт, замена, списки файлов
        Импорт файлов в хранилище
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-3
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
        19.04.2004 nadejda - добавлен параметр вызова процедуры просмотра - стирать/не стирать временный каталог
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

{mainhead.i SGNCARD0}
{sgn.i}

def input parameter p-files as char.

def var v-sgnarc as char init "/data/export/signs/arc/".
def var v-sgnimp as char init "nt2003:W:/scanned.doc/import/".
def var v-result as char.
def var v-ourbank as char.
def var v-acc as char.
def var v-ext as char.
def var i as integer.
def var v-tim as integer.
def var v-num as integer.
def var v-select as integer.
def var v-newcard as logical.
def var v-arcname as char.
def var v-datetime as char.
def var v-norepl as logical init no.

def temp-table t-sgn like sgnhis.
def temp-table t-err 
  field file as char
  field err as char.

find sysc where sysc.sysc = "SGNARC" no-lock no-error.
if avail sysc then v-sgnarc = trim(sysc.chval).
else do transaction on error undo, retry:
  create sysc.
  assign sysc.sysc = "SGNARC"
         sysc.des = "Путь к архивным карточкам"
         sysc.chval = v-sgnarc.
end.
if substr(v-sgnarc, length(v-sgnarc), 1) <> "/" then v-sgnarc = v-sgnarc + "/".

find sysc where sysc.sysc = "SGNIMP" no-lock no-error.
if avail sysc then v-sgnimp = trim(sysc.chval).
else do transaction on error undo, retry:
  create sysc.
  assign sysc.sysc = "SGNIMP"
         sysc.des = "Путь к каталогу импорта карт."
         sysc.chval = v-sgnimp.
end.
if substr(v-sgnimp, length(v-sgnimp), 1) <> "/" then v-sgnimp = v-sgnimp + "/".

message " Ждите...".

input through value ("sgnget " + s-tmppath + " " + v-sgnimp + p-files + "; echo $?").
repeat:
  import v-result.
end.

if v-result <> "0" then do:
  message skip " Произошла ошибка при импорте файлов !" skip(1) 
          view-as alert-box buttons ok title " ОШИБКА ! ".
end.

find sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc then v-ourbank = trim(sysc.chval).

{comm-dir.i}
run comm-dir (s-tmppath, "", no).
for each comm-dir:
/*  displ comm-dir.fname.*/

  v-acc = entry(1, comm-dir.fname, ".").
  i = index(v-acc, "-").
  if i = 0 then do:
    v-ext = "." + entry(2, comm-dir.fname, ".").
    v-num = 0.
  end.
  else do:
    v-num = integer(trim(substr(v-acc, i + 1))) no-error.
    if error-status:error then do:
      message " Название файла содержит недопустимые символы после номера счета - " v-acc. 
      pause 100.

      create t-err.
      t-err.file = comm-dir.fname.
      t-err.err = " Название файла содержит недопустимые символы после номера счета - " + v-acc.

      next.
    end.

    v-ext = substr(comm-dir.fname, i).
    v-acc = substr(v-acc, 1, i - 1).
  end.
  
  if length(v-acc) < 9 then v-acc = fill("0", 9 - length(v-acc)) + v-acc.

  find aaa where aaa.aaa = v-acc no-lock no-error.
  if not avail aaa then do:
    message " Счет не найден -" v-acc. 
    pause 100.
    
    create t-err.
    t-err.file = comm-dir.fullname.
    t-err.err = " Счет не найден - " + v-acc.

    next.
  end.

  
  FILE-INFO:FILE-NAME = s-sgnpath + lc (aaa.cif + v-ext).
  v-newcard = (FILE-INFO:FILE-TYPE = ?).
  IF not v-newcard THEN do:
    if v-norepl then do:
      /* спросить, если не сегодняшняя */
      find sgn where sgn.bank = v-ourbank and sgn.cif = aaa.cif and sgn.num = v-num no-lock no-error.
      if sgn.udt = today then next.
    end.

    repeat:
      v-select = 3.
      run sel2 (" КАРТОЧКА УЖЕ ЕСТЬ В КАТАЛОГЕ ! ", 
                " 1. Показать старую карточку | 2. Заменить существующую карточку | 3. Отменить импорт карточки | 4. Отменить эту и все загруж-е сегодня | 5. Выйти из процедуры импорта", 
                output v-select).
      if v-select = 1 then run sgnview (aaa.cif, no).
                      else leave.
    end.
    if v-select = 0 or v-select = 3 then next.

    if v-select = 5 then do:
      leave.
    end.

    if v-select = 4 then do:
      v-norepl = yes.
      next.
    end.

    if v-select = 2 then do:
      v-datetime = substr(string(year(today),"9999"), 3, 2) + string(month(today), "99") + string(day(today), "99").
      v-tim = time.
      v-datetime = v-datetime + entry(1, string(v-tim, "HH:MM:SS"), ":") + entry(2, string(v-tim, "HH:MM:SS"), ":") + entry(3, string(v-tim, "HH:MM:SS"), ":").
      v-arcname = aaa.cif + entry(1, v-ext, ".") + "-" + v-datetime + entry(2, v-ext, ".").
      input through value("cp " + s-sgnpath + lc (aaa.cif + v-ext) + " " + v-sgnarc + lc (v-arcname) + "; echo $?").
      repeat:
        import v-result.
      end.
      if v-result <> "0" then do:
        message skip " Произошла ошибка при переносе файла в архив " s-sgnpath + lc (aaa.cif + v-ext) skip(1) 
                view-as alert-box buttons ok title " ОШИБКА ! ".
        
        create t-err.
        t-err.file = comm-dir.fullname.
        t-err.err = " Произошла ошибка при переносе файла в архив " + s-sgnpath + lc (aaa.cif + v-ext).

        next.
      end.
      else unix silent value("rm -f " + s-sgnpath + lc (aaa.cif + v-ext)).
    end.
  end.


  input through value("cp " + comm-dir.fullname + " " + s-sgnpath + lc (aaa.cif + v-ext) + "; echo $?").
  repeat:
    import v-result.
  end.
  if v-result <> "0" then do:
    message skip " Произошла ошибка при копировании файла" comm-dir.fullname skip(1) 
            view-as alert-box buttons ok title " ОШИБКА ! ".
    
    create t-err.
    t-err.file = comm-dir.fname.
    t-err.err = " Произошла ошибка при копировании файла " + comm-dir.fullname.

    next.
  end.

  do transaction on error undo, retry:
    find sgn where sgn.bank = v-ourbank and sgn.cif = aaa.cif and sgn.num = v-num exclusive-lock no-error.
    if v-newcard or not avail sgn then do:
      create sgn.
      assign sgn.bank = v-ourbank
             sgn.cif = aaa.cif
             sgn.num = v-num
             sgn.rdt = today
             sgn.rwho = g-ofc
             sgn.sts = "N"
             sgn.udt = today
             sgn.uwho = g-ofc.
    end.
    else do:
      assign sgn.udt = today
             sgn.uwho = g-ofc
             sgn.sts = "R".
    end.

    create sgnhis.
    buffer-copy sgn to sgnhis.
    assign sgnhis.rdt = today
           sgnhis.rtim = time
           sgnhis.rwho = g-ofc
           sgnhis.action = if v-newcard then "ADD" else "REPL"
           sgnhis.filename = comm-dir.fname.

    create t-sgn.
    buffer-copy sgnhis to t-sgn.
  end.
  release sgn.
  release sgnhis.
end.
unix silent rm -rf value(s-tmppath).

find first t-sgn no-error.
if avail t-sgn then do:

  output to sgnimp.html.
  {html-title.i &title = " Список импортированных карточек клиентов" &size-add = "x-"}

  find first cmp no-lock no-error.
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  put unformatted 
    "<P>" cmp.name "<br>" string(today, "99/99/9999") "<br>Исполнитель : " ofc.name "</P>" skip
    "<P style=""font-size:small; font:bold"">Список импортированных карточек клиентов</P>" skip
    "<TABLE cellpadding=5 cellspacing=0 border=1>" skip
      "<TR align=center style=""font-size:xx-small; font:bold"">" skip
          "<TD>N</TD>" skip
          "<TD>БАНК</TD>" skip
          "<TD>КОД КЛИЕНТА</TD>" skip
          "<TD>НАИМЕНОВАНИЕ</TD>" skip
          "<TD>ДОП.КАРТ.</TD>" skip
          "<TD>СТС</TD>" skip
          "<TD>ФАЙЛ</TD>" skip
      "</TR>" skip.

  i = 0.
  for each t-sgn:
    i = i + 1.
    find cif where cif.cif = t-sgn.cif no-lock no-error.
    put unformatted 
      "<TR>" skip
        "<TD align=center>" i "</TD>" skip
        "<TD align=center>" t-sgn.bank "</TD>" skip
        "<TD align=center>" t-sgn.cif "</TD>" skip
        "<TD>" trim(trim(cif.prefix) + " " + trim(cif.name)) "</TD>" skip
        "<TD align=center>" if t-sgn.num = 0 then "&nbsp;" else string(t-sgn.num) "</TD>" skip
        "<TD align=center>" t-sgn.action "</TD>" skip
        "<TD>" t-sgn.filename "</TD>" skip
      "</TR>" skip.
  end.

  put unformatted "</TABLE>" skip.

  {html-end.i}
  output close.

  unix silent cptwin sgnimp.html iexplore.
  pause 0.

end.


find first t-err no-error.
if avail t-err then do:

  output to sgnimperr.html.
  {html-title.i &title = " Список ошибок при импорте карточек клиентов" &size-add = "x-"}

  find first cmp no-lock no-error.
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  put unformatted 
    "<P>" cmp.name "<br>" string(today, "99/99/9999") "<br>Исполнитель : " ofc.name "</P>" skip
    "<P style=""font-size:small; font:bold"">Список ошибок при импорте карточек клиентов</P>" skip
    "<TABLE cellpadding=5 cellspacing=0 border=1>" skip
      "<TR align=center style=""font-size:xx-small; font:bold"">" skip
          "<TD>N</TD>" skip
          "<TD>ФАЙЛ</TD>" skip
          "<TD>ОШИБКА</TD>" skip
      "</TR>" skip.

  i = 0.
  for each t-err:
    i = i + 1.
    put unformatted 
      "<TR>" skip
        "<TD align=center>" i "</TD>" skip
        "<TD align=left>" t-err.file "</TD>" skip
        "<TD align=left>" t-err.err "</TD>" skip
      "</TR>" skip.
  end.

  put unformatted "</TABLE>" skip.

  {html-end.i}
  output close.

  unix silent cptwin sgnimperr.html iexplore.
  pause 0.

end.

