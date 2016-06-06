/* vctamps.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Информация по паспортам сделок для сверки между таможенным органом и банком
        если выбирают активные контракты, то статус указывается А (со статусом S по умолчанию), 
        закрытые отдельно С или СА
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        18.09.2006 u00600 
        
*/

{comm-txb.i}

def shared var g-today as date. 
def var s-vcourbank as char.

def temp-table t-tamps no-undo
    field cif            like vccontrs.cif 
    field v-tam          like vccontrs.custom
    field num-ps         like vcps.dnnum
    field dat-ps         like vcps.dndate    /*as char*/
    field ei             like vccontrs.expimp    
    field num-contr      like vccontrs.ctnum     
    field dat-contr      like vccontrs.ctdate   /*as char*/
    field sum-contr      like vccontrs.ctsum     
    field crc-contr      like crc.code           
    field name-cif       like cif.name           
    field OKPO-cif       like cif.ssn            
    field RNN-cif        like cif.jss            
    field fiz-ur         like cif.type          
    field KATO-cif       as char                 
    field name-partn     like vcpartners.name    
    field strana         like vcpartners.country .

def var v-dtb as date.
def var v-dte as date.
def var v-tam as char init "".
def var v-sts as char init "".

def var name-partn like vcpartners.name. def var strana like vcpartners.country.
def var name-cif like cif.name. def var OKPO-cif like cif.ssn. 
def var RNN-cif like cif.jss. def var fiz-ur like cif.type.
def var v-crc like crc.code. def var v-KATO as char.
def var i as integer init 0.
def var OKPObank as char init "". def var namebank as char init "".

s-vcourbank = comm-txb().

v-dtb = 01/01/1999. v-dte = g-today.
   
form 
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999" 
  validate (v-dtb <= g-today, " Дата не может быть больше " + string (g-today))   
  v-dte label "  Конец периода " format "99/99/9999" 
  validate (v-dte <= g-today, " Дата не может быть больше " + string (g-today)) skip
  skip

  v-sts label " Статус контракта "   validate (v-sts <> "", "Введите статус контракта!")  help "Введите статус контракта A,C,CA"
  v-tam label " Таможенный орган"   validate (v-tam <> "", "Введите код таможенного органа!")
  skip(1)
  with centered side-label row 3 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

displ v-dtb v-dte v-sts v-tam with frame f-dt.
update v-dtb v-dte v-sts v-tam with frame f-dt.

message "  Формируется отчет...".

if v-sts = "A" then v-sts = "A,S".

 /*(vccontrs.sts = 'A' or vccontrs.sts = 'S')*/
  for each vccontrs where vccontrs.bank = s-vcourbank and lookup(vccontrs.sts,v-sts) > 0 and vccontrs.cttype = '1' and vccontrs.custom = v-tam no-lock :

    c-vcps:
    for each vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock:

/*      if not (vcps.rdt >= v-dtb and vcps.rdt <= v-dte) then next c-vcps.*/
      if not (vcps.dndate >= v-dtb and vcps.dndate <= v-dte) then next c-vcps.

      find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
        if avail vcpartners then do: name-partn = vcpartners.name. /*strana = vcpartners.country.*/ end.
           else do: name-partn = "". strana = "" . end.

      find first codfr where codfr.codfr = 'iso3166' and codfr.code = vcpartners.country no-lock no-error.
      if avail codfr then strana = codfr.name[2].
      else strana = "".

      find first cif where cif.cif = vccontrs.cif no-lock no-error.
        if avail cif then do: name-cif = cif.name. OKPO-cif = (if cif.type = 'b' then cif.ssn else ""). RNN-cif = cif.jss. fiz-ur = cif.type. end.
           else do: name-cif = "".  OKPO-cif = "". RNN-cif = "". fiz-ur = "". end.

      find first ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
        if avail ncrc then v-crc = ncrc.code.
           else v-crc = "".

      find first sub-cod where sub-cod.sub   = 'cln' 
                 and sub-cod.acc   = vccontrs.cif 
                 and sub-cod.d-cod = 'regionkz' no-lock  no-error.

      if avail sub-cod then v-KATO = sub-cod.ccode .
      else v-KATO = "".


      if LENGTH(OKPO-cif) <> 12 then do:
        i = LENGTH(OKPO-cif).
        if i = 8 then OKPO-cif = OKPO-cif + "0000".
        if i = 9 then OKPO-cif = OKPO-cif + "000".
      end.

      create  t-tamps.          
      assign  t-tamps.cif          =  vccontrs.cif
              t-tamps.v-tam        =  vccontrs.custom     
              t-tamps.num-ps       =  vcps.dnnum
              t-tamps.dat-ps       =  vcps.dndate    /*string(day(vcps.dndate), "99") + "." + string(month(vcps.dndate), "99") + "." + string(year(vcps.dndate), "9999")*/
              t-tamps.ei           =  vccontrs.expimp
              t-tamps.num-contr    =  vccontrs.ctnum
              t-tamps.dat-contr    =  vccontrs.ctdate   /*string(day(vccontrs.ctdate), "99") + "." + string(month(vccontrs.ctdate), "99") + "." + string(year(vccontrs.ctdate), "9999")*/
              t-tamps.sum-contr    =  vccontrs.ctsum / 1000
              t-tamps.crc-contr    =  v-crc
              t-tamps.name-cif     =  name-cif
              t-tamps.OKPO-cif     =  OKPO-cif
              t-tamps.RNN-cif      =  RNN-cif
              t-tamps.fiz-ur       =  fiz-ur
              t-tamps.KATO-cif     =  v-KATO
              t-tamps.name-partn   =  name-partn
              t-tamps.strana       =  strana.

    end.
  end.

  find first cmp no-lock no-error . 
  if avail cmp then do: namebank = cmp.name. OKPObank = cmp.addr[3]. end.
  else do: namebank = "" . OKPObank = "" . end.

def stream vcrpt.
output to sverka.html.

 {html-title.i 
  &stream = "  "
  &title = " "
  &size-add = "x-"
 }

  put unformatted   
    "<br><P align=""center"" style=""font:bold"">Информация по паспортам сделок <br>"
     " За период с " string(v-dtb, "99/99/9999") " по " string (v-dte,"99/99/9999") "</P>" skip.

if v-sts = "A,S" then do:

  put unformatted     
         "<TABLE cellspacing=""0"" cellpadding=""15"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center rowspan=2></td>"
          "<td align=center rowspan=2>N</td>"
          "<td align=center rowspan=""2"">Код<br>таможенного<br>органа</td>"
          "<td colspan=""2"">Реквизиты банка<br>паспорта сделки</td>"
          "<td align=center colspan=""2"">Реквизиты паспорта<br>сделки</td>"
          "<td align=center rowspan=""2"">Признак -<br>экспорт/<br>импорт</td>"
          "<td colspan=""4"">Данные по контракту</td>"
          "<td colspan=5>Данные экспортера/импортера</td>"
          "<td colspan=""2"">Нерезидент</td>"
          "<td align=center rowspan=""2"">Признак<br>паспорта<br>сделки -<br>действующий,<br>отнесенный<br>на отдель<br>ный учет</td>" skip.

  put unformatted     
          "</TR>" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center>Наименование</td>"
          "<td align=center>ОКПО</td>"      
          "<td align=center>N</td>"
          "<td align=center>дата</td>"
          "<td align=center>N</td>"
          "<td align=center>Дата</td>"
          "<td align=center>Сумма</td>"
          "<td align=center>Валюта</td>"
          "<td align=center>Наименование/ФИО</td>"
          "<td align=center>ОКПО</td>"
          "<td align=center>РНН</td>"
          "<td align=center>Признак -<br>юриди<br>ческое<br>лицо/индиви<br>дуальный<br>предпри<br>ниматель</td>"
          "<td align=center>Код области</td>"
          "<td align=center>Наименование/<br>ФИО</td>"
          "<td align=center>Страна</td>"
          "</tr>" skip.

i = 0 . 
  for each t-tamps by t-tamps.cif .
  i = i + 1.

  put unformatted 
        "<TR><TD>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</TD>" skip
          "<TD>" i "</TD>" skip
          "<TD >" t-tamps.v-tam "</TD>" skip 
          "<TD >" namebank "</TD>" skip
          "<TD >&nbsp;" OKPObank "</TD>" skip  
          "<TD >"t-tamps.num-ps "</TD>" skip
          "<TD >" t-tamps.dat-ps format "99/99/9999" "</TD>" skip
          "<TD >" if t-tamps.ei = "e" then "1" else "2" "</TD>" skip
          "<TD >&nbsp;" t-tamps.num-contr "</TD>" skip
          "<TD >" t-tamps.dat-contr format "99/99/9999" "</TD>" skip
          "<TD >" replace(trim(string(t-tamps.sum-contr, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</TD>" skip
          "<TD >" t-tamps.crc-contr "</TD>" skip
          "<TD >" t-tamps.name-cif "</TD>" skip
          "<TD >&nbsp;" t-tamps.OKPO-cif "</TD>" skip
          "<TD >&nbsp;" t-tamps.RNN-cif "</TD>" skip
          "<TD >" if t-tamps.fiz-ur = "b" then "1" else "2" "</TD>" skip
          "<TD >" t-tamps.KATO-cif "</TD>" skip
          "<TD >" t-tamps.name-partn "</TD>" skip
          "<TD >" t-tamps.strana "</TD>" skip
          "<TD >1</TD>" skip
          "</TR>" skip.  
  end.

  end.

  if v-sts = "C" or v-sts = "CA" then do: 

  put  unformatted     
         "<TABLE cellspacing=""0"" cellpadding=""15"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center rowspan=2>N</td>"
          "<td align=center rowspan=""2"">Код<br>таможенного<br>органа</td>"
          "<td colspan=""2"">Реквизиты паспорта сделки</td>"
          "<td align=center rowspan=""2"">Признак -<br>экспорт/<br>импорт</td>"
          "<td colspan=""4"">Данные по контракту</td>"
          "<td colspan=""1"">Данные экспортера/импортера</td>" skip.
  put  unformatted     
          "</TR>" skip
          "<TR align=""center"" style=""font:bold"">" skip
          "<td align=center>N</td>"
          "<td align=center>дата</td>"
          "<td align=center>N</td>"
          "<td align=center>Дата</td>"
          "<td align=center>Сумма</td>"
          "<td align=center>Валюта</td>"
          "<td align=center>Наименование/ФИО</td>"
          "</tr>" skip.

i = 0 . 
  for each t-tamps by t-tamps.cif .
  i = i + 1.

  put unformatted 
        "<TR><TD>" i "</TD>" skip
          "<TD >" t-tamps.v-tam "</TD>" skip 
          "<TD >"t-tamps.num-ps "</TD>" skip
          "<TD >" t-tamps.dat-ps "</TD>" skip
          "<TD >" if t-tamps.ei = "e" then "1" else "2" "</TD>" skip
          "<TD >&nbsp;" t-tamps.num-contr "</TD>" skip
          "<TD >" t-tamps.dat-contr "</TD>" skip
          "<TD >" replace(trim(string(t-tamps.sum-contr, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</TD>" skip
          "<TD >" t-tamps.crc-contr "</TD>" skip
          "<TD >" t-tamps.name-cif "</TD>" skip
          "</TR>" skip.  
  end.
 
  end.

  put unformatted "</table>" skip.
  put unformatted "</table></body></html>" skip.  
  output close.
  unix silent cptwin sverka.html excel.exe.
