/* rskclass.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Автоматическое проставление классификации риск-менеджером
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        20/09/2004 madiar
 * CHANGES
        27/09/2004 madiar - автоматически проставляем только финансовое состояние
*/

{mainhead.i}

{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

/*def var hanket as handle.
run lnlib persistent set hanket.*/

def var v-dt as date.
def var v-dtrm as date.
def stream err.
output stream err to err.txt.

/*
def var dayc1 as int init 0.
def var dayc2 as int init 0.
def var maxday as int init 0.
def var v-am1 as decimal init 0.
def var v-am3 as decimal init 0.
*/
def var bilance   as decimal format "->,>>>,>>>,>>9.99".
/*
def var bilancepl as decimal format "->,>>>,>>9.99".
def var tempdt  as date.
def var tempost as deci.
define var dlong as date.
*/

def var balact1 like bal_cif.amount extent 27.
def var balpas1 like bal_cif.amount extent 22.
def var balres1 like bal_cif.amount extent 17.
def var balact2 like bal_cif.amount extent 27.
def var balpas2 like bal_cif.amount extent 22.
def var i as integer.
def var v-dt1 as date.
def var v-dt2 as date.

/*define var v-sec3 as deci.  -- стоимость обеспечения по 3 группе - деньги --
define var v-sec  as deci.  -- стоимость остального обеспечения --
define buffer b-crc for crc.*/

def var c_values as deci extent 7.
def var opt_values as deci extent 7 init [1.5, 0.7, 0.7, 4, 6, 0.5, 0.08].
def var weight_values as deci extent 7 init [20, 15, 15, 10, 10, 15, 15].
def var bb1 as deci.
def var tek_ob_68 as deci.
def var vsego_act1 as deci.
def var vsego_act2 as deci.
def var cfinsost as deci init 0.
def var resch as char.
def var isa as logi extent 2 init [ no, no ].
def var isp as logi extent 2 init [ no, no ].

def var bb as logi extent 4 init [ no, no, no, no ].
def var mesa as integer.

def var v-rat as deci.
def var v-rat_rm as deci.
def var v-prosr as char.
def var v-prosr_rm as char.
def var kdklass as char.
def var kdklass_rm as char.

message "Проставить классификацию риск-менеджера по всем кредитам ю/л?"
              view-as alert-box question buttons ok-cancel title "" update ja as logical.
if not ja then return.

/* по всем кредитам юр. лиц */
mesa = 0.
for each lon where lon.grp = 10 or lon.grp = 15 or lon.grp = 30 or lon.grp = 35 or lon.grp = 50 or lon.grp = 55 or lon.grp = 70 no-lock:
/*for each lon where lon.cif = 't12035' no-lock:*/
  
  run lonbal('lon', lon.lon, g-today, "1,7,21", yes, output bilance).
  if bilance <= 0 then next.
  
  v-dt = ?. v-dtrm = ?.
  find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif and kdlonkl.kdlon = lon.lon use-index bclrdt no-lock no-error.
  if avail kdlonkl then do:
    v-dt = kdlonkl.rdt.
    if kdlonkl.info[4] <> "" and kdlonkl.info[4] <> "?" then v-dtrm = date(kdlonkl.info[4]). else v-dtrm = ?.
  end.
  if v-dt = ? then do:
    put stream err unformatted lon.cif " " lon.lon " - классификация не проставлена менеджером КД" skip.
    next.
  end.
  
  /* ---------------*******************------------------------ */
  
  /*кол-во дней просрочки*/

  /*bilancepl = 0.   -- На тек день по графику погашения должен погасить --
  for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 and lnsch.stdat <= g-today no-lock:
     bilancepl = bilancepl + lnsch.stval.
  end.

  v-am3 = 0.
  bilancepl = lon.opnamt - bilancepl. -- долг по графику , который должен остаться --
  v-am3 = bilance - bilancepl.
  if v-am3 < 0 then v-am3 = 0.
  
  v-am1 = 0.
  for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc no-lock:
     if trxbal.lev = 9 or trxbal.lev = 10 then v-am1 = v-am1 + trxbal.dam - trxbal.cam.
  end.
  
  dayc1 = 0. dayc2 = 0.

     if v-am1 > 1 then do:
       find last lnsci where lnsci.lni = lon.lon and lnsci.idat <= g-today and lnsci.f0 = 0 no-lock no-error.
          if avail lnsci then do:
            tempdt = lnsci.idat. 
            find last lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 
                 and lnsci.fpn = 0 and lnsci.f0 > 0 and lnsci.idat >= tempdt and lnsci.idat <= g-today no-lock no-error.
            if avail lnsci then dayc2 = g-today - lnsci.idat. else dayc2 = g-today - tempdt. 
       end.
          else do:
              find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
              dayc2 = g-today - lnsci.idat. -- если не было погашений то берем долг от первого графика --
          end.
     end.

       if v-am3 > 0 then do:
          tempdt = g-today.
          tempost = 0.
          repeat:
            find last lnsch where lnsch.lnn = lon.lon and lnsch.stdat < tempdt and lnsch.f0 > 0 no-lock no-error.
            if avail lnsch then do:
               tempost = tempost + lnsch.stval.
               if v-am3 <= tempost then do:
                  dayc1 = g-today - lnsch.stdat.
                  if v-am3 = tempost and day(g-today) = day(lnsch.stdat) then
                     dayc1 = g-today - tempdt.
                  leave.
               end.   
               tempdt =  lnsch.stdat.
            end.  
            else leave.
          end.  
       end.            
   dlong = lon.duedt.
    if lon.ddt[5] <> ? then dlong = lon.ddt[5].
    if lon.cdt[5] <> ? then dlong = lon.cdt[5].
    if dlong > lon.duedt and dlong > g-today then do: 
          dayc1 = 0. dayc2 = 0. 
    end.

  if dayc1 > dayc2 then maxday = dayc1.
                   else maxday = dayc2.
  */
  
  /* качество обеспечения */
  
  /*
  find first crc where crc.crc = lon.crc no-lock no-error.
  v-sec = 0.
  v-sec3 = 0.
  for each lonsec1 where lonsec1.lon = lon.lon:
     find first b-crc where b-crc.crc = lonsec1.crc no-lock no-error.
     if lonsec1.lonsec = 3 then v-sec3 = v-sec3 + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
                           else v-sec = v-sec + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
  end.
  */

  /* Финансовая устойчивость (состояние) - только для риск менеджера */
  
  cfinsost = 0. isa = no. isp = no.
  find last bal_cif where bal_cif.cif = lon.cif and (bal_cif.nom begins 'z' or bal_cif.nom begins 'd') use-index rdt no-lock no-error.
  if avail bal_cif then do:
    v-dt1 = bal_cif.rdt.
    resch = substring(bal_cif.nom,1,1).
    for each bal_cif where bal_cif.cif = lon.cif and bal_cif.rdt = v-dt1 use-index cif-rdt no-lock:
      if bal_cif.nom begins 'a' then do:
        isa[1] = true.
        balact1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
      if bal_cif.nom begins 'p' then do:
        isp[1] = true.
        balpas1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
      if bal_cif.nom begins resch then do:
        balres1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
    end.
  
    if isa[1] and isp[1] then do:
      if day(v-dt1) = 1 and month(v-dt1) = 1 then v-dt2 = date(1,1,year(v-dt1) - 1).
      else v-dt2 = date(1,1,year(v-dt1)).
      for each bal_cif where bal_cif.cif = lon.cif and bal_cif.rdt = v-dt2 use-index cif-rdt no-lock:
        if bal_cif.nom begins 'a' then do:
          isa[2] = true.
          balact2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
        end.
        if bal_cif.nom begins 'p' then do:
          isp[2] = true.
          balpas2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
        end.
      end.
      if not isa[2] then put stream err unformatted lon.cif " " lon.lon " - не найдены активы на дату " + string(v-dt2, "99/99/9999") + " (2)" skip.
      if not isp[2] then put stream err unformatted lon.cif " " lon.lon " - не найдены пассивы на дату " + string(v-dt2, "99/99/9999") + " (2)" skip.
    end.
    else do:
      if not isa[1] then put stream err unformatted lon.cif " " lon.lon " - не найдены активы на дату " + string(v-dt1, "99/99/9999") + " (1)" skip.
      if not isp[1] then put stream err unformatted lon.cif " " lon.lon " - не найдены пассивы на дату " + string(v-dt1, "99/99/9999") + " (1)" skip.
    end.
    
    if isa[1] and isp[1] and isa[2] and isp[2] then do: /* балансы на обе даты есть */
    /***********************/
    
      bb1 = 0. vsego_act1 = 0. vsego_act2 = 0.
      do i = 11 to 27: bb1 = bb1 + balact1[i]. end.
      do i = 1 to 27: vsego_act1 = vsego_act1 + balact1[i]. vsego_act2 = vsego_act2 + balact2[i]. end.
      do i = 11 to 21: tek_ob_68 = tek_ob_68 + balpas1[i]. end.
      /* коэфф текущей ликвидности */
      c_values[1] = bb1 / tek_ob_68.
      /* коэфф быстрой (срочной) ликвидности */
      c_values[2] = (balact1[16] + balact1[17] + balact1[22] + balact1[23] + balact1[24] + balact1[25] + balact1[26]) / tek_ob_68.
      /* коэфф кредитоспособности */
      c_values[3] = (balpas1[1] + balpas1[2] + balpas1[3] + balpas1[4] + balpas1[5]) / (balpas1[8] + balpas1[9] + balpas1[10] + tek_ob_68).
      
      bb1 = (balact1[11] + balact1[12] + balact1[13] + balact1[14] + balact1[15] + balact2[11] + balact2[12] + balact2[13] + balact2[14] + balact2[15]) / 2.
      /* коэфф оборачиваемости ТМЗ */
      c_values[4] = balres1[2] / bb1.
      
      bb1 = (balact1[16] + balact1[17] + balact2[16] + balact2[17]) / 2.
      /* коэфф оборачиваемости кредиторской задолженности */
      c_values[5] = balres1[1] / bb1.
      /* коэфф автономии */
      c_values[6] = (balpas1[1] + balpas1[2] + balpas1[3] + balpas1[4] + balpas1[5]) / vsego_act1.
      /* коэфф ROA */
      c_values[7] = balres1[14] / ((vsego_act1 + vsego_act2) / 2).
      
      do i = 1 to 7:
        if c_values[i] > opt_values[i] then c_values[i] = opt_values[i].
        cfinsost = cfinsost + c_values[i] / opt_values[i] * weight_values[i].
      end.
    
    /***********************/
    end.

  end. /* if avail bal_cif */
  else put stream err unformatted lon.cif " " lon.lon " - не найдены фин. результаты " skip.
  
  /* ----------*******************-------------- */
  bb = no. v-rat = 0. v-rat_rm = 0.
  for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif and kdlonkl.kdlon = lon.lon
                         and kdlonkl.rdt = v-dt:
    case kdlonkl.kod:
       /*when "prosr" then do: -- просрочка --
         if maxday < 1 then kdlonkl.info[1] = '01'.
         if maxday >= 1 and maxday <= 30 then kdlonkl.info[1] = '02'.
         if maxday >= 31 and maxday <= 60 then kdlonkl.info[1] = '03'.
         if maxday >= 61 and maxday <= 90 then kdlonkl.info[1] = '04'.
         if maxday >= 91 then kdlonkl.info[1] = '05'.
         find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = kdlonkl.info[1] no-lock no-error.
         if avail bookcod then
            assign kdlonkl.info[2] = bookcod.name
                   kdlonkl.info[3] = trim(bookcod.info[1]).
         v-prosr = kdlonkl.val1. v-prosr_rm = kdlonkl.info[1].
         bb[1] = yes.
       end.
       when "obesp1" then do: -- качество обеспечения --
         kdlonkl.info[1] = '05'.
         if v-sec3 > 0 and v-sec = 0 then do:
            if v-sec3 >= bilance then kdlonkl.info[1] = '01'.
            if v-sec3 < bilance and v-sec3 >= 0.9 * bilance then kdlonkl.info[1] = '02'.
            if v-sec3 < 0.9 * bilance and v-sec3 >= 0.75 * bilance then kdlonkl.info[1] = '03'.
            if v-sec3 < 0.75 * bilance and v-sec3 >= 0.5 * bilance then kdlonkl.info[1] = '04'.
            if v-sec3 < 0.5 * bilance then kdlonkl.info[1] = '05'.
         end.
         if v-sec > 0 then do:
            bilance = bilance - v-sec3.
            if v-sec >= bilance then kdlonkl.info[1] = '03'.
            if v-sec < bilance and v-sec >= 0.5 * bilance then kdlonkl.info[1] = '04'.
            if v-sec < 0.5 * bilance then kdlonkl.info[1] = '05'.
         end.
         find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = kdlonkl.info[1] no-lock no-error.
           if avail bookcod then assign kdlonkl.info[2] = bookcod.name
                                        kdlonkl.info[3] = trim(bookcod.info[1]).
         bb[2] = yes.
       end.
       when "long1" then do: -- количество пролонгаций --
         kdlonkl.info[1] = '0'.
         if lon.ddt[5] <> ? then kdlonkl.info[1] = '1'.
         if lon.cdt[5] <> ? then kdlonkl.info[1] = '2'.
         find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
         if avail bookcod then assign kdlonkl.info[2] = bookcod.name
                                      kdlonkl.info[3] = string(decimal(kdlonkl.info[1]) * deci(trim(bookcod.info[1]))).
         bb[3] = yes.
       end.*/
       when "finsost1" then do: /* финансовое состояние */
         if isa[1] and isp[1] and isa[2] and isp[2] then do:
           if cfinsost < 40 then kdlonkl.info[1] = '04'.
           if cfinsost >= 40 and cfinsost < 60 then kdlonkl.info[1] = '03'.
           if cfinsost >= 60 and cfinsost < 80 then kdlonkl.info[1] = '02'.
           if cfinsost >= 80 and cfinsost <= 100 then kdlonkl.info[1] = '01'.
           find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.info[1] no-lock no-error.
           if avail bookcod then assign kdlonkl.info[2] = bookcod.name
                                        kdlonkl.info[3] = trim(bookcod.info[1]).
         end.
         bb[4] = yes.
       end.
       otherwise do:
         kdlonkl.info[1] = kdlonkl.val1.
         kdlonkl.info[2] = kdlonkl.valdesc.
         kdlonkl.info[3] = string(kdlonkl.rating).
       end.
    end. /* case kdlonkl.kod */
    if kdlonkl.kod <> "klass" then do:
      kdlonkl.info[4] = string(g-today, "99/99/9999").
      v-rat = v-rat + kdlonkl.rating.
      v-rat_rm = v-rat + deci(kdlonkl.info[3]).
    end.
  end. /* for each kdlonkl */
  
  if v-rat <= 1 then kdklass  = '01'.
  if v-rat > 1 and  v-rat <= 2 and v-prosr = '01' then kdklass = '02'.
  if v-rat > 1 and  v-rat <= 2 and v-prosr ne '01' then kdklass = '03'.
  if v-rat > 2 and  v-rat <= 3 and v-prosr = '01' then kdklass = '04'.
  if v-rat > 2 and  v-rat <= 3 and v-prosr ne '01' then kdklass = '05'.
  if v-rat > 3 and  v-rat <= 4 then  kdklass = '06'.
  if v-rat > 4 then kdklass = '07'.
  
  if v-rat_rm <= 1 then kdklass_rm  = '01'.
  if v-rat_rm > 1 and  v-rat_rm <= 2 and v-prosr_rm = '01' then kdklass_rm = '02'.
  if v-rat_rm > 1 and  v-rat_rm <= 2 and v-prosr_rm ne '01' then kdklass_rm = '03'.
  if v-rat_rm > 2 and  v-rat_rm <= 3 and v-prosr_rm = '01' then kdklass_rm = '04'.
  if v-rat_rm > 2 and  v-rat_rm <= 3 and v-prosr_rm ne '01' then kdklass_rm = '05'.
  if v-rat_rm > 3 and  v-rat_rm <= 4 then kdklass_rm = '06'.
  if v-rat_rm > 4 then kdklass_rm = '07'.
  
  find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = lon.cif and kdlonkl.kdlon = lon.lon
                         and kdlonkl.rdt = v-dt and kdlonkl.kod = "klass" no-error.
  if avail kdlonkl then do:
    kdlonkl.info[1] = kdklass_rm.
    kdlonkl.info[4] = string(g-today, "99/99/9999").
    if kdlonkl.val1 <> kdklass then put stream err unformatted lon.cif " " lon.lon " - не совпадает!!!!!" skip.
  end.
  else put stream err unformatted lon.cif " " lon.lon " - не найдена запись klass в kdlonkl" skip.
  
  /*if not bb[1] then put stream err unformatted lon.cif " " lon.lon " - не найдена запись prosr в kdlonkl" skip.
  if not bb[2] then put stream err unformatted lon.cif " " lon.lon " - не найдена запись obesp1 в kdlonkl" skip.
  if not bb[3] then put stream err unformatted lon.cif " " lon.lon " - не найдена запись long1 в kdlonkl" skip.*/
  if not bb[4] then put stream err unformatted lon.cif " " lon.lon " - не найдена запись finsost1 в kdlonkl" skip.
  
  mesa = mesa + 1.
  hide message no-pause.
  message ' обработано ' + string(mesa) + ' кредитов '.
  
end. /* for each lon */

output stream err close.
hide message no-pause.
run menu-prt ("err.txt").

