 /* pkdebr2.p
 * MODULE
        Мониторинг задолжников
 * DESCRIPTION
        Отчет по по проведенной работе
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
        02.04.2004 tsoy
 * CHANGES
        13.04.2004 tsoy изменил дату последнего погащения на ту дату с которой пошла просрочка
        21/10/2005 madiyar - небольшая оптимизация
        17/01/2006 madiyar - не совпадала шаренная таблица t-pkdebt с оригинальным описанием, исправил
        02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
        27/11/2006 Natalya D. - синхронизировала вр.таблицу t-pkdebt c оригинальным описанием.
        11/02/2008 madiyar - добавил остаток долга, дни просрочки %%, примечания к последнему контролю
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
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
output stream m-out to pkdebr2.html.

def shared temp-table t-pkdebt like pkdebt
  field name      as   char
  field checkdt   as   date
  field yessendlt as   char
  field bal1      like lon.opnamt   /* просроченный основной долг (7) */
  field bal2      like lon.opnamt   /* просроченные проценты (4,9,10) */
  field balpen    like lon.opnamt   /* штрафы (5,16) */
  field balcom    like lon.opnamt   /* комиссия за вед. счета */
  field bal3      like lon.opnamt   /* штрафы (5,16) */
  field balz1     like lon.opnamt   /* списанный ОД */
  field balz2     like lon.opnamt   /* списанные % */
  field balzpen   like lon.opnamt   /* списанные штрафы */
  field bal4      like lon.opnamt   /* 4уровень */
  field bal5      like lon.opnamt   /* 5уровень */
  field balmon    like lon.opnamt   /* ежемесячный платеж */
  field aaabal    like lon.opnamt   /* остаток на счете */
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

def temp-table t-pkreport no-undo
  field cif       as    char
  field name      as    char
  field lon       as    char
  field stype     as    char
  field days      as    integer
  field days_prc  as    integer
  field sumdebt   as    decimal
  field bilance   as    decimal
  field lstdt     as    date        /* */
  field lstact    as    char        /* */
  field lstres    as    char        /* */
  field lstrem    as    char        /* */
  field nxtdt     as    date        /* */
  field expsum    as    decimal     /* */
  field mngfio    as    char.        /* */
def var i as integer no-undo init 1.
def var v-str as char no-undo.
def var v-name as char no-undo.

def var v-delim as char no-undo init "^".

for each t-pkdebt where t-pkdebt.sumdebt > 0 no-lock.
   find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = t-pkdebt.lon and pkdebtdat.rdt > (g-today - t-pkdebt.days) /* t-pkdebt.lgrfdt */
              use-index lonrdt no-lock no-error.
   if not avail pkdebtdat then do:
       create t-pkreport.
       /*buffer-copy t-pkdebt to t-pkreport.*/
          t-pkreport.lstact = "-" .
          t-pkreport.lstres = "-" .

       t-pkreport.cif      =  t-pkdebt.cif.
       t-pkreport.name     =  t-pkdebt.name.
       t-pkreport.lon      =  t-pkdebt.lon.
       t-pkreport.stype    =  t-pkdebt.stype.
       t-pkreport.sumdebt  =  t-pkdebt.sumdebt.
       find first lon where lon.lon = t-pkdebt.lon no-lock no-error.
       if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output t-pkreport.bilance).
       t-pkreport.days  = t-pkdebt.days.
       find first londebt where londebt.cif = t-pkdebt.cif no-lock no-error.
       if avail londebt then t-pkreport.days_prc = londebt.days_prc.
       t-pkreport.expsum = 0.
   end.
   else do:
       for each pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = t-pkdebt.lon and pkdebtdat.rdt > (g-today - t-pkdebt.days) /* t-pkdebt.lgrfdt */
                use-index lonrdt no-lock.
           create t-pkreport.
              t-pkreport.cif      =  t-pkdebt.cif.
              t-pkreport.name     =  t-pkdebt.name.
              t-pkreport.lon      =  t-pkdebt.lon.
              t-pkreport.stype    =  t-pkdebt.stype.
              t-pkreport.sumdebt  =  t-pkdebt.sumdebt.
              find first lon where lon.lon = t-pkdebt.lon no-lock no-error.
              if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output t-pkreport.bilance).

              t-pkreport.days  = t-pkdebt.days.
              find first londebt where londebt.cif = t-pkdebt.cif no-lock no-error.
              if avail londebt then t-pkreport.days_prc = londebt.days_prc.

              find ofc where ofc.ofc = pkdebtdat.rwho no-lock no-error.
              if avail ofc then
                  t-pkreport.mngfio = ofc.name.
              else
                  t-pkreport.mngfio = pkdebtdat.rwho.

              t-pkreport.lstdt  = pkdebtdat.rdt.
              find bookcod where bookcod.bookcod = 'pkdbtact' and bookcod.code = pkdebtdat.action no-lock no-error.
              if avail bookcod then
                  t-pkreport.lstact  = bookcod.name.

              find bookcod where bookcod.bookcod = 'pkdbtres' and bookcod.code = pkdebtdat.result no-lock no-error.
              if avail bookcod then
                  t-pkreport.lstres  = bookcod.name.

              t-pkreport.lstrem = trim(pkdebtdat.info[1]).

              t-pkreport.expsum = 0. /* deci(pkdebtdat.info[2]).*/
              t-pkreport.nxtdt = pkdebtdat.checkdt.
       end.
   end.
end.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream m-out unformatted "<h3>Отчет по проведенной работе <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.

       put stream m-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td rowspan=""2"" >N</td>"
                         "<td rowspan=""2"">Код<br>клиента</td>"
                         "<td rowspan=""2"">Наименование заемщика</td>"
                         "<td rowspan=""2"">Вид<br>кредита</td>"
                         "<td rowspan=""2"">Менеджер-контролер</td>"
                         "<td rowspan=""2"">Остаток<br>долга</td>"
                         "<td rowspan=""2"">Итого<br>задолженность</td>"
                         "<td rowspan=""2"">Дней<br>просрочки ОД</td>"
                         "<td rowspan=""2"">Дней<br>просрочки %%</td>"
                         "<td colspan=""4"">Последний контроль </td>"
                         "<td rowspan=""2"">Расходы по <br> произведенной работе </td>"
                         "<td rowspan=""2"">Дата следующего<br>контроля</td>"
                          skip.

       put stream m-out unformatted "</tr><tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Дата      </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Действие  </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Результат </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"" >Примечание</td>"
                         "</tr>" skip.


for each t-pkreport break by t-pkreport.name:

if  first-of(t-pkreport.name) then v-name = t-pkreport.name.
else v-name = "".

       put stream m-out  unformatted "<tr>"
                   "<td>" string(i)       "</td>"
                   "<td>" t-pkreport.cif  "</td>"  skip
                   "<td>" v-name "</td>"  skip
                   "<td>" t-pkreport.stype  "</td>"  skip
                   "<td>" t-pkreport.mngfio "</td>"skip
                   "<td>" replace(trim(string(t-pkreport.bilance, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td style=""font:bold"" >" replace(trim(string(t-pkreport.sumdebt, "->>>>>>>>>>>>9.99")),".",",") "</td>" skip
                   "<td>" string(t-pkreport.days) "</td>" skip
                   "<td>" string(t-pkreport.days_prc) "</td>" skip
                   "<td>" if t-pkreport.lstdt = ? then "" else  string(t-pkreport.lstdt, "99.99.9999") "</td>" skip
                   "<td>" t-pkreport.lstact "</td>" skip
                   "<td>" t-pkreport.lstres "</td>" skip
                   "<td>" t-pkreport.lstrem "</td>" skip
                   "<td>" string(t-pkreport.expsum, "->>>>>>>>>>>>9.99")  "</td>"skip
                   "<td>" if t-pkreport.nxtdt = ? then "" else string(t-pkreport.nxtdt, "99.99.9999") "</td>"skip
                   "</tr>" skip.
        i = i + 1.
end.

put stream m-out unformatted
                "</table>".

output stream m-out close.
unix silent cptwin pkdebr2.html excel.

pause 0.
