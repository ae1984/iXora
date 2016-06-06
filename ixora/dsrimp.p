/* dsrimp.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление досье клиентв - импорт, замена, списки файлов
        Импорт
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-13-6
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
        07/07/06 marinav - пути к файлам свои у каждого СПФ и филиала,
                           это прописывается в sysc (напр, sysc = DSR1, DSR2, DSR9 ....) по номеру СПФ
        04.10.2006 u00124 - на филиалах заменил скрипты стандартными командами(не работало)
        22/11/06  marinav - убран rcp
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        06/02/12 dmitriy - удаление успешно загруженных файлов (ТЗ 1076)
*/

{mainhead.i SGNCARD0}
{dsr.i}

def input parameter p-files as char.

def var v-dsrarc as char init "/data/export/dossier/arc/".
def var v-dsrimp as char init "nt2003:W:/scanned.doc/import/".
def var s-tmppath1 as char init "tmpdsr1".
def var v-result as char.
def var v-ourbank as char.
def var v-acc as char.
def var v-ext as char.
def var v-doc as char.
def var v-docsp  as char.
def var i as integer.
def var v-tim as integer.
def var v-num as integer.
def var v-select as integer.
def var v-newcard as logical.
def var v-arcname as char.
def var v-datetime as char.
def var v-norepl as logical init no.
def var v-lbhst as char.
def var v-lbeks as char.

def buffer b-ofc for ofc.

def temp-table t-dsr like dsrhis.
def temp-table t-err
  field file as char
  field err as char.

find sysc where sysc.sysc = "DSRARC" no-lock no-error.
if avail sysc then v-dsrarc = trim(sysc.chval).
else do transaction on error undo, retry:
  create sysc.
  assign sysc.sysc = "DSRARC"
         sysc.des = "Путь к архивным карточкам"
         sysc.chval = v-dsrarc.
end.
if substr(v-dsrarc, length(v-dsrarc), 1) <> "/" then v-dsrarc = v-dsrarc + "/".

/*find sysc where sysc.sysc = "DSRDOC" no-lock no-error.
if avail sysc then v-docsp = trim(sysc.chval).
*/

/*  пути к файлам свои у каждого СПФ и филиала
find sysc where sysc.sysc = "DSRIMP" no-lock no-error.
if avail sysc then v-dsrimp = trim(sysc.chval).
else do transaction on error undo, retry:
  create sysc.
  assign sysc.sysc = "DSRIMP"
         sysc.des = "Путь к каталогу импорта карт."
         sysc.chval = v-dsrimp.
end.
*/

/*  определим пути к файлам свои у каждого СПФ и филиала*/

{get-dep.i}
{comm-txb.i}
def var v-dep as inte.
v-dep = get-dep(g-ofc, g-today).
find first sysc where sysc.sysc = "DSR" + trim(string(v-dep)) no-lock no-error.
if avail sysc then v-dsrimp = trim(sysc.chval).

if substr(v-dsrimp, length(v-dsrimp), 1) <> "/" then v-dsrimp = v-dsrimp + "/".

/*Временный каталог для импорта*/
  find sysc where sysc.sysc = "DSRTM1" no-lock no-error.
  if avail sysc then s-tmppath1 = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "DSRTM1"
           sysc.des = "Каталог времен.файлов досье"
           sysc.chval = s-tmppath1.
  end.
  if substr(s-tmppath1, length(s-tmppath1), 1) <> "/" then s-tmppath1 = s-tmppath1 + "/".

message " Ждите...".


/*
  def var ss as char.
  ss = "*.*".
if comm-cod() = 1 then do:
  input through value ("mkdir " + s-tmppath1).
  input through value ("rcp `askhost`" + v-dsrimp + p-files + ss + " " + s-tmppath1 + "; echo $?").
end.
else do:
*/
 input through value ("sgnget " + s-tmppath1 + " " + v-dsrimp + p-files + "; echo $?").
/*end.*/

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
run comm-dir (s-tmppath1, "", no).
for each comm-dir:
/*  displ comm-dir.fname.*/
  v-doc = entry(1, comm-dir.fname,'-').

/*  if lookup(v-doc, v-docsp) = 0 then do:*/
  find first bookcod where bookcod.bookcod = 'sgndoc' and bookcod.code = v-doc no-lock no-error.
  if not avail bookcod then do:
      message " Название файла содержит недопустимые символы перед номером счета - " v-doc.
      pause 100.

      create t-err.
      t-err.file = comm-dir.fname.
      t-err.err = " Название файла содержит недопустимые символы перед номером счета - " + v-doc.
      next.
  end.

  v-acc = entry(1,substr( comm-dir.fname, index( comm-dir.fname,'-') + 1), '.').
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


  FILE-INFO:FILE-NAME = s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext).
  v-newcard = (FILE-INFO:FILE-TYPE = ?).
  IF not v-newcard THEN do:

  /***** Проверка на профит-центр - кто обслуживает клиента, тот и изменяет *********/
  /*  find first cif where cif.cif = aaa.cif no-lock no-error.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    find first b-ofc where b-ofc.ofc = cif.fname no-lock no-error.
    if avail ofc and avail b-ofc then do:
           if ofc.titcd ne b-ofc.titcd then do:
               message " Ваше подразделение не имеет право на изменение/удаление досье клиента - " + aaa.cif .
               pause 100.
               create t-err.
               t-err.file = comm-dir.fname.
               t-err.err = " Ваше подразделение не имеет право на изменение/удаление досье клиента - " + aaa.cif .
               next.
           end.
      end.
      else do:
            message " Не найден менеджер, обслуживающий клиента - " + aaa.cif + "  " + cif.fname.
            pause 100.
            create t-err.
            t-err.file = comm-dir.fname.
            t-err.err = " Не найден менеджер, обслуживающий клиента - " + aaa.cif + "  " + cif.fname.
            next.
      end.
   */

  /****** Проверить на блокировку ********/

      find dsr where dsr.bank = v-ourbank and dsr.cif = aaa.cif and dsr.docs = v-doc no-lock no-error.
      if avail dsr  and dsr.bdt ne ? then do:
            message " Досье заблокировано, изменения невозможны - " + aaa.cif .
            pause 100.
            create t-err.
            t-err.file = comm-dir.fname.
            t-err.err = " Досье заблокировано, изменения невозможны - " + aaa.cif .
            next.
      end.



  /**************/
    if v-norepl then do:
      /* спросить, если не сегодняшняя */
      find dsr where dsr.bank = v-ourbank and dsr.cif = aaa.cif and dsr.docs = v-doc no-lock no-error.
      if dsr.udt = today then next.
    end.

    repeat:
      v-select = 3.
      run sel2 (" ДОКУМЕНТ УЖЕ ЕСТЬ В КАТАЛОГЕ ! ",
                " 1. Показать старый документ | 2. Заменить существующий документ | 3. Отменить импорт  | 4. Отменить эту и все загруж-е сегодня | 5.Выйти из процедуры импорта",
                output v-select).
      if v-select = 1 then run dsrview (aaa.cif, v-doc, 0).
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
      v-arcname = v-doc + '-' + aaa.cif + entry(1, v-ext, ".") + "-" + v-datetime + '.' + entry(2, v-ext, ".").
      input through value("cp " + s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext) + " " + v-dsrarc + lc (v-arcname) + "; echo $?").
      repeat:
        import v-result.
      end.
      if v-result <> "0" then do:
        message skip " Произошла ошибка при переносе файла в архив " s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext) skip(1)
                view-as alert-box buttons ok title " ОШИБКА ! ".

        create t-err.
        t-err.file = comm-dir.fullname.
        t-err.err = " Произошла ошибка при переносе файла в архив " + s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext).

        next.
      end.
      else unix silent value("rm -f " + s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext)).
    end.
  end.


  input through value("cp " + comm-dir.fullname + " " + s-dsrpath + lc (v-doc + '-' + aaa.cif + v-ext) + "; echo $?").
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
    find dsr where dsr.bank = v-ourbank and dsr.cif = aaa.cif and dsr.docs = v-doc  and dsr.sts = 'D' exclusive-lock no-error.
    if avail dsr then do:
      assign dsr.udt = today
             dsr.uwho = g-ofc
             dsr.adt = ?
             dsr.awho = ''
             dsr.sts = "R".
    end.
    else do:
        find dsr where dsr.bank = v-ourbank and dsr.cif = aaa.cif and dsr.docs = v-doc  exclusive-lock no-error.
        if v-newcard or not avail dsr  then do:
          create dsr.
          assign dsr.bank = v-ourbank
                 dsr.cif = aaa.cif
                 dsr.docs = v-doc
                 dsr.rdt = today
                 dsr.rwho = g-ofc
                 dsr.sts = "N"
                 dsr.udt = today
                 dsr.uwho = g-ofc.
        end.
        else do:
          assign dsr.udt = today
                 dsr.uwho = g-ofc
                 dsr.adt = ?
                 dsr.awho = ''
                 dsr.sts = "R".
        end.
    end.
    create dsrhis.
    buffer-copy dsr to dsrhis.
    assign dsrhis.rdt = today
           dsrhis.rtim = time
           dsrhis.rwho = g-ofc
           dsrhis.action = if v-newcard then "ADD" else "REPL"
           dsrhis.filename = comm-dir.fname.

    create t-dsr.
    buffer-copy dsrhis to t-dsr.
  end.
  release dsr.
  release dsrhis.
end.
unix silent rm -rf value(s-tmppath1).

find first t-dsr no-error.
if avail t-dsr then do:

  output to dsrimp.html.
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
          "<TD>ДОКУМЕНТ</TD>" skip
          "<TD>СТС</TD>" skip
          "<TD>ФАЙЛ</TD>" skip
      "</TR>" skip.

  i = 0.
  for each t-dsr:
    i = i + 1.
    find cif where cif.cif = t-dsr.cif no-lock no-error.
    put unformatted
      "<TR>" skip
        "<TD align=center>" i "</TD>" skip
        "<TD align=center>" t-dsr.bank "</TD>" skip
        "<TD align=center>" t-dsr.cif "</TD>" skip
        "<TD>" trim(trim(cif.prefix) + " " + trim(cif.name)) "</TD>" skip
        "<TD align=center>"  string(t-dsr.docs) "</TD>" skip
        "<TD align=center>" t-dsr.action "</TD>" skip
        "<TD>" t-dsr.filename "</TD>" skip
      "</TR>" skip.


        /*-------------------------------------------*/
        v-lbhst = entry(1, v-dsrimp, ":").          /*  host   */
        v-lbeks = substr(v-dsrimp, length(v-lbhst) + 2).   /* адрес/  */
        v-lbeks = replace(v-lbeks, "/", "\\\\") .

        unix value("ssh " + v-lbhst + " erase /q " + v-lbeks + t-dsr.filename ).
        /*-------------------------------------------*/

  end.

  put unformatted "</TABLE>" skip.

  {html-end.i}
  output close.

  unix silent cptwin dsrimp.html iexplore.
  pause 0.

end.


find first t-err no-error.
if avail t-err then do:

  output to sgnimperr.html.
  {html-title.i &title = " Список ошибок при импорте документов клиентов" &size-add = "x-"}

  find first cmp no-lock no-error.
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  put unformatted
    "<P>" cmp.name "<br>" string(today, "99/99/9999") "<br>Исполнитель : " ofc.name "</P>" skip
    "<P style=""font-size:small; font:bold"">Список ошибок при импорте документов клиентов</P>" skip
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


