/* pkdebr3.p
 * MODULE
        Мониторинг задолжников
 * DESCRIPTION
       Отчет клиенты вышедшие из списка задолжников
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
       13.04.2004 tsoy поставил ограничение только на текущий банк
       21/10/2005 madiyar - небольшая оптимизация
       02/08/2006 madiyar - no-undo
       11/02/2008 madiyar - добавил поля в отчет
       10/06/2008 madiyar - не выводим в отчет, если дней просрочки 0
 */

{mainhead.i}

define var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define stream m-out.
output stream m-out to pkdebr3.html.

def temp-table t-pkreport no-undo
  field cif       as    char
  field name      as    char
  field lon       as    char
  field stype     as    char
  field eday      as    integer
  field days_od   as    integer
  field days_od_all as    integer
  field days_prc  as    integer
  field days_prc_all as    integer
  field totamt    as    decimal
  field totbal    as    decimal
  field balmon    as    decimal
  field sumacc    as    decimal
  field sumdebt   as    decimal
  field lstdt     as    date        /* */
  field lstact    as    char        /* */
  field lstres    as    char        /* */
  field lstrem    as    char        /* */
  field expsum    as    decimal     /* */
  field mngfio    as    char        /* */
  field tel       as    char        /* */
  field job       as    char        /* */
  field posit     as    char        /* */
  field rnn       as    char.        /* */

def temp-table t-lonres no-undo
  field jdt as date
  field dc as char
  field sum as deci
  index idx is primary jdt.

def var v-dtb as date no-undo format "99/99/9999".
def var v-dte as date no-undo format "99/99/9999".
def var i as integer no-undo init 1.
def var v-str as char no-undo.
def var v-delim as char no-undo init "^".
def var v-msum as deci no-undo.
def var st_dt as date no-undo.
def var days_all as integer no-undo.
def var days_last as integer no-undo.

form
  v-dtb  format "99/99/9999" label " Начальная дата периода "
    help " Введите дату начала периода"
    validate (v-dtb <= g-today, " Дата не может быть больше " + string (g-today)) skip

  v-dte  format "99/99/9999" label " Конечная дата периода  "
    help " Введите дату конца периода"
    validate (v-dte <= g-today, " Дата не может быть больше " + string (g-today)) skip
  with overlay width 78 centered row 6 side-label title " Параметры отчета "  frame f-period.

  v-dte = g-today.
  update v-dtb v-dte with frame f-period.

   {comm-txb.i}
   def var v-bank as char.
   v-bank = comm-txb().

for each pkdebt where sts = "C"
                      and pkdebt.stsdt  >= v-dtb
                      and pkdebt.stsdt  <= v-dte
                      and pkdebt.bank   = v-bank
                      no-lock.

   find cif where cif.cif = pkdebt.cif no-lock no-error.
   if not avail cif then next.

   create t-pkreport.
   t-pkreport.cif  =  pkdebt.cif.
   
   t-pkreport.name = cif.name.
   if trim(cif.tel) <> '' then t-pkreport.tel = 'дом. ' + trim(cif.tel).
   if trim(cif.tlx) <> '' then do:
     if t-pkreport.tel <> '' then t-pkreport.tel = t-pkreport.tel + ', '.
     t-pkreport.tel = t-pkreport.tel + 'раб. ' + trim(cif.tlx).
   end.
   if trim(cif.btel) <> '' then do:
     if t-pkreport.tel <> '' then t-pkreport.tel = t-pkreport.tel + ', '.
     t-pkreport.tel = t-pkreport.tel + 'конт. ' + trim(cif.btel).
   end.
   if trim(cif.fax) <> '' then do:
     if t-pkreport.tel <> '' then t-pkreport.tel = t-pkreport.tel + ', '.
     t-pkreport.tel = t-pkreport.tel + 'сот. ' + trim(cif.fax).
   end.
                              
   find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkdebt.credtype no-lock no-error.
   if avail bookcod then t-pkreport.stype = bookcod.info[1].

   find lon where lon.lon = pkdebt.lon no-lock no-error.
   
   if avail lon then t-pkreport.eday = lon.day.

   t-pkreport.lon = pkdebt.lon.

   find first trxbal where trxbal.subled ='lon'
                           and trxbal.acc = pkdebt.lon
                           and trxbal.level = 1 no-lock no-error.

   if avail trxbal then do:
        t-pkreport.totamt  = trxbal.dam.
        t-pkreport.totbal  = trxbal.dam - trxbal.cam.
   end.
   
   find first lnsch where lnsch.lnn = pkdebt.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 no-lock no-error.
   
   find first lnsci where lnsci.lni = pkdebt.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
   
   if avail lnsci and avail lnsch then t-pkreport.balmon = lnsch.stval + lnsci.iv-sc.
   else t-pkreport.balmon = 0.
    
   t-pkreport.sumacc = pkdebt.sumacc.
   t-pkreport.sumdebt = pkdebt.sumdebt.
   
   for each t-lonres: delete t-lonres. end.
   for each lonres where lonres.lon = pkdebt.lon and lonres.lev = 7 no-lock:
     create t-lonres.
     t-lonres.jdt = lonres.jdt.
     t-lonres.dc = lonres.dc.
     t-lonres.sum = lonres.amt.
   end.
   
   v-msum = 0. st_dt = ?.
   days_all = 0. days_last = 0.
   for each t-lonres no-lock:
       if t-lonres.dc = 'd' then do:
           if v-msum = 0 then st_dt = t-lonres.jdt.
           v-msum = v-msum + t-lonres.sum.
       end.
       else do:
           v-msum = v-msum - t-lonres.sum.
           if v-msum < 0 then v-msum = 0.
           if v-msum = 0 then
               if st_dt <> ? then do:
                   days_last = t-lonres.jdt - st_dt.
                   days_all = days_all + days_last.
                   st_dt = ?.
               end.
       end.
   end.
   
   t-pkreport.days_od  = days_last.
   t-pkreport.days_od_all  = days_all.
   
   for each t-lonres: delete t-lonres. end.
   for each lonres where lonres.lon = pkdebt.lon and lonres.lev = 9 no-lock:
     create t-lonres.
     t-lonres.jdt = lonres.jdt.
     t-lonres.dc = lonres.dc.
     t-lonres.sum = lonres.amt.
   end.
   
   v-msum = 0. st_dt = ?.
   days_all = 0. days_last = 0.
   for each t-lonres no-lock:
       if t-lonres.dc = 'd' then do:
           if v-msum = 0 then st_dt = t-lonres.jdt.
           v-msum = v-msum + t-lonres.sum.
       end.
       else do:
           v-msum = v-msum - t-lonres.sum.
           if v-msum < 0 then v-msum = 0.
           if v-msum = 0 then
               if st_dt <> ? then do:
                   days_last = t-lonres.jdt - st_dt.
                   days_all = days_all + days_last.
                   st_dt = ?.
               end.
       end.
   end.
   
   t-pkreport.days_prc  = days_last.
   t-pkreport.days_prc_all  = days_all.
   
   if t-pkreport.days_od + t-pkreport.days_prc + t-pkreport.days_od_all + t-pkreport.days_prc_all <= 0 then do:
       delete t-pkreport.
       next.
   end.
   
   find last pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = pkdebt.lon use-index lonrdt no-lock no-error.
   if avail pkdebtdat then do:
       t-pkreport.lstdt = pkdebtdat.rdt.

       find ofc where ofc.ofc = pkdebtdat.rwho no-lock no-error.
       if avail ofc then
           t-pkreport.mngfio = ofc.name.
        else
           t-pkreport.mngfio = pkdebtdat.rwho.

       find bookcod where bookcod.bookcod = 'pkdbtact' and bookcod.code = pkdebtdat.action no-lock no-error.
       if avail bookcod then
           t-pkreport.lstact  = bookcod.name.

       find bookcod where bookcod.bookcod = 'pkdbtres' and bookcod.code = pkdebtdat.result no-lock no-error.
       if avail bookcod then
           t-pkreport.lstres  = bookcod.name.
       
       t-pkreport.lstrem = trim(pkdebtdat.info[1]).
   
   end.
   
   /*
   find last lnsch where lnsch.stdat < pkdebt.stsdt and lnsch.lnn = pkdebt.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
   if avail lnsch then do:
       for each pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = pkdebt.lon and pkdebtdat.rdt > lnsch.stdat no-lock.
              t-pkreport.expsum = t-pkreport.expsum + deci(pkdebtdat.info[2]).
       end.
   end.
   */
   t-pkreport.expsum = 0.
   


   if avail cif then do:
       t-pkreport.job     = cif.ref[8].
       if cif.item <> "" then do:
         t-pkreport.rnn = entry(1, cif.item, "|").
       end.
   end.

   find first pkanketh where pkanketh.bank           = v-bank
                             and pkanketh.ln         = pkdebt.ln
                             and pkanketh.credtype   = pkdebt.credtype
                             and pkanketh.kritcod    = "jobsn" no-lock no-error.
   if avail pkanketh then
       t-pkreport.posit   = pkanketh.value1.
   else
       t-pkreport.posit   = "".

end.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream m-out unformatted "<h3>Отчет по задолжникам <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.

       put stream m-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td rowspan=""2"" >N</td>"
                         "<td rowspan=""2"">Код<br>клиента</td>"
                         "<td rowspan=""2"">Наименование заемщика</td>"
                         "<td rowspan=""2"">Вид<br>кредита</td>"
                         "<td rowspan=""2"">День расчета<br>(ежемесячно)</td>"
                         "<td rowspan=""2"">Сумма<br>кредита</td>"
                         "<td rowspan=""2"">Остаток<br>долга</td>"
                         "<td rowspan=""2"">Погашенная<br>просрочка</td>"
                         "<td rowspan=""2"">Ежемесячный<br>платеж</td>"
                         
                         "<td rowspan=""2"">Дней<br>просрочки ОД</td>"
                         "<td rowspan=""2"">Дней<br>просрочки %%</td>"
                         "<td rowspan=""2"">Всего дней<br>просрочки ОД</td>"
                         "<td rowspan=""2"">Всего дней<br>просрочки %%</td>"
                         
                         "<td rowspan=""2"">Сумма<br>на текущем счете</td>"
                         "<td colspan=""4"">Последний контроль </td>"
                         "<td rowspan=""2"">РНН организации</td>"
                         "<td rowspan=""2"">Место работы</td>"
                         "<td rowspan=""2"">Должность</td>"
                         "<td rowspan=""2"">Телефоны</td>"
                         "<td rowspan=""2"">Расходы по <br> произведенной работе </td>"
                         "<td rowspan=""2"">Менеджер-контролер</td>"
                          skip.

       put stream m-out unformatted "</tr><tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Дата      </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Действие  </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Результат </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Примечание</td>"
                         "</tr>" skip.


for each t-pkreport break by t-pkreport.name:

       put stream m-out  unformatted "<tr>"
                   "<td>" string(i)       "</td>"
                   "<td>" t-pkreport.cif  "</td>"  skip
                   "<td>" t-pkreport.name "</td>"  skip
                   "<td>" t-pkreport.stype "</td>"  skip
                   "<td>" string(t-pkreport.eday) "</td>"  skip
                   "<td>" replace(trim(string(totamt, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(totbal, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.sumdebt, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" replace(trim(string(t-pkreport.balmon,  "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   
                   "<td>" trim(string(t-pkreport.days_od, "->>>>>>9")) "</td>" skip
                   "<td>" trim(string(t-pkreport.days_prc, "->>>>>>9")) "</td>" skip
                   "<td>" trim(string(t-pkreport.days_od_all, "->>>>>>9")) "</td>" skip
                   "<td>" trim(string(t-pkreport.days_prc_all, "->>>>>>9")) "</td>" skip
                   
                   "<td>" replace(trim(string(t-pkreport.sumacc,  "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" if t-pkreport.lstdt = ? then "" else  string(t-pkreport.lstdt, "99.99.9999") "</td>" skip
                   "<td>" t-pkreport.lstact "</td>" skip
                   "<td>" t-pkreport.lstres "</td>" skip
                   "<td>" t-pkreport.lstrem "</td>" skip
                   "<td>" "'" string(t-pkreport.rnn, "x(12)")             "</td>"skip
                   "<td>" t-pkreport.job             "</td>"skip
                   "<td>" t-pkreport.posit           "</td>"skip
                   "<td>" t-pkreport.tel "</td>"skip
                   "<td>" string(t-pkreport.expsum, "->>>>>>>>>>>>9.99")  "</td>"skip
                   "<td>" t-pkreport.mngfio          "</td>"skip
                   "</tr>" skip.
        i = i + 1.
end.

put stream m-out unformatted
                "</table>".

output stream m-out close.
unix silent cptwin pkdebr3.html excel.
