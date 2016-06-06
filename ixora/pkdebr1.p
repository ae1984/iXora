
/* pkdebr1.p
 * MODULE
        Мониторинг задолжников
 * DESCRIPTION
        Отчет по задолжникам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
     pkdebtrep.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
        4.14.1
 * AUTHOR
        30.03.2004 tsoy
 * CHANGES
       07.04.2004 tsoy поменял местами РНН и Место работы
       05.05.2004 tsoy Добавил выделение зеленым цветом сумм и кодов клиентов где просрочка ОД < 1
       13.05.2004 tsoy     - показываем синим цветом тех задолжников которые являются работниками наших клиентов
       24.05.2004 tsoy     - добавил дату открытия
       14.09.2004 saltanat - добавила выделение желтым фоном клиентов с плат. картами
       20.09.2004 saltanat - включила дисконект базы Cards.
       30.09.2004 saltanat - включила проверку на статус карточки
       21/10/2005 madiyar - небольшая оптимизация
       23/02/2006 madiyar - исправил несоответствие в шаренной таблице
       16/05/2006 madiyar  - добавил статус "Z" - списанные за баланс
       02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
       10/09/2007 madiyar - убрал коннекты к cards, проверку rnn-is-client; исправил расчет дней просрочки процентов
       11/02/2008 madiyar - t-pkreport.expsum = 0
       08.04.2009 galina - убрала пеню из итоговой суммы; добавила вывод валюты кредита и комиссионого долга в валюте кредита
       04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
       08/02/2010 madiyar - перекомпиляция
*/

{mainhead.i}
/* {con-crd.i} */

define var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define stream m-out.
output stream m-out to pkdebr1.html.

def shared temp-table t-pkdebt like pkdebt
  field name      as   char
  field checkdt   as   date
  field yessendlt as   char
  field bal1      like lon.opnamt   /* основной долг */
  field bal2      like lon.opnamt   /* проценты      */
  field balpen    like lon.opnamt   /* штрафы        */
  field balcom    like lon.opnamt   /* комиссия за вед. счета */
  field bal3      like lon.opnamt   /* общая сумма задолженности */
  field balz1     like lon.opnamt   /* списанный ОД */
  field balz2     like lon.opnamt   /* списанные % */
  field balzpen   like lon.opnamt   /* списанные штрафы */
  field bal4      like lon.opnamt   /*4уровень*/
  field bal5      like lon.opnamt   /*5уровень*/
  field balmon    like lon.opnamt
  field aaabal    like lon.opnamt
  field crc       like lon.crc
  field lastlt    as   char
  field lastltdt  as   date
  field roll      as   integer
  field stype     as   char
  field duedt     like lon.duedt
  field lgrfdt    as date
  field expdt     as date
  field eday      as integer
  field prkol     as integer.

def temp-table t-pkreport like t-pkdebt
  field totamt    like  trxbal.dam  /* */
  field totbal    like  trxbal.dam  /* */
  field idt       as    integer     /* */
  field lstdt     as    date        /* */
  field lstact    as    char        /* */
  field lstres    as    char        /* */
  field nxtdt     as    date        /* */
  field expsum    as    decimal     /* */
  field mngfio    as    char        /* */
  field tel       as    char        /* */
  field job       as    char        /* */
  field posit     as    char        /* */
  field rnn       as    char        /* */
  field aliv      as    char        /* */
  field asign     as    char        /* */

  /*
  field is-cl     as    logical
  */
  field lonrdt     like  lon.rdt.   /* */

def var i as integer no-undo init 1.
def var v-str as char no-undo.
def var v-delim as char no-undo init "^".
def var v-is-client as logical no-undo.

/* 14.09.2004 saltanat - если клиент имеет плат.карточку выделяется фиолетовым цветом */
/*
function card_color returns logical (input v-cif as char).
def var v-color as logical init false.
find first cif where cif.cif = v-cif no-lock no-error.
find first card_status where card_status.rnn = cif.jss no-lock no-error.
if avail card_status and not (card_status.name matches "*clos*") then v-color = true.
return v-color.
end function.
*/

for each t-pkdebt where (t-pkdebt.bal1 + t-pkdebt.bal2 + t-pkdebt.bal3) > 0 no-lock.

   create t-pkreport.
   buffer-copy t-pkdebt to t-pkreport.
   find first trxbal where trxbal.subled ='lon'
                           and trxbal.acc = t-pkdebt.lon
                           and trxbal.level = 1 no-lock.

   if avail trxbal then do:
        t-pkreport.totamt  = trxbal.dam.
        t-pkreport.totbal  = trxbal.dam - trxbal.cam.
   end.

   /* дней просрочки процентов - из londebt */
   find first londebt where londebt.lon = t-pkdebt.lon no-lock no-error.
   if avail londebt then t-pkreport.idt = londebt.days_prc.

   find last pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = t-pkdebt.lon use-index lonrdt no-lock no-error.
   if avail pkdebtdat then do:
       t-pkreport.lstdt = pkdebtdat.rdt.

       find ofc where ofc.ofc = pkdebtdat.rwho no-lock no-error.
       if avail ofc then
           t-pkreport.mngfio = ofc.name.
        else
           t-pkreport.mngfio = pkdebtdat.rwho.

       t-pkreport.nxtdt = pkdebtdat.checkdt.

       find bookcod where bookcod.bookcod = 'pkdbtact' and bookcod.code = pkdebtdat.action no-lock no-error.
       if avail bookcod then
           t-pkreport.lstact  = bookcod.name.

       find bookcod where bookcod.bookcod = 'pkdbtres' and bookcod.code = pkdebtdat.result no-lock no-error.
       if avail bookcod then
           t-pkreport.lstres  = bookcod.name.

   end.

   /*
   for each pkdebtdat where pkdebtdat.bank = s-ourbank and
                            pkdebtdat.lon = t-pkdebt.lon and
                            pkdebtdat.rdt > t-pkdebt.lgrfdt use-index lonrdt no-lock.
          t-pkreport.expsum = t-pkreport.expsum + deci(pkdebtdat.info[2]).
   end.
   */
   t-pkreport.expsum = 0.

   find cif where cif.cif = t-pkdebt.cif no-lock no-error.
   if avail cif then do:
       t-pkreport.tel     = trim(cif.tel) + "," + trim(cif.tlx) + "," + trim(cif.fax) + "," + trim(cif.btel).
       t-pkreport.job     = cif.ref[8].

       if cif.item <> "" then do:
         t-pkreport.rnn = entry(1, cif.item, "|").
       end.


      if cif.dnb <> "" then do:
        v-str = entry(1, cif.dnb, "|").
        if num-entries(v-str, v-delim) > 1 then t-pkreport.asign =  entry(2, v-str, v-delim).
        if num-entries(v-str, v-delim) > 2 then t-pkreport.asign =  t-pkreport.asign + " д." + entry(3, v-str, v-delim).
        if num-entries(v-str, v-delim) > 3 then t-pkreport.asign =  t-pkreport.asign + " кв."  + entry(4, v-str, v-delim).
        if num-entries(cif.dnb, "|") > 1 then do:
          v-str = entry(2, cif.dnb, "|").
          if num-entries(v-str, v-delim) > 1 then t-pkreport.aliv = entry(2, v-str, v-delim).
          if num-entries(v-str, v-delim) > 2 then t-pkreport.aliv = t-pkreport.aliv + " д." +  entry(3, v-str, v-delim).
          if num-entries(v-str, v-delim) > 3 then t-pkreport.aliv = t-pkreport.aliv + " кв."  + entry(4, v-str, v-delim).
        end.
      end.

      /*
      run rnn-is-client (t-pkreport.rnn, input-output v-is-client).
      t-pkreport.is-cl = v-is-client.
      */

   end.

   {comm-txb.i}
   def var v-bank as char.
   v-bank = comm-txb().

   find first pkanketh where pkanketh.bank           = v-bank
                             and pkanketh.ln         = t-pkdebt.ln
                             and pkanketh.credtype   = t-pkdebt.credtype
                             and pkanketh.kritcod    = "jobsn" no-lock no-error.
   if avail pkanketh then
       t-pkreport.posit   = pkanketh.value1.
   else
       t-pkreport.posit   = "".

   find first lon where lon.lon = t-pkdebt.lon no-lock no-error.
   if avail lon then
       t-pkreport.lonrdt = lon.rdt.

end.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream m-out unformatted "<h3>Отчет по задолжникам <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

       put stream m-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td rowspan=""2"" >N</td>"
                         "<td rowspan=""2"">Код<br>клиента</td>"
                         "<td rowspan=""2"">Наименование заемщика</td>"
                         "<td rowspan=""2"">Вид<br>кредита</td>"
                         "<td rowspan=""2"">Валюта<br>кредита</td>"
                         "<td rowspan=""2"">Статус</td>"
                         "<td rowspan=""2"">День Расчета<br>(ежемесячно)</td>"
                         "<td rowspan=""2"">Сумма<br>кредита</td>"
                         "<td rowspan=""2"">Остаток<br>долга</td>"
                         "<td rowspan=""2"">Итого задолженность <br> (без штрафов)</td>"
                         "<td rowspan=""2"">Ежемесячный<br>платеж</td>"
                         "<td rowspan=""2"">Сумма<br>на текущем счете</td>"
                         "<td rowspan=""2"">Пеня</td>"
                         "<td rowspan=""2"">Просрочка %        </td>"
                         "<td rowspan=""2"">Дней<br>просорочки % </td>"
                         "<td rowspan=""2"">Просрочка ОД </td>"
                         "<td rowspan=""2"">Дней<br>просорочки ОД</td>"
                         "<td rowspan=""2"">Задолж-ть по ком. <br> в вал. кредита</td>"
                         "<td rowspan=""2"">Дата открытия <br>кредита</td>"
                         "<td rowspan=""2"">Дата последнего <br> погашения</td>"
                         "<td colspan=""3"">Последний контроль </td>"
                         "<td rowspan=""2"">Дата следующего<br>контроля</td>"
                         "<td rowspan=""2"">Телефоны</td>"
                         "<td rowspan=""2"">РНН организации</td>"
                         "<td rowspan=""2"">Место работы</td>"
                         "<td rowspan=""2"">Должность</td>"
                         "<td rowspan=""2"">Адрес<br>проживания </td>"
                         "<td rowspan=""2"">Адрес<br>прописки</td>"
                         "<td rowspan=""2"">Расходы по <br> произведенной работе </td>"
                         "<td rowspan=""2"">Менеджер котролер</td>"
                         skip.

       put stream m-out unformatted "</tr><tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Дата      </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Действие  </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Результат </td>"
                         "</tr>" skip.


for each t-pkreport break by t-pkreport.name:
   find first crc where crc.crc = t-pkreport.crc no-lock no-error.

       put stream m-out  unformatted "<tr>"
                   "<td>" string(i)       "</td>"
                   "<td align=""left""" if t-pkreport.bal1 < 1 then " style=""font:bold;color:green""" else "" "> " t-pkreport.cif "</td>" skip
                   "<td>" t-pkreport.name  "</td>"
                   "<td>" t-pkreport.stype "</td>"  skip
                   "<td>" crc.code  "</td>"
                   "<td>" t-pkreport.sts "</td>"   skip
                   "<td>" string(t-pkreport.eday) "</td>"  skip
                   "<td>" replace(trim(string(totamt, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(totbal, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td style=""font:bold"">" replace(trim(string(t-pkreport.bal1 + t-pkreport.bal2 + t-pkreport.balz1 + t-pkreport.balz2 + t-pkreport.balcom, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.balmon,  "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.aaabal,  "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.bal3 + t-pkreport.balzpen,    "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.bal2,    "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" string(t-pkreport.idt)  "</td>" skip
                   "<td" if t-pkreport.bal1 < 1 then " style=""font:bold;color:green""" else "" ">" replace(trim(string(t-pkreport.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td>" string(t-pkreport.days) "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.balcom,  "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" if t-pkreport.lonrdt = ? then "" else  string(t-pkreport.lonrdt, "99.99.9999") "</td>" skip
                   "<td>" if t-pkreport.expdt = ? then "" else  string(t-pkreport.expdt, "99.99.9999") "</td>"  skip
                   "<td>" if t-pkreport.lstdt = ? then "" else  string(t-pkreport.lstdt, "99.99.9999") "</td>" skip
                   "<td>" t-pkreport.lstact "</td>" skip
                   "<td>" t-pkreport.lstres "</td>" skip
                   "<td>" if t-pkreport.nxtdt = ? then "" else string(t-pkreport.nxtdt, "99.99.9999") "</td>"skip
                   "<td>" t-pkreport.tel format "x(40)"  "</td>"skip
                   "<td>" "'" string(t-pkreport.rnn, "x(12)")             "</td>"skip
                   "<td>" t-pkreport.job             "</td>"skip
                   "<td>" t-pkreport.posit           "</td>"skip
                   "<td>" t-pkreport.aliv            "</td>"skip
                   "<td>" t-pkreport.asign           "</td>"skip
                   "<td>" string(t-pkreport.expsum, "->>>>>>>>>>>>9.99")  "</td>"skip
                   "<td>" t-pkreport.mngfio          "</td>"skip
                   "</tr>" skip.
        i = i + 1.
end.

put stream m-out unformatted
                "</table>".

output stream m-out close.
unix silent cptwin pkdebr1.html excel.
/*
if connected ("cards") then disconnect cards no-error.
*/

