/* lnklass.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредита на конец каждого месяца
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-1-4 КлассРиск
 * AUTHOR
        20/08/2004 madiar - скопировал из lnklass.p с редакцией
 * CHANGES
        25/08/2004 madiar - добавил автоматическое определение финансового состояния
        26/08/2004 madiar - оптимизировал расчет финансового состояния
        27/08/2004 madiar - при сохранении новой класс-ции вставил pause - чтобы успели message разглядеть
        31/08/2004 madiar - исправил опечатку в сообщении о ненайденных пассивах/активах
        17/09/2004 madiar - дату классификации риск-менеджером сохраняем в t-klass.info[4]
                            изменил расчет просрочки
        27/09/2004 madiar - автоматически вычисляем только финансовое состояние
*/


{global.i}
{kd.i "new"}

define shared var s-lon like lon.lon.
define  shared variable v-cif like cif.cif init "".
/*
def new shared var s-lon like lon.lon.
define new shared variable v-cif like cif.cif init "".

s-lon = '000147242'. 
v-cif = 't29186'.
displ s-lon. pause 100.
*/

def var v-cod as char.
define var v-rat as deci init 0.
define var v-prosr as char.
define var v-statdescr as char init ''.
define var v-dt as date.
define var v-dtrm as date.
def var ja as log format "да/нет" init no.
def var v-select as integer init 3.

def var hanket as handle.
run lnlib persistent set hanket.
pause 0.

def new shared temp-table t-klass like kdlonkl.

for each kdklass where kdklass.type = 2 use-index kritcod no-lock .
    create t-klass.
    assign t-klass.bank = s-ourbank
           t-klass.kdcif = v-cif 
           t-klass.kdlon = s-lon 
           t-klass.kod = kdklass.kod 
           t-klass.ln = kdklass.ln
           t-klass.who = g-ofc 
           t-klass.whn = g-today. 
end.

define variable s_rowid as rowid.
def var v-title as char init " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА ".
def var v-fl as inte.

/*def shared var hanket as handle.*/

find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif 
                     and kdlonkl.kdlon = s-lon use-index bclrdt no-lock no-error.
if avail kdlonkl then do:
   v-dt = kdlonkl.rdt.
   if kdlonkl.info[4] <> "" and kdlonkl.info[4] <> "?" then v-dtrm = date(kdlonkl.info[4]). else v-dtrm = ?.
   for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif 
                     and kdlonkl.kdlon = s-lon and kdlonkl.rdt = v-dt no-lock .
       find t-klass where t-klass.kod = kdlonkl.kod no-error.
       if avail t-klass then assign t-klass.val1 = kdlonkl.val1
                                    t-klass.rating = kdlonkl.rating
                                    t-klass.valdesc = kdlonkl.valdesc
                                    t-klass.info[1] = kdlonkl.info[1]
                                    t-klass.info[2] = kdlonkl.info[2]
                                    t-klass.info[3] = kdlonkl.info[3].
   end.
end.

/*кол-во дней просрочки*/

/* 27/09/2004 madiar

def var datums as date.
def var dayc1 as int init 0.
def var dayc2 as int init 0.
def var maxday as int init 0.
datums = g-today.
def var v-am1 as decimal init 0.
def var v-am3 as decimal init 0. 
def var bilance   as decimal format "->,>>>,>>>,>>9.99".
def var bilancepl as decimal format "->,>>>,>>9.99".
def var tempdt  as date.
def var tempost as deci.
define var dlong as date.

find first lon where lon.lon = s-lon no-lock no-error.

run atl-dat (lon.lon,datums,output bilance).

bilancepl = 0.
for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 and lnsch.stdat <= datums no-lock:
   bilancepl = bilancepl + lnsch.stval.
end.

v-am3 = 0.
bilancepl = lon.opnamt - bilancepl.
v-am3 = bilance - bilancepl.
if v-am3 < 0 then v-am3 = 0.

v-am1 = 0.
for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc no-lock:
   if trxbal.lev = 9 or trxbal.lev = 10 then v-am1 = v-am1 + trxbal.dam - trxbal.cam.
end.


dayc1 = 0. dayc2 = 0.

     if v-am1 > 1 then do:
       find last lnsci where lnsci.lni = lon.lon and lnsci.idat <= datums 
           and lnsci.f0 = 0 no-lock no-error.
          if avail lnsci then do:
            tempdt = lnsci.idat. 
            find last lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 
                 and lnsci.fpn = 0 and lnsci.f0 > 0 and lnsci.idat >= tempdt and lnsci.idat <= datums no-lock no-error.
            if avail lnsci then dayc2 = datums - lnsci.idat. else dayc2 = datums - tempdt. 
       end.
          else do:
              find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 
               and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
              dayc2 = datums - lnsci.idat.
          end.
     end.

       if v-am3 > 0 then do:
          tempdt = datums.
          tempost = 0.
          repeat:
            find last  lnsch where  lnsch.lnn =  lon.lon and  lnsch.stdat < tempdt and  lnsch.f0 > 0 no-lock no-error.
            if avail  lnsch then do:
               tempost = tempost +  lnsch.stval.
               if v-am3 <= tempost then do:
                  dayc1 = datums -  lnsch.stdat.
                  if v-am3 = tempost and day(datums) = day(lnsch.stdat) then
                     dayc1 = datums - tempdt.
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
    if dlong > lon.duedt and dlong > datums then do: 
          dayc1 = 0. dayc2 = 0. 
    end.


if dayc1 > dayc2 then maxday = dayc1.
                 else maxday = dayc2.
find t-klass where t-klass.kod = 'prosr' no-lock no-error.
if avail t-klass then do:
   if maxday < 1 then t-klass.info[1] = '01'.
   if maxday >= 1 and maxday <= 30 then t-klass.info[1] = '02'.
   if maxday >= 31 and maxday <= 60 then t-klass.info[1] = '03'.
   if maxday >= 61 and maxday <= 90 then t-klass.info[1] = '04'.
   if maxday >= 91 then t-klass.info[1] = '05'.
   find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = t-klass.info[1] no-lock no-error.
      if avail bookcod then
            assign t-klass.info[2] = bookcod.name
                   t-klass.info[3] = trim(bookcod.info[1]).
end. */

/*качество обеспечения*/
/* 27/09/2004 madiar
define var v-sec3 as deci.
define var v-sec  as deci.
define buffer b-crc for crc.

find t-klass where t-klass.kod = 'obesp1' no-lock no-error.
if avail t-klass then do: 
     find first crc where crc.crc = lon.crc no-lock no-error.
     v-sec = 0.
     v-sec3 = 0.
     for each lonsec1 where lonsec1.lon = s-lon.
         find first b-crc where b-crc.crc = lonsec1.crc no-lock no-error.
         if lonsec1.lonsec = 3 then v-sec3 = v-sec3 + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
                               else v-sec = v-sec + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
     end.
     t-klass.info[1] = '05'.
     if v-sec3 > 0 and v-sec = 0 then do:
        if v-sec3 >= bilance then t-klass.info[1] = '01'.
        if v-sec3 < bilance and v-sec3 >= 0.9 * bilance then t-klass.info[1] = '02'.
        if v-sec3 < 0.9 * bilance and v-sec3 >= 0.75 * bilance then t-klass.info[1] = '03'.
        if v-sec3 < 0.75 * bilance and v-sec3 >= 0.5 * bilance then t-klass.info[1] = '04'.
        if v-sec3 < 0.5 * bilance then t-klass.info[1] = '05'.
     end.
     if v-sec > 0 then do:
        bilance = bilance - v-sec3.
        if v-sec >= bilance then t-klass.info[1] = '03'.
        if v-sec < bilance and v-sec >= 0.5 * bilance then t-klass.info[1] = '04'.
        if v-sec < 0.5 * bilance then t-klass.info[1] = '05'.
     end.
     find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = t-klass.info[1] no-lock no-error.
       if avail bookcod then assign t-klass.info[2] = bookcod.name
                                    t-klass.info[3] = trim(bookcod.info[1]).
end.
*/

/*кол-во пролонгаций*/

/* 27/09/2004 madiar
find t-klass where t-klass.kod = 'long1' no-lock no-error.
if avail t-klass then do:
 t-klass.info[1] = '0'.
 if lon.ddt[5] <> ? then t-klass.info[1] = '1'.
 if lon.cdt[5] <> ? then t-klass.info[1] = '2'.
 find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
      if avail bookcod then assign t-klass.info[2] = bookcod.name
                                   t-klass.info[3] = string(decimal(t-klass.info[1]) * deci(trim(bookcod.info[1]))).
end.
*/

/* Финансовая устойчивость (состояние) - только для риск менеджера */

def var balact1 like bal_cif.amount extent 27.
def var balpas1 like bal_cif.amount extent 22.
def var balres1 like bal_cif.amount extent 14.
def var balact2 like bal_cif.amount extent 27.
def var balpas2 like bal_cif.amount extent 22.
def var i as integer.
def var v-dt1 as date.
def var v-dt2 as date.

def var c_values as deci extent 7.
def var opt_values as deci extent 7 init [1.5, 0.7, 0.7, 4, 6, 0.5, 0.08].
def var weight_values as deci extent 7 init [20, 15, 15, 10, 10, 15, 15].
def var bb1 as deci.
def var tek_ob_68 as deci.
def var vsego_act1 as deci.
def var vsego_act2 as deci.
def var cfinsost as deci init 0.

def var isa as logi extent 2 init [false,false].
def var isp as logi extent 2 init [false,false].
find last bal_cif where bal_cif.cif = v-cif and bal_cif.nom begins 'z' use-index rdt no-lock no-error.
if avail bal_cif then do:
  v-dt1 = bal_cif.rdt.
  for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dt1 use-index cif-rdt no-lock:
    if bal_cif.nom begins 'a' then do:
      isa[1] = true.
      balact1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
    end.
    if bal_cif.nom begins 'p' then do:
      isp[1] = true.
      balpas1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
    end.
    if bal_cif.nom begins 'z' then do:
      balres1[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
    end.
  end.

  if isa[1] and isp[1] then do:
    if day(v-dt1) = 1 and month(v-dt1) = 1 then v-dt2 = date(1,1,year(v-dt1) - 1).
    else v-dt2 = date(1,1,year(v-dt1)).
    for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dt2 use-index cif-rdt no-lock:
      if bal_cif.nom begins 'a' then do:
        isa[2] = true.
        balact2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
      if bal_cif.nom begins 'p' then do:
        isp[2] = true.
        balpas2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
    end.
    if not isa[2] then message " Не найдены активы на дату " + string(v-dt2, "99/99/9999") + " (2)" view-as alert-box buttons ok title " Ошибка ".
    if not isp[2] then message " Не найдены пассивы на дату " + string(v-dt2, "99/99/9999") + " (2)" view-as alert-box buttons ok title " Ошибка ".
  end.
  else do:
    if not isa[1] then message " Не найдены активы на дату " + string(v-dt1, "99/99/9999") + " (1)" view-as alert-box buttons ok title " Ошибка ".
    if not isp[1] then message " Не найдены пассивы на дату " + string(v-dt1, "99/99/9999") + " (1)" view-as alert-box buttons ok title " Ошибка ".
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
    
    find t-klass where t-klass.kod = 'finsost1' no-lock no-error.
    if avail t-klass then do:
       if cfinsost < 40 then t-klass.info[1] = '04'.
       if cfinsost >= 40 and cfinsost < 60 then t-klass.info[1] = '03'.
       if cfinsost >= 60 and cfinsost < 80 then t-klass.info[1] = '02'.
       if cfinsost >= 80 and cfinsost <= 100 then t-klass.info[1] = '01'.
       find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = t-klass.info[1] no-lock no-error.
       if avail bookcod then assign t-klass.info[2] = bookcod.name
                                    t-klass.info[3] = trim(bookcod.info[1]).
    end.
    
    /***********************/
  end.

end. /* if avail bal_cif */
else do: message " Не найдены фин. результаты " view-as alert-box buttons ok title " Ошибка ". end.


repeat:

{jabrw.i 
&start     = " "
&head      = "t-klass"
&headkey   = "kod"
&index     = "bankln"

&formname  = "lnklassr"
&framename = "lnklassr"
&frameparm = " "
&where     = " true "
&predisplay = " find first kdklass where kdklass.kod = t-klass.kod no-lock no-error. "
&addcon    = "false"
&deletecon = "false"
&postcreate = " "
&postupdate   = " find first kdklass where kdklass.kod = t-klass.kod no-lock no-error.
                  run value(kdklass.proc) in hanket (kdklass.kod,'risk-mngr').
                  display kdklass.name t-klass.val1 t-klass.info[1] t-klass.info[2] t-klass.info[3] with frame lnklassr. "
                 
&prechoose = " hide message. message 'Последняя дата классификации ' v-dt ' (rm - ' v-dtrm ')'."

&postdisplay = " "

&display   = " kdklass.name t-klass.val1 t-klass.info[1] t-klass.info[2] t-klass.info[3] "
&update    = " t-klass.info[1] "
&highlight = " t-klass.info[1] "

&postkey   = " " 
&end = " hide message no-pause. "
}



  ja = no.
  run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ :", 
            " 1. Сохранить классификацию за этот месяц (РМ) | 2. Не сохранять классификацию | 3. Вернуться к редактированию  ", 
            output v-select).

  case v-select:
    when 1 then do: ja = yes. leave. end.
    when 2 then do: ja = no. leave. end.
  end case.
end.

hide all no-pause.

/* сохранение */

define var v-rat_rm as deci init 0.
define var v-prosr_rm as char.

if ja then do:
     for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif 
                     and kdlonkl.kdlon = s-lon and kdlonkl.rdt = v-dt.
       delete kdlonkl.
     end.

     for each t-klass:
         create kdlonkl.
         buffer-copy t-klass to kdlonkl.
         kdlonkl.rdt = v-dt.
         kdlonkl.info[4] = string(g-today, "99/99/9999").
         v-rat = v-rat + t-klass.rating.
         v-rat_rm = v-rat + deci(t-klass.info[3]).
         if t-klass.kod = 'prosr' then do: v-prosr = t-klass.val1. v-prosr_rm = t-klass.info[1]. end.
     end.
     create kdlonkl.
     assign kdlonkl.bank = s-ourbank
            kdlonkl.kdcif = v-cif
            kdlonkl.kdlon = s-lon
            kdlonkl.kod = 'klass'
            kdlonkl.rdt = v-dt
            kdlonkl.who = g-ofc
            kdlonkl.whn = g-today
            kdlonkl.info[4] = string(g-today, "99/99/9999").
     
     if v-rat <= 1 then kdlonkl.val1  = '01'.
     if v-rat > 1 and  v-rat <= 2 and v-prosr = '01' then kdlonkl.val1 = '02'.
     if v-rat > 1 and  v-rat <= 2 and v-prosr ne '01' then kdlonkl.val1 = '03'.
     if v-rat > 2 and  v-rat <= 3 and v-prosr = '01' then kdlonkl.val1 = '04'.
     if v-rat > 2 and  v-rat <= 3 and v-prosr ne '01' then kdlonkl.val1 = '05'.
     if v-rat > 3 and  v-rat <= 4 then  kdlonkl.val1 = '06'.
     if v-rat > 4 then kdlonkl.val1  = '07'.
     
     if v-rat_rm <= 1 then kdlonkl.info[1]  = '01'.
     if v-rat_rm > 1 and  v-rat_rm <= 2 and v-prosr_rm = '01' then kdlonkl.info[1] = '02'.
     if v-rat_rm > 1 and  v-rat_rm <= 2 and v-prosr_rm ne '01' then kdlonkl.info[1] = '03'.
     if v-rat_rm > 2 and  v-rat_rm <= 3 and v-prosr_rm = '01' then kdlonkl.info[1] = '04'.
     if v-rat_rm > 2 and  v-rat_rm <= 3 and v-prosr_rm ne '01' then kdlonkl.info[1] = '05'.
     if v-rat_rm > 3 and  v-rat_rm <= 4 then  kdlonkl.info[1] = '06'.
     if v-rat_rm > 4 then kdlonkl.info[1]  = '07'.
     
     find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlonkl.info[1] no-lock no-error.
         if avail bookcod then v-statdescr = bookcod.name. 
     message 'Классификация этого кредита (РМ) - '  kdlonkl.info[1] ' ' v-statdescr .
     release kdlonkl.
     pause.

end.


