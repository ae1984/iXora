/* dcls55.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Автоматическое погашение кредитов при наступлении графика, перенос на просрочку ОД и %%
 * RUN

 * CALLER
        dayclose.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        11.09.2003 marinav
 * CHANGES
        22.10.2003 nadejda - имя файла формируется с указанием даты
        08.01.2003 marinav - убрана проверка на нулевую задолженность
        23.02.2004 marinav - погашение индексации и перенос на просрочку
        05.04.2004 tsoy    - убрал ограничение на сумму < 1 для быстрых кредитов
        20/05/2004 madiyar - ввод схемы 4 для потреб. кредитов: погашение начисленных процентов только в день по графику
        03/08/2004 sasco   - исправил назначение платежа (переброс суммы в ордере с ОД на просроч.%%)
        28/10/2004 madiyar - в atl-prcl1 к рассчитанной сумме добавляются проценты, доначисленные вручную позже даты расчета
                             теперь начисленные % рассчитываются по histrxbal
        29/10/2004 madiyar - отменил изменения сделанные 28/10/2004
                             в atl-prcl1 в рассчитанную сумму входят проценты, доначисленные вручную позже даты расчета - просто вычитаем их
        07/01/2005 madiyar - автоматическое погашение 2 уровня с уровня предоплаты
        11/01/2005 madiyar - исправил небольшую проблему с 4-ой схемой
        07/05/2005 madiyar - новая схема начисления индексации - в связи с этим изменения в погашении индексации
                             добавил проверку v-bal2 на непревышение начисленных процентов на 2-ом уровне
        07/05/2005 madiyar - новая схема начисления индексации - в связи с этим изменения в погашении индексации
        29/11/2005 madiyar - погашение делается в первую очередь со счета, привязанного к кредиту
        16/01/2006 madiyar - при погашении предоплаты добавляем сумму предоплаты в pay12
        25/01/2006 madiyar - небольшие изменения в формате отчета-лога
        26/01/2006 madiyar - зануляем все pay-переменные после транзакции
        15/02/2006 Natalia D. добавлен перенос сумм % и штрафов, начисленных за балансом, в баланс
        24/03/2006 madiyar - раскидка доходов по профит-центрам; небольшая оптимизация
        28/03/2006 Natalya D. добавлено зануление pay4 и pay5, wrk.ppay4 и wrk.ppay5.
        06/06/2006 madiyar - изменение раскидки доходов по профит-центрам
        05/10/2006 madiyar - в комментариях к проводкам добавил номер ссудного договора и курс индексации
        14/11/06   marinav - при списании с 11 уровня добавляется сумма переноса с 4 ур.
        07/03/2007 madiyar - проставляем статус "C" погашенным кредитам
        16/04/2007 madiyar - статус "C" по погашенным кредитам не проставлялся, исправил
        17/04/2207 marinav - если сумма %% 0.01 , то проценты не погашать (связано с округлениями)
        10/11/2008 madiyar - только статус "A", убрал лишний код
        13/04/2009 galina - проставляем статус "C" сразу после погашения кредита
        17/04/2009 marinav - изменен расчет %% на 2-м уровне для Метрокредитов
        25/06/2009 madiyar - учет комиссий
        08/09/2009 galina - гасим беззалоговые кредиты согласно выбраному порядку погашения
        09/11/2009 madiyar - поправил - если кредит активный, но при этом opnamt=0, то помечаем как закрытый
        26/01/2010 madiyar - убрал проверку остатков после погашения (иначе не начисляется последняя комиссия), теперь проверка делается в dcls54.p
        02/02/2010 madiyar - выключено погашение по кредиту 007141925 Фрайзстрой
        16/04/2010 madiyar - поправил проблему по экспресс-кредитам с погашением сумм, меньших 1 тенге
        07/05/2010 madiyar - перевыдан кредит Фрайзстрой, выключено погашение по новому кредиту 005147112
        17/07/2010 madiyar - добавил обработку 6-ой схемы (так же, как 4 и 5)
        24/07/2010 madiyar - добавилась 4-ая схема погашения 9-4-7-com-2-1-16-5 (sub-cod.ccode = '03')
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        17/09/2010 madiyar - уменьшение суммы комиссии по кредитам бывших сотрудников при погашении
        03/12/2010 madiyar - восстановление возобн. остатка по КЛ при погашении транша
        07/12/2010 madiyar - подправил создание проводки по восстановлению остатка КЛ
        15/12/2010 madiyar - подправил запись истории по проводке по восстановлению остатка КЛ
        26/01/2011 madiyar - остаток КЛ не восстанавливается при наступлении срока периода доступности
        23/06/2011 madiyar - схема 3-я (sub-cod.ccode = '02') поменялась с 16-5-7-9-4-com-1-2 на 16-9-7-2-1-com-4-5 (ТЗ 1075)
        05/09/2011 madiyar - схемы погашения распространяем на все кредиты
        28/06/2012 kapar - ASTANA BONUS
        04/09/2012 kapar - ASTANA BONUS (lnsci.paid-iv = wrk.ppay2 + wrk.ppay49.)
        11/10/2012 kapar - поставил  use-index lni (а то не во всех случаях берется последняя дата и не списывается %)
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115
        08/11/2013 galina - ТЗ982 убрала обнудение 1 и второго уровня при наличии пролонгации
        22/11/2013 Luiza   - ТЗ 2220 замена текста «Оплата кредита» на «Оплата по договору»
*/


{global.i}
{lonlev.i}
def var coun as int init 1.
def var ja as log format "да/нет".
def var v-bal like glbal.bal no-undo.
def var v-param as char no-undo.
def var vdel as char initial "^".
def var vm as deci no-undo.
define new shared var s-jh like jh.jh.
define var s-jh1 like jh.jh.
define variable v-name as character no-undo.
def var bilance like jl.dam no-undo.
def var bilance1 like jl.dam no-undo.
def var bilancepl like jl.dam no-undo.
def var bilance2 like jl.dam no-undo.
def var v-bal16 like jl.dam no-undo.
def var v-bal5 like jl.dam no-undo.
def var v-bal9 like jl.dam no-undo.
def var v-bal4 like jl.dam no-undo.
def var v-bal7 like jl.dam no-undo.
def var v-bal2 like jl.dam no-undo.
def var v-bal1 like jl.dam no-undo.
def var v-bal10 like jl.dam no-undo.
def var v-bal20 like jl.dam no-undo.

/*def var v-bal21 like jl.dam.*/
def var v-bal22 like jl.dam no-undo.
/*def var v-bal23 like jl.dam.*/
def var vavl like jl.dam no-undo.
def var vhbal like jl.dam no-undo.
def var vbal like jl.dam no-undo.
def var vfbal like jl.dam no-undo.
def var vcrline like jl.dam no-undo.
def var vcrlused like jl.dam no-undo.
def var vooo like aaa.aaa no-undo.
def var pay1 like jl.dam no-undo.
def var pay2 like jl.dam no-undo.
def var pay4 like jl.dam no-undo.
def var pay5 like jl.dam no-undo.
def var pay7 like jl.dam no-undo.
def var pay9 like jl.dam no-undo.
def var pay16 like jl.dam no-undo.
def var pay12 like jl.dam no-undo.
def var pay20 like jl.dam no-undo.
/*def var pay21 like jl.dam.*/
def var pay22 like jl.dam no-undo.
/*def var pay23 like jl.dam.*/
def var pay10_2 like jl.dam no-undo. /* учет предоплаты - погашение %% */
def var pay10_9 like jl.dam no-undo. /* учет предоплаты - погашение просроченных %% */
def var paycom like jl.dam no-undo. /* учет комиссий */
def var v-srok as int init 0.
def var v-nxt as int init 0.
def var s-glremx as char extent 5.
def var dlong as date no-undo.
def var vcu like lon.opnamt extent 6 decimals 2.
def var v-bala like jl.dam no-undo.

def var v-balkoms like jl.dam no-undo.
def var paykoms like jl.dam no-undo.

def temp-table  wrk  no-undo
    field lon      like lon.lon
    field aaa      like aaa.aaa
    field name     like cif.name
    field bal      like jl.dam
    field ppay1    like jl.dam
    field ppay2    like jl.dam
    field ppay4    like jl.dam
    field ppay12   like jl.dam
    field ppay7    like jl.dam
    field ppay5    like jl.dam
    field ppay9    like jl.dam
    field ppay10_2 like jl.dam
    field ppay10_9 like jl.dam
    field ppaycom  like jl.dam
    field ppaykoms like jl.dam
    field ppay16   like jl.dam
    field ppay20   like jl.dam
   /* field ppay21   like jl.dam */
    field ppay22   like jl.dam
   /* field ppay23   like jl.dam */
    field pbal1    like jl.dam
    field pbal2    like jl.dam
   /*astana bonus*/
    field ppay49   like jl.dam
    field ppay50   like jl.dam
    field ppay52   like jl.dam
    field ppay53   like jl.dam
    field pbal49   like jl.dam
   /* field pbal20   like jl.dam */
   /* field pbal22   like jl.dam */.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var dat as date no-undo.
def var v-amt as dec no-undo.
def var v-amt1 as dec no-undo.
define var i as inte no-undo.
def var tempdt as date no-undo.
def var v-londog as char no-undo.
def var v-indrate as char no-undo.
/* def var v-bala as deci no-undo. */

def var dat_wrk as date no-undo.
find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

def var sp-aaa as char no-undo.
def var pn as integer no-undo.

def var v-code as char no-undo.
def var v-dep as char no-undo.
def buffer bjl for jl.
def buffer bcrc for crc.
{getdep.i}

def var v-pog as deci no-undo.
def buffer blon for lon.

define shared var s-bday as log.
define shared var s-target as date.
dat = g-today.
find first cmp no-lock no-error.
define stream m-out.
output stream m-out to value("lonrepday" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".html").
define stream m-out1.
output stream m-out1 to value("lonreptemp" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".html").

put stream m-out unformatted
                 "<html><head><title>Метрокомбанк</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out unformatted
                 "<br><br><tr align=""left""><td><h3>" cmp.name format "x(79)"
                 "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out1 unformatted
                 "<html><head><title>Метрокомбанк</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out1 unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out1 unformatted
                 "<br><br><tr align=""left""><td><h3>" cmp.name format "x(79)"
                 "</h3></td></tr><br><br>" skip(1).

put stream m-out1 unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

for each lon where lon.sts = 'A' no-lock:

     if lon.opnamt <= 0 then do:
          find first blon where blon.lon = lon.lon exclusive-lock.
          blon.sts = 'C'.
          find current blon no-lock.
          next. /* если кредит даже и не выдавался - пропускаем */
     end.

     /* пропускаем кредит 005147112 Фрайзстрой */
     if lon.cif = "A11401" and lon.lon = "005147112" then next.

     /* run atl-dat1 (lon.lon,dat,3,output bilance). -- фактич остаток  ОД -- */
     run lonbalcrc('lon',lon.lon,dat,"1,7",yes,lon.crc,output bilance).

     /* run atl-dat1 (lon.lon,dat,1,output bilance1). -- остаток  ОД на 1 уровне -- */
     run lonbalcrc('lon',lon.lon,dat,"1",yes,lon.crc,output bilance1).

     /*
     run atl-prcl1(input lon.lon, input dat - 1, output vcu[3], output vcu[4], output vcu[2]).
     bilance2 = vcu[3].  -- остаток %% на 2 уровне --
     */
     run lonbalcrc('lon',lon.lon,dat,"2",yes,lon.crc,output bilance2).

      assign v-bal16 = 0 v-bal5 = 0 v-bal9 = 0 v-bal4 = 0 v-bal7 = 0 v-bal2 = 0 v-bal1 = 0 v-bal20 = 0 /*v-bal21 = 0*/ v-bal22 = 0 /*v-bal23 = 0*/ v-bal10 = 0 v-balkoms = 0.
      assign pay16 = 0 pay5 = 0 pay9 = 0 pay4 = 0 pay7 = 0 pay2 = 0 pay1 = 0 pay12 = 0 pay20 = 0 /*pay21 = 0*/ pay22 = 0 /*pay23 = 0*/ pay10_2 = 0 pay10_9 = 0 paykoms = 0.


      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 16 no-lock :
          v-bal16 = v-bal16 + (trxbal.dam - trxbal.cam).
      end.
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 5 no-lock :
          v-bal5 = v-bal5 + (trxbal.dam - trxbal.cam).
      end.
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 9 no-lock :
          v-bal9 = v-bal9 + (trxbal.dam - trxbal.cam).
      end.
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 4 no-lock :
          v-bal4 = v-bal4 + (trxbal.dam - trxbal.cam).
      end.
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 7 no-lock :
          v-bal7 = v-bal7 + (trxbal.dam - trxbal.cam).
      end.
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 10 no-lock :
          v-bal10 = v-bal10 + (trxbal.cam - trxbal.dam).
      end.

      if bilance + v-bal7 + bilance2 + v-bal9 + v-bal4 + v-bal16 + v-bal5 <= 0 then do:
          find first blon where blon.lon = lon.lon exclusive-lock.
          blon.sts = 'C'.
          find current blon no-lock.
          next. /* если кредит погашен - пропускаем */
      end.

      v-londog = ''.
      find first loncon where loncon.lon = lon.lon no-lock no-error.
      if avail loncon then v-londog = loncon.lcnt.

           bilancepl = 0.   /* На тек день по графику погашения должен был погасить */
           for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 and lnsch.stdat <= dat no-lock:
              bilancepl = bilancepl + lnsch.stval.
           end.

           bilancepl = lon.opnamt - bilancepl. /* долг по графику , который должен остаться*/

           v-bal1 = bilance1 - bilancepl.
           if not (lon.grp = 90 or lon.grp = 92) then do:
              if v-bal1 < 1 then v-bal1 = 0.
           end.

 /*     end.*/


     find last lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 and lnsci.idat <= dat use-index lni no-lock no-error.
      if avail lnsci then do:
         run atl-prcl1(input lon.lon, input lnsci.idat - 1, output vcu[3], output vcu[4], output vcu[2]).
         v-bal2 = vcu[3].      /* долг % на дату последнего графика */

         /* 29/10/2004 madiyar - отнимаем вручную доначисленные проценты */
         for each lonres where lonres.lon = lon.lon and lonres.jdt > lnsci.idat no-lock:
           if lonres.lev = 2 and lonres.dc = 'D' then v-bal2 = v-bal2 - lonres.amt.
         end.
         /* 29/10/2004 madiyar - end */

         tempdt = lnsci.idat.
         for each lnsci where lnsci.lni = lon.lon and lnsci.idat >= tempdt and lnsci.f0 eq 0 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock.
             v-bal2 = v-bal2 - lnsci.paid.
         end.
         if not (lon.grp = 90 or lon.grp = 92) then do:
            if v-bal2 < 1 then v-bal2 = 0.
         end.
         if v-bal2 = 0.01 then v-bal2 = 0.

      end.
      else v-bal2 = 0.

         put stream m-out1 unformatted "<tr align=""right"">"
                             "<td align=""center""> По старому </td>"
                             "<td align=""center"">&nbsp;" lon.lon "</td>"
                             "<td align=""center"">&nbsp;" v-bal2 "</td>".

      /****************************************************/
      if lon.plan = 4 or lon.plan = 5 or lon.plan = 6 then do:
         v-bal2 = 0.
         /*по графику на день*/
         for each lnsci where lnsci.lni = lon.lon and lnsci.idat <= dat and lnsci.f0 > 0 and lnsci.fpn = 0 and lnsci.flp = 0 no-lock :
            v-bal2 = v-bal2 + lnsci.iv-sc.
         end.
         /*погашено на день*/
         for each lnsci where lnsci.lni = lon.lon and lnsci.idat <= dat and lnsci.f0 = 0 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock :
             v-bal2 = v-bal2 - lnsci.paid-iv .
         end.
         v-bal2 = v-bal2 - v-bal9.
         if v-bal2 <= 1 then v-bal2 = 0.
      end.
      /****************************************************/

      if v-bal10 - v-bal9 > 0 then do:
        if v-bal2 < v-bal10 - v-bal9 then do:
           if v-bal10 - v-bal9 <= lon.dam[2] - lon.cam[2] then v-bal2 = v-bal10 - v-bal9.
           else v-bal2 = lon.dam[2] - lon.cam[2].
        end.
      end.

      if lon.plan = 3 then v-bal2 = lon.dam[2] - lon.cam[2].

    /* Учтем пролонгации */
/*      dlong = lon.duedt.
      if lon.ddt[5] <> ? then dlong = lon.ddt[5].
      if lon.cdt[5] <> ? then dlong = lon.cdt[5].
      if dlong > lon.duedt and dlong > g-today then do:
          v-bal1 = 0. v-bal2 = 0.
      end.*/

    /* Если пролонгация закончилась, то гасить все что есть на 1 и 2 уровнях */
/*      if dlong <= g-today then do: v-bal1 = lon.dam[1] - lon.cam[1]. v-bal2 = lon.dam[2] - lon.cam[2]. end.*/

    /* проверим v-bal2 на непревышение начисленных процентов на 2-ом уровне */
    if v-bal2 > bilance2 then v-bal2 = bilance2.

    /* 22/12/2004 madiyar - корректировка погашаемых процентов с учетом предоплаты */

    if v-bal10 > 0 and v-bal9 > 0 then do:
        if v-bal9 <= v-bal10 then pay10_9 = v-bal9.
        else pay10_9 = v-bal10.
        v-bal10 = v-bal10 - pay10_9.
        v-bal9 = v-bal9 - pay10_9.
    end.

    if v-bal10 > 0 and v-bal2 > 0 then do:
        if v-bal2 <= v-bal10 then pay10_2 = v-bal2.
        else pay10_2 = v-bal10.
        v-bal10 = v-bal10 - pay10_2.
        v-bal2 = v-bal2 - pay10_2.
    end.

       put stream m-out1 unformatted  "<td> " v-bal2 "</td></tr>" skip.

    /* 22/12/2004 madiyar - end */

    /*посчитаем , что гасить по уровням индексаций*/
      for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 20 and trxbal.crc = 1 no-lock:
          v-bal20 = v-bal20 + (trxbal.dam - trxbal.cam).
      end.
      /*v-bal20 = v-bal20 * v-bal1 / bilance1.*/

      for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 22 and trxbal.crc = 1 no-lock:
          v-bal22 = v-bal22 + (trxbal.dam - trxbal.cam).
      end.
      /*v-bal22 = v-bal22 * v-bal2 / bilance2.*/

      /*
      for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
          and trxbal.level = 21 and trxbal.crc eq 1 no-lock :
          v-bal21 = v-bal21 + (trxbal.dam - trxbal.cam).
      end.

      for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
          and trxbal.level = 23 and trxbal.crc eq 1 no-lock :
          v-bal23 = v-bal23 + (trxbal.dam - trxbal.cam).
      end.
      */

      /* комиссия по кредитам бывших сотрудников */
      find first lons where lons.lon = lon.lon no-lock no-error.
      if avail lons then do:
          if lons.amt > 0 then do:
              /*по графику на день*/
              for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat <= dat no-lock:
                  v-balkoms = v-balkoms + lnscs.stval.
              end.
              /*погашено на день*/
              for each lnscs where lnscs.lon = lon.lon and lnscs.sch = no and lnscs.stdat <= dat no-lock:
                  v-balkoms = v-balkoms - lnscs.stval.
              end.

              if v-balkoms > lons.amt then v-balkoms = lons.amt.
          end.
      end.
      /**/
      if v-bal16 > 0 or v-bal5 > 0 or v-bal9 > 0 or v-bal4 > 0 or v-bal7 > 0 or v-bal1 > 0 or v-bal2 > 0 or pay10_2 > 0 or pay10_9 > 0 or v-balkoms > 0 then do:
          find crc where crc.crc = lon.crc no-lock no-error.
          i = 0.
          sp-aaa = ''.
          if lon.aaa <> '' then do:
            find first aaa where aaa.aaa = lon.aaa no-lock no-error.
            if avail aaa then if aaa.sta <> 'C' and aaa.sta <> 'E' then sp-aaa = aaa.aaa.
          end.
          for each lgr where lgr.led eq "DDA" or lgr.led eq "SAV", each aaa of lgr where aaa.cif eq lon.cif and aaa.sta ne "C":
            if aaa.aaa <> lon.aaa then do:
              if sp-aaa <> '' then sp-aaa = sp-aaa + ','.
              sp-aaa = sp-aaa + aaa.aaa.
            end.
          end.

          do pn = 1 to num-entries(sp-aaa):

            find first aaa where aaa.aaa = entry(pn,sp-aaa) no-lock no-error.
            if not avail aaa then next.

            run aaa-bal777(input aaa.aaa, output vbal,output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).

           i = 0.
           /* учет предоплаты */
           if pay10_2 > 0 or pay10_9 > 0 then do:
               pay12 = pay12 + (pay10_2 + pay10_9) * crc.rate[1] / crc.rate[9].
               i = 1.
           end.

           /*07/09/2009 galina - учитываем выбранный порядок погашения беззалоговых кредитов*/
           find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnpog' no-lock no-error.
           if /*(lon.grp = 90 or lon.grp = 92) and*/ avail sub-cod and sub-cod.ccode <> 'msc' then do:

               /*схема 1-ая 16-5-9-4-com-7-2-koms-1 sub-cod.ccode = 'msc'*/
               /*схема 2-ая 7-9-4-com-1-2-16-5 sub-cod.ccode = '01'*/
               /*схема 3-я 16-9-7-2-1-com-4-5 sub-cod.ccode = '02'*/
               /*схема 4-ая 9-4-7-com-2-1-16-5 sub-cod.ccode = '03'*/

               if sub-cod.ccode = '01' then do:
                   /* сумма для погашения просроченного ОД */
                   if vavl > 0 and v-bal7 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal7 then pay7 = v-bal7.
                                        else pay7 = vavl.

                         vavl = vavl - pay7.
                         v-bal7 = v-bal7 - pay7.
                         i = 1.
                   end.

                   /* сумма для погашения просроченных процентов */
                   if vavl > 0 and v-bal9 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal9 then pay9 = v-bal9.
                                        else pay9 = vavl.

                      vavl = vavl - pay9.
                      v-bal9 = v-bal9 - pay9.
                      pay12 = pay12 + pay9 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.


                   /* сумма для погашения просроченных процентов за балансом*/
                   if vavl > 0 and v-bal4 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal4 then pay4 = v-bal4.
                                        else pay4 = vavl.

                       vavl = vavl - pay4.
                       v-bal4 = v-bal4 - pay4.
                       i = 1.
                   end.

                   /* резервирование средств для погашения комиссии */
                   paycom = 0.
                   if ((lon.plan = 4) or (lon.plan = 5)) and aaa.aaa = lon.aaa and vavl > 0 then do:
                      for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' no-lock:
                           paycom = paycom + bxcif.amount.
                      end.
                      if s-bday then do:
                         find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat > dat_wrk and lnsch.stdat <= g-today and lnsch.f0 > 0 no-lock no-error.
                         if avail lnsch then do:
                            find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
                            if avail tarifex2 then paycom = paycom + tarifex2.ost.
                         end.
                      end.
                      if vavl > 0 and paycom > 0 and aaa.crc = lon.crc then do:
                         if vavl < paycom then paycom = vavl.
                         vavl = vavl - paycom.
                         i = 1.
                      end.
                   end.

                   /* сумма для погашения ОД по графику */
                   if vavl > 0 and v-bal1 > 0 and aaa.crc = lon.crc then do:

                     if vavl >= v-bal1 then pay1 = v-bal1.
                                       else pay1 = vavl.

                     vavl = vavl - pay1.
                     v-bal1 = v-bal1 - pay1.
                     i = 1.
                   end.

                   /* сумма для погашения процентов по графику */
                   if vavl > 0 and v-bal2 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal2 then pay2 = v-bal2.
                                        else pay2 = vavl.

                      vavl = vavl - pay2.
                      v-bal2 = v-bal2 - pay2.
                      pay12 = pay12 + pay2 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.

                   /* сумма для погашения штрафов */
                   if vavl > 0 and v-bal16 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal16 then pay16 = v-bal16.
                                          else pay16 = vavl.
                       vavl = vavl - pay16.
                       v-bal16 = v-bal16 - pay16.
                       i = 1.
                   end.

                   /* сумма для погашения внебалансных штрафов*/
                   if vavl > 0 and v-bal5 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal5 then pay5 = v-bal5.
                                          else pay5 = vavl.
                       vavl = vavl - pay5.
                       v-bal5 = v-bal5 - pay5.
                       i = 1.
                   end.
               end. /* if (sub-cod.ccode = '01') */
               else
               if sub-cod.ccode = '02' then do:
                   /* сумма для погашения штрафов */
                   if vavl > 0 and v-bal16 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal16 then pay16 = v-bal16.
                                          else pay16 = vavl.
                       vavl = vavl - pay16.
                       v-bal16 = v-bal16 - pay16.
                       i = 1.
                   end.

                   /* сумма для погашения просроченных процентов */
                   if vavl > 0 and v-bal9 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal9 then pay9 = v-bal9.
                                        else pay9 = vavl.

                      vavl = vavl - pay9.
                      v-bal9 = v-bal9 - pay9.
                      pay12 = pay12 + pay9 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.

                   /* сумма для погашения просроченного ОД */
                   if vavl > 0 and v-bal7 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal7 then pay7 = v-bal7.
                                        else pay7 = vavl.

                         vavl = vavl - pay7.
                         v-bal7 = v-bal7 - pay7.
                         i = 1.
                   end.

                   /* сумма для погашения процентов по графику */
                   if vavl > 0 and v-bal2 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal2 then pay2 = v-bal2.
                                        else pay2 = vavl.

                      vavl = vavl - pay2.
                      v-bal2 = v-bal2 - pay2.
                      pay12 = pay12 + pay2 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.

                   /* сумма для погашения ОД по графику */
                   if vavl > 0 and v-bal1 > 0 and aaa.crc = lon.crc then do:

                     if vavl >= v-bal1 then pay1 = v-bal1.
                                       else pay1 = vavl.

                     vavl = vavl - pay1.
                     v-bal1 = v-bal1 - pay1.
                     i = 1.
                   end.

                   /* резервирование средств для погашения комиссии */
                   paycom = 0.
                   if ((lon.plan = 4) or (lon.plan = 5)) and aaa.aaa = lon.aaa and vavl > 0 then do:
                      for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' no-lock:
                           paycom = paycom + bxcif.amount.
                      end.
                      if s-bday then do:
                         find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat > dat_wrk and lnsch.stdat <= g-today and lnsch.f0 > 0 no-lock no-error.
                         if avail lnsch then do:
                            find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
                            if avail tarifex2 then paycom = paycom + tarifex2.ost.
                         end.
                      end.
                      if vavl > 0 and paycom > 0 and aaa.crc = lon.crc then do:
                         if vavl < paycom then paycom = vavl.
                         vavl = vavl - paycom.
                         i = 1.
                      end.
                   end.

                   /* сумма для погашения просроченных процентов за балансом*/
                   if vavl > 0 and v-bal4 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal4 then pay4 = v-bal4.
                                        else pay4 = vavl.

                       vavl = vavl - pay4.
                       v-bal4 = v-bal4 - pay4.
                       i = 1.
                   end.

                   /* сумма для погашения внебалансных штрафов*/
                   if vavl > 0 and v-bal5 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal5 then pay5 = v-bal5.
                                          else pay5 = vavl.
                       vavl = vavl - pay5.
                       v-bal5 = v-bal5 - pay5.
                       i = 1.
                   end.
               end. /* if sub-cod.ccode = '02' */
               else
               if sub-cod.ccode = '03' then do:
                   /* сумма для погашения просроченных процентов */
                   if vavl > 0 and v-bal9 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal9 then pay9 = v-bal9.
                                        else pay9 = vavl.

                      vavl = vavl - pay9.
                      v-bal9 = v-bal9 - pay9.
                      pay12 = pay12 + pay9 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.

                   /* сумма для погашения просроченных процентов за балансом*/
                   if vavl > 0 and v-bal4 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal4 then pay4 = v-bal4.
                                        else pay4 = vavl.

                       vavl = vavl - pay4.
                       v-bal4 = v-bal4 - pay4.
                       i = 1.

                   end.

                   if vavl > 0 and v-bal7 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal7 then pay7 = v-bal7.
                                        else pay7 = vavl.

                         vavl = vavl - pay7.
                         v-bal7 = v-bal7 - pay7.
                         i = 1.
                   end.

                   /* резервирование средств для погашения комиссии */
                   paycom = 0.
                   if ((lon.plan = 4) or (lon.plan = 5)) and aaa.aaa = lon.aaa and vavl > 0 then do:
                      for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' no-lock:
                           paycom = paycom + bxcif.amount.
                      end.
                      if s-bday then do:
                         find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat > dat_wrk and lnsch.stdat <= g-today and lnsch.f0 > 0 no-lock no-error.
                         if avail lnsch then do:
                            find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
                            if avail tarifex2 then paycom = paycom + tarifex2.ost.
                         end.
                      end.
                      if vavl > 0 and paycom > 0 and aaa.crc = lon.crc then do:
                         if vavl < paycom then paycom = vavl.
                         vavl = vavl - paycom.
                         i = 1.
                      end.
                   end.

                   /* сумма для погашения процентов по графику */
                   if vavl > 0 and v-bal2 > 0 and aaa.crc = lon.crc then do:
                      if vavl >= v-bal2 then pay2 = v-bal2.
                                        else pay2 = vavl.

                      vavl = vavl - pay2.
                      v-bal2 = v-bal2 - pay2.
                      pay12 = pay12 + pay2 * crc.rate[1] / crc.rate[9].
                      i = 1.
                   end.

                   /* сумма для погашения ОД по графику */
                   if vavl > 0 and v-bal1 > 0 and aaa.crc = lon.crc then do:

                     if vavl >= v-bal1 then pay1 = v-bal1.
                                       else pay1 = vavl.

                     vavl = vavl - pay1.
                     v-bal1 = v-bal1 - pay1.
                     i = 1.
                   end.

                   /* сумма для погашения штрафов */
                   if vavl > 0 and v-bal16 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal16 then pay16 = v-bal16.
                                          else pay16 = vavl.
                       vavl = vavl - pay16.
                       v-bal16 = v-bal16 - pay16.
                       i = 1.
                   end.

                   /* сумма для погашения внебалансных штрафов*/
                   if vavl > 0 and v-bal5 > 0 and  aaa.crc = 1 then do:
                       if vavl >= v-bal5 then pay5 = v-bal5.
                                          else pay5 = vavl.
                       vavl = vavl - pay5.
                       v-bal5 = v-bal5 - pay5.
                       i = 1.
                   end.

               end.
           end.
           /************/
           else do:
               /* сумма для погашения штрафов */

               if vavl > 0 and v-bal16 > 0 and  aaa.crc = 1 then do:
                   if vavl >= v-bal16 then pay16 = v-bal16.
                                      else pay16 = vavl.
                   vavl = vavl - pay16.
                   v-bal16 = v-bal16 - pay16.
                   i = 1.
               end.

               /* сумма для погашения внебалансных штрафов 15/02/2006 Natalia D.*/

               if vavl > 0 and v-bal5 > 0 and  aaa.crc = 1 then do:

                   if vavl >= v-bal5 then pay5 = v-bal5.
                                      else pay5 = vavl.
                   vavl = vavl - pay5.
                   v-bal5 = v-bal5 - pay5.
                   i = 1.
               end.

               /* сумма для погашения индексированных % */
               if vavl > 0 and v-bal22 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal22 then pay22 = v-bal22.
                                      else pay22 = vavl.
                   vavl = vavl - pay22.
                   v-bal22 = v-bal22 - pay22.
                   i = 1.
               end.

               /* сумма для погашения индексированного ОД */
               if vavl > 0 and v-bal20 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal20 then pay20 = v-bal20.
                                      else pay20 = vavl.
                   vavl = vavl - pay20.
                   v-bal20 = v-bal20 - pay20.
                   i = 1.
               end.

               /* сумма для погашения просроченных процентов */ /* 04/05/2005 madiyar - убрал просроченные индекс. % */
               if vavl > 0 and v-bal9 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal9 then pay9 = v-bal9.
                                     else pay9 = vavl.

                   vavl = vavl - pay9.
                   v-bal9 = v-bal9 - pay9.
                   pay12 = pay12 + pay9 * crc.rate[1] / crc.rate[9].
                   i = 1.
               end.
               /* сумма для погашения просроченных процентов за балансом 15/02/2006 Natalia D.*/
               if vavl > 0 and v-bal4 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal4 then pay4 = v-bal4.
                                     else pay4 = vavl.

                   vavl = vavl - pay4.
                   v-bal4 = v-bal4 - pay4.
                   /*pay12_4 = pay12_4 + pay4 * crc.rate[1] / crc.rate[9].*/
                   i = 1.

               end.

               /* резервирование средств для погашения комиссии */
               paycom = 0.
               if ((lon.plan = 4) or (lon.plan = 5)) and aaa.aaa = lon.aaa and vavl > 0 then do:
                   for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' no-lock:
                       paycom = paycom + bxcif.amount.
                   end.
                   if s-bday then do:
                       find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat > dat_wrk and lnsch.stdat <= g-today and lnsch.f0 > 0 no-lock no-error.
                       if avail lnsch then do:
                           find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
                           if avail tarifex2 then paycom = paycom + tarifex2.ost.
                       end.
                   end.
                   if vavl > 0 and paycom > 0 and aaa.crc = lon.crc then do:
                       if vavl < paycom then paycom = vavl.
                       vavl = vavl - paycom.
                       i = 1.
                   end.
               end.

               /* сумма для погашения просроченного ОД */ /* 04/05/2005 madiyar - убрал просроченный индекс. ОД */
               if vavl > 0 and v-bal7 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal7 then pay7 = v-bal7.
                                     else pay7 = vavl.

                   vavl = vavl - pay7.
                   v-bal7 = v-bal7 - pay7.
                   i = 1.
               end.

               /* сумма для погашения процентов по графику */ /* 04/05/2005 madiyar - убрал индекс. % */
               if vavl > 0 and v-bal2 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal2 then pay2 = v-bal2.
                                     else pay2 = vavl.

                   vavl = vavl - pay2.
                   v-bal2 = v-bal2 - pay2.
                   pay12 = pay12 + pay2 * crc.rate[1] / crc.rate[9].
                   i = 1.
               end.

               /* сумма для погашения комиссии по кредитам бывших сотрудников */
               if vavl > 0 and v-balkoms > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-balkoms then paykoms = v-balkoms.
                                        else paykoms = vavl.

                   vavl = vavl - paykoms.
                   v-balkoms = v-balkoms - paykoms.
                   i = 1.
               end.

               /* сумма для погашения ОД по графику */ /* 04/05/2005 madiyar - убрал индекс. ОД */
               if vavl > 0 and v-bal1 > 0 and aaa.crc = lon.crc then do:
                   if vavl >= v-bal1 then pay1 = v-bal1.
                                     else pay1 = vavl.

                   vavl = vavl - pay1.
                   v-bal1 = v-bal1 - pay1.
                   i = 1.
               end.
           end.

           if i = 1 then do:
                 find cif where cif.cif = lon.cif no-lock no-error.
                 if aaa.crc = 1 then do:
                    create wrk.
                    wrk.lon = lon.lon.
                    wrk.aaa = aaa.aaa.
                    wrk.name = cif.name.
                    wrk.ppay1 = pay1.
                    wrk.ppay2 = pay2.
                    wrk.ppay12 = pay12.
                    wrk.ppay7 = pay7.
                    wrk.ppay9 = pay9.
                    wrk.ppay5 = pay5.
                    wrk.ppay10_2 = pay10_2.
                    wrk.ppay10_9 = pay10_9.
                    wrk.ppaycom = paycom.
                    wrk.ppaykoms = paykoms.
                    wrk.ppay16 = pay16.
                    wrk.ppay4 = pay4.
                    wrk.ppay20 = pay20.
                   /* wrk.ppay21 = pay21. */
                    wrk.ppay22 = pay22.
                   /* wrk.ppay23 = pay23. */
                    wrk.pbal1 = 0.
                    wrk.pbal2 = 0.
                   /* wrk.pbal20 = 0. */
                   /* wrk.pbal22 = 0. */
                 end.
                 else do:
                    create wrk.
                    wrk.lon = lon.lon.
                    wrk.aaa = aaa.aaa.
                    wrk.name = cif.name.
                    wrk.ppay1 = pay1.
                    wrk.ppay2 = pay2.
                    wrk.ppay12 = pay12.
                    wrk.ppay7 = pay7.
                    wrk.ppay9 = pay9.
                    wrk.ppay4 = pay4.
                    wrk.ppay10_2 = pay10_2.
                    wrk.ppay10_9 = pay10_9.
                    wrk.ppaycom = paycom.
                    wrk.ppaykoms = paykoms.
                    wrk.ppay16 = 0.
                    wrk.ppay5 = 0.
                    wrk.ppay20 = 0.
                   /* wrk.ppay21 = 0. */
                    wrk.ppay22 = 0.
                   /* wrk.ppay23 = 0. */
                    wrk.pbal1 = 0.
                    wrk.pbal2 = 0.
                   /* wrk.pbal20 = 0. */
                   /* wrk.pbal22 = 0. */
                 end.
                /*astana bonus*/
                run lonbalcrc('lon',lon.lon,dat,"49",yes,lon.crc,output wrk.ppay49).
                run lonbalcrc('lon',lon.lon,dat,"50",yes,lon.crc,output wrk.ppay50).
                run lonbalcrc('lon',lon.lon,dat,"51",yes,lon.crc,output wrk.ppay52).
                run lonbalcrc('lon',lon.lon,dat,"53",yes,lon.crc,output wrk.ppay53).

            /* Сразу же сделать проводку, погасим основные уровни*/

                  find cif where cif.cif = lon.cif no-lock.
                  find crc where crc.crc = lon.crc no-lock no-error.
                  v-name = wrk.aaa + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
                  if cif.jss ne "" then v-name = v-name + " ИИН/БИН " + cif.bin.
/*begin --- 15/02/2006 Natalia D.*/
                  /*перенесём начисленные за балансом штрафы в баланс*/

                 if wrk.ppay5 > 0 then do:


                    if wrk.ppay5 ne 0 then
                         s-glremx[1] = "Сумма погашаемого забалансового штрафа" +
                         trim(string(wrk.ppay5,">>>,>>>,>>9.99-"))
                         + " " + crc.code.
                       else s-glremx[1] = "".

                    v-param = string(wrk.ppay5) + vdel + wrk.lon + vdel +
                              s-glremx[1] + vdel + string(wrk.ppay5).


                    s-jh = 0.

                    run trxgen ("lon0119", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
                    {upd-dep.i}

                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.

                   run lonresadd(s-jh).
                find jh where jh.jh eq s-jh no-lock no-error.

                put stream m-out unformatted "<tr align=""right"">"
                             "<td align=""center""> Погашение </td>"
                             "<td align=""center"">&nbsp;" wrk.lon "</td>"
                             "<td align=""center"">&nbsp;" wrk.aaa "</td>"
                             "<td> " s-jh "</td>"
                             "</tr>" skip.

                end.


                /*перенесём начисленные за балансом проценты в баланс*/

                 if wrk.ppay4 > 0 then do:

                    if wrk.ppay4 ne 0 then
                          s-glremx[2] = "Сумма погашаемых забалансовых %% " +
                          trim(string(wrk.ppay4,">>>,>>>,>>9.99-")) + " " + crc.code.
                       else s-glremx[2] = "".

                    /*v-param = string(wrk.ppay4) + vdel + wrk.lon + vdel +
                              s-glremx[2] + vdel + string(wrk.ppay4).*/
                       if crc.crc = 1 then v-param = "0" + vdel + wrk.lon + vdel +
                              s-glremx[2] + vdel + "0" + vdel + string(wrk.ppay4) + vdel + wrk.lon + vdel +
                              s-glremx[2] + vdel + string(wrk.ppay4).
                       else v-param = string(wrk.ppay4) + vdel + wrk.lon + vdel +
                              s-glremx[2] + vdel + string(wrk.ppay4) + vdel + "0" + vdel + wrk.lon + vdel +
                              s-glremx[2] + vdel + "0".


                    s-jh = 0.

                    run trxgen ("lon0115", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
                    {upd-dep.i}

                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.

                   run lonresadd(s-jh).
                find jh where jh.jh eq s-jh no-lock no-error.

                put stream m-out unformatted "<tr align=""right"">"
                             "<td align=""center""> Погашение </td>"
                             "<td align=""center"">&nbsp;" wrk.lon "</td>"
                             "<td align=""center"">&nbsp;" wrk.aaa "</td>"
                             "<td> " s-jh "</td>"
                             "</tr>" skip.

                end.
/*end --- 15/02/2006 Natalia D.*/

                /* погасим комиссию по кредитам бывших сотрудников */
                if wrk.ppaykoms > 0 then do:
                    v-param = string(wrk.ppaykoms) + vdel + wrk.aaa + vdel +
                              "Оплата комиссии по кредиту " + lon.lon + " " + v-londog + " " + trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-")) + " " + crc.code + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin + vdel +
                              "" + vdel + "" + vdel + "" + vdel.

                    s-jh = 0.

                    run trxgen ("lon0135", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
                    {upd-dep.i}

                    if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                    end.

                    find first lons where lons.lon = lon.lon exclusive-lock no-error.
                    if avail lons then lons.amt = lons.amt - wrk.ppaykoms.
                    find current lons no-lock.

                    create lnscs.
                    assign lnscs.lon = lon.lon
                           lnscs.sch = no
                           lnscs.stdat = g-today
                           lnscs.stval = wrk.ppaykoms.

                    create lonsres.
                    assign lonsres.lon = lon.lon
                           lonsres.restype = "p"
                           lonsres.fdt = g-today
                           lonsres.tdt = g-today
                           lonsres.od = bilance1
                           lonsres.prem = lons.prem
                           lonsres.amt = wrk.ppaykoms
                           lonsres.who = g-ofc.

                end.
                /* комиссия по кредитам бывших сотрудников - end*/

                 if wrk.ppay16 > 0 or wrk.ppay5 > 0 or wrk.ppay9 > 0 or wrk.ppay4 > 0 or wrk.ppay7 > 0 or wrk.ppay2 > 0 or wrk.ppay1 > 0 or wrk.ppay10_2 > 0 or wrk.ppay10_9 > 0 then do:

                     /*astana bonus*/
                     if (wrk.ppay2 > 0 or wrk.ppay9 > 0) and (wrk.ppay49 > 0 or wrk.ppay50 > 0 or wrk.ppay53 > 0) then do:

                        if not wrk.ppay2 > 0 then do:
                          wrk.ppay49 = 0.
                          wrk.ppay52 = wrk.ppay50.
                        end.
                        else do:
                          wrk.ppay49 = wrk.ppay49 + wrk.ppay53.
                          wrk.ppay52 = abs(wrk.ppay52) + wrk.ppay53.
                        end.

                        v-param = string(wrk.ppay50) + vdel + wrk.aaa + vdel + wrk.lon + vdel +
                                  string(wrk.ppay49) + vdel + wrk.aaa + vdel + wrk.lon.

                         for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 51 no-lock:
                            bilance = trxbal.cam - trxbal.dam.
                         end.
                         if wrk.ppay52 > bilance then v-param = v-param + vdel + string(bilance) + vdel + wrk.lon + vdel + wrk.lon.
                                                 else v-param = v-param + vdel + string(wrk.ppay52) + vdel + wrk.lon + vdel + wrk.lon.

                        if wrk.ppay49 ne 0 then
                              s-glremx[1] = "Сумма погашаемых %% ASTANA BONUS" +
                              trim(string(wrk.ppay49,">>>,>>>,>>9.99-")) + " " + crc.code.
                           else s-glremx[1] = "".
                        if wrk.ppay50 ne 0 then
                              s-glremx[2] = "Сумма погашаемого просроч %% ASTANA BONUS" +
                              trim(string(wrk.ppay50,">>>,>>>,>>9.99-")) + " " + crc.code.
                           else s-glremx[2] = "".


                        v-param = v-param + vdel +
                                  s-glremx[1] + vdel +
                                  s-glremx[2].

                        s-jh = 0.
                        run trxgen ("lon0164", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
                        {upd-dep.i}

                        if rcode ne 0 then do:
                           message rdes.
                           pause 1000.
                           next.
                        end.

                        run lonresadd(s-jh).
                     end.

                     wrk.ppay16 = wrk.ppay16 + wrk.ppay5.
                     wrk.ppay2 = wrk.ppay2 + wrk.ppay4.
                     wrk.ppay12 = wrk.ppay12 + wrk.ppay4 * crc.rate[1] / crc.rate[9].

                     v-param = string(wrk.ppay16) + vdel + wrk.aaa + vdel +
                               wrk.lon.

                     v-srok = (round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30.
                     if v-srok > 360 then v-param = v-param + vdel + "423".
                                          else v-param = v-param + vdel + "421".

                     v-param = v-param + vdel +
                               string(wrk.ppay9) + vdel +
                               string(wrk.ppay7) + vdel +
                               string(wrk.ppay2) + vdel +
                               string(wrk.ppay1).

                      for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 11 no-lock:
                         bilance = trxbal.cam - trxbal.dam.
                      end.
                      if wrk.ppay12 > bilance then v-param = v-param + vdel + string(bilance).
                                              else v-param = v-param + vdel + string(wrk.ppay12).


                    s-glremx[1] = "Оплата по договору " + lon.lon + " " + v-londog + " " +
                         trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                         + " " + crc.code + " "
                         + trim(trim(cif.prefix) + " " + trim(cif.name)) /*+ " РНН " + cif.jss */.
                    if wrk.ppay1 ne 0 then
                         s-glremx[2] = "Сумма погашаемого осн. долга " +
                         trim(string(wrk.ppay1,">>>,>>>,>>9.99-"))
                         + " " + crc.code.
                       else s-glremx[2] = "".
                    if wrk.ppay2 ne 0 then
                          s-glremx[3] = "Сумма погашаемых %% " +
                          trim(string(wrk.ppay2 + wrk.ppay10_2,">>>,>>>,>>9.99-")) + " " + crc.code.
                       else s-glremx[3] = "".
                    if wrk.ppay7 ne 0 then
                          s-glremx[4] = "Сумма погашаемого просроч ОД" +
                          trim(string(wrk.ppay7,">>>,>>>,>>9.99-")) + " " + crc.code.
                       else s-glremx[4] = "".
                    if wrk.ppay9 ne 0 then
                          s-glremx[5] = "Сумма погашаемого просроч %%" +
                          trim(string(wrk.ppay9 + wrk.ppay10_9,">>>,>>>,>>9.99-")) + " " + crc.code.
                       else s-glremx[5] = "".
                    if wrk.ppay16 ne 0 then
                          s-glremx[5] = s-glremx[5] + "Сумма погашаемого штрафа" +
                          trim(string(wrk.ppay16,">>>,>>>,>>9.99-")) + " KZT" .


                    v-param = v-param + vdel +
                              s-glremx[1] + vdel +
                              s-glremx[2] + vdel +
                              s-glremx[3] + vdel +
                              s-glremx[4] + vdel +
                              s-glremx[5] .

                    v-param = v-param + vdel +
                              string(wrk.ppay10_2) + vdel +
                              string(wrk.ppay10_9).

                    s-jh = 0.
                    run trxgen ("lon0062", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
                    {upd-dep.i}

                    if rcode ne 0 then do:
                       message rdes.
                       pause 1000.
                       next.
                    end.

                    run lonresadd(s-jh).

                   if pay1 + pay7 > 0 and lon.clmain <> '' and lon.trtype = 1 then do:
                       find first blon where blon.lon = lon.clmain no-lock no-error.
                       if avail blon and blon.idt15 > g-today then do:
                           v-param = string (pay1 + pay7) + vdel + lon.clmain.
                           find first loncon where loncon.lon = lon.clmain no-lock no-error.
                           s-glremx[1] = "Создание возобн. дост. остатка КЛ, " + lon.clmain + " " + if avail loncon then loncon.lcnt else ''.
                           s-glremx[1] = s-glremx[1] + " " + trim(string(pay1 + pay7,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                                         " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin.
                           v-param = v-param + vdel + s-glremx[1] + vdel + vdel + vdel + vdel.
                           s-jh1 = 0.
                           run trxgen ("LON0137", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh1).
                           if rcode <> 0 then do:
                               message rdes + " Ошибка создания возобн. дост. остатка КЛ!".
                               pause 1000.
                           end.
                           else run lonresadd(s-jh1).
                       end.
                   end.

                   pay10_2 = 0. pay10_9 = 0. /* зануляем чтобы не погашалось вторично при наличии нескольких тек. счетов */
                   pay1 = 0. pay2 = 0. pay7 = 0. pay9 = 0. pay12 = 0. pay16 = 0. pay20 = 0. pay22 = 0. pay4 = 0. pay5 = 0. /* зануляем все переменные */

                find jh where jh.jh = s-jh no-lock no-error.

                if wrk.ppay1 > 0 then do:
                  v-nxt = 0.
                  for each lnsch where lnsch.lnn = lon.lon no-lock:
                     if lnsch.f0 = 0 and lnsch.flp > 0 then do:
                        if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                     end.
                  end.
                  create lnsch.
                  lnsch.lnn = lon.lon.
                  lnsch.f0 = 0.
                  lnsch.flp = v-nxt + 1.
                  lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
                  lnsch.paid = wrk.ppay1.
                  lnsch.stdat = jh.jdt.
                  lnsch.jh = jh.jh.
                  lnsch.whn = dat.
                  lnsch.who = g-ofc.
                end.

                if wrk.ppay7 > 0 then do:
                  v-nxt = 0.
                  for each lnsch where lnsch.lnn = lon.lon no-lock:
                     if lnsch.f0 = 0 and lnsch.flp > 0 then do:
                        if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                     end.
                  end.
                  create lnsch.
                  lnsch.lnn = lon.lon.
                  lnsch.f0 = 0.
                  lnsch.flp = v-nxt + 1.
                  lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
                  lnsch.paid = wrk.ppay7.
                  lnsch.stdat = jh.jdt.
                  lnsch.jh = jh.jh.
                  lnsch.whn = dat.
                  lnsch.who = g-ofc.
                end.

                if wrk.ppay2 > 0 then do:
                    v-nxt = 0.
                    for each lnsci where lnsci.lni = lon.lon no-lock:
                        if lnsci.f0 = 0 and lnsci.flp > 0 then do:
                           if v-nxt < lnsci.flp then v-nxt = lnsci.flp.
                        end.
                    end.
                    create lnsci.
                    lnsci.lni = lon.lon.
                    lnsci.f0 = 0.
                    lnsci.flp = v-nxt + 1.
                    lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
                    lnsci.paid-iv = wrk.ppay2 + wrk.ppay49.
                    lnsci.idat = jh.jdt.
                    lnsci.jh = jh.jh.
                    lnsci.whn = dat.
                    lnsci.who = g-ofc.

                end.

                if wrk.ppay9 gt 0 then do:
                    v-nxt = 0.
                    for each lnsci where lnsci.lni eq lon.lon no-lock :
                        if lnsci.f0 eq 0 and lnsci.flp gt 0 then do:
                           if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
                        end.
                    end.
                    create lnsci.
                    lnsci.lni = lon.lon.
                    lnsci.f0 = 0.
                    lnsci.flp = v-nxt + 1.
                    lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
                    lnsci.paid-iv = wrk.ppay9 + wrk.ppay50.
                    lnsci.idat = jh.jdt.
                    lnsci.jh = jh.jh.
                    lnsci.whn = dat.
                    lnsci.who = g-ofc.

                end.

                if wrk.ppay7 ne 0 then do:
                        create lonpen.
                        assign lonpen.lon = lon.lon
                               lonpen.cif = lon.cif
                               lonpen.rdt = g-today
                               lonpen.who = g-ofc
                               lonpen.lev = 7
                               lonpen.cam = wrk.ppay7.
                end.

                put stream m-out unformatted "<tr align=""right"">"
                             "<td align=""center""> Погашение </td>"
                             "<td align=""center"">&nbsp;" wrk.lon "</td>"
                             "<td align=""center"">&nbsp;" wrk.aaa "</td>"
                             "<td> " s-jh "</td>"
                             "</tr>" skip.

                end.
            /*************************************/
            /*погасим уровни индексации*/ /* 04/05/2005 madiyar - убрал просроченную индексацию */

                 if wrk.ppay20 > 0 or wrk.ppay22 > 0 then do:
                  v-param = /*string(wrk.ppay23)*/ "0" + vdel + wrk.aaa + vdel + wrk.lon.

                 v-srok = (round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30.
                 if v-srok > 360 then v-param = v-param + vdel + "423".
                                 else v-param = v-param + vdel + "421".

                 v-param =  v-param + vdel +
                        /*string(wrk.ppay21)*/ "0" + vdel +
                        string(wrk.ppay22) + vdel +
                        string(wrk.ppay20).

                v-indrate = ''.
                find first lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
                if avail lonhar then find first bcrc where bcrc.crc = lonhar.rez-int[1] no-lock no-error.
                if avail bcrc then v-indrate = trim(string(bcrc.rate[1],">>>,>>9.99")).

                s-glremx[1] = "Оплата индексации кредита " + lon.lon + " " + v-londog + " " +
                     trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                     + " " + crc.code + " "
                     + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin .
                if wrk.ppay20 ne 0 then
                     s-glremx[2] = "Сумма погашаемой индексации ОД " +
                     trim(string(wrk.ppay20,">>>,>>>,>>9.99-"))
                     + " " + crc.code + ", курс " + v-indrate.
                   else s-glremx[2] = "".
                if wrk.ppay22 ne 0 then
                      s-glremx[3] = "Сумма погашаемой индексации %% " +
                      trim(string(wrk.ppay22,">>>,>>>,>>9.99-")) + " " + crc.code + ", курс " + v-indrate.
                   else s-glremx[3] = "".
                s-glremx[4] = "".
                s-glremx[5] = "".
                /*
                if wrk.ppay21 ne 0 then
                      s-glremx[4] = "Сумма погашаемого просроч ОД" +
                      trim(string(wrk.ppay21,">>>,>>>,>>9.99-")) + " " + crc.code.
                   else s-glremx[4] = "".
                if wrk.ppay23 ne 0 then
                      s-glremx[5] = "Сумма погашаемого просроч %%" +
                      trim(string(wrk.ppay23,">>>,>>>,>>9.99-")) + " " + crc.code.
                   else s-glremx[5] = "".
                */

                    v-param = v-param + vdel +
                              s-glremx[1] + vdel +
                              s-glremx[2] + vdel +
                              s-glremx[3] + vdel +
                              s-glremx[4] + vdel +
                              s-glremx[5] .


                    s-jh = 0.
                    run trxgen ("lon0074", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).

                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.
                   run lonresadd(s-jh).
                find jh where jh.jh eq s-jh no-lock no-error.

                put stream m-out unformatted "<tr align=""right"">"
                             "<td align=""center""> Погашение </td>"
                             "<td align=""center"">&nbsp;" wrk.lon "</td>"
                             "<td align=""center"">&nbsp;" wrk.aaa "</td>"
                             "<td> " s-jh "</td>"
                             "</tr>" skip.

                end.
                /*************************************/
           end. /* if i = 1 */

        end. /* do pn = 1 to ... */

        if (lon.grp = 90 or lon.grp = 92) or (v-bal1 >= 1 or v-bal2 >= 1) /* or v-bal20 > 0 or v-bal22 > 0 */ then do:
             find cif where cif.cif = lon.cif no-lock no-error.
             create wrk.
             wrk.lon = lon.lon.
             wrk.aaa = "".
             wrk.name = cif.name.
             wrk.ppay1 = 0.
             wrk.ppay2 = 0.
             wrk.ppay12 = 0.
             wrk.ppay7 = 0.
             wrk.ppay9 = 0.
             wrk.ppay4 = 0.
             wrk.ppay16 = 0.
             wrk.ppay5 = 0.
             wrk.pbal1 = v-bal1.
             wrk.pbal2 = v-bal2.
             /*
             wrk.pbal20 = v-bal20.
             wrk.pbal22 = v-bal22.
             */

             /*astana bonus*/
             run lonbalcrc('lon',lon.lon,dat,"49",yes,lon.crc,output wrk.pbal49).
            /* Сразу же сделать проводку*/
            if wrk.pbal1 > 0 then do:
                v-param = string(wrk.pbal1) + vdel + wrk.lon.

                s-glremx[1] = "Перенос на счет просрочки " + lon.lon + " " + v-londog + " " +
                     trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                     + " " + crc.code + " "
                     + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin .
                if wrk.pbal1 ne 0 then
                     s-glremx[2] = "Сумма перенесенного осн. долга " +
                     trim(string(wrk.pbal1,">>>,>>>,>>9.99-"))
                     + " " + crc.code.
                   else s-glremx[2] = "".
                   assign s-glremx[3] = "" s-glremx[4] = "" s-glremx[5] = "".


                    v-param = v-param + vdel +
                              s-glremx[1] + vdel +
                              s-glremx[2] + vdel +
                              s-glremx[3] + vdel +
                              s-glremx[4] + vdel +
                              s-glremx[5] .

                s-jh = 0.
                    run trxgen ("lon0008", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).

                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.
                   run lonresadd(s-jh).
                 find jh where jh.jh eq s-jh no-error.
                 if jh.sts < 6 then jh.sts = 6.
                 for each jl of jh:
                     if jl.sts < 6 then jl.sts = 6.
                 end.
                 find jh where jh.jh eq s-jh no-lock no-error.

                 if wrk.pbal1 ne 0 then do:
                    create lonpen.
                    assign lonpen.lon = lon.lon
                           lonpen.cif = lon.cif
                           lonpen.rdt = g-today
                           lonpen.who = g-ofc
                           lonpen.lev = 7
                           lonpen.dam = wrk.pbal1.
                 end.

               put stream m-out unformatted "<tr align=""right"">"
                         "<td align=""center""> Перенос ОД </td>"
                         "<td align=""center"">&nbsp;" wrk.lon "</td>"
                         "<td align=""center""> </td>"
                         "<td> " s-jh "</td>"
                         "</tr>" skip.

            end.

           if wrk.pbal2 > 0 then do:
             v-param = string(wrk.pbal2) + vdel + wrk.lon.

                  s-glremx[1] = "Перенос на счет просрочки " + lon.lon + " " + v-londog + " " +
                       trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                       + " " + crc.code + " "
                       + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin .
                  if wrk.pbal2 ne 0 then
                       s-glremx[2] = "Сумма перенесенных %% " +
                       trim(string(wrk.pbal2,">>>,>>>,>>9.99-"))
                       + " " + crc.code.
                     else s-glremx[2] = "".
                     assign s-glremx[3] = "" s-glremx[4] = "" s-glremx[5] = "".


                      v-param = v-param + vdel +
                                s-glremx[1] + vdel +
                                s-glremx[2] + vdel +
                                s-glremx[3] + vdel +
                                s-glremx[4] + vdel +
                                s-glremx[5] .

                  s-jh = 0.
                      run trxgen ("lon0029", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).

                     if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                     end.
                     run lonresadd(s-jh).
                   find jh where jh.jh eq s-jh no-error.
                   if jh.sts < 6 then jh.sts = 6.
                   for each jl of jh:
                       if jl.sts < 6 then jl.sts = 6.
                   end.
                   find jh where jh.jh eq s-jh no-lock no-error.
              put stream m-out unformatted "<tr align=""right"">"
                         "<td align=""center""> Перенос %% </td>"
                         "<td align=""center"">&nbsp;" wrk.lon "</td>"
                         "<td align=""center""> </td>"
                         "<td> " s-jh "</td>"
                         "</tr>" skip.
            end.

           /*astana bonus*/
           if wrk.pbal49 > 0 then do:
             v-param = string(wrk.pbal49) + vdel + wrk.lon.

                  s-glremx[1] = "Перенос на счет просрочки ASTANA BONUS" + lon.lon + " " + v-londog + " " +
                       trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                       + " " + crc.code + " "
                       + trim(trim(cif.prefix) + " " + trim(cif.name)) + " ИИН/БИН " + cif.bin .
                  if wrk.pbal2 ne 0 then
                       s-glremx[2] = "Сумма перенесенных %% ASTANA BONUS " +
                       trim(string(wrk.pbal49,">>>,>>>,>>9.99-"))
                       + " " + crc.code.
                     else s-glremx[2] = "".
                     assign s-glremx[3] = "" s-glremx[4] = "" s-glremx[5] = "".


                      v-param = v-param + vdel +
                                s-glremx[1] + vdel +
                                s-glremx[2] + vdel +
                                s-glremx[3] + vdel +
                                s-glremx[4] + vdel +
                                s-glremx[5] .

                  s-jh = 0.
                      run trxgen ("lon0165", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).

                     if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                     end.
                     run lonresadd(s-jh).
                   find jh where jh.jh eq s-jh no-error.
                   if jh.sts < 6 then jh.sts = 6.
                   for each jl of jh:
                       if jl.sts < 6 then jl.sts = 6.
                   end.
                   find jh where jh.jh eq s-jh no-lock no-error.
              put stream m-out unformatted "<tr align=""right"">"
                         "<td align=""center""> Перенос %% </td>"
                         "<td align=""center"">&nbsp;" wrk.lon "</td>"
                         "<td align=""center""> </td>"
                         "<td> " s-jh "</td>"
                         "</tr>" skip.
            end.
        /*перенести на просрочку индексацию */ /* 04/05/2005 madiyar - убрал просрочку индексации */
/*
            if wrk.pbal20 > 0 then do:
                v-param = string(wrk.pbal20) + vdel + wrk.lon.

                s-glremx[1] = "Перенос на счет просрочки " + lon.lon + " " +
                     trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                     + " " + crc.code + " "
                     + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss .
                if wrk.pbal20 ne 0 then
                     s-glremx[2] = "Сумма перенесеннй индексации осн. долга " +
                     trim(string(wrk.pbal20,">>>,>>>,>>9.99-"))
                     + " " + crc.code.
                   else s-glremx[2] = "".
                   assign s-glremx[3] = "" s-glremx[4] = "" s-glremx[5] = "".


                    v-param = v-param + vdel +
                              s-glremx[1] + vdel +
                              s-glremx[2] + vdel +
                              s-glremx[3] + vdel +
                              s-glremx[4] + vdel +
                              s-glremx[5] .

                s-jh = 0.
                    run trxgen ("lon0075", vdel, v-param, "lon" , lon.lon , output rcode,
                    output rdes, input-output s-jh).

                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.
                   run lonresadd(s-jh).
                 find jh where jh.jh eq s-jh no-error.
                 if jh.sts < 6 then jh.sts = 6.
                 for each jl of jh:
                     if jl.sts < 6 then jl.sts = 6.
                 end.
                 find jh where jh.jh eq s-jh no-lock no-error.

               put stream m-out unformatted "<tr align=""right"">"
                         "<td align=""center""> Перенос инд ОД </td>"
                         "<td align=""center"">&nbsp;" wrk.lon "</td>"
                         "<td align=""center""> </td>"
                         "<td> " s-jh "</td>"
                         "</tr>" skip.
            end.

           if wrk.pbal22 > 0 then do:
             v-param = string(wrk.pbal22) + vdel + wrk.lon.

                  s-glremx[1] = "Перенос на счет просрочки " + lon.lon + " " +
                       trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
                       + " " + crc.code + " "
                       + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss .
                  if wrk.pbal22 ne 0 then
                       s-glremx[2] = "Сумма перенесенной индек %% " +
                       trim(string(wrk.pbal22,">>>,>>>,>>9.99-"))
                       + " " + crc.code.
                     else s-glremx[2] = "".
                     assign s-glremx[3] = "" s-glremx[4] = "" s-glremx[5] = "".


                      v-param = v-param + vdel +
                                s-glremx[1] + vdel +
                                s-glremx[2] + vdel +
                                s-glremx[3] + vdel +
                                s-glremx[4] + vdel +
                                s-glremx[5] .

                  s-jh = 0.
                      run trxgen ("lon0076", vdel, v-param, "lon" , lon.lon , output rcode,
                      output rdes, input-output s-jh).

                     if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                     end.
                     run lonresadd(s-jh).
                   find jh where jh.jh eq s-jh no-error.
                   if jh.sts < 6 then jh.sts = 6.
                   for each jl of jh:
                       if jl.sts < 6 then jl.sts = 6.
                   end.
                   find jh where jh.jh eq s-jh no-lock no-error.
              put stream m-out unformatted "<tr align=""right"">"
                         "<td align=""center""> Перенос индекс %% </td>"
                         "<td align=""center"">&nbsp;" wrk.lon "</td>"
                         "<td align=""center""> </td>"
                         "<td> " s-jh "</td>"
                         "</tr>" skip.
            end.
*/
        end.

    end.  /* v-bal > 0 */

end.   /* lon */


put stream m-out "</table><br><br>" skip.
put stream m-out1 "</table><br><br>" skip.


put stream m-out unformatted "<tr align=""center""><td><h3> Кредиты к погашению по графику " skip
                 " за " string(dat)
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).

       put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Текущий счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма штрафа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма штрафа<br>начисленного за балансом</td>"
              /*    "<td bgcolor=""#C0C0C0"" align=""center"">Сумма просроч инд %</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма просроч %</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма просроч %<br>начисленных за балансом</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Резерв<br>для комиссии</td>"
              /*    "<td bgcolor=""#C0C0C0"" align=""center"">Сумма просроч инд ОД</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма просроч ОД</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма инд % по граф</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма % по граф</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма инд ОД по граф</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД по граф</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 12 уров</td>"
              /*    "<td bgcolor=""#C0C0C0"" align=""center"">Перенос инд % по граф</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Перенос % по граф</td>"
              /*    "<td bgcolor=""#C0C0C0"" align=""center"">Перенос инд ОД по граф</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Перенос ОД по граф</td>"
                   /*astana bonus*/
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 49-уровень</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма 50-уровень</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Перенос 52-уровень</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Перенос 53-уровень</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Перенос 49-уровень на 50-уровень</td>"
                  "</tr>" skip.

for each wrk.
            put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td align=""center"">&nbsp;" wrk.lon "</td>"
               "<td align=""center"">&nbsp;" wrk.aaa "</td>"
               "<td> " replace(trim(string(wrk.ppay16, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay5, "->>>>>>>>>>>9.99")),".",",")  "</td>"
             /*  "<td> " replace(trim(string(wrk.ppay23, "->>>>>>>>>>>9.99")),".",",")  "</td>" */
               "<td> " replace(trim(string(wrk.ppay9, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay4, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppaycom, "->>>>>>>>>>>9.99")),".",",")  "</td>"
             /*  "<td> " replace(trim(string(wrk.ppay21, "->>>>>>>>>>>9.99")),".",",")  "</td>" */
               "<td> " replace(trim(string(wrk.ppay7, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay22, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay20, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay12, "->>>>>>>>>>>9.99")),".",",")  "</td>"
             /*  "<td> " replace(trim(string(wrk.pbal22, "->>>>>>>>>>>9.99")),".",",")  "</td>" */
               "<td> " replace(trim(string(wrk.pbal2, "->>>>>>>>>>>9.99")),".",",")  "</td>"
             /*  "<td> " replace(trim(string(wrk.pbal20, "->>>>>>>>>>>9.99")),".",",")  "</td>" */
               "<td> " replace(trim(string(wrk.pbal1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               /*astana bonus*/
               "<td> " replace(trim(string(wrk.ppay49, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay50, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay52, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.ppay53, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.pbal49, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "</tr>" skip.
         coun = coun + 1.
end.

put stream m-out unformatted "</table>" skip.
output stream m-out close.
put stream m-out1 unformatted "</table>" skip.
output stream m-out1 close.
/*
unix silent cptwin repday.html excel.exe.
*/
