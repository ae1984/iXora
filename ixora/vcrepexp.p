/*vcrepexp.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет о поступлении валютной выручки за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10/08/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1672,1928.
*/
{mainhead.i}

def var v-bin as char.
def var v-ctnum as char.
def var v-ctdt as date.
def var v-dt1 as date.
def var v-dt2 as date.
def var v-clname as char.
def var v-pnname as char.
def var v-psdt as date.
def var v-psnum as char.
def var i as integer.

def temp-table t-pay
  field okpo as char
  field rnn as char
  field bin as char
  field name as char
  field pnname as char
  field dt as date
  field sum as deci
  field ctnum as char
  field ctdt as date
  field psnum as char
  field psdt as date
  field crccode as char
  index dt1 is primary dt.


def new shared var s-cif like cif.cif.
def new shared var s-contract like vccontrs.contract.
def new shared var s-contrstat as char initial 'all'.

form
  v-bin label "ИИН/БИН" format "999999999999" help "Введите РНН клиента" validate(can-find(first cif where cif.bin = v-bin no-lock),'Клиент не найден')
  "   "  v-clname format "x(20)" no-label  skip
  v-ctnum label "Номер конракта" format "x(40)" help "Выберите контракт (F2 - поиск)" skip
  v-ctdt  label "Дата контракта" format "99/99/9999" validate(v-ctdt <= g-today,'Дата не может быть больше операционной') skip
  v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
  v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
with frame f-client centered side-label width 80 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

on help of v-ctnum in frame f-client do:
  run h-contract.
  if s-contract <> 0 then do:
     find vccontrs where vccontrs.contract = s-contract no-lock no-error.
     v-ctnum = vccontrs.ctnum.
     v-ctdt = vccontrs.ctdate.
     displ v-ctnum v-ctdt with frame f-client.
  end.
end.
update v-bin with frame f-client.
find first cif where cif.bin = v-bin no-lock.
s-cif = cif.cif.
v-clname = trim(trim(cif.prefix) + " " + trim(cif.name)).
display v-clname with frame f-client.
repeat:
    update v-ctnum v-ctdt with frame f-client.
    find first vccontrs where vccontrs.cif = s-cif and vccontrs.ctdate = v-ctdt and vccontrs.ctnum = v-ctnum and vccontrs.expimp = 'e' no-lock no-error.
    if avail vccontrs then leave.
    else do:
      message 'Контракт не найден. Или не является экспортным'.
      hide message.
      pause 0.
    end.
end.

update v-dt1 with frame f-client.
update v-dt2 with frame f-client.

v-psnum = ''.
v-psdt = ?.
if vccontrs.cttype = '1' then do:
   find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
   if avail vcps then do:
      v-psnum = vcps.dnnum + string(vcps.num).
      v-psdt = vcps.dndate.
   end.
end.

for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = '02' and vcdocs.dndate >= v-dt1 and vcdocs.dndate <= v-dt2 and vcdocs.payret = no no-lock:
    find first crc where crc.crc = vcdocs.pcrc no-lock no-error.
    create t-pay.
    t-pay.okpo = cif.ssn.
    t-pay.rnn = cif.jss.
    t-pay.bin = cif.bin.
    t-pay.name = v-clname.
    find first vcpartners where vcpartners.partner = vcdocs.info[4] no-lock no-error.
    if avail vcpartners then t-pay.pnname = trim(trim(vcpartners.name) + ' ' + trim(vcpartners.formasob)).
    t-pay.dt = vcdocs.dndate.
    t-pay.sum = vcdocs.sum.
    t-pay.ctnum = vccontrs.ctnum.
    t-pay.ctdt = vccontrs.ctdate.
    t-pay.psnum = v-psnum.
    t-pay.psdt = v-psdt.
    t-pay.crccode = crc.code.
end.
def stream v-out.

find first t-pay no-lock no-error.
if avail t-pay then do:
    find first cmp no-lock no-error.
    output stream v-out to payments.xls.
    {html-title.i &title = "ForteBank" &stream = "stream v-out" &size-add = "x-"}

    put stream v-out unformatted
        "<P align=right>Утверждено<br><U><B>приказом</U></B>&nbsp;Министра финансов<br>Республики Казахстан<br>от 30 декабря 2008 года № 629</P>" skip.

    put stream v-out unformatted
        "<p><b>Заключение о поступлении валютной выручки <br>за период с " + string(v-dt1,'99/99/9999') + " года по " + string(v-dt2,'99/99/9999') + " года</b></p>"  skip.

    put stream v-out unformatted
        "<TABLE border=""1"" cellpadding=""10"" cellspacing=""0"">" skip.

    put stream v-out unformatted skip
        "<tr style=""font:bold;font-size:10pt"" align=""center"">"
        "<td rowspan=""2"">№</td>"
        "<td colspan=""2"">Проверяемый<br>налогоплательщик</td>"
        "<td rowspan=""2"">Валюта<br>счета</td>"
        "<td colspan=""3"">Сведения о<br>поступлении<br>валютной выручки</td>"
        "<td rowspan=""2"">Номер и<br>дата<br>контракта</td>"
        "<td rowspan=""2"">Учетный номер<br>контракта и <br>дата его присвоения<br> либо номер и<br>дата паспорта<br> сделки</td></tr>"
        "<tr style=""font:bold"" align=""center"">"
        "<td>индивидуальный<br>идентификационный<br>номер/ бизнес-идентификационный<br>номер<br>(ИИН/БИН)</td>"
        "<td>Наименование<br>налогоплательщика</td>"
        "<td>Наименование<br>отправителя</td>"
        "<td>Дата</td>"
        "<td>Сумма<br>платежа</td>"
        "</tr>" skip.

    for each t-pay no-lock:
        i = i + 1.
        put stream v-out unformatted
        "<tr align=center style='font-size:10pt'>"
        "<td>" string(i) "</td>"
        "<td>&nbsp;" t-pay.bin "</td>"
        "<td>" t-pay.name "</td>"
        "<td>" t-pay.crccode "</td>"
        "<td>" t-pay.pnname "</td>"
        "<td>" string(t-pay.dt,'99/99/9999') "</td>"
        "<td>" replace(trim(string(t-pay.sum,">>>>>>>>>>9.99")),'.',',') "</td>"
        "<td>" t-pay.ctnum " " string(t-pay.ctdt,'99/99/9999') "</td>".
        if t-pay.psdt <> ? then put stream v-out unformatted
            "<td>" t-pay.psnum " "  string(t-pay.psdt,'99/99/9999') "</td>" skip.
        else put stream v-out unformatted
            "<td></td>".
        put stream v-out unformatted
            "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.
    output stream v-out close.
    unix silent value("cptwin payments.xls excel").
    unix silent rm -f payments.xls.
end.
