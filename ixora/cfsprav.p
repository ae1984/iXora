/* cfsprav.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Справки по счетам клиентов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1.13
 * BASES
        BANK COMM
 * AUTHOR
        25.03.2003 nadejda
 * CHANGES
        16.06.2003 nadejda - вынесла формирование строки реквизитов банка в отдельную процедуру
        20.08.2003 nadejda - отключила проверку КНП в справках 6-9, поскольку в старых транзакциях его не было и идут ошибки
        12.09.2003 nadejda - в справке 10 поменяла число, выдаваемое в справке - остаток на конец периода - последний остаток закрытого опердня с этой датой, т.е. НА утро следующего опердня, поэтому выдаем v-dte + 1
        11.01.2004 nadejda - при поиске в jl поменяла условие поиска по jl.gl на jl.lev, иначе не брались проводки по старому плану счетов
        20.02.2004 tsoy    - Доработана pril123
                             Добавлена процедура prtdoc12
                             Добавлены функции IsFindCurDebtsK2
                                               IsFindCurDebtsLon
                                               IsFindDebtsLonByPeriod
                                               IsFindDebtsK2ByPeriod
        27.02.2004 tsoy    - Добавлена проверка на претензии к счету за период такие как предписания
        01.09.2004 dpuchkov - добавил ограничение на просмотр.
        08.04.2004 dpuchkov - запись удачных попыток
        10.11.2004 dpuchkov - не печатать справки (по ссудн задолжн) если есть ссудная задолженность ТЗ 1184.
        24.11.2004 dpuchkov - добавил справку по счетам по запросу нац банка ТЗ 1118
        20.05.2005 dpuchkov - изменил справку для участия в тендере фраза 'отсутствие просроченной ссудной задолженности' звучит как 'отсутствие просроченной задолженности по всем видам обязательств '
                              служебка от 20.05.05.
        17/06/2005 madiar  - изменил проверку на наличие ссудной задолженности, раньше проверялась просрочка
        31.08.2006 u00124  - оптимизация
        26.09.2006 u00777  - Добавлены процедуры put_headerEngl
                                                 put_footerEngl
                                                 findacc2
                             Доработаны процедуры findaccs,pril123. Реализован выбор языка (анг./рус),
                             выбор типа счета (депозитные/текущие),выбор конкретных счетов при формировании
                             справок "Остаток средств на счете", "О наличии счета".
        29.09.2006 u00777   - Добавлена переменная - название банка на англ. языке.
        25.08.2008 galina - дата закрытия счета из таблицы sub-cod
                            поменяла формы справок и добавила новую справку под номером 13 в соотвествии со служебной запиской от 15.08.2008
        12.09.2008 galina - изменила шрифт для исполнителя, убрала линии в заголовке
                            раскомитила концовку для справки 2 и 3 (и отсуствии задолженности...)
                            привела в соотвествие текст справок 8,9,10
        09.07.2010 aigul - добавила строку для подписи главного бухгалтера в справке для участия в тендере
        13/10/2010 aigul - добавила формирование ежемесячного отчета в 4 и 5 пункте
        15/10/2010 aigul - обнуление суммы конечной даты месяца ежемесячного отчета в 4 и 5 пункте
        29/11/2010 Luiza - в п.м. 1.4.4.10 "Справка для участия в тендере" подпункт 12, добавила вывод номера телефона и измен послед-ть вывода БИК и ИИК
        25/11/2011 evseev - ТЗ1119, вывод в справке бин/иин
        02.02.2012 lyubov - добавила в выборку сим.касспл. условие "cashpl.act"
        28.03.2012 damir - корректировка текста при выводе WORD согласно СЗ от 28.03.2012, t-docs.code = 12.
        02/04/2012 id00810 - использование v-bankname для печати
        25.04.2012 Lyubov - в v-bankname складывается полное наименование филиала, убрала картинку в фоном
        04/05/2012 evseev - изменил путь к логотипу
        25.10.2012 damir - корректировка текста при выводе WORD согласно СЗ от 25.10.2012, t-docs.code = 12.
*/

{mainhead.i}
{trim.i}

def var v-datastrkz as char no-undo.

def var v-docs as char init "
1.  о налич.счетов клиента|
2.  о налич.счетов и отсутствии ссудной задолженности|
3.  о налич.счетов и отсутствии ссуд.задолж-ти,К-2 и претензий к счету|
4.  об оборотах по счетам за период (дебет - кредит)|
5.  об оборотах по счетам за период и отсутствии ссудной задолженности|
6.  о наличных поступлениях (дебет-касса - кредит-счет)|
7.  об отсутствии наличных поступлений|
8.  ""Наличные на зарплату не выдавались""|
9.  ""Наличные не выдавались""|
10. ""Остаток средств на счете""|
11. ""Операции не проводились, кроме комиссии""|
12. ""Справка для участия в тендере""|
13. ""Взносы наличности в качестве торговой выручки не производились""|
".

define var choice as logic.
def var vans as logical                   no-undo.
def var i as integer                      no-undo.
def var n as integer                      no-undo.
def var s as char                         no-undo.
def var v-cif as char                     no-undo.
def var v-cifname as char                 no-undo.
def new shared var s-cif as char.
def new shared var s-aaa as char.
def var v-cifdt as date                   no-undo.
def var v-dtb as date format "99/99/9999" no-undo.
def var v-dte as date format "99/99/9999" no-undo.
def new shared var s-dtb as date format "99/99/9999".
def new shared var s-dte as date format "99/99/9999".
def var v-dt as date                      no-undo.
def var v-dtcheck as date                 no-undo.
def var v-str1 as char                    no-undo.
def var v-str2 as char                    no-undo.
def var v-datastr as char                 no-undo.
def var v-bankname as char                no-undo.
def var v-bnknm as char                   no-undo.
def var v-bankrnn as char                 no-undo.
def var v-bankokpo as char                no-undo.
def var v-bankbik as char                 no-undo.
def var v-bankiik as char                 no-undo.
def var v-bankfull as char                no-undo.
def var v-grups as char                   no-undo.
def var v-glcash as integer               no-undo.
def var v-availempty as logical           no-undo.
def var v-symkas as char                  no-undo.
def var v-sumdig as char                  no-undo.
def var v-sumstr as char                  no-undo.
def var v-sign1 as char                   no-undo.
def var v-sign2 as char                   no-undo.
def var od as integer                     no-undo.
def var v-grups2 as char                  no-undo. /*Для типа счета*/
def var v-type1 as integer                no-undo.
def var v-lang1 as integer                no-undo.
def var v-typen as char                   no-undo.
def var v-langn as char                   no-undo.
def var v-ciftyp as char                  no-undo.
def var v-engname as char                 no-undo. /*Название банка на англ. языке*/



def var dt1 as date no-undo. /* начало периода */
def var dt2 as date no-undo. /* конец периода */

def var dtc as date no-undo.
def var year as integer.
def var month as integer.
def var cs as decimal.
def var ds as decimal.

def new shared temp-table wrk
    field acc as char
    field jdt as date
    field dt as date
    field dtb as date
    field dte as date
    field cs as decimal
    field ds as decimal.

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

/*********/
def new shared temp-table t-lang no-undo
    field id_lang as integer
    field nm_lang as char
index id_lang id_lang.

create t-lang.
assign t-lang.id_lang = 1
       t-lang.nm_lang = "Русский".
create t-lang.
assign t-lang.id_lang = 2
       t-lang.nm_lang = "Английский".


def new shared temp-table t-type no-undo
    field id_type as integer
    field nm_type as char
index id_type id_type.
create t-type.
assign t-type.id_type = 1
       t-type.nm_type = "Текущие".

def buffer b-jl for jl.

def temp-table t-symkas
  field sim as integer
  field sum as decimal
  index sim is primary sim.


def temp-table t-docs
  field code as integer
  field choice as char
  field name as char
  index main is primary unique code.

def temp-table t-crcname
  field crc as integer
  field name as char
  index crc is primary unique crc.

def stream rep.

do i = 1 to num-entries(v-docs, "|"):
  create t-docs.
  assign t-docs.code = i
         t-docs.name = entry(i, v-docs, "|").
end.

for each crc no-lock:
  create t-crcname.
  t-crcname.crc = crc.crc.

  case crc.crc:
    when 1 then t-crcname.name  = "тенге".
    when 2 then t-crcname.name  = "долларах США".
    when 3 then t-crcname.name  = "евро".
    /*when 3 then t-crcname.name  = "немецких марках".*/
    when 4 then t-crcname.name  = "российских рублях".
    when 5 then t-crcname.name  = "украинских гривнах".
    /*when 11 then t-crcname.name = "евро".
    when 12 then t-crcname.name = "швейцарских франках".*/
    otherwise t-crcname.name    = crc.code.
  end case.
end.

assign v-cif = ""
       v-cifname = "".

def frame f-client
  v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)" validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
  v-cifname no-label format "x(45)" colon 18  with side-label row 4 no-box.
update v-cif with frame f-client.

find first cif where cif.cif = v-cif no-lock no-error.
v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
v-cifdt = cif.regdt.
  find last cifsec where cifsec.cif = cif.cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "2.4.15 Справки по счетам клиентов".
          return.
     end.
     else
     do:
        create ciflogu.
        assign
          ciflogu.ofc = g-ofc
          ciflogu.jdt = today
          ciflogu.sectime = time
          ciflogu.cif = cif.cif
          ciflogu.menu = "2.4.15 Справки по счетам клиентов" .
     end.

  end.


displ v-cifname with frame f-client.

run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).
find first cmp no-lock no-error.
/*v-bankname = caps(cmp.name).*/
v-bankrnn = cmp.addr[2].
if cmp.code = 0 then v-bankokpo = substr(cmp.addr[3], 1, 8). else v-bankokpo = cmp.addr[3].

{sysc.i}
v-bankbik = get-sysc-cha ("clecod").
if v-bankbik = ? then v-bankbik = "".
v-bankiik = get-sysc-cha ("bnkiik").
if v-bankiik = ? then v-bankiik = "".
v-bnknm = get-sysc-cha ("bankname").
if v-bnknm = ? then v-bnknm = "".
/*29/09/06 u00777*/
v-engname = get-sysc-cha ("bnkadr").
if v-engname =? then v-engname = "".
else v-engname = entry(10,v-engname,"|") no-error.

if v-bnknm <> "" then do:
    find sysc where sysc.sysc = 'ourbnk' no-lock no-error.
    if sysc.chval = 'TXB00' then v-bankname = 'АО ' + v-bnknm.
    else do:
        v-bankname = 'Филиал АО ' + v-bnknm.
        case sysc.chval:
            when 'TXB01' then v-bankname = v-bankname + ' по Актюбинской области '.
            when 'TXB02' then v-bankname = v-bankname + ' по Костанайской области '.
            when 'TXB03' then v-bankname = v-bankname + ' по Жамбылской области '.
            when 'TXB04' then v-bankname = v-bankname + ' по Западно-Казахстанской области '.
            when 'TXB05' then v-bankname = v-bankname + ' по Карагандинской области '.
            when 'TXB06' then v-bankname = v-bankname + ' в городе Семей '.
            when 'TXB07' then v-bankname = v-bankname + ' по Акмолинской области '.
            when 'TXB08' then v-bankname = v-bankname + ' в городе Астана '.
            when 'TXB09' then v-bankname = v-bankname + ' по Павлодарской области '.
            when 'TXB10' then v-bankname = v-bankname + ' по Северо-Казахстанской области '.
            when 'TXB11' then v-bankname = v-bankname + ' по Атырауской области '.
            when 'TXB12' then v-bankname = v-bankname + ' по Мангистауской области '.
            when 'TXB13' then v-bankname = v-bankname + ' в городе Жезказган '.
            when 'TXB14' then v-bankname = v-bankname + ' по Восточно-Казахстанской области '.
            when 'TXB15' then v-bankname = v-bankname + ' по Южно-Казахстанской области '.
            when 'TXB16' then v-bankname = v-bankname + ' в городе Алматы '.
        end case.
    end.
end.

run defbnkreq (output v-bankfull).

find sysc where sysc.sysc = "vc-agr" no-lock no-error.
v-grups = sysc.chval.

find sysc where sysc.sysc = "cashgl" no-lock no-error.
v-glcash = sysc.inval.

find sysc where sysc.sysc = "sprpar" no-lock no-error.
if not avail sysc then do:
  create sysc.
  assign sysc.sysc  = "sprpar"
         sysc.des   = "Параметры справок по счетам клиентов"
         sysc.chval = "Зам. Председателя Правления|Главный бухгалтер".
  find current sysc no-lock.
end.
if num-entries(sysc.chval, "|") > 0 then v-sign1 = entry(1, sysc.chval, "|").
if num-entries(sysc.chval, "|") > 1 then v-sign2 = entry(2, sysc.chval, "|").

/*Определение типа клиента u00777*/
find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'clnsts' no-lock no-error.
if avail sub-cod then
   v-ciftyp = sub-cod.ccode.

/*Для физ. лица выдаются справки по депозитным счетам u00777*/

if v-ciftyp = "1" then do:
   create t-type.
   assign t-type.id_type = 2
       t-type.nm_type = "Депозитные".
   create t-type.
   assign t-type.id_type = 3
       t-type.nm_type = "Все".
end.

define frame f-params
  v-sign1 label " ПЕРВАЯ ПОДПИСЬ " format "x(50)" help " Должность лица с правом первой подписи"
  v-sign2 label " ВТОРАЯ ПОДПИСЬ " format "x(50)" help " Должность лица с правом второй подписи"
  with overlay centered side-label row 10 title " ПАРАМЕТРЫ СПРАВОК ".

define frame f-footer
  "<ENTER>- справка         <S>- настройка"
  with overlay centered no-label row 20 no-box.

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
  def var l-leave as logical init false.
  l-leave = false.
  for each t-docs where t-docs.choice = "*":
         if t-docs.code = 2 or t-docs.code = 3 or  t-docs.code = 5  then do:
             for each lon where lon.cif = cif.cif no-lock:
                 run lonbalcrc('lon', lon.lon, g-today, "1,7", lon.crc, yes, output od).
                 if od <> 0 then do:
                     message "У клиента имеется ссудная задолженность."
                     view-as alert-box question buttons ok title "".
                     l-leave = True.
                     leave.
                 end.
                 else l-leave = False.
             end.
             if l-leave then leave.
         end.

    run value ("prtdoc" + string(t-docs.code)).
  end.

  if not can-find(first t-docs where t-docs.choice = "*") then leave.
end.


procedure put_header.

  def input parameter p-var as char.

  def var v-exist as char.

  output stream rep to value("sprav" + p-var + ".htm").

  {html-title.i &stream = "stream rep" &title = " " &size-add = " "}
       put stream rep unformatted
       "<P><BR><BR><BR><BR><BR><BR><BR><BR><BR></P>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" style=""font-family:Arial; font-size:11.0pt"">" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""left"">" skip
          v-datastr skip
          " г."
           /*"<HR noshade color=""black"" size=""1"" align=""left"" width=""50%""></font></TD>" skip*/
           "<TD width=""40%"" align=""right"">"
           "По месту требования<BR><BR>"
           /*"<HR noshade color=""black"" size=""1""><BR>"
           "<HR noshade color=""black"" size=""1"">" skip*/
           "</TD>" skip
         "</TR>"
       "</TABLE>" skip
       "<P><BR><BR><BR><BR><BR></P>" skip.
end procedure.

/*Формирования заголовка для справки на анг.яз.u00777*/
procedure put_headerEngl.
  def input parameter p-var as char.

  output stream rep to value("sprav" + p-var + ".htm").
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

procedure put_footer_for_tender.
  def input parameter p-var as char.
  def input parameter p-bdata as logical.
  def input parameter p-chief as logical.
  def input parameter p-ofc as logical.
  def input parameter p-stamp as logical.

 put stream rep unformatted
       "<P><BR><BR><BR><BR><BR><BR><BR></P>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" style=""font-family:Arial; font-size:11.0pt"">" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""left"">" skip
          "Уполномоченное лицо Банка<BR></TD></TR>" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""center""><BR>" skip
          "<HR noshade color=""black"" size=""1"" width=""80%"">"
           "Должность</TD>"
           "<TD rowspan""2"" width=""40%"" align=""center""><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "(Ф.И.О.)<BR><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "Подпись"
           "</TD>" skip
         "</TR>"
       "</TABLE>" skip.

 put stream rep unformatted

       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" style=""font-family:Arial; font-size:11.0pt"">" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""left"">" skip
          "Главный бухгалтер<BR></TD></TR>" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""center""><BR>" skip
          "<HR noshade color=""black"" size=""1"" width=""80%"">"
           "Должность</TD>"
           "<TD rowspan""2"" width=""40%"" align=""center""><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "(Ф.И.О.)<BR><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "Подпись"
           "</TD>" skip
         "</TR>"
       "</TABLE>" skip.


    /*if p-ofc then do:*/
        find ofc where ofc.ofc = g-ofc no-lock no-error.
        if avail ofc then
            put stream rep unformatted
             "<P align=""left"" style=""font-family:Arial; font-size:9.0pt""><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель: " ofc.name "</P>" skip.
        else put stream rep unformatted
             "<P align=""left"" style=""font-family:Arial; font-size:9.0pt""><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель:</P>" skip.

    /*end.
    else  put stream rep unformatted
        "<P align=""left""><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель:</P>" skip.  */

  {html-end.i "stream rep"}

  output stream rep close.
  unix silent value("cptwin sprav" + p-var + ".htm winword").
end procedure.


procedure put_footer.
  def input parameter p-var as char.
  def input parameter p-bdata as logical.
  def input parameter p-chief as logical.
  def input parameter p-ofc as logical.
  def input parameter p-stamp as logical.

/*  put stream rep unformatted
    "</P><BR><TABLE width=""96%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
      "<TR valign=""top"">" skip
        "<TD width="""
        if p-bdata then "55" else "70"
        "%"">" skip
          "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""5"" align=""left"">" skip.

  if p-chief then
  put stream rep unformatted
            "<TR valign=""top"">" skip
              "<TD width=""60%"" align=""left"">" if v-sign1 <> "" then caps(v-sign1) else "&nbsp;" "</TD>" skip
              "<TD><HR noshade color=""black"" size=""1"" align=""right""></TD>" skip
            "</TR>" skip.

  put stream rep unformatted
            "<TR valign=""top"">" skip
              "<TD align=""left"">" if v-sign2 <> "" then caps(v-sign2) else "&nbsp;" "</TD>" skip
              "<TD ><HR noshade color=""black"" size=""1"" align=""right""></TD>" skip
            "</TR>"skip.

  if p-ofc then do:
    find ofc where ofc.ofc = g-ofc no-lock no-error.
    put stream rep unformatted
            "<TR valign=""top"">" skip
              "<TD align=""left"">ИСПОЛНИТЕЛЬ</TD>" skip
              "<TD>"
              ofc.name
              "</TD>" skip
            "</TR>" skip.
  end.

  if p-stamp then
    put stream rep unformatted
              "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
              "<TR><TD align=""right"">М.П.</TD><TD>&nbsp;</TD></TR>" skip.

  put stream rep unformatted
            "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip
          "</TABLE>" skip
        "</TD>" skip
        "<TD width="""
        if p-bdata then "45" else "30"
        "%"">" skip.

  if p-bdata then
    put stream rep unformatted
          "<TABLE width=""80%"" border=""0"" cellspacing=""0"" cellpadding=""3"" align=""right"">" skip
            "<TR valign=""top"">" skip
              "<TD width=""50%"" align=""left"">РНН:</TD>" skip
              "<TD align=""left"">" v-bankrnn "</TD>" skip
            "</TR>"
            "<TR valign=""top"">" skip
              "<TD align=""left"">БИК:</TD>" skip
              "<TD align=""left"">" v-bankbik "</TD>" skip
            "</TR>"
            "<TR valign=""top"">" skip
              "<TD align=""left"">КОР.СЧЕТ:</TD>" skip
              "<TD align=""left"">" v-bankiik "</TD>" skip
            "</TR>"
            "<TR valign=""top"">" skip
              "<TD align=""left"">ОКПО:</TD>" skip
              "<TD align=""left"">" v-bankokpo "</TD>" skip
            "</TR>"
          "</TABLE>" skip.
  else put stream rep unformatted "&nbsp;" skip.


  put stream rep unformatted
        "</TD>" skip
      "</TR>"
    "</TABLE>" skip
    "</TD></TR>" skip
    "<TR><TD align=""center"" style=""font:bold; font-size:9.0pt"">Данная информация предоставляется без какой-либо ответственности для Банка и его сотрудников.</TD></TR>" skip
    "<TR><TD align=""center"" style=""font:bold; font-size:9.0pt""><HR noshade color=""black"" size=""3"">"
    v-bankfull
    "</TD></TR>" skip
    "</TABLE>" skip.*/

     put stream rep unformatted
       "<P><BR><BR><BR><BR><BR><BR><BR></P>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" style=""font-family:Arial; font-size:11.0pt"">" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""left"">" skip
          "Уполномоченное лицо Банка<BR></TD></TR>" skip
          "<TR valign=""top"">" skip
          "<TD width=""60%"" align=""center""><BR>" skip
          "<HR noshade color=""black"" size=""1"" width=""80%"">"
           "Должность</TD>"
           "<TD rowspan""2"" width=""40%"" align=""center""><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "(Ф.И.О.)<BR><BR>"
           "<HR noshade color=""black"" size=""1"" width=""70%"">"
           "Подпись"
           "</TD>" skip
         "</TR>"
       "</TABLE>" skip.

    /*if p-ofc then do:*/
        find ofc where ofc.ofc = g-ofc no-lock no-error.
        if avail ofc then
            put stream rep unformatted
             "<P align=""left"" style=""font-family:Arial; font-size:9.0pt""><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель: " ofc.name "</P>" skip.
        else put stream rep unformatted
             "<P align=""left"" style=""font-family:Arial; font-size:9.0pt""><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель:</P>" skip.

    /*end.
    else  put stream rep unformatted
        "<P align=""left""><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>Исполнитель:</P>" skip.  */

  {html-end.i "stream rep"}

  output stream rep close.
  unix silent value("cptwin sprav" + p-var + ".htm winword").
end procedure.

/*Формирования конца справки на англ. языке u00777*/
 procedure put_footerEngl.
  def input parameter p-var as char.
  put stream rep unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "<TR></TR>" SKIP
    "<TR valign=""top"">" skip
    "<TD width=""60%"" align=""left"">CHAIRMAN OF BOARD</TD>" skip
    "<TD width=""40%"" align=""center""> </TD>" skip
    "</TR>"
    "<TR></TR>" SKIP
    "<TR valign=""top"">" skip
    "<TD width=""60%"" align=""left"">CHIEF ACCOUNTER</TD>" skip
    "<TD width=""40%"" align=""center""> </TD>" skip
    "</TR>"
    "<TR></TR>" SKIP
    "</TABLE>" skip.


  put stream rep unformatted
    "<TR><TD align=""center"" style=""font:bold; font-size:9.0pt""><HR noshade color=""black"" size=""3"">"  v-bankfull "</TD></TR>" skip.


  {html-end.i "stream rep"}
  output stream rep close.
  unix silent value("cptwin sprav" + p-var + ".htm winword").
end procedure.



def temp-table t-vars
    field name as char
    index main is primary name.


/*
 * Функция возвращет true если у клиента есть К2
*/
function IsFindCurDebtsK2 returns logical( p_aaa as char).

    def var v_ret as logical.

    def var v-payee as char  init "K2,K-2,К2,К-2,ПРЕДП".
    def var ii as integer initial 0.


    do ii = 1 to num-entries(v-payee) :
        create t-vars.
        t-vars.name = caps(entry(ii, v-payee)).
    end.

    v_ret=false.
    for each aas where aas.aaa = p_aaa no-lock:
       if can-find(first t-vars where index(caps(aas.payee), t-vars.name) > 0) then return true.
    end.

return v_ret.

end function.

/*
 * Функция возвращет true если у клиента есть Cсудная задолжность
*/
function IsFindCurDebtsLon returns logical(p_cif as char).
    def var v_ret as logical.
    v_ret=false.
    for each lon where lon.cif = p_cif no-lock:
             find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 7 no-lock no-error.
             v_ret = avail trxbal and (trxbal.dam - trxbal.cam) > 0.
             if v_ret then return v_ret.
             find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 9 no-lock no-error.
             v_ret = avail trxbal and (trxbal.dam - trxbal.cam) > 0.
             if v_ret then return v_ret.
             find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 16 no-lock no-error.
             v_ret = avail trxbal and (trxbal.dam - trxbal.cam) > 0.
             if v_ret then return v_ret.
             find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 21 no-lock no-error.
             v_ret = avail trxbal and (trxbal.dam - trxbal.cam) > 0.
             if v_ret then return v_ret.
             find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 23 no-lock no-error.
             v_ret = avail trxbal and (trxbal.dam - trxbal.cam) > 0.
             if v_ret then return v_ret.
   end.
return v_ret.

end function.

form
  v-langn format "x(10)" colon 25 label "Язык"
  help " Выберите язык для формирования справки - F2" skip
  v-typen format "x(10)" colon 25  label "Тип счета"
  help " Выберите тип счета - F2" skip
  with overlay width 60 centered row 6 side-label title " ДОПОЛНИТЕЛЬНЫЕ
  ПАРАМЕТРЫ"
frame f-par.

function check-accs returns logical (input p-value as char, input p-availempty as logical).
  if p-value = "" then
    return p-availempty.

  do i = 1 to num-entries (p-value):
    find t-accs where t-accs.aaa = entry(i, p-value) no-error.
    if not avail t-accs then return false.
  end.

  return true.
end function.


form
  v-str1 format "x(50)" label " Номера счетов " colon 25
  help " Введите счета через запятую или оставьте пустым для ВСЕХ счетов"
  validate (check-accs(v-str1,yes), " Недопустимый номер счета!") skip
  with overlay width 78 centered row 6 side-label title " СПРАВКА : " + t-docs.name + " " frame f-acc.



procedure findacc2.
    def input-output parameter vans as logical.
   /*Определение типа счета и выбор языка u00777*/
    displ v-langn v-typen with frame f-par.

    on help of v-langn in frame f-par do:
       run cfsprav-lang(output v-lang1,output v-langn).
       displ v-langn  v-typen with frame f-par.
    end.
    on help of v-typen in frame f-par do:
      run cfsprav-type(output v-type1,output v-typen).
      displ v-langn v-typen with frame f-par.
    end.

    update v-langn v-typen with frame f-par.
    hide frame f-par no-pause.

    if v-type1 > 1 then do:
       v-grups2 = "".
     /*Список депозитных счетов*/
       for each lgr no-lock:
          if lgr.led = "TDA" or lgr.led = "CDA" then
             v-grups2 = v-grups2 + "," + trim(lgr.lgr).
       end.
       if v-type1 = 2 then v-grups2 = substring(v-grups2,2).
       else v-grups2 = v-grups + v-grups2.
    end.

    for each t-accs. delete t-accs. end.

    for each aaa where aaa.cif = v-cif no-lock:
       /* берем только ТЕКУЩИЕ/ДЕПОЗИТНЫЕ СЧЕТА */
       if lookup(aaa.lgr, v-grups2) = 0 then next.

       /* закрытые на дату начала периода счета не обрабатываем */
       if aaa.sta = "c" then next.

       if  aaa.crc <> 1 and vans = no then  next.

       find crc where crc.crc = aaa.crc no-lock no-error.

       create t-accs.
       assign t-accs.aaa = aaa.aaa
              t-accs.gl = aaa.gl
              t-accs.crc = aaa.crc
              t-accs.crccode = crc.code.
    end.

    vans = yes.
    if not can-find(first t-accs) then do:
      vans = no.
      message skip " Нет доступных счетов ! Печатать пустую справку ?" skip(1)
      view-as alert-box buttons yes-no title "" update vans.
    end.

    if vans then do:
       on help of v-str1 in frame f-acc do:
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

              displ v-str1 with frame f-acc.
          end.

          update v-str1 with frame f-acc.
         /* hide frame f-acc no-pause. */

          if v-str1 = "" then
             for each t-accs:
                if t-accs.crc <> 1 then
                     v-str2  =  v-str2 + ", "  + t-accs.aaa + "(" + t-accs.crccode + ")".
                 else
                     v-str1  =  v-str1 + ", " + t-accs.aaa.
             end.
          else do:
             v-str1 = "".
             for each t-accs:
                 if t-accs.choice = "*" then do:
                    if t-accs.crc <> 1 then
                        v-str2  =  v-str2 + ", " + t-accs.aaa + "(" + t-accs.crccode + ")".
                    else
                        v-str1  =  v-str1 + ", " + t-accs.aaa.
                 end.
            end.
          end.
          assign v-str1 = substring(v-str1,2)
                 v-str2 = substring(v-str2,2).
          hide frame f-acc no-pause.
   end.
else hide frame f-par no-pause.
end procedure.

procedure pril123.
  def input parameter p-var as char.

  def var v-k2 as logical.
  def var v-lon as logical.

  v-grups2 = v-grups.

  find first t-type no-error.
  if avail t-type then
     assign  v-type1 = t-type.id_type
             v-typen = t-type.nm_type.

  find first t-lang no-error.
  if avail t-lang then
     assign  v-lang1 = t-lang.id_lang
             v-langn = t-lang.nm_lang.

  v-k2   = false.
  v-lon  = false.

  vans = yes.

  find t-docs where t-docs.code = integer(p-var) no-error.
  message skip " Показать ВСЕ текущие счета (Yes) или только в ТЕНГЕ (No) ? " skip(1) view-as alert-box buttons yes-no title " СПРАВКА : " + t-docs.name + " "
  update vans.

  v-str1 = "".
  v-str2 = "".

  if p-var ne "1" then do:
     for each aaa where aaa.cif = v-cif no-lock:
        /* закрытые счета не обрабатываем */
        if aaa.sta = "c" then next.
        /* берем только ТЕКУЩИЕ/ДЕПОЗИТНЫЕ СЧЕТА */
        if lookup(aaa.lgr, v-grups2) = 0 then next.
        v-lon = IsFindCurDebtsLon(aaa.cif).

        if aaa.crc = 1 then do:
          if v-str1 <> "" then v-str1 = v-str1 + ", ".
          v-str1 = v-str1 + aaa.aaa.
          if not v-k2 then v-k2 = IsFindCurDebtsK2(aaa.aaa).
        end.

       if aaa.crc <> 1 and vans then do:
         if v-str2 <> "" then v-str2 = v-str2 + ", ".
            find crc where crc.crc = aaa.crc no-lock no-error.
            v-str2 = v-str2 + aaa.aaa + "&nbsp;(" + crc.code + ")".
           if not v-k2 then v-k2 = IsFindCurDebtsK2 (aaa.aaa).
       end.
     end.

     vans = yes.
     if v-str1 = "" and v-str2 = "" then do:
        vans = no.
        message skip " Нет доступных счетов ! Печатать пустую справку ?" skip(1)
                view-as alert-box buttons yes-no title "" update vans.
     end.
  end.
  else
     run findacc2(input-output vans).
 case p-var :
    when "2" then
          if v-lon then do:
            message skip " Есть ссудная задолжность" skip(1)
                  view-as alert-box buttons ok title "".
            vans = no.
          end.
    when "3" then do:
          if v-k2 and v-lon then do:
             message skip " Есть спец. инструкции и ссудная задолжность" skip(1)
                   view-as alert-box buttons ok title "".
             vans = no.
          end.
          else do:
               if v-k2 then do:
                  message skip " Есть спец. инструкции " skip(1)
                        view-as alert-box buttons ok title "".
                  vans = no.
               end.

               if v-lon then do:
                  message skip " Есть ссудная задолжность " skip(1)
                        view-as alert-box buttons ok title "".
                  vans = no.
               end.
          end.
    end.
  end case.

  if vans then do:
   if v-lang1  ne 2 then do:
    run put_header(p-var).

    /*put stream rep unformatted
      "<P style=""text-align:justify"">" skip
      "СОГЛАСНО ЗАПРОСУ КЛИЕНТА <U><I><B>" skip
      v-cifname
      "</B></I></U> ПОДТВЕРЖДАЕМ НАЛИЧИЕ У НЕГО В " v-bankname skip.
      case v-type1:
        when 2 then put stream rep unformatted
          " ДЕПОЗИТНОГО СЧЕТА" skip
          "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
          "<TR valign=""top"" align=""left"">" skip
          "<TD width=""5"">В&nbsp;ТЕНГЕ&nbsp;&nbsp;</TD><TD><I><B>" skip
          v-str1
          "</B></I></TD></TR>" skip.
        when 3 then put stream rep unformatted
          " ТЕКУЩЕГО/ДЕПОЗИТНОГО СЧЕТА" skip
          "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
          "<TR valign=""top"" align=""left"">" skip
          "<TD width=""5"">В&nbsp;ТЕНГЕ&nbsp;&nbsp;</TD><TD><I><B>" skip
          v-str1
          "</B></I></TD></TR>" skip.
        otherwise
             put stream rep unformatted
          " ТЕКУЩЕГО СЧЕТА" skip
          "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
          "<TR valign=""top"" align=""left"">" skip
          "<TD width=""5"">В&nbsp;ТЕНГЕ&nbsp;&nbsp;</TD><TD><I><B>" skip
          v-str1
          "</B></I></TD></TR>" skip.
      end case.


    if v-str2 <> "" then
      put stream rep unformatted
          "<TR valign=""top"" align=""left"">" skip
            "<TD>В&nbsp;ВАЛЮТЕ&nbsp;&nbsp;</TD><TD><I><B>" skip
            v-str2
            "</B></I></TD></TR>" skip.

    put stream rep unformatted
      "</TABLE>" skip.

    case p-var :
      when "2" then
         if not v-lon then do:
             put stream rep unformatted
                "И ОТСУТСТВИЕ ССУДНОЙ ЗАДОЛЖЕННОСТИ." skip.
         end.
      when "3" then do:
         if (not v-lon) and (not v-k2)  then do:
             put stream rep unformatted
                "ОТСУТСТВИЕ ССУДНОЙ ЗАДОЛЖЕННОСТИ, К-2 И ПРЕТЕНЗИЙ К СЧЕТУ." skip.
         end.
      end.
    end case.*/
    put stream rep unformatted
      "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
      "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает наличие".


    case v-type1:
        when 2 then put stream rep unformatted
          " депозитного счета " skip.
        when 3 then put stream rep unformatted
          " текущего/депозитного счета " skip.
        otherwise
             put stream rep unformatted
          " текущего счета " skip.
    end case.

    put stream rep unformatted
      "<strong>" + v-cifname + "</strong>" skip.

    if v-str1 <> "" then put stream rep unformatted
      " в тенге <B>" + v-str1 "</B>" skip.
    if v-str2 <> "" then put stream rep unformatted
       ", в иностранной валюте: <B>" + v-str2 + "</B>" skip.

    case p-var :
      when "2" then
         if not v-lon then do:
             put stream rep unformatted
                "и отсутствие ссудной задолженности перед Банком.</P>" skip.
         end.
      when "3" then do:
         if (not v-lon) and (not v-k2)  then do:
             put stream rep unformatted
                ".И отсутствие задолженности по займу перед Банком и К-2.</P>" skip.
         end.
      end.
      otherwise put stream rep unformatted ".</P>".
    end case.

    run put_footer(p-var, yes, yes, no, yes).
  end.

  /*Английская версия справки 26/09/2006 u00777*/
  else do:
      run put_headerEngl(p-var).
      if v-type1 = 2 then
         put stream rep unformatted
         "<P style=""text-align:justify"">&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS DEPOSIT " skip.

      else if v-type1 = 3 then
         put stream rep unformatted
         "<P style=""text-align:justify"">&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS CURRENT/DEPOSIT " skip.
      else
         put stream rep unformatted
         "<P style=""text-align:justify"">&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS CURRENT " skip.

     if (num-entries( v-str1 ) + num-entries( v-str2 )) > 1 then
         put stream rep unformatted "ACCOUNTS" skip.
     else
         put stream rep unformatted "ACCOUNT" skip.
      put stream rep unformatted "<U><I><B>&nbsp; "          trim(v-str1) skip.

      if v-str2 <> "" and v-str1 <> "" then
         v-str2 = ", " + v-str2.

      put stream rep unformatted  v-str2 "</U></I></B> &nbsp;OPENED WITH US AS OF &nbsp;" + string(g-today, "99/99/9999") + ".</P>" skip.
      run put_footerEngl(p-var).
  end.
end.
end procedure.


/*def temp-table waaatbl like aaa.
procedure prtdoc13. /*счета клиента*/
    def var ch_num_mail as char.
    def var dt_date_mail as date.
    def var ch_name as char.
    def var ch_fio as char.
    def var ch_jss as char.
    def var l_fnd as logical init false.

    for each waaatbl:
       delete waaatbl.
    end.


    define frame getlist1
       ch_num_mail format "x(30)" label "Введите номер письма НБ  " skip
       dt_date_mail  label              "Введите дату письма НБ   " skip
       ch_name format "x(50)" label     "Наименование адресата    " skip
       ch_fio  format "x(50)" label     "Ф.И.О Запраш. физ/юр лица" skip
       ch_jss  format "x(12)" label     "РНН   Запраш. физ/юр лица" skip
    with side-labels centered row 9.

    update ch_num_mail dt_date_mail ch_name ch_fio ch_jss with frame getlist1.

    if ch_jss <> "" then do:
       for each cif where cif.jss = ch_jss no-lock:
            for each aaa where aaa.cif = cif.cif and aaa.sta = "A" no-lock:
                 create waaatbl.
                        waaatbl.cr[1] = aaa.cr[1].
                        waaatbl.dr[1] = aaa.dr[1].
                        waaatbl.aaa = aaa.aaa.
                        waaatbl.cif = cif.cif.
                        find last crc where crc.crc = aaa.crc no-lock no-error.
                        if avail crc then do:
                           waaatbl.lgr =  crc.code.
                        end.
               l_fnd = True.
            end.
       end.
    end.


    if ch_name <> "" and not l_fnd then do:
       for each cif where cif.name = ch_fio no-lock:
            for each aaa where aaa.cif = cif.cif and aaa.sta = "A" no-lock:
                 create waaatbl.
                        waaatbl.cr[1] = aaa.cr[1].
                        waaatbl.dr[1] = aaa.dr[1].
                        waaatbl.aaa = aaa.aaa.
                        waaatbl.cif = cif.cif.
                        find last crc where crc.crc = aaa.crc no-lock no-error.
                        if avail crc then do:
                           waaatbl.lgr =  crc.code.
                        end.
               l_fnd = True.
            end.
       end.
    end.

    if not l_fnd then
    do:
       find last cif where cif.cif = v-cif no-lock no-error.
       if avail cif then do:
            for each aaa where aaa.cif = cif.cif and aaa.sta = "A" no-lock:
                 create waaatbl.
                        waaatbl.cr[1] = aaa.cr[1].
                        waaatbl.dr[1] = aaa.dr[1].
                        waaatbl.aaa = aaa.aaa.
                        waaatbl.cif = cif.cif.
                        find last crc where crc.crc = aaa.crc no-lock no-error.
                        if avail crc then do:
                           waaatbl.lgr =  crc.code.
                        end.
               l_fnd = True.
            end.
       end.
    end.

    /*  output stream rep to value("sprav300.htm"). */
                output stream rep to value("sprav300.htm").
                {html-title.i &stream = "stream rep" &title = " " &size-add = " "}
                put stream rep unformatted
                   "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
                   "<TR><TD align=""right""><img src=""c://tmp/top_logo_bw.jpg""></TD></TR>" skip

                   "<TR><TD><BR>" skip
                     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
                       "<TR valign=""top"">" skip
                         "<TD width=""70%"" align=""left"">" skip
                         v-datastr skip
                         " г."
                         "<HR noshade color=""black"" size=""1"" align=""left"" width=""50%""></TD>" skip

                         "<TD width=""40%"" align=""left"">"
                          ch_num_mail " от " dt_date_mail
                         "<BR width=""40%"" align=""left"">" ch_name "<BR>"
                         "</TD>" skip
                      "</TR>"

                     "</TABLE>" skip.


if not l_fnd then /*клиент не найден*/
                     put stream rep unformatted
                       "<P style=""text-align:justify"">" skip
                       "НА ЗАПРОС НАЦИОНАЛЬНОГО БАНКА РК N <U><I><B>" skip
                       ch_num_mail  "</B></I></U> от <U><I><B>"  dt_date_mail "</B></I></U> г.  сообщаем что " cif.name " в списках клиентов " v-bankname " не значится. </P>" skip.
else
do:
   find last waaatbl.
   find last cif where cif.cif = waaatbl.cif no-lock no-error.
                       put stream rep unformatted
                       "<P style=""text-align:justify"">" skip
                       "В ответ на запрос Национального Банка РК N <U><I><B>" skip
                       ch_num_mail "</B></I></U> от <U><I><B> " dt_date_mail " </U></I></B> " v-bankname " подтверждает наличие у " cif.name " РНН  " cif.jss " текущие счета: <TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip.

                       for each waaatbl no-lock :
                          put stream rep unformatted  "<TR valign=""top"" align=""left"">" skip.
                          put stream rep unformatted  "<td>        ИИК <B>" waaatbl.aaa "</B>  в " waaatbl.lgr ", с остатком денежных средств на " g-today "    <b>" waaatbl.cr[1] - waaatbl.dr[1] format "zzz,zzz,zzz,zzz,zz9.99"   " </B></td>" skip.
                       end.
                put stream rep unformatted  "</TABLE>" skip.
end.

    run put_footer("300", yes, yes, no, yes).
    output close.
end procedure.*/

procedure prtdoc13.
  form
  v-dtb  format "99/99/9999" label " Начальная дата периода " colon 25
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше сегодняшней!") skip
  with overlay width 78 centered row 6 side-label title " СПРАВКА : " + t-docs.name + " " frame f-period1.

  v-dtb = g-today.
  update v-dtb with frame f-period1.
  hide frame f-period1.

   /*19.08.2008 galina*/
  run pkdefdtstr(v-dtb, output v-datastr, output v-datastrkz).

  /*output stream rep to value("sprav13.htm"). */
  run put_header("13").
  put stream rep unformatted
      "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
      "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что <B>" v-cifname "</B> за период с момента от " v-datastr "г. по настоящее время взносы наличности в качестве торговой выручки не производились.".

  run put_footer("13", yes, yes, no, yes).
   output close.
end procedure.


procedure prtdoc1.
  run pril123 ("1").
end procedure.

procedure prtdoc2.
  run pril123 ("2").
end procedure.

procedure prtdoc3.
  run pril123 ("3").
end procedure.


form
  v-dtb  format "99/99/9999" label " Начальная дата периода " colon 25
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше сегодняшней!") skip

  v-dte  format "99/99/9999" label " Конечная дата периода " colon 25
    help " Введите дату конца периода"
    validate (v-dte <= v-dtcheck, " Дата не может быть больше " + string(v-dtcheck) + "!") skip

  v-str1 format "x(50)" label " Номера счетов " colon 25
    help " Введите счета через запятую или оставьте пустым для ВСЕХ счетов"
    validate (check-accs(v-str1, v-availempty), " Недопустимый номер счета!") skip
  with overlay width 78 centered row 6 side-label title " СПРАВКА : " + t-docs.name + " " frame f-prils.

procedure findaccs.
  def input parameter p-var as char.
  def input parameter p-empty as logical.
  def input parameter p-yesdtb as logical.
  def input parameter p-yesdte as logical.
  def output parameter p-ans as logical.

  find t-docs where t-docs.code = integer(p-var) no-error.

  if p-yesdtb then v-dtb = g-today.
              else v-dtb = v-cifdt.

  if p-yesdte then v-dte = g-today.
  else do:
    find last cls no-lock no-error.
    v-dte = cls.whn.
  end.
  if v-dtb > v-dte then v-dtb = v-dte.
  v-dtcheck = v-dte.
  v-str1 = "".

  /*Определение типа счета  и выбор языка u00777*/
  v-grups2 = v-grups.

  find first t-type no-error.
  if avail t-type then
    assign  v-type1 = t-type.id_type
            v-typen = t-type.nm_type.

  find first t-lang no-error.
  if avail t-lang then
     assign  v-lang1 = t-lang.id_lang
            v-langn = t-lang.nm_lang.

  if p-var = "10" then do:
    displ v-langn v-typen with frame f-par.
    on help of v-langn in frame f-par do:
       run cfsprav-lang(output v-lang1,output v-langn).
       displ v-langn  v-typen with frame f-par.
    end.

    on help of v-typen in frame f-par do:
      run cfsprav-type(output v-type1,output v-typen).
      displ v-langn v-typen with frame f-par.
    end.

     update v-langn v-typen with frame f-par.
     hide frame f-par no-pause.

    if v-type1 > 1 then do:
        v-grups2 = "".
        for each lgr no-lock:
         /*Список депозитных счетов*/
         if lgr.led = "TDA" or lgr.led = "CDA" then
            v-grups2 = v-grups2 + "," + trim(lgr.lgr).
        end.

        if v-type1 = 2 then
          v-grups2 = substring(v-grups2,2).
        else
          v-grups2 = v-grups + v-grups2.
     end.
  end.

  displ v-dtb v-dte v-str1 with frame f-prils.
  update v-dtb when p-yesdtb v-dte with frame f-prils.

  for each t-accs. delete t-accs. end.

  for each aaa where aaa.cif = v-cif no-lock:
    /* берем только ТЕКУЩИЕ/ДЕПОЗИТНЫЕ СЧЕТА */
    if lookup(aaa.lgr, v-grups2) = 0 then next.

    /* закрытые на дату начала периода счета не обрабатываем */
    /*19.08.08 galina - дата закрытия счета из sub-cod if aaa.sta = "c" and aaa.cltdt <= v-dtb then next.*/
    if aaa.sta = "c" then do:
        find sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
        if sub-cod.rdt <= v-dtb then next.

    end.
    /* если дата задана только одна - не обрабатываем счета, закрытые на эту дату */
    /*19.08.08 galina - дата закрытия счета из sub-cod if not p-yesdtb and aaa.sta = "c" and aaa.cltdt <= v-dte then next.*/

    if aaa.sta = "c" and not p-yesdtb then do:
        find sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
        if sub-cod.rdt <= v-dte then
         next.
    end.

    /* открытые позже даты начала периода счета не обрабатываем */
    if aaa.regdt > v-dte then
     next.
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
    message skip " Нет доступных счетов ! Печатать пустую справку ?" skip(1)
    view-as alert-box buttons yes-no title "" update p-ans.
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


/***********************************************/
procedure pril45.
  def input parameter p-var as char.
  run findaccs (p-var, yes, yes, no, output vans).
  if vans then do:
    def button  btn1  label "Формировать ежемесячно".
    def button  btn2  label "За весь период".
    def frame fr_bt
    skip(1) btn1 btn2 with centered title "Выберите опцию:" row 5 .
    on choose of btn1 do:
        /*aigul - ежемесячный отчет*/
        def var dtt as date no-undo.
        find first t-accs where t-accs.choice = "*" no-error.
        if avail t-accs then do:
        empty temp-table wrk.
            for each t-accs where t-accs.choice = "*":
                dtt = v-dtb.
                /*нарисуем даты*/
                repeat:
                   create wrk.
                   wrk.acc = t-accs.aaa.
                   wrk.dtb = dtt.
                   year = year(dtt).
                   month = month(dtt) + 1.
                   if month = 13 then assign month = 1 year = year + 1.
                   dtc = date(month,1,year) - 1.
                   wrk.dte = dtc.
                   dtt = dtc + 1.
                   if dtc >= v-dte then do:
                        wrk.dte = v-dte.
                        leave.
                   end.
                end.
                /*найдем движения по счету*/
                cs = 0.
                ds = 0.
                wrk.ds = 0.
                wrk.cs = 0.

                for each jl where jl.sub = 'cif' and jl.acc = t-accs.aaa and jl.lev = 1 and jl.jdt >= v-dtb and jl.jdt <= v-dte no-lock:
                    find first wrk where wrk.acc = t-accs.aaa and wrk.dtb <= jl.jdt and wrk.dte >= jl.jdt no-error.
                    if avail wrk then do:
                        wrk.ds = wrk.ds + jl.dam.
                        wrk.cs = wrk.cs + jl.cam.
                    end.
                end.
            end.

            /*вывод в excel*/
            run put_header (p-var).
              put stream rep unformatted
                "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
                "<span style='mso-spacerun:yes'>           </span>" v-bankname " подтверждает, что у <B>"
                v-cifname
                "</B> за период с <B>"
                string(v-dtb, "99/99/9999")
                "</B> по <B>"
                string(v-dte, "99/99/9999")
                "</B></P><P style=""text-align:left"">" skip.

                for each wrk no-lock break by wrk.dtb by wrk.acc:
                    for each t-accs where t-accs.choice = "*" and t-accs.aaa = wrk.acc:
                        if first-of(wrk.dtb) then do:
                            put stream rep unformatted "<br></B> за период с <B>".
                            put stream rep unformatted
                            skip string(wrk.dtb, "99/99/9999")
                            "</B> по <B>".
                            put stream rep unformatted skip
                            string(wrk.dte, "99/99/9999") "</B></U><BR>" skip.
                        end.
                        /*запись суммы прописью и в валюте*/
                        t-accs.damdig = replace(trim(string(wrk.ds, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
                        t-accs.camdig = replace(trim(string(wrk.cs, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").

                        run Sm-vrd (wrk.ds, output t-accs.damstr).
                        run Sm-vrd (wrk.cs, output t-accs.camstr).

                        run sm-wrdcrc (substr(t-accs.damdig, 1, length(t-accs.damdig) - 3),
                                       substr(t-accs.damdig, length(t-accs.damdig) - 1),
                                       t-accs.crc, output v-str1, output v-str2).
                        t-accs.damstr = t-accs.damstr + "&nbsp;" + v-str1 + " " +
                                        substr(t-accs.damdig, length(t-accs.damdig) - 1) + "&nbsp;" + v-str2.

                        run sm-wrdcrc (substr(t-accs.camdig, 1, length(t-accs.camdig) - 3),
                                       substr(t-accs.camdig, length(t-accs.camdig) - 1),
                                       t-accs.crc, output v-str1, output v-str2).
                        t-accs.camstr = t-accs.camstr + "&nbsp;" + v-str1 + " " +
                                        substr(t-accs.camdig, length(t-accs.camdig) - 1) + "&nbsp;" + v-str2.

                        put stream rep unformatted skip
                        "По текущему счету №&nbsp;<U>" t-accs.aaa " (" t-accs.crccode  ")</U><BR>" skip
                        "Обороты по дебету составили <U>"
                        t-accs.damdig "&nbsp;" t-accs.crccode
                        " (" t-accs.damstr ") </U>,<BR>" skip
                        "Обороты по кредиту составили <U>"
                        t-accs.camdig "&nbsp;" t-accs.crccode skip
                        " (" t-accs.camstr ") </U><br>".
                   end.
                end.
                case p-var :
                    when "5" then put stream rep unformatted skip ",<BR><BR>И отсутствие ссудной задолженности перед Банком.".
                end case.
                put stream rep unformatted "." skip.
                run put_footer(p-var, no, yes, no, yes).
        end.
    end. /*button*/
    on choose of btn2 do:
        find first t-accs where t-accs.choice = "*" no-error.
        if avail t-accs then do:

          for each t-accs where t-accs.choice = "*":
            /* найти обороты по счету */
            do v-dt = v-dtb to v-dte:
              for each jl where jl.jdt = v-dt and jl.acc = t-accs.aaa and jl.lev = 1 and jl.dc = "d" no-lock:
                if jl.rem[1] begins "O/D PROTECT" or
                   jl.rem[1] begins "O/D PAYMENT" then next.
                accumulate jl.dam (total).
              end.
              t-accs.dam = t-accs.dam + accum total jl.dam.

              for each jl where jl.jdt = v-dt and jl.acc = t-accs.aaa and jl.lev = 1 and jl.dc = "c" no-lock:
                if jl.rem[1] begins "O/D PROTECT" or
                   jl.rem[1] begins "O/D PAYMENT" then next.
                accumulate jl.cam (total).
              end.
              t-accs.cam = t-accs.cam + accum total jl.cam.
            end.

            t-accs.damdig = replace(trim(string(t-accs.dam, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
            t-accs.camdig = replace(trim(string(t-accs.cam, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").

            run Sm-vrd (t-accs.dam, output t-accs.damstr).
            run Sm-vrd (t-accs.cam, output t-accs.camstr).

            run sm-wrdcrc (substr(t-accs.damdig, 1, length(t-accs.damdig) - 3),
                           substr(t-accs.damdig, length(t-accs.damdig) - 1),
                           t-accs.crc, output v-str1, output v-str2).
            t-accs.damstr = t-accs.damstr + "&nbsp;" + v-str1 + " " +
                            substr(t-accs.damdig, length(t-accs.damdig) - 1) + "&nbsp;" + v-str2.

            run sm-wrdcrc (substr(t-accs.camdig, 1, length(t-accs.camdig) - 3),
                           substr(t-accs.camdig, length(t-accs.camdig) - 1),
                           t-accs.crc, output v-str1, output v-str2).
            t-accs.camstr = t-accs.camstr + "&nbsp;" + v-str1 + " " +
                            substr(t-accs.camdig, length(t-accs.camdig) - 1) + "&nbsp;" + v-str2.
          end.

          run put_header (p-var).

          put stream rep unformatted
            "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
            "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что у <B>"
            v-cifname
            "</B> за период с <B>"
            string(v-dtb, "99/99/9999")
            "</B> по <B>"
            string(v-dte, "99/99/9999")
            "</B></P><P style=""text-align:left"">" skip.

          for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.
          n = accum count t-accs.aaa.
          i = 0.

          for each t-accs where t-accs.choice = "*":
            i = i + 1.
            put stream rep unformatted skip
              "По текущему счету №&nbsp;<U>" t-accs.aaa " (" t-accs.crccode  ")</U><BR>" skip
              "Обороты по дебету составили <U>"
              t-accs.damdig "&nbsp;" t-accs.crccode
              " (" t-accs.damstr ") </U>,<BR>" skip
              "Обороты по кредиту составили <U>"
              t-accs.camdig "&nbsp;" t-accs.crccode skip
              " (" t-accs.camstr ") </U>"
              if i = n then "" else ",<BR><BR>".
          end.
          case p-var :
            when "5" then put stream rep unformatted skip ",<BR><BR>И отсутствие ссудной задолженности перед Банком.".
          end case.

          put stream rep unformatted "." skip.

          run put_footer(p-var, no, yes, no, yes).
        end.
    end.
    enable all with frame fr_bt.
    wait-for choose of btn1, btn2.
  end.
end procedure.

procedure prtdoc4.
  run pril45 ("4").
end procedure.

procedure prtdoc5.
  run pril45 ("5").
end procedure.

procedure pril6789.
  def input parameter p-aaa as char.
  def input parameter p-knp as char.
  def input parameter p-dcaaa as char.
  def input parameter p-dckas as char.
  def output parameter p-sum as deci.

  p-sum = 0.
  v-str1 = "".

  do v-dt = v-dtb to v-dte:
    c-jl:
    for each jl where jl.jdt = v-dt and jl.lev = 1 and jl.acc = p-aaa no-lock:
      if jl.dc <> p-dcaaa or
         jl.rem[1] begins "O/D PROTECT" or
         jl.rem[1] begins "O/D PAYMENT" then next c-jl.

      if jl.dc = "c" then
        find first b-jl where b-jl.jh = jl.jh and b-jl.gl = v-glcash and b-jl.dc = p-dckas and b-jl.dam = jl.cam no-lock no-error.
      else
        find first b-jl where b-jl.jh = jl.jh and b-jl.gl = v-glcash and b-jl.dc = p-dckas and b-jl.cam = jl.dam no-lock no-error.

      if not avail b-jl then next c-jl.

      if v-symkas = "" then do:
        if jl.dc = "c" then p-sum = p-sum + jl.cam.
                       else p-sum = p-sum + jl.dam.
        find jlsach where jlsach.jh = jl.jh and jlsach.ln = b-jl.ln no-lock no-error.
        if avail jlsach and lookup(string(jlsach.sim, "999"), v-str1) = 0 then do:
          if v-str1 <> "" then v-str1 = v-str1 + ",".
          v-str1 = v-str1 + string(jlsach.sim, "999").
        end.
      end.
      else
        for each t-symkas:
          find jlsach where jlsach.jh = jl.jh and jlsach.ln = b-jl.ln and jlsach.sim = t-symkas.sim no-lock no-error.
          if avail jlsach then do:
            if jl.dc = "c" then t-symkas.sum = t-symkas.sum + jl.cam.
                           else t-symkas.sum = t-symkas.sum + jl.dam.
          end.
        end.
    end.
  end.
end.

procedure pril67899.
  def input parameter p-aaa as char.
  def input parameter p-knp as char.
  def input parameter p-dcaaa as char.
  def input parameter p-dckas as char.
  def output parameter p-sum as deci.
  def buffer b-aaa for aaa.
  def var d-sm as integer init 0.

  p-sum = 0.
  v-str1 = "".

  do v-dt = v-dtb to v-dte:
    c-jl:
    for each jl where jl.jdt = v-dt and jl.lev = 1 and jl.acc = p-aaa no-lock:

      if jl.dc <> p-dcaaa or
         jl.rem[1] begins "O/D PROTECT" or
         jl.rem[1] begins "O/D PAYMENT" then next c-jl.

      if jl.dc = "c" then
        find first b-jl where b-jl.jh = jl.jh and b-jl.gl = v-glcash and b-jl.dc = p-dckas and b-jl.dam = jl.cam no-lock no-error.
      else
        find first b-jl where b-jl.jh = jl.jh and b-jl.gl = v-glcash and b-jl.dc = p-dckas and b-jl.cam = jl.dam no-lock no-error.

      d-sm = 0.
      if not avail b-jl then do:
         find last jh where jh.jh = jl.jh no-lock no-error.
         if avail jh then do:
            find last joudoc where joudoc.docnum = jh.ref no-lock no-error.
            if avail joudoc then do:
               find last b-aaa where b-aaa.aaa = t-accs.aaa no-lock no-error.
               find last arp where arp.cif = b-aaa.cif and arp.arp begins "000729" no-lock no-error.
               if avail arp then do:
                  if joudoc.dracc = arp.arp  and joudoc.cracc = t-accs.aaa then do:
                  d-sm = 1.
                  end.
               end.
            end.
         end.
       end.
       if not avail b-jl and d-sm = 0 then next c-jl.

      if v-symkas = "" then do:
        if jl.dc = "c" then p-sum = p-sum + jl.cam.
                       else p-sum = p-sum + jl.dam.
        find jlsach where jlsach.jh = jl.jh and jlsach.ln = b-jl.ln no-lock no-error.
        if avail jlsach and lookup(string(jlsach.sim, "999"), v-str1) = 0 then do:
          if v-str1 <> "" then v-str1 = v-str1 + ",".
          v-str1 = v-str1 + string(jlsach.sim, "999").
        end.
      end.
      else
        for each t-symkas:
          find jlsach where jlsach.jh = jl.jh and jlsach.ln = b-jl.ln and jlsach.sim = t-symkas.sim no-lock no-error.
          if avail jlsach then do:
             if jl.dc = "c" then t-symkas.sum = t-symkas.sum + jl.cam. else t-symkas.sum = t-symkas.sum + jl.dam.
          end.
          else  do:

               if t-symkas.sim = 200 then do:
                  find last jh where jh.jh = jl.jh no-lock no-error.
                  if avail jh then do:
                     find last joudoc where joudoc.docnum = jh.ref no-lock no-error.
                     if avail joudoc then do:
                        find last b-aaa where b-aaa.aaa = t-accs.aaa no-lock no-error.
                        find last arp where arp.cif = b-aaa.cif and arp.arp begins "000729" no-lock no-error.
                        if avail arp then do:
                           if joudoc.dracc = arp.arp  and joudoc.cracc = t-accs.aaa then do:
                              if jl.dc = "c" then t-symkas.sum = t-symkas.sum + jl.cam. else t-symkas.sum = t-symkas.sum + jl.dam.
                           end.
                        end.
                     end.
                  end.
                 end.
               end.
        end.
    end.
  end.
end.

procedure prtdoc6.
  def var v-sum as decimal.

  run findaccs ("6", no, yes, no, output vans).

  if vans then do:
    v-symkas = "010,200".
    for each t-symkas. delete t-symkas. end.
    do i = 1 to num-entries (v-symkas):
      create t-symkas.
      t-symkas.sim = integer(entry(i, v-symkas)).
    end.

    for each t-accs where t-accs.choice = "*":
      for each t-symkas. t-symkas.sum = 0. end.

      run pril67899 (t-accs.aaa, "311", "c", "d", output v-sum).

      /* сформировать справку */
      find first t-symkas where t-symkas.sum <> 0 no-error.

      if not avail t-symkas then do:
        vans = yes.
        message skip " На счет" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "по символам касплана" v-symkas skip
                "поступлений наличных денег не было!" skip(1)
                " Печатать справку об отсутствии наличных поступлений (Приложение 7) ?" skip(1)
                view-as alert-box button yes-no title " ВНИМАНИЕ ! " update vans.
        if vans then run print7 (t-accs.aaa).
        next.
      end.

      run print6 (t-accs.aaa, t-accs.crc, t-accs.crccode).
    end.
  end.
end.

procedure print6.
  def input parameter p-aaa as char.
  def input parameter p-crc as integer.
  def input parameter p-crccode as char.

  run put_header ("6").

  put stream rep unformatted
    "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
    "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что на текущий счет <B>"
     p-aaa " " v-cifname "</B> за период с <B>" string(v-dtb, "99/99/9999") "г. </B> по <B>" string(v-dte, "99/99/9999")
    "г. </B> наличные деньги поступили " skip.

    for each t-symkas where t-symkas.sum <> 0. accumulate t-symkas.sim (count). end.
    n = accum count t-symkas.sim.
    i = 0.
    for each t-symkas where t-symkas.sum <> 0:
      v-sumdig = replace(trim(string(t-symkas.sum, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").

      run Sm-vrd (t-symkas.sum, output v-sumstr).

      run sm-wrdcrc (substr(v-sumdig, 1, length(v-sumdig) - 3),
                     substr(v-sumdig, length(v-sumdig) - 1),
                     p-crc, output v-str1, output v-str2).
      v-sumstr = v-sumstr + "&nbsp;" + v-str1 + " " +
                      substr(v-sumdig, length(v-sumdig) - 1) + "&nbsp;" + v-str2.

      find cashpl where cashpl.sim = t-symkas.sim and cashpl.act no-lock no-error.

      i = i + 1.
      put stream rep unformatted
        if i = 1 then "" else ", "
        "в&nbsp;сумме&nbsp;"
        v-sumdig "&nbsp;" p-crccode
        " (" v-sumstr ")&nbsp;- " skip
        cashpl.des
        if i = n then "." else ""
        skip.
    end.

  run put_footer("6", no, yes, no, yes).
end.

procedure print7.
  def input parameter p-aaa as char.

  run put_header ("7").

  put stream rep unformatted
    "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
     "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что на текущий счет <B>"
     p-aaa " " v-cifname "</B> за период с <B>" string(v-dtb, "99/99/9999") "г. </B> по <B>" string(v-dte, "99/99/9999")
    "г. </B> наличные деньги не поступали." skip.
  run put_footer("7", no, yes, no, yes).
end.

procedure prtdoc7.
  def var v-sum as decimal.

  run findaccs ("7", no, yes, no, output vans).

  if vans then do:
    v-symkas = "".

    for each t-symkas. delete t-symkas. end.

    for each t-accs where t-accs.choice = "*":

      run pril6789 (t-accs.aaa, "311", "c", "d", output v-sum).

      if v-sum > 0 then do:
        message skip " На счет" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "было поступление наличных денег по символам касплана :" v-str1 skip
                "в сумме"
                trim(string(v-sum, "->>>,>>>,>>>,>>>,>>9.99")) t-accs.crccode "!" skip(1)
                " Распечатайте справку о наличных поступлениях (Приложение 6) !" skip(1)
                view-as alert-box button ok title " ВНИМАНИЕ ! ".
        next.
      end.

      /* сформировать справку */
      run print7 (t-accs.aaa).
    end.
  end.
end.


procedure prtdoc8.
  def var v-sum as decimal.

  run findaccs ("8", no, yes, no, output vans).

  if vans then do:
    for each t-symkas. delete t-symkas. end.
    v-symkas = "320".
    do i = 1 to num-entries (v-symkas):
      create t-symkas.
      t-symkas.sim = integer(entry(i, v-symkas)).
    end.

    for each t-accs where t-accs.choice = "*":
      for each t-symkas. t-symkas.sum = 0. end.

      run pril6789 (t-accs.aaa, "321", "d", "c", output v-sum).

      /* сформировать справку */
      find first t-symkas where t-symkas.sum <> 0 no-error.

      if avail t-symkas then do:
        message skip " По счету" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "выдавались наличные деньги по символам касплана :" t-symkas.sim skip
                "в сумме"
                trim(string(t-symkas.sum, "->>>,>>>,>>>,>>>,>>9.99")) t-accs.crccode "!" skip(1)
                " Невозможно сформировать справку об отсутствии выдач!" skip(1)
                view-as alert-box button ok title " ВНИМАНИЕ ! ".
        next.
      end.

      /* сформировать справку */
      run put_header ("8").
      put stream rep unformatted
       "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
       "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что за период с <B>" string(v-dtb, "99/99/9999") "г. </B> по <B>" string(v-dte, "99/99/9999")
       "г. </B> по текущему счету<B> " t-accs.aaa " " v-cifname "</B> наличные деньги на заработную плату не выдавались." skip.
      run put_footer("8", no, no, yes, no).

    end.
  end.
end.


procedure prtdoc9.
  def var v-sum as decimal.

  run findaccs ("9", no, yes, no, output vans).

  if vans then do:
    for each t-symkas. delete t-symkas. end.
    v-symkas = "".

    for each t-accs where t-accs.choice = "*":

      run pril6789 (t-accs.aaa, "321", "d", "c", output v-sum).

      /* сформировать справку */
      if v-sum > 0 then do:
        message skip " По счету" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "выдавались наличные деньги по символам касплана :" v-str1 skip
                "в сумме"
                trim(string(v-sum, "->>>,>>>,>>>,>>>,>>9.99")) t-accs.crccode "!" skip(1)
                " Невозможно сформировать справку об отсутствии выдач!" skip(1)
                view-as alert-box button ok title " ВНИМАНИЕ ! ".
        next.
      end.

      /* сформировать справку */
      run put_header ("9").

      put stream rep unformatted
       "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
       "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что за период с <B>" string(v-dtb, "99/99/9999") "г. </B> по <B>" string(v-dte, "99/99/9999")
       "г. </B>на текущий счет " t-accs.aaa " " v-cifname "</B> наличные деньги не выдавались." skip.

      run put_footer("9", no, no, yes, no).

    end.
  end.
end.

procedure prtdoc10.
  run findaccs ("10", yes, no, no, output vans).
  if vans then do:
    for each t-accs where t-accs.choice = "*". accumulate t-accs.aaa (count). end.
    n = accum count t-accs.aaa.
    i = 0.

    if n > 0 then do:
      if v-lang1 ne 2 then do:
        run put_header ("10").

        put stream rep unformatted
           "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
           "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает наличие".
        case v-type1:
          when 2 then
             put stream rep unformatted " депозитного счета" skip.
          when 3 then
             put stream rep unformatted " текущего/депозитного счета" skip.
          otherwise
             put stream rep unformatted " текущего счета" skip.
        end case.
        put stream rep unformatted
           "<B>" v-cifname "</B>" skip.


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
          put stream rep unformatted
          "<BR>в&nbsp;"
          caps(t-crcname.name)
          " N&nbsp;"
          t-accs.aaa
          ", с остатком средств на "
          string(v-dte + 1, "99/99/9999")
          "&nbsp;г. в&nbsp;сумме&nbsp;<U>"
          v-sumdig "&nbsp;" t-accs.crccode
          " (" v-sumstr ")</U>"
          if i = n then "." else ","
          skip.

        end.
        run put_footer("10", yes, yes, no, yes).
      end.
      else do:
      /*Английская версия справки u00777*/
        run put_headerEngl("10").

        if v-type1 = 2 then
         put stream rep unformatted
         "<br> <p style='text-align:justify'>&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS DEPOSIT " skip.
        else if v-type1 = 3 then
         put stream rep unformatted
         "<br> <p style='text-align:justify'>&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS CURRENT/DEPOSIT " skip.
        else
         put stream rep unformatted
         "<br> <p style='text-align:justify'>&nbsp;     " v-engname " HEREBY CONFIRMS THAT  <U><I><B>" v-cifname "</B></I></U>
         HAS CURRENT " skip.

        if n > 1 then
          put stream rep unformatted "ACCOUNTS" skip.
        else
          put stream rep unformatted "ACCOUNT" skip.
        for each t-accs where t-accs.choice = "*":
          find last aab where aab.aaa = t-accs.aaa and aab.fdt <= v-dte no-lock no-error.

          v-sumdig = replace(trim(string(aab.bal, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;").
          /*формирование суммы прописью на англ. языке*/
          run Sm-vrde (aab.bal, output v-sumstr).
          run sm-wrdcrce (t-accs.crc, output v-str1, output v-str2).
          v-sumstr = v-sumstr + " " + v-str1 + " " + substr(v-sumdig, length(v-sumdig) - 1) + " " + v-str2.

          find t-crcname where t-crcname.crc = t-accs.crc no-error.
          i = i + 1.
          put stream rep unformatted "<U><I><B> " t-accs.aaa + " "
          + "</B></I></U> OPENED WITH US WITH TOTAL BALANCE AVAILABLE ON THE ABOVE ACCOUNT
          IN THE AMOUNT OF <B><I><U>"
          v-sumdig " " t-accs.crccode "</U>"skip
          " (" caps(v-sumstr) ")</I></B> AS OF <U><B>" string(g-today, "99/99/9999") "</B></U>"
          if i = n then ".</P>" else ","
          skip.
        end.
        run put_footerEngl("10").
      end.
    end.
  end.
end.


procedure prtdoc11.
  def var v-sum as decimal.

  run findaccs ("11", no, yes, no, output vans).

  if vans then do:
    for each t-symkas. delete t-symkas. end.
    v-symkas = "".

    for each t-accs where t-accs.choice = "*":
      /* проверить транзакции на предмет чего-либо кроме комиссий */

      /* кредит */
      vans = false.
      c-dt:
      do v-dt = v-dtb to v-dte:
        c-jl:
        for each jl where jl.jdt = v-dt and jl.acc = t-accs.aaa and jl.lev = 1 and jl.dc = "c" use-index jdt no-lock:

          if (jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT") then next c-jl.

          vans = true.
          leave c-dt.
        end.
      end.

      if vans then do:
        message skip " По счету" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "проводились кредитовые операции!" skip(1)
                " Невозможно сформировать справку об отсутствии операций!" skip(1)
                view-as alert-box button ok title " ОШИБКА ! ".
        next.
      end.

      /* дебет */
      vans = false.
      c-dt:
      do v-dt = v-dtb to v-dte:
        c-jl:
        for each jl where jl.jdt = v-dt and jl.acc = t-accs.aaa and jl.lev = 1 and jl.dc = "d" use-index jdt no-lock:

          if (jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT") then next c-jl.

          for each b-jl where b-jl.jh = jl.jh and b-jl.dc = "c" no-lock:
            if not (b-jl.sub = "" and string(b-jl.gl) begins "4") then do:
              vans = true.
              leave c-dt.
            end.
          end.
        end.
      end.

      if vans then do:
        message skip " По счету" t-accs.aaa "за период с" string(v-dtb, "99/99/9999")
                "по" string(v-dte, "99/99/9999") skip
                "проводились дебетовые операции!" skip(1)
                " Невозможно сформировать справку об отсутствии операций!" skip(1)
                view-as alert-box button ok title " ОШИБКА ! ".
        next.
      end.

      /* сформировать справку */
      run put_header ("11").

      put stream rep unformatted
        "<P style=""text-align:left"" style=""font-family:Arial; font-size:11.0pt"">" skip
        "<span style='mso-spacerun:yes'>           </span>"  v-bankname " подтверждает, что за период с <B>"
        string(v-dtb, "99/99/9999")
        "г. </B> по <B>"
        string(v-dte, "99/99/9999")
        "г. </B> по текущему счету <B>" t-accs.aaa " " v-cifname
        "</B> операции не проводились, кроме оплаты комиссионных за услуги Банка." skip.
      run put_footer("11", no, no, yes, no).

    end.
  end.
end.

form
  v-dtb  format "99/99/9999" label " Начальная дата периода " colon 25
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше сегодняшней!") skip

  v-dte  format "99/99/9999" label " Конечная дата периода " colon 25
    help " Введите дату конца периода"
    validate (v-dte <= g-today, " Дата не может быть больше сегодняшней!") skip
  with overlay width 78 centered row 6 side-label title " СПРАВКА : " + t-docs.name + " " frame f-period.


/*
 * Функция возвращет true если у клиента есть Cсудная задолжность
 * за период
*/
function IsFindDebtsLonByPeriod returns logical(      p_bdate as date,
                                                      p_edate as date,
                                                      p_cif as char
                                               ).
    def var     v_ret as logical.
    define var  v-bilance as decimal.
    define var  v-idt as date.

    v_ret=false.

       for each lon where lon.cif = p_cif no-lock:
       do v-idt = p_bdate to p_edate:
           run atl-dat1 (lon.lon, v-idt, 2, output v-bilance).
               if  v-bilance >0 then return true.
       end.
           for each jl where     jl.acc = lon.lon
                                 and jl.jdt >=p_bdate
                                 and jl.jdt <=p_edate
                                 /* use-index jdtaccgl */ no-lock.
                 if jl.lev = 7  or
                    jl.lev = 9  or
                    jl.lev = 16 or
                    jl.lev = 21 or
                    jl.lev = 23
                 then return true.
           end.
   end.
return v_ret.

end function.

/*
 * Функция возвращет true если у клиента есть К2
 * за период
*/
function IsFindDebtsK2ByPeriod returns logical( p_bdate as date,
                                                   p_edate as date,
                                                   p_aaa as char
                                                 ).

    def var v_ret as logical.

    def var v-payee as char  init "K2,K-2,К2,К-2,ПРЕДП".
    def var ii as integer initial 0.


    do ii = 1 to num-entries(v-payee) :
        create t-vars.
        t-vars.name = caps(entry(ii, v-payee)).
    end.

    v_ret=false.
      for each aas_hist where aas_hist.aaa = p_aaa
                              and  aas_hist.regdt >=p_bdate
                              and  aas_hist.regdt <=p_edate
                        no-lock:
         if can-find(first t-vars where index(caps(aas_hist.payee), t-vars.name) > 0) then return true.
      end.

return v_ret.

end function.

/*
*   tsoy Справка для участия в тендере
*/

procedure prtdoc12.
  vans = yes.
  v-dtb = g-today - 90.
  v-dte = g-today - 1.

  def var v-k2 as logical.
  def var v-lon as logical.

  v-k2   = false.
  v-lon  = false.

  update v-dtb v-dte with frame f-period.
  hide frame f-period.
  /*19.08.2008 galina*/
  run pkdefdtstr(v-dte, output v-datastr, output v-datastrkz).

  /*message skip " Показать ВСЕ текущие счета (Yes) или только в ТЕНГЕ (No) ? " skip(1)
          view-as alert-box buttons yes-no title " СПРАВКА : " + t-docs.name + " " update vans.*/

  v-str1 = "".
  /*v-str2 = "".*/

  for each aaa where aaa.cif = v-cif no-lock:
          /* закрытые счета не обрабатываем */
          if aaa.sta = "c" then next.
          /* берем только ТЕКУЩИЕ СЧЕТА */
          if lookup(aaa.lgr, v-grups) = 0 then next.

          if aaa.crc = 1 then do:
             if v-str1 <> "" then v-str1 = v-str1 + ", ".
             v-str1 = v-str1 + aaa.aaa.
             if not v-k2 then v-k2 = IsFindCurDebtsK2 ( aaa.aaa ).
             if not v-k2 then v-k2 = IsFindDebtsK2ByPeriod  ( v-dtb,
                                                              v-dte,
                                                              aaa.aaa
                                                            ).
          end.

          /*if aaa.crc <> 1 and vans then do:
             if v-str2 <> "" then v-str2 = v-str2 + ", ".
             find crc where crc.crc = aaa.crc no-lock no-error.
             v-str2 = v-str2 + aaa.aaa + "&nbsp;(" + crc.code + ")".
             if not v-k2 then v-k2 = IsFindCurDebtsK2 ( aaa.aaa ).
             if not v-k2 then v-k2 = IsFindDebtsK2ByPeriod  ( v-dtb,
                                                              v-dte,
                                                              aaa.aaa
                                                            ).
          end.*/
   end.

   v-lon = IsFindCurDebtsLon ( v-cif ).
   if not v-lon then v-lon = IsFindDebtsLonByPeriod( v-dtb,
                                                     v-dte,
                                                     v-cif
                                                   ).

  vans = yes.
  if v-k2 and v-lon then do:
     message skip " Есть спец. инструкции и ссудная задолжность" skip(1)
           view-as alert-box buttons ok title "".
     vans = no.
  end.
  else do:
       if v-k2 then do:
          message skip " Есть спец. инструкции" skip(1)
                view-as alert-box buttons ok title "".
          vans = no.
       end.

       if v-lon then do:
          message skip " Есть ссудная задолжность" skip(1)
                view-as alert-box buttons ok title "".
          vans = no.
       end.
  end.

  if vans then do:
         /*БИК банка*/
         find sysc where sysc.sysc = 'CLECOD' no-lock no-error.
         run put_header("12").
          put stream rep unformatted
              "<P align=""center"" style=""font-family:Arial; font-size:11.0pt"">" skip
              "Справка об отсутствии задолженности <BR><P/>" skip.
          put stream rep unformatted
              "<P style=""text-align:justify;font-family:Arial; font-size:11.0pt"">" skip
              "<span style='mso-spacerun:yes'>           </span>" v-bankname " по состоянию на "
              v-datastr " г.  подтверждает отсутствие просроченной задолженности  перед банком, длящейся более трех месяцев,
              предшествующих дате выдачи справки, согласно типового плану счетов бухгалтерского учета в банках второго уровня и ипотечных компаниях,
              утвержденному постановлением Правления Национального Банка Республики Казахстан <B>"
              v-cifname ", </B> тел. " cif.tel ", адрес: " cif.addr[1] ", обслуживающимся в данном Банке.</P>".
         run put_footer_for_tender("12", yes, yes, no, yes).

  end.
end procedure.

procedure procparam.
  update v-sign1 v-sign2 with frame f-params.
  hide frame f-params no-pause.
  find sysc where sysc.sysc = "sprpar" exclusive-lock no-error.
  sysc.chval = v-sign1 + "|" + v-sign2.
  release sysc.
end procedure.