/* vcrptac1.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Список контрактов клиента
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        25.08.2009 galina
 * BASES
        BANK COMM
 * CHANGES
        18/11/2010 aigul  - сделала отчет консолидированным и добавила выбор всех типов контракта
        01.02.2011 aigul  - вывод суммы оплат, гтд и актов
        25/04/2012 evseev - rebranding. Название банка из sysc или изменил проверку банка или рко
        22.05.2012 damir  - перекомпиляция.
*/

{vc.i}
{global.i}
{comm-txb.i}
{nbankBik.i}

def var v-txbbank as char.
def var v-text as char no-undo.
def var v-dt1 as date no-undo.
def var v-dt2 as date no-undo.
def var v-sts as char no-undo.
def var v-cttype as char no-undo.
def var v-nps as char no-undo.
def var v-dtps as date no-undo.
def var v-clname as char no-undo.
def new shared var s-cif like cif.cif.
def var t as integer.
def new shared var v-name as char.
def new shared var v-cif like cif.cif.
def new shared temp-table t-contract no-undo
    field bank as char
    field name as char    /* наименование клиента */
    field num as char    /* номер контракта */
    field dt as date    /* дата контракта */
    field numps as char    /* номер паспорта сделки */
    field ctype as char /*тип котракта*/
    field dtps as date    /* номер паспорта сделки */
    field sum as deci /*сумма контракта*/
    field crc as char /*валюта*/
    field expimp as char /*экспор импорт*/
    field clsdt as date /*дата закрытия контракта*/
    field sum_opl as decimal
    field sum_gtd as decimal
    field sum_akt as decimal.

def var v-sum-opl as decimal.
def var v-sum-opl1 as decimal.
def var v-sum-opl2 as decimal.
def var v-sum-gtd as decimal.
def var v-sum-akt as decimal.
def stream vcrpt.

def var s-vcourbank as char no-undo.
def buffer b-ncrchis for ncrchis.

def var v-sumplat as decimal.
  def var vp-sum as decimal.
def temp-table t-dntype
  field dntype as char
  index dntype is primary dntype.

def frame f-param
v-dt1 label "С" format "99/99/99" validate(v-dt1 <= g-today,'Дата не может быть больше текущей!')
v-dt2 label   " по" format "99/99/99" validate(v-dt2 <= g-today,'Дата не может быть больше текущей!')  skip
v-cttype label "Тип конракта"  format "x(3)" validate (can-find(first codfr where codfr.codfr = 'vccontr' and codfr.code = v-cttype no-lock) or v-cttype = 'ALL', " Не верный тип контракта!") help " Введите код контракта (F2 - поиск)" skip
v-sts label "Статус" format "x(1)" validate(v-sts = 'A' or v-sts = 'C', 'Не верный статус контракта!')  help " Введите статус контракта: А - активный, С - закрытый"
s-cif label "КЛИЕНТ " format "x(6)"  help " Введите код клиента (F2 - поиск)"
validate (can-find(first cif where cif.cif = s-cif no-lock) or s-cif = 'ALL', " Клиент с таким кодом не найден!")
v-clname format "x(40)" no-label
with side-label width 60 centered row 10 title " ПАРАМЕТРЫ ОТЧЕТА ".

/*s-vcourbank = comm-txb().*/
v-dt1 = g-today.
v-dt2 = g-today.
s-cif = 'ALL'.
v-cttype = 'ALL'.
v-sts = 'A'.
update v-dt1 v-dt2 v-cttype v-sts with frame f-param.
update s-cif with frame f-param.
find first cif where cif.cif = s-cif no-lock no-error.
if avail cif then v-clname = cif.prefix + " " + cif.name.
display v-clname with frame f-param.


def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
def var v-sel as int.
def var v-banklist as char.
def var v-txblist as char.
def var v-bank as char.
v-banklist = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. ЦО | 2. Актобе | 3. Кустанай | 4. Тараз | 5. Уральск | 6. Караганда | 7. Семск | 8. Кокчетав | 9. Астана | 10. Павлодар | 11. Петропавловск | 12. Атырау | 13. Актау | 14. Жезказган | 15. Усть-Каман | 16. Чимкент | 17. Алматы".
v-txblist = "ALL,TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
v-sel = 0.

if s-ourbank = "TXB00" then do:
    run sel2("ФИЛИАЛЫ",v-banklist,output v-sel).
    if v-sel > 0 then v-bank = entry(v-sel,v-txblist).
    else return.
end.
if s-ourbank <> "TXB00" then v-bank = s-ourbank.



for each vccontrs where (vccontrs.bank = v-bank or v-bank = "ALL") and /*vccontrs.cttype = v-cttype*/
(vccontrs.cttype = v-cttype or  v-cttype = 'ALL') and (vccontrs.cif = s-cif or s-cif = 'ALL') no-lock:
  if v-sts = 'A' then do:
     if vccontrs.sts <> 'A' and   vccontrs.sts <> 'N' then next.
     if vccontrs.ctregdt < v-dt1 then next.
     if vccontrs.ctregdt > v-dt2 then next.
  end.
  if v-sts = 'C' then do:
     if vccontrs.sts <> 'C' then next.
     if vccontrs.stsdt < v-dt1 then next.
     if vccontrs.stsdt > v-dt2 then next.
  end.
  if s-cif <> 'ALL' and vccontrs.cif <> s-cif then next.
  /*
  find first cif where cif.cif = vccontrs.cif no-lock no-error.
  if not avail cif then next.
  */
  v-cif = vccontrs.cif.
  find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
  if avail comm.txb then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run vcrptac1cif.
  end.
  v-nps = ''.
  v-dtps = ?.
  if vccontrs.cttype = '1' then do:
     find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
     if not avail vcps then next.
     v-nps = vcps.dnnum + string(num).
     v-dtps = vcps.dndate.
  end.
  find first crc where crc.crc = vccontrs.ncrc no-lock no-error.
  if not avail crc then next.

    v-sum-opl = 0.
    v-sum-opl1 = 0.
    v-sum-opl2 = 0.
    v-sum-gtd = 0.
    v-sum-akt = 0.

  /*Сумма оплат*/
  /*
  for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
    find last ncrchis where ncrchis.rdt <= vcdocs.dndate and ncrchis.crc = vccontrs.ncrc no-lock no-error.
    if avail ncrchis then do:
        find last b-ncrchis where b-ncrchis.rdt <= vcdocs.dndate and b-ncrchis.crc = vcdocs.pcrc no-lock
        no-error.
        if avail b-ncrchis then do:
            if vcdocs.dntype = "03" then v-sum-opl1 = v-sum-opl1 + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
            if vcdocs.dntype = "02" then v-sum-opl2 = v-sum-opl2 + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
            if vccontrs.expimp = "i" then v-sum-opl = v-sum-opl1 - v-sum-opl2.
            if vccontrs.expimp = "e" then v-sum-opl = v-sum-opl2 - v-sum-opl1.
        end.
    end.
  end.
  */

  v-sumplat = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and
     (vcdocs.dntype = "03" or vcdocs.dntype = "02") no-lock:
    if vcdocs.payret then vp-sum = - vcdocs.sum.
    else vp-sum = vcdocs.sum.
    vp-sum = vp-sum / vcdocs.cursdoc-con.
    v-sum-opl = v-sum-opl + vp-sum .
  end.


  /*Сумма ГТД и Актов*/
  for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
    find last ncrchis where ncrchis.rdt <= vcdocs.dndate and ncrchis.crc = vccontrs.ncrc no-lock no-error.
    if avail ncrchis then do:
        find last b-ncrchis where b-ncrchis.rdt <= vcdocs.dndate and b-ncrchis.crc = vcdocs.pcrc no-lock
        no-error.
        if avail b-ncrchis then do:
           if vcdocs.dntype = "14" then v-sum-gtd = v-sum-gtd + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
           if vcdocs.dntype = "17" then v-sum-akt = v-sum-akt + vcdocs.sum * b-ncrchis.rate[1] / ncrchis.rate[1].
        end.
    end.
  end.


  create t-contract.
  assign
         t-contract.bank = vccontrs.bank
         t-contract.name = /*cif.prefix + " " + cif.name*/ v-name
         t-contract.num = vccontrs.ctnum
         t-contract.dt = vccontrs.ctdate
         t-contract.numps = v-nps
         t-contract.ctype = vccontrs.cttype
         t-contract.dtps = v-dtps
         t-contract.sum = vccontrs.ctsum
         t-contract.crc = crc.code
         t-contract.expimp = vccontrs.expimp.
         if v-sts = 'C' then t-contract.clsdt = vccontrs.stsdt.
         t-contract.sum_opl = v-sum-opl.
         t-contract.sum_gtd = v-sum-gtd.
         t-contract.sum_akt = v-sum-akt.

end.

find first t-contract no-lock no-error.
if not avail t-contract then return.

if s-ourbank = "TXB00" then v-txbbank = v-nbankru.
if v-bank <> "TXB00" and s-ourbank = "TXB00" then do:
    find first txb where txb.bank = v-bank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.
if s-ourbank <> "TXB00" then do:
    find first txb where txb.bank = s-ourbank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.

output stream vcrpt to vcrptac.html.
{html-title.i
 &stream = " stream vcrpt "
 &size-add = "xx-"
 &title = "Отчет по открытым и закрытым контрактам"
}
if v-sts = 'A' then v-text = 'открытым'.
else v-text = 'закрытым'.
/*find bankl where bankl.bank = s-ourbank no-lock no-error.
if avail bankl then put stream vcrpt unformatted "<P><B><tr align=""left""><font size=""3"">" bankl.name "</tr></B></FONT></P>" skip.*/


 put stream vcrpt unformatted "<P><B><tr align=""left""><font size=""3"">" v-txbbank "</tr></B></FONT></P>" skip.
 put stream vcrpt unformatted
     "<B>" skip
     "<P align = ""center""><FONT size=""3"" >"
     "Отчет по " + v-text + " контрактам клиентов <br> за период с " + string(v-dt1, '99/99/9999') + " по " + string(v-dt2, '99/99/9999') + "</FONT></P>" skip.

 put stream vcrpt unformatted
     "<B>" skip
     "<table border=""1"" cellpadding=""5"" cellspacing=""0"" style=""border-collapse: collapse""><FONT size = ""3"">" skip.

 put stream vcrpt unformatted "<tr><B>"
     "<td align=""center"" bgcolor=""#C0C0C0"">№ п/п</td>"
     /*"<td align=""center"" bgcolor=""#C0C0C0"">Bank</td>"*/
     "<td align=""center"" bgcolor=""#C0C0C0"">Наименование клиента</td>"
     "<td align=""center"" bgcolor=""#C0C0C0""> Экспорт/Импорт</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Номер и дата контракта</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Тип контракта</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Номер и дата паспорта сделки</td>"
	 "<td align=""center"" bgcolor=""#C0C0C0"">Сумма конракта</td>"
	 "<td align=""center"" bgcolor=""#C0C0C0"">Валюта конракта</td>"
	 "<td align=""center"" bgcolor=""#C0C0C0"">Дата закрытия</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Сумма оплат</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Сумма ГТД</td>"
     "<td align=""center"" bgcolor=""#C0C0C0"">Сумма Актов</td>"
     "</FONT></B></tr>" skip.
  for each t-contract no-lock:
    t = t + 1.
    put stream vcrpt  unformatted "<tr align=""center""><font size=""3"">"
        "<td>" string(t) "</td>" skip
        /*"<td>" t-contract.bank "</td>" skip*/
        "<td>" t-contract.name "</td>" skip
        "<td>" t-contract.expimp "</td>" skip
        "<td>" t-contract.num "&nbsp;" string(t-contract.dt,'99/99/99') "</td>" skip
        "<td>" t-contract.ctype "</td>" skip.
        if t-contract.numps <> '' then put stream vcrpt  unformatted
        "<td>" t-contract.numps "&nbsp;" string(t-contract.dtps,'99/99/99') "</td>" skip.
        else put stream vcrpt  unformatted "<td>" "</td>" skip.
        put stream vcrpt  unformatted "<td>" replace(trim(string(t-contract.sum,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" t-contract.crc "</td>" skip.
        if v-sts = 'C' then put stream vcrpt  unformatted  "<td>" t-contract.clsdt "</td>" skip.
        else put stream vcrpt  unformatted  "<td>" "</td>" skip.
        put stream vcrpt  unformatted "<td>" replace(trim(string(t-contract.sum_opl,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(t-contract.sum_gtd,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(t-contract.sum_akt,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "</FONT></tr>" skip.
  end.

put stream vcrpt unformatted  "</FONT></table>".



find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then  put stream vcrpt unformatted
    "<P align=""left""><B><font size=""2""><BR>Исполнитель: " ofc.name "</font></B></P>" skip.

{html-end.i}

output stream vcrpt close.
unix silent cptwin vcrptac.html excel.
unix silent rm -f vcrptac.html.
