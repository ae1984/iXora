/* vcrptstr.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Информация по контрактам с выборкой по странам
        если выбирают активные контракты, то статус указывается А (со статусом S по умолчанию),
        если закрытые С по умолчанию С и СА
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
       9-3-18
 * AUTHOR
        06.11.2006 u00600
 * BASES
        BANK COMM
 * CHANGES
        09/11/2010 madiyar - убрал -H,-S
        18/11/2010 aigul - сделала отчет консолидированным
        02.03.2011 damir - Убрал проверку  на страну инопартнера и все что связанос инопартнерами  при выборке и из пункта меню b соответствующие поля в таблице
                           убрал и добавил некоторые поля для вывода в отчет.все что в комментах - это я закомментил.
                           добавил vcrptstrdat.p разбранчевку


*/
{vc.i}
{comm-txb.i}
def shared var g-today as date.

def new shared temp-table t-cif
    field cif       like cif.cif
    field bank      as char
    field name      as char
    field contract  as char
    field data      as date
    field cttype    as char
    field v-amt     as decimal init 2
    field crc       like ncrc.crc
    field name-ino  as char
    field rekv-ino  as char
    field strana    as char
    field tovar     as char
    field expimp    as char
    field sts       as char
    field psnum     as char
    field psnumnum  as integer
    field vcrslc    as char
    index main is primary name cif data contract.

def var v-filename as char init "vc.htm".
/*def new shared var v-cif like cif.cif. def new shared var v-name as char.
def new shared var v-gr10 as char. def new shared var v-tovar as char.
def new shared var v-crc like ncrc.crc. def new shared var v-crcN as char.
def new shared var v-str1 like codfr.code. def new shared var v-strana as char.*/

def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var v-str as char init "". def new shared var v-sts as char init "".
def new shared var v-type as char init "".
def var i as integer init 0.
def var v-txbbank as char.
def var v-ncrccod as char.
v-dtb = 01/01/1999. v-dte = g-today.

form
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999"
  validate (v-dtb <= g-today, " Дата не может быть больше " + string (g-today))
  v-dte label "  Конец периода " format "99/99/9999"
  validate (v-dte <= g-today, " Дата не может быть больше " + string (g-today)) skip
  skip

  v-sts label " Статус контракта "  validate (v-sts <> "", "Введите статус контракта!")  help "Введите статус контракта A,C"
  /*v-str label " Страна инопартнера " validate (v-str <> "", "Введите код страны инопартнера!")  help " F2 - ВЫБОР "*/
  v-type label " Тип контракта " validate (v-type <> "", "Введите тип контракта!") help "Введите тип контракта"
  skip(1)
  with centered side-label row 3 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

/*on help of v-str in frame f-dt do:
                            run h-country.
                            v-str:screen-value = return-value.
                            v-str = v-str:screen-value.
                          end.*/

displ v-dtb v-dte v-sts /*v-str*/ v-type with frame f-dt.
update v-dtb v-dte v-sts /*v-str*/ v-type with frame f-dt.

if v-sts = "A" then v-sts = "A,S".  if v-sts = "C" then v-sts = "C,CA".
/*if v-type = "1" then v-type = "1,2,11,5".*/

{r-brfilial.i   &proc = " vcrptstrdat(input txb.bank,0 ,v-dtb ,v-dte ,v-sts, v-type) "}

/*def var s-ourbank as char no-undo.
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
v-txblist = "ALL,TXB00,TXB01,TXB02,TXB03,TXB04 ,TXB05,TXB06,TXB07,TXB08,TXB09 ,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
v-sel = 0.
if s-ourbank = "TXB00" then do:
    run sel2("ФИЛИАЛЫ",v-banklist,output v-sel).
    if v-sel > 0 then v-bank = entry(v-sel,v-txblist).
    else return.
    message "  Формируется отчет...".
    for each vccontrs where (vccontrs.rdt >= v-dtb and vccontrs.rdt <= v-dte) and lookup(vccontrs.sts,v-sts) > 0 and lookup(vccontrs.cttype, v-type) > 0
    and (vccontrs.bank = v-bank or v-bank = "ALL") no-lock :*/
        /*find first vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
        if avail vcpartners then do:
            if vcpartners.country <> v-str then next.
            v-cif = vccontrs.cif. v-tovar = vccontrs.cttype. v-crc = vccontrs.ncrc. v-str1 = vcpartners.country.*/
        /*find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrptstrcif.
        end.
        create t-cif.
        assign
        t-cif.bank = vccontrs.bank
        t-cif.name = v-name
        t-cif.contract = vccontrs.ctnum
        t-cif.data = vccontrs.ctdate
        t-cif.v-amt = vccontrs.ctsum
        t-cif.crc = v-crcN
        t-cif.name-ino = trim(trim(txb.vcpartners.name) + " " + trim(vcpartners.formasob))
        t-cif.rekv-ino = txb.vcpartners.bankdata
        t-cif.strana = v-strana
        t-cif.tovar = v-gr10
        t-cif.expimp = vccontrs.expimp
        t-cif.sts = vccontrs.sts .
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "1" no-lock no-error.
        if avail vcps then do:
            t-cif.psnum = vcps.dnnum.
            t-cif.psnumnum = vcps.num.
        end.
        else do:
            t-cif.psnum = "".
        end.
    end.
end.
if s-ourbank <> "TXB00" then do:
    message "  Формируется отчет...".
    for each vccontrs where (vccontrs.rdt >= v-dtb and vccontrs.rdt <= v-dte) and lookup(vccontrs.sts,v-sts) > 0 and lookup(vccontrs.cttype, v-type) > 0
    and (vccontrs.bank = s-ourbank) no-lock :*/
        /*find first vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
        if avail vcpartners then do:
            if vcpartners.country <> v-str then next.
            v-cif = vccontrs.cif. v-tovar = vccontrs.cttype. v-crc = vccontrs.ncrc. v-str1 = vcpartners.country.*/
        /*find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrptstrcif.
        end.
        create t-cif.
        assign
        t-cif.bank = vccontrs.bank
        t-cif.name = v-name
        t-cif.contract = vccontrs.ctnum
        t-cif.data = vccontrs.ctdate
        t-cif.v-amt = vccontrs.ctsum
        t-cif.crc = v-crcN
        t-cif.name-ino = trim(trim(txb.vcpartners.name) + " " + trim(vcpartners.formasob))
        t-cif.rekv-ino = txb.vcpartners.bankdata
        t-cif.strana = v-strana
        t-cif.tovar = v-gr10
        t-cif.expimp = vccontrs.expimp
        t-cif.sts = vccontrs.sts .
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "1" no-lock no-error.
        if avail vcps then do:
            t-cif.psnum = vcps.dnnum.
            t-cif.psnumnum = vcps.num.
        end.
        else do:
            t-cif.psnum = "".
        end.
    end.
end.

if v-bank = "ALL" then v-txbbank = "АО 'МЕТРОКОМБАНК'".
else do:
    find first txb where txb.bank = v-bank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.*/
def stream vcrpt.
output stream vcrpt to value(v-filename).

 {html-title.i
  &stream = "  "
  &title = " "
  &size-add = "x-"
 }
put stream vcrpt unformatted
    "<html><head>
    <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
    <META content=ru http-equiv=Content-Language>
    </head>".
put stream vcrpt unformatted
    "<table border=1>" skip
    "<br><P align=""center"" style=""font:bold"">" v-txbbank "<br>"
    "<br><P align=""center"" style=""font:bold"">Информация по контрактам <br>"
     " За период с " string(v-dtb, "99/99/9999") " по " string (v-dte,"99/99/9999") "</P>" skip.

 /*put unformatted
         "<TABLE cellspacing=""0"" cellpadding=""12"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center rowspan=2>N</td>"*/
          /*"<td align=center rowspan=2>Bank</td>"*/
          /*"<td align=center colspan=""5"">Клиента банка</td>"
          "<td align=center colspan=""3"">Инопартнер</td>"
          "<td align=center colspan=""3"">Информация по контракту</td>"
          skip.*/

  put stream vcrpt unformatted
          "</TR>" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center>№</td>"
          "<td align=center>Наименование клиента</td>"
          "<td align=center>N контракта</td>"
          "<td align=center>Дата контракта</td>"
          "<td align=center>Экспорт и импорт</td>"
          "<td align=center>Тип контракта</td>"
          "<td align=center>Сумма контракта</td>"
          "<td align=center>Валюта контракта</td>"
          /*"<td align=center>Наименование, Ф.И.О., форма собственности</td>"
          "<td align=center>Банковские реквизиты, город</td>"
          "<td align=center>Страна</td>"
          "<td align=center>Товар/услуги</td>"
          "<td align=center>Статус контракта</td>"*/
          "<td align=center>№ ПС</td>"
          "<td align=center>№ Свидетельство о регистрации и/свид-во об уведомлении</td>"
          "</tr>" skip.

  i = 0.
  for each t-cif no-lock.
    i = i + 1.
    put stream vcrpt unformatted
        "<TR><TD>" i "</TD>" skip
        /*"<TD>" t-cif.bank "</TD>" skip*/
        "<TD>" t-cif.name "</TD>" skip
        "<TD >&nbsp;" t-cif.contract "</TD>" skip
        "<TD >" t-cif.data format "99/99/9999" "</TD>" skip
        "<TD >" if t-cif.expimp = "e" then "экспорт" else "импорт" "</TD>" skip
        "<TD >" t-cif.cttype "</TD>" skip
        "<TD >" replace(trim(string(t-cif.v-amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</TD>" skip.
        /*"<TD >" t-cif.data format "99/99/9999" "</TD>" skip*/
        find ncrc where ncrc.crc = t-cif.crc no-lock no-error.
        if avail ncrc then v-ncrccod = ncrc.code.
        else v-ncrccod = "&nbsp;".
    put stream vcrpt unformatted
        "<TD >" v-ncrccod "</TD>" skip.
    if t-cif.psnum <> "" then
    put stream vcrpt unformatted
        "<TD >" t-cif.psnum "</TD>" skip.
    else
    put stream vcrpt unformatted
        "<TD >" "отсутствует" "</TD>" skip.
    put stream vcrpt unformatted
        "<TD >" t-cif.vcrslc "</TD>" skip
        /*"<TD >" t-cif.name-ino "</TD>" skip
        "<TD >&nbsp;" t-cif.rekv-ino "</TD>" skip
        "<TD >" t-cif.strana "</TD>" skip
        "<TD >" t-cif.tovar "</TD>" skip
        "<TD >" t-cif.sts "</TD>" skip*/
        "</TR>" skip.

  end.

  put stream vcrpt unformatted "</table>" skip.
  put stream vcrpt unformatted "</table></body></html>" skip.
  output stream vcrpt close.
  unix silent cptwin value(v-filename) excel.
