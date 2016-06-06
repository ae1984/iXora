/* rsk_proc.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Вычисление коэффициентов для матрицы рисков
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
        24/09/2004 madiar
 * CHANGES
*/

def stream err.
output stream err to err.txt append.

def input parameter s-cif like cif.cif.
def shared var g-today as date.

def shared var coeff as deci extent 6.
def shared var coeff_a as deci extent 7.

def var ecdiv_cost as deci extent 8 init [90,80,70,60,50,40,30,20].
def var ecdiv_spis as char extent 8 init ["11","10,12,13,14,51,65,66,67","15,23,24,25,26,27,28,29,34,35,45","50,52,55,70,71,72,73,74,80,85,90,92","16,17,18,19,20,21,22,30,31,32,33,36,37,38,39,40,41,60,61,62,63","64","01,02,05","75,91,93,95,98,99"].

def var bb as deci.
def var bb1 as deci.
def var i as integer.

/* 1. Отрасль */

find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = s-cif and sub-cod.d-cod = "ecdivis" no-lock no-error.
do i = 1 to 8:
  if lookup(sub-cod.ccode,ecdiv_spis[i]) <> 0 then do:
    coeff[1] = ecdiv_cost[i]. leave.
  end.
end.

/* 3. Чистый среднемес. оборот по KZT счетам / сумма займа */

def var bilance_all as deci.
def var bilance_c as deci.

bb = 0.

for each lgr where lgr.led = "DDA" or lgr.led = "SAV" no-lock,
 each aaa of lgr where aaa.cif = s-cif and aaa.crc = 1 no-lock:
     
     /* for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and jl.jdt >= g-today - 180 and jl.dc = 'C' no-lock.
           find first jh where jh.jh = jl.jh and jh.ref begins 'RMZ' no-lock no-error.
           if avail jh then bb = bb + jl.cam.
     end. */
     
     for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and jl.jdt >= g-today - 180 no-lock use-index acc:
         if jl.dc = 'C' then do:
            find first jh where jh.jh = jl.jh no-lock no-error.
            if avail jh then 
               if jh.ref begins 'RMZ' then bb = bb + jl.cam. /* чистый кредитовый оборот за последние полгода */
         end.
     end.
     
end.

bilance_all = 0.
for each lon where lon.cif = s-cif no-lock:
  run lonbal('lon', lon.lon, g-today, '1,7,8,20,21', yes, output bilance_c).
  if bilance_c > 0 then do:
     if lon.crc <> 1 then do:
       find first crc where crc.crc = lon.crc no-lock no-error.
       bilance_all = bilance_all + bilance_c * crc.rate[1].
     end.
     else bilance_all = bilance_all + bilance_c.
  end.
end.
bb = bb / 6 / bilance_all.

if bb < 0.5 then coeff[3] = 0.
if bb >= 0.5 and bb < 1 then coeff[3] = 70.
if bb >= 1 and bb < 1.5 then coeff[3] = 80.
if bb >= 1.5 and bb < 2 then coeff[3] = 90.
if bb >= 2 then coeff[3] = 100.

/* 6. Финансовое состояние */

def var balact1 like bal_cif.amount extent 27.
def var balpas1 like bal_cif.amount extent 22.
def var balres1 like bal_cif.amount extent 14.
def var balact2 like bal_cif.amount extent 27.
def var balpas2 like bal_cif.amount extent 22.
def var v-dt1 as date.
def var v-dt2 as date.

def var opt_values as deci extent 7 init [1.5, 0.7, 0.7, 4, 6, 0.5, 0.08].
def var weight_values as deci extent 7 init [20, 15, 15, 10, 10, 15, 15].
def var tek_ob_68 as deci.
def var vsego_act1 as deci.
def var vsego_act2 as deci.
def var cfinsost as deci init 0.

def var isa as logi extent 2 init [false,false].
def var isp as logi extent 2 init [false,false].
find last bal_cif where bal_cif.cif = s-cif and bal_cif.nom begins 'z' use-index rdt no-lock no-error.
if avail bal_cif then do:
  v-dt1 = bal_cif.rdt.
  for each bal_cif where bal_cif.cif = s-cif and bal_cif.rdt = v-dt1 use-index cif-rdt no-lock:
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
    for each bal_cif where bal_cif.cif = s-cif and bal_cif.rdt = v-dt2 use-index cif-rdt no-lock:
      if bal_cif.nom begins 'a' then do:
        isa[2] = true.
        balact2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
      if bal_cif.nom begins 'p' then do:
        isp[2] = true.
        balpas2[ integer(substr(bal_cif.nom,2,2))] = bal_cif.amount.
      end.
    end.
    if not isa[2] then put stream err unformatted s-cif " - Не найдены активы на дату " + string(v-dt2, "99/99/9999") + " (2)" skip.
    if not isp[2] then put stream err unformatted s-cif " - Не найдены пассивы на дату " + string(v-dt2, "99/99/9999") + " (2)" skip.
  end.
  else do:
    if not isa[1] then put stream err unformatted s-cif " - Не найдены активы на дату " + string(v-dt1, "99/99/9999") + " (1)" skip.
    if not isp[1] then put stream err unformatted s-cif " - Не найдены пассивы на дату " + string(v-dt1, "99/99/9999") + " (1)" skip.
  end.
  
  if isa[1] and isp[1] and isa[2] and isp[2] then do: /* балансы на обе даты есть */
    /***********************/
    
    bb1 = 0. vsego_act1 = 0. vsego_act2 = 0.
    do i = 11 to 27: bb1 = bb1 + balact1[i]. end.
    do i = 1 to 27: vsego_act1 = vsego_act1 + balact1[i]. vsego_act2 = vsego_act2 + balact2[i]. end.
    do i = 11 to 21: tek_ob_68 = tek_ob_68 + balpas1[i]. end.
    /* коэфф текущей ликвидности */
    coeff_a[1] = bb1 / tek_ob_68.
    /* коэфф быстрой (срочной) ликвидности */
    coeff_a[2] = (balact1[16] + balact1[17] + balact1[22] + balact1[23] + balact1[24] + balact1[25] + balact1[26]) / tek_ob_68.
    /* коэфф кредитоспособности */
    coeff_a[3] = (balpas1[1] + balpas1[2] + balpas1[3] + balpas1[4] + balpas1[5]) / (balpas1[8] + balpas1[9] + balpas1[10] + tek_ob_68).
    
    bb1 = (balact1[11] + balact1[12] + balact1[13] + balact1[14] + balact1[15] + balact2[11] + balact2[12] + balact2[13] + balact2[14] + balact2[15]) / 2.
    /* коэфф оборачиваемости ТМЗ */
    coeff_a[4] = balres1[2] / bb1.
    
    bb1 = (balact1[16] + balact1[17] + balact2[16] + balact2[17]) / 2.
    /* коэфф оборачиваемости кредиторской задолженности */
    coeff_a[5] = balres1[1] / bb1.
    /* коэфф автономии */
    coeff_a[6] = (balpas1[1] + balpas1[2] + balpas1[3] + balpas1[4] + balpas1[5]) / vsego_act1.
    /* коэфф ROA */
    coeff_a[7] = balres1[14] / ((vsego_act1 + vsego_act2) / 2).
    
    do i = 1 to 7:
      if coeff_a[i] > opt_values[i] then coeff_a[i] = opt_values[i].
      coeff[6] = coeff[6] + coeff_a[i] / opt_values[i] * weight_values[i].
    end.
    /***********************/
  end.

end. /* if avail bal_cif */
else do: put stream err unformatted s-cif " - Не найдены фин. результаты" skip. end.

output stream err close.
