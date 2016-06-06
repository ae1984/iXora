/* r-opersp.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Справки по счетам физических лиц
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2.4.14
 * AUTHOR
        09.01.2004 valery
* CHANGES
        11.02.2004 suchkov - Поправлены позиции в связи с добавлением e-mail для отправки балансов по городам.
        01.09.2004 dpuchkov - добавил ограничение на просмотр реквизитов клиента
        08.09.2004 dpuchkov - запись удачных попыток
        23.08.2006 u00124   - оптимизация
        04/05/2012 evseev - подтягивать логотип с c://tmp/top_logo_bw.jpg
*/

{global.i}
def var der_dep as char initial "БОЯРКИНА И.Я.".
def stream rep.
def var f-name as char.
def var v-cif as char.
def var v-cifname as char.
def var v-cifdt as date.   /*дата регистрации клиента*/
def var v-datastr as char.
def var vans as logical.
def var v-str1 as char format "x(9)".
def var v-str2 as char.
def var v-grups as char.
def var i as integer.
def var n as integer.
def var v-bankengl as char.
def var v-bankname as char.
def var v-bankrnn as char.
def var v-bankokpo as char.
def var v-dtb as date  format "99/99/9999".
def var v-dte as date  format "99/99/9999".
def var v-dtcheck as date.
def var v-availempty as logical.
def var v-sumdig as char.
def var v-sumstr as char.
def var v-sign1 as char.
def var v-sign2 as char.
def var v-bankbik as char.
def var v-bankiik as char.
def var v-bankfull as char.
def var v-glcash as integer.
def var v-datastrkz as char no-undo.

def var v-docs as char init "
1. О налич.счетов клиента(рус.)|
2. О налич.счетов клиента(англ.)|
3. Остаток средств на счете(рус.)|
4. Остаток средств на счете(англ.)|".

def temp-table t-crcname
  field crc as integer
  field name as char
  index crc is primary unique crc.


def temp-table t-docs
  field code as integer
  field choice as char
  field name as char
  index main is primary unique code.

def new shared temp-table t-accs
  field aaa as char
  field choice as char
  field name as char
  field dam as deci
  field damdig as char
  field damstr as char
  field cam as deci
  field camdig as char
  field camstr as char
  field gl as integer
  field crc as integer
  field crccode as char
  index aaa is primary unique aaa.


/*заполняем таблицу пунктов меню*/
do i = 1 to num-entries(v-docs, "|"):
  create t-docs.
  assign t-docs.code = i
         t-docs.name = entry(i, v-docs, "|").
end.

/*Вводим код клиента или нажимаем F2 для поиска клиента по реквизитам*/
def frame f-client
  v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = v-cif and cif.type = "P" no-lock), " Клиент с таким кодом не найден! Либо клиент не является физ.лицом!")
  v-cifname no-label format "x(45)" colon 18 with side-label row 4 no-box.
  update v-cif with frame f-client.

  find last cifsec where cifsec.cif = v-cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = v-cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = v-cif
          ciflog.sectime = time
          ciflog.menu = "2.4.14 Справки по счету физ.лиц. (рус/англ)".
          return.
     end.
     else
     do:
        create ciflogu.
        assign
          ciflogu.ofc = g-ofc
          ciflogu.jdt = today
          ciflogu.sectime = time
          ciflogu.cif = v-cif
          ciflogu.menu = "2.4.14 Справки по счету физ.лиц. (рус/англ)" .
     end.
  end.


/*Выводим на экран полное имя клиента*********************************/
find first cif where cif.cif = v-cif no-lock no-error.
v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
v-cifdt = cif.regdt.
displ v-cifname with frame f-client.
/*********************************************************************/


/*получаем информацию о филиале банка***************************/
find first cmp no-lock no-error.
v-bankname = caps(cmp.name).
v-bankrnn = cmp.addr[2].
if cmp.code = 0 then v-bankokpo = substr(cmp.addr[3], 1, 8). else v-bankokpo = cmp.addr[3].

{sysc.i}
v-bankbik = get-sysc-cha ("clecod").
if v-bankbik = ? then v-bankbik = "".
v-bankiik = get-sysc-cha ("bnkiik").
if v-bankiik = ? then v-bankiik = "".

run defbnkreq (output v-bankfull).

find sysc where sysc.sysc = "vc-agr" no-lock no-error.
v-grups = sysc.chval.

find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if avail sysc then
          v-bankengl = entry(10, sysc.chval, "|") no-error.

find sysc where sysc.sysc = "cashgl" no-lock no-error.
v-glcash = sysc.inval.


repeat:
  for each t-docs. t-docs.choice = "". end.

  {jabr.i
    &start     =  " view frame f-footer. "
    &head      =  "t-docs"
    &headkey   =  "code"
    &index     =  "main"
    &formname  =  "cfsprav"
    &framename =  "f-docs"
    &where     =  " true "
    &addcon    =  "false"
    &deletecon =  "false"
    &prechoose =  " "
    &predisplay = " "
    &display   =  " t-docs.choice t-docs.name "
    &highlight =  " t-docs.choice t-docs.name "
    &postkey   =  " else if keyfunction(lastkey) = 'insert-mode' then do:
                      if t-docs.choice = '' then t-docs.choice = '*'.
                                            else t-docs.choice = ''.
                      leave outer.
                    end.
                    else if keyfunction(lastkey) = 's' then do:
                      run procparam.
                      hide frame f-params no-pause.
                    end.
                    else if keyfunction(lastkey) = 'return' then do:
                        t-docs.choice = '*'.
                        leave upper.
                    end. "
    &end =        " hide frame f-docs. hide frame f-footer. "
  }

  for each t-docs where t-docs.choice = "*":
    run value ("prtdoc" + string(t-docs.code)).
  end.

  if not can-find(first t-docs where t-docs.choice = "*") then leave.
end.

/**************************************************************/

find sysc where sysc.sysc = "vc-agr" no-lock no-error.
v-grups = sysc.chval.

/*Процедура создания шапки справки************************************/
procedure put_header.
  def input parameter p-var as char.
  f-name = string(random(1,9999)).

 /*приводит текущую дату к формату "01 января 2003"********************/
  run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).
/*********************************************************************/

/* output stream rep to value("sprav" + p-var + ".htm").*/
   output stream rep to value(f-name + ".htm").
   {html-title.i &stream = "stream rep" &title = " " &size-add = " "}

  put stream rep unformatted
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
     "<TR><TD align=""right""><img src=""c://tmp/top_logo_bw.jpg""></TD></TR>" skip
     "<TR><TD><BR>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left""><HR noshade color=""black"" size=""1""></TD>" skip
           "<TD width=""35%"" align=""center""><HR noshade color=""black"" size=""1""></TD>" skip
         "</TR>"
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left""><HR noshade color=""black"" size=""1""></TD>" skip
           "<TD width=""35%"" align=""center""><HR noshade color=""black"" size=""1""></TD>" skip
         "</TR>"
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left"">ДАТА</TD>" skip
           "<TD width=""35%"" align=""center""><U>" v-datastr "</U></TD>" skip
         "</TR>"

       "</TABLE>" skip.
end procedure.
/*********************************************************************/
procedure put_headerEngl.
  def input parameter p-var as char.
  f-name = string(random(1,9999)).
  output stream rep to value(f-name + ".htm").
  {html-title.i &stream = "stream rep" &title = " " &size-add = " "}

  put stream rep unformatted
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
     "<TR><TD align=""right""><img src=""c://tmp/top_logo_bw.jpg""></TD></TR>" skip
     "<TR><TD><BR>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left""><HR noshade color=""black"" size=""1""></TD>" skip
           "<TD width=""35%"" align=""center""><HR noshade color=""black"" size=""1""></TD>" skip
         "</TR>"
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left""><HR noshade color=""black"" size=""1""></TD>" skip
           "<TD width=""35%"" align=""center""><HR noshade color=""black"" size=""1""></TD>" skip
         "</TR>"
         "<TR valign=""top"">" skip
           "<TD width=""63%"" align=""left""></TD>" skip
       "<TD width=""2%"" align=""left"">DATE</TD>" skip
           "<TD width=""35%"" align=""center""><HR noshade color=""black"" size=""1""></TD>" skip
         "</TR>"

       "</TABLE>" skip.
end procedure.
/*********************************************************************/

function check-accs returns logical (input p-value as char, input p-availempty as logical).
  if p-value = "" then return p-availempty.
  do i = 1 to num-entries (p-value):
    find t-accs where t-accs.aaa = entry(i, p-value) no-error.
    if not avail t-accs then return false.
  end.
  return true.
end function.



form
  v-dtb  format "99/99/9999" label " Начальная дата периода " colon 25
    help " Введите дату начала периода" validate (v-dtb <= g-today, " Дата не может быть больше сегодняшней!") skip
  v-dte  format "99/99/9999" label " Конечная дата периода " colon 25
    help " Введите дату конца периода" validate (v-dte <= v-dtcheck, " Дата не может быть больше " + string(v-dtcheck) + "!") skip
  v-str1 format "x(50)" label " Номера счетов " colon 25
    help " Введите счета через запятую или оставьте пустым для ВСЕХ счетов" validate (check-accs(v-str1, v-availempty), " Недопустимый номер счета!") skip
  with overlay width 78 centered row 6 side-label  frame f-prils.


procedure findaccs.
  def input parameter p-var as char.
  def input parameter p-empty as logical.
  def input parameter p-yesdtb as logical.
  def input parameter p-yesdte as logical.
  def output parameter p-ans as logical.
  find t-docs where t-docs.code = integer(p-var) no-error.
  if p-yesdtb then v-dtb = g-today. else v-dtb = v-cifdt.

  if p-yesdte then v-dte = g-today. else do:
    find last cls no-lock no-error.
    v-dte = cls.whn.
  end.
  if v-dtb > v-dte then v-dtb = v-dte.
  v-dtcheck = v-dte.
  v-str1 = "".

  displ v-dtb v-dte v-str1 with frame f-prils.
  update v-dtb when p-yesdtb v-dte with frame f-prils title t-docs.name.

  for each t-accs. delete t-accs. end.

  for each aaa where aaa.cif = v-cif no-lock:
    /* берем только ТЕКУЩИЕ СЧЕТА */
    if lookup(aaa.lgr, v-grups) = 0 then next.

    /* закрытые на дату начала периода счета не обрабатываем */
    if aaa.sta = "c" and aaa.cltdt <= v-dtb then next.

    /* если дата задана только одна - не обрабатываем счета, закрытые на эту дату */
    if not p-yesdtb and aaa.sta = "c" and aaa.cltdt <= v-dte then next.

    /* открытые позже даты начала периода счета не обрабатываем */
    if aaa.regdt > v-dte then next.

    find lgr where lgr.lgr = aaa.lgr no-lock no-error.
    find crc where crc.crc = aaa.crc no-lock no-error.

    create t-accs.
    assign t-accs.aaa = aaa.aaa
           t-accs.name = lgr.des
           t-accs.gl = aaa.gl
           t-accs.crc = aaa.crc
           t-accs.crccode = crc.code.
  end.

  p-ans = yes.
  if not can-find(first t-accs) then do:
    p-ans = no.
    message skip " Нет доступных счетов ! Печатать пустую справку ?" skip(1) view-as alert-box buttons yes-no title "" update p-ans.
  end.


  if p-ans then do:
     on help of v-str1 in frame f-prils do:

        for each t-accs. t-accs.choice = "". end.
          do i = 1 to num-entries (v-str1):
             find t-accs where t-accs.aaa = entry(i, v-str1) no-error.
             if avail t-accs then t-accs.choice = "*".
          end.

          run cfsprav-aaa.

          v-str1 = "".
          for each t-accs where t-accs.choice = "*":
              if v-str1 <> "" then v-str1 = v-str1 + ",".
              v-str1 = v-str1 + t-accs.aaa.
          end.

          displ v-str1 with frame f-prils.
     end.

     v-availempty = p-empty.

     update v-str1 with frame f-prils.

     hide frame f-prils no-pause.

     if v-str1 = "" then for each t-accs. t-accs.choice = "*". end.
     else do:
       for each t-accs. t-accs.choice = "". end.
           do i = 1 to num-entries (v-str1):
              find t-accs where t-accs.aaa = entry(i, v-str1) no-error.
              if avail t-accs then t-accs.choice = "*".
           end.
     end.
  end.
end procedure.



/*Формирование справки о наличие у клиентов счетов Русс********************/
procedure pril123.
  def input parameter p-var as char.
  run findaccs (p-var, yes, no, no, output vans).

  if vans then do:

    for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.

    n = accum count t-accs.aaa.
    i = 0.

 if n > 0 then do:
      run put_header (p-var).

/*приводит текущую дату к формату "01 января 2003"********************/
 run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).
/*********************************************************************/

      put stream rep unformatted
        "<P style=""text-align:justify"">" skip
        "СОГЛАСНО ЗАПРОСУ КЛИЕНТА &nbsp;<U><B>" skip
        CAPS(v-cifname) skip
        "</B></U>&nbsp; ПОДТВЕРЖДАЕМ НАЛИЧИЕ У НЕГО В &nbsp;" v-bankname " &nbsp;" skip.

if n > 1 then
    put stream rep unformatted "ТЕКУЩИХ СЧЕТОВ&nbsp;#&nbsp;" skip.
       else
    put stream rep unformatted "ТЕКУЩЕГО СЧЕТА&nbsp;#&nbsp;" skip.

      for each t-accs where t-accs.choice = "*":
        find last aab where aab.aaa = t-accs.aaa and aab.fdt <= v-dte no-lock no-error.

        v-sumdig = replace(trim(string(aab.bal, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").

        run Sm-vrd (aab.bal, output v-sumstr).

        run sm-wrdcrc (substr(v-sumdig, 1, length(v-sumdig) - 3),
                       substr(v-sumdig, length(v-sumdig) - 1),
                       t-accs.crc, output v-str1, output v-str2).
        v-sumstr = v-sumstr + "&nbsp;" + v-str1 + " " +
                        substr(v-sumdig, length(v-sumdig) - 1) + "&nbsp;" + v-str2.

        find t-crcname where t-crcname.crc = t-accs.crc no-error.

        i = i + 1.
        put stream rep unformatted "<U><B>" t-accs.aaa "</U></B>" skip.
      end.
        put stream rep unformatted "&nbsp;НА&nbsp;" + CAPS(v-datastr) skip.
      run put_footer(p-var, yes, yes, no, yes).
    end.
  end.
end procedure.
/*********************************************************************/


/*Формирование справки о наличие у клиентов счетов Англ********************/
procedure pril123Engl.
  def input parameter p-var as char.
  run findaccs (p-var, yes, no, no, output vans).

  if vans then do:

    for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.

    n = accum count t-accs.aaa.
    i = 0.

    if n > 0 then do:
      run put_headerEngl (p-var).

      put stream rep unformatted
      "<P style=""text-align:justify"">" skip
      v-bankengl
      "&nbsp; HEREBY CONFIRMS THAT &nbsp;<U><B>" skip
      CAPS(v-cifname) skip.


 if n > 1 then
            put stream rep unformatted "</B></U> &nbsp; HAS ACCOUNTS &nbsp;#&nbsp;" skip.
      else
        put stream rep unformatted "</B></U> &nbsp; HAS ACCOUNT &nbsp;#&nbsp;"  skip.


      for each t-accs where t-accs.choice = "*":
        find last aab where aab.aaa = t-accs.aaa and aab.fdt <= v-dte no-lock no-error.

        v-sumdig = replace(trim(string(aab.bal, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").

        run Sm-vrd (aab.bal, output v-sumstr).

        run sm-wrdcrc (substr(v-sumdig, 1, length(v-sumdig) - 3), substr(v-sumdig, length(v-sumdig) - 1), t-accs.crc, output v-str1, output v-str2).
        v-sumstr = v-sumstr + "&nbsp;" + v-str1 + " " + substr(v-sumdig, length(v-sumdig) - 1) + "&nbsp;" + v-str2.

        find t-crcname where t-crcname.crc = t-accs.crc no-error.
        i = i + 1.
        put stream rep unformatted "<U><B>&nbsp;" t-accs.aaa ",</U></B>" skip.
      end.
      put stream rep unformatted "&nbsp;OPENED WITH US AS OF &nbsp;" + string(g-today, "99/99/9999") skip.
      put stream rep unformatted "</P>" skip.
      run put_footerEngl(p-var, yes, yes, no, yes).
    end.
  end.
end procedure.
/*********************************************************************/



/*Формирование справки о наличие у клиентов счетов с остатком средств********************/
procedure prtdoc10.
  def input parameter p-var as char.
  run findaccs (p-var, yes, no, no, output vans).

  if vans then do:
    for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.
    n = accum count t-accs.aaa.
    i = 0.

    if n > 0 then do:
      run put_header ("10").
/*приводит текущую дату к формату "01 января 2003"********************/
      run pkdefdtstr(v-dte, output v-datastr, output v-datastrkz).
/*********************************************************************/
      put stream rep unformatted "<P style=""text-align:justify"">" skip
                                 "СОГЛАСНО ЗАПРОСУ КЛИЕНТА &nbsp;<U><B>" skip
                                 CAPS(v-cifname) skip
                                 "</B></U>&nbsp; ПОДТВЕРЖДАЕМ НАЛИЧИЕ У НЕГО В &nbsp;" v-bankname " &nbsp;" skip.

      if n > 1 then put stream rep unformatted "ТЕКУЩИХ СЧЕТОВ&nbsp;" skip.
               else put stream rep unformatted "ТЕКУЩЕГО СЧЕТА&nbsp;" skip.

      for each t-accs where t-accs.choice = "*":
          find last aab where aab.aaa = t-accs.aaa and aab.fdt <= v-dte no-lock no-error.
          v-sumdig = replace(trim(string(aab.bal, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").
          run Sm-vrd (aab.bal, output v-sumstr).
          run sm-wrdcrc (substr(v-sumdig, 1, length(v-sumdig) - 3), substr(v-sumdig, length(v-sumdig) - 1), t-accs.crc, output v-str1, output v-str2).
          v-sumstr = v-sumstr + " " + v-str1 + " " +
          substr(v-sumdig, length(v-sumdig) - 1) + " " + v-str2.
          find t-crcname where t-crcname.crc = t-accs.crc no-error.

          i = i + 1.
          put stream rep unformatted "<BR>#&nbsp;<U><B>" t-accs.aaa "</B></U>&nbsp;С ОСТАТКОМ СРЕДСТВ&nbsp;<U><B>"
          v-sumdig "&nbsp;" t-accs.crccode " (" CAPS(v-sumstr) ")</B></U>&nbsp;НА&nbsp;<U>" CAPS(v-datastr) "</U>&nbsp;г."
          if i = n then "." else ","
          skip.
      end.
      run put_footer("10", yes, yes, no, yes).
    end.
  end.
end.

/*********************************************************************/
/*Формирование справки о наличие у клиентов счетов с остатком средств********************/
procedure prtdoc10Engl.
  def input parameter p-var as char.
  run findaccs (p-var, yes, no, no, output vans).
  if vans then do:
    for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.
    n = accum count t-accs.aaa.
    i = 0.

    if n > 0 then do:
      run put_headerEngl ("10").
      put stream rep unformatted "<P style=""text-align:justify"">" skip
                   v-bankengl "&nbsp;HEREBY CONFIRMS THAT &nbsp;<U><B>" skip CAPS(v-cifname) skip.

      if n > 1 then
            put stream rep unformatted "</B></U> &nbsp; HAS ACCOUNTS &nbsp;" skip.
      else
            put stream rep unformatted "</B></U> &nbsp; HAS ACCOUNT &nbsp;" skip.

      for each t-accs where t-accs.choice = "*":
          find last aab where aab.aaa = t-accs.aaa and aab.fdt <= v-dte no-lock no-error.
          v-sumdig = replace(trim(string(aab.bal, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").
          run Sm-vrd (aab.bal, output v-sumstr).
          run sm-wrdcrc (substr(v-sumdig, 1, length(v-sumdig) - 3), substr(v-sumdig, length(v-sumdig) - 1), t-accs.crc, output v-str1, output v-str2).
          v-sumstr = v-sumstr + "&nbsp;" + v-str1 + " " + substr(v-sumdig, length(v-sumdig) - 1) + "&nbsp;" + v-str2.
          find t-crcname where t-crcname.crc = t-accs.crc no-error.
          i = i + 1.
          put stream rep unformatted "<BR><U><B> " t-accs.aaa + " " + "</B></U> &nbsp; OPENED WITH US WITH TOTAL BALANCE AVAILABLE ON THE ABOVE ACCOUNT IN THE AMOUNT OF &nbsp;<U><B>"
          v-sumdig " &nbsp; " t-accs.crccode "</B></U>&nbsp; AS OF &nbsp;<U><B>" string(g-today, "99/99/9999") "</B></U>"
          if i = n then "." else ","
          skip.
      end.
      run put_footerEngl("10", yes, yes, no, yes).
    end.
  end.
end.
/*********************************************************************/


procedure put_footer.
  def input parameter p-var as char.
  def input parameter p-bdata as logical.
  def input parameter p-chief as logical.
  def input parameter p-ofc as logical.
  def input parameter p-stamp as logical.

  put stream rep unformatted
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
        "<TR valign=""top"">" skip
           "<TD width=""60%"" align=""left"">ДИРЕКТОР ОПЕРАЦИОННОГО ДЕПАРТАМЕНТА</TD>" skip
           "<TD width=""40%"" align=""center"">" der_dep "</TD>" skip
       "</TR>"
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
       "</TABLE>" skip.


  put stream rep unformatted
    "<TR><TD align=""center"" style=""font:bold; font-size:9.0pt""><HR noshade color=""black"" size=""3"">" v-bankfull "</TD></TR>" skip.
    {html-end.i "stream rep"}

    output stream rep close.
    unix silent value("cptwin " + f-name + ".htm winword").
end procedure.


procedure put_footerEngl.
  def input parameter p-var as char.
  def input parameter p-bdata as logical.
  def input parameter p-chief as logical.
  def input parameter p-ofc as logical.
  def input parameter p-stamp as logical.

  put stream rep unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "<TR valign=""top"">" skip
    "<TD width=""60%"" align=""left"">DIRECTOR OF OPERATION DEPARTMENT</TD>" skip
    "<TD width=""40%"" align=""center""> </TD>" skip
    "</TR>"
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "</TABLE>" skip.


  put stream rep unformatted
    "<TR><TD align=""center"" style=""font:bold; font-size:9.0pt""><HR noshade color=""black"" size=""3"">"  v-bankfull "</TD></TR>" skip.
  {html-end.i "stream rep"}
  output stream rep close.
  unix silent value("cptwin " + f-name + ".htm winword").
end procedure.


procedure prtdoc1.
  run pril123 ("1").
end procedure.

procedure prtdoc2.
 run pril123Engl ("2").
end procedure.

procedure prtdoc3.
  run prtdoc10("3").
end procedure.

procedure prtdoc4.
  run prtdoc10Engl("4").
end procedure.


