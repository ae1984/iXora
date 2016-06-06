/* lncomiss.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        12/10/2004 madiyar
 * CHANGES
        22/10/2004 madiyar - теперь показывает ранее начисленные комиссии и автоматически рассчитывает суммы для доначисления
                             добавил печать операционного ордера
        08/12/2004 madiyar - добавил выбор режима - начисление или возврат комиссий
        28/10/2005 madiyar - включил редактирование самих сумм в обоих режимах
        20/07/2006 madiyar - комиссия за оформление документации - программа не позволяла ввести отрицательную сумму
*/

def shared var s-lon like lnsch.lnn.
def new shared var s-jh like jh.jh.
def shared var g-today as date.
def var v-templ as char.

def var comm_pred as deci init 0. /* комиссия за предоставление кредита (сумма, как правило 14905 тенге) */
def var comm_ved as deci init 0. /* комиссия за ведение ссудного счета (ставка, как правило 0.5% от суммы кредита) */
def var comm_prod as deci init 0. /* комиссия за продление ссуды (как правило 0.25% от суммы кредита) */
def var comm_ved_sum as deci init 0.
def var comm_prod_sum as deci init 0.

def var comm_pred1 as deci init 0.
def var comm_ved1 as deci init 0.
def var comm_prod1 as deci init 0.
def var comm_ved1_sum as deci init 0.
def var comm_prod1_sum as deci init 0.
def var v-crc as char format "xxx" extent 4.
def var v-crcp as char format "xxx".

def var ja as logi format "да/нет" init no.

def var comiss as deci extent 3.
def var vdel as char initial "^".
def var glkomiss like gl.gl.
def var v-param as char.
def var rcode as int.
def var rdes as char.
def var remx as char extent 4.
def var v-type as int init 1.

def var sumkzt_before as deci extent 2.
def var sumkzt_now as deci extent 2.
def var sum as deci extent 2.

/*
def var v-glint26 like gl.gl.
def var v-glint27 like gl.gl.
def var v-glint28 like gl.gl.
*/

form
    " -- НАЧИСЛЕНО -- " skip
    comm_pred1  format ">>>,>>>,>>>,>>9.99" at 2 label "Оформление кред.докум. (KZT) " skip
    comm_ved1   format ">9.99" at 2 label "Предоставление кредита (%)   " "  "
    v-crc[1] no-label comm_ved1_sum no-label format "->>>,>>>,>>>,>>9.99" " " skip
    comm_prod1  format ">9.99" at 2 label "Продление ссуды        (%)   " "  "
    v-crc[2] no-label comm_prod1_sum no-label format "->>>,>>>,>>>,>>9.99" " " skip(1)
    v-type format "zz9" at 5 label "Операция " help " 1. Начисление  2. Возврат " skip(1)
    " -- НАЧИСЛИТЬ / ВОЗВРАТИТЬ -- " skip
    comm_pred  format "->>>,>>>,>>>,>>9.99" at 2 label "Оформление кред.докум. (KZT) " help "F4 - выход; F1, Enter - далее" skip
    comm_ved   format ">9.99" at 2 label "Предоставление кредита (%)   " help "F4 - выход; F1, Enter - далее" "  "
    v-crc[3] no-label comm_ved_sum no-label format "->>>,>>>,>>>,>>9.99" " " skip
    comm_prod  format ">9.99" at 2 label "Продление ссуды        (%)   " help "F4 - выход; F1, Enter - далее" "  "
    v-crc[4] no-label comm_prod_sum no-label format "->>>,>>>,>>>,>>9.99" " " skip(2)
    ja at 2 label "Создать проводку (да/нет)? " skip(1)
    with side-label no-hide /*2 columns*/ centered row 4 overlay title " Комиссии " frame loncomm.

for each lonres where lonres.lon = s-lon no-lock:
  if lookup(string(lonres.lev),"27,28,29") > 0 and lonres.dc = "D" then do:
    find jh where jh.jh = lonres.jh no-lock no-error.
    if avail jh then
      if not(jh.party begins "Storn") then do:
        if lonres.lev = 27 then comm_pred1 = comm_pred1 + lonres.amt.
        if lonres.lev = 28 then comm_ved1_sum = comm_ved1_sum + lonres.amt.
        if lonres.lev = 29 then comm_prod1_sum = comm_prod1_sum + lonres.amt.
      end.
  end.
  if lookup(string(lonres.lev),"27,28,29") > 0 and lonres.dc = "C" then do:
    find jh where jh.jh = lonres.jh no-lock no-error.
    if avail jh then
      if not(jh.party begins "Storn") then do:
        find jl where jl.jh = lonres.jh and jl.lev = lonres.lev no-lock no-error.
        if jl.rem[1] begins "Возврат комиссии" then do:
          if lonres.lev = 27 then comm_pred1 = comm_pred1 - lonres.amt.
          if lonres.lev = 28 then comm_ved1_sum = comm_ved1_sum - lonres.amt.
          if lonres.lev = 29 then comm_prod1_sum = comm_prod1_sum - lonres.amt.
        end.
      end.
  end.
end.

find lon where lon.lon = s-lon no-lock no-error.
find crc where crc.crc = lon.crc no-lock no-error.
v-crc = crc.code.

find first lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock no-error.
if avail lonhar then do:
  comm_ved1 = lonhar.rez-dec[3].
  if comm_ved1 > 0 then do:
    comm_ved = comm_ved1.
    comm_ved_sum = round(lon.opnamt * comm_ved / 100, 2) - comm_ved1_sum.
  end.
  comm_prod1 = lonhar.rez-dec[4].
  if comm_prod1 > 0 then do:
    comm_prod = comm_prod1.
    comm_prod_sum = round(lon.opnamt * comm_prod / 100, 2) - comm_prod1_sum.
  end.
end.

display v-type v-crc comm_pred1 comm_ved1 comm_prod1
        comm_ved1_sum comm_prod1_sum
        comm_pred comm_ved comm_prod
        comm_ved_sum comm_prod_sum with frame loncomm.

update v-type with frame loncomm.
update comm_pred with frame loncomm.
update comm_ved with frame loncomm.
comm_ved_sum = round(lon.opnamt * comm_ved / 100, 2) - comm_ved1_sum.
display comm_ved_sum with frame loncomm.
/*if v-type = 2 then*/ update comm_ved_sum with frame loncomm.
update comm_prod with frame loncomm.
comm_prod_sum = round(lon.opnamt * comm_prod / 100, 2) - comm_prod1_sum.
display comm_prod_sum with frame loncomm.
/*if v-type = 2 then*/ update comm_prod_sum with frame loncomm.

if v-type = 1 and (comm_pred < 0 or comm_ved_sum < 0 or comm_prod_sum < 0) then do:
  message "Некорректная сумма начисляемой комиссии, должна быть > 0" view-as alert-box buttons ok.
  undo,retry.
end.
if v-type = 2 and (comm_pred > 0 or comm_ved_sum > 0 or comm_prod_sum > 0) then do:
  message "Некорректная сумма комиссии возвращаемой комиссии, должна быть < 0" view-as alert-box buttons ok.
  undo,retry.
end.

update ja with frame loncomm.
if not ja then do: message "Проводка не была создана" view-as alert-box buttons ok. return. end.

find crc where crc.crc = lon.crc no-lock no-error.
find cif where cif.cif = lon.cif no-lock no-error.

find longrp where longrp.longrp = lon.grp no-lock no-error.
glkomiss = 0.
if avail longrp then do:
  if substr(string(longrp.stn),1,1) = '1' then glkomiss = 442920.
  if substr(string(longrp.stn),1,1) = '2' then glkomiss = 442910.
end.
if glkomiss = 0 then do:
  message " Ошибка! Проверьте настройку группы кредита ".
  return.
end.

if v-type = 1 then do:
  
  remx[1] = "Начисление комиссии, " + lon.lon + " " +
            trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
            + " " + crc.code + " "
            + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
  remx[2] = " Комиссия за оформление кред.докум. KZT" + trim(string(comm_pred,">>>,>>>,>>9.99-")).
  remx[3] = " Комиссия за предоставление кредита " + crc.code + " " + trim(string(comm_ved_sum,">>>,>>>,>>9.99-")).
  remx[4] = " Комиссия за продление ссуды " + crc.code + " " + trim(string(comm_prod_sum,">>>,>>>,>>9.99-")).
  
  v-param = string(comm_pred) + vdel +
            lon.lon + vdel +
            string(glkomiss) + vdel +
            remx[1] + vdel +
            remx[2] + vdel +
            string(comm_ved_sum) + vdel +
            remx[3] + vdel +
            string(comm_prod_sum) + vdel +
            remx[4].
  
  if lon.crc = 1 then v-templ = "lon0097". else v-templ = "lon0096".
  
  s-jh = 0.
  run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode,
              output rdes, input-output s-jh).
  
  if rcode ne 0 then do:
        message rdes.
        pause no-message.
        return.
   end.
   run lonresadd(s-jh).
   
   /* message "Проводка " + string(s-jh) view-as alert-box buttons ok. */
   run vou_bank(2).
  
end.

if v-type = 2 then do:
  
  remx[1] = "Возврат комиссии, " + lon.lon + " " +
            trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-"))
            + " " + crc.code + " "
            + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
  remx[2] = " Комиссия за оформление кред.докум. KZT" + trim(string(comm_pred,">>>,>>>,>>9.99-")).
  remx[3] = " Комиссия за предоставление кредита " + crc.code + " " + trim(string(comm_ved_sum,">>>,>>>,>>9.99-")).
  remx[4] = " Комиссия за продление ссуды " + crc.code + " " + trim(string(comm_prod_sum,">>>,>>>,>>9.99-")).
  
  comm_pred = - comm_pred.
  comm_ved_sum = - comm_ved_sum.
  comm_prod_sum = - comm_prod_sum.
  
  v-param = string(comm_pred) + vdel +
            string(glkomiss) + vdel +
            lon.lon + vdel +
            remx[1] + vdel +
            remx[2].
  
  if lon.crc = 1 then do:
    v-templ = "lon0099".
    v-param = v-param + vdel +
              string(comm_ved_sum) + vdel +
              remx[3] + vdel +
              string(comm_prod_sum) + vdel +
              remx[4].
    /*
    displ v-param format "x(320)" view-as fill-in size 60 by 1 with frame frrr.
    update v-param with frame frrr.
    */
  end.
  else do:
    
    v-templ = "lon0098".
    
    find crc where crc.crc = lon.crc no-lock no-error.
    sumkzt_now[1] = comm_ved_sum * crc.rate[1].
    sumkzt_now[2] = comm_prod_sum * crc.rate[1].
    sumkzt_before = 0. sum = 0.
    for each lonres where lonres.lon = lon.lon and lonres.lev = 28 and lonres.dc = "D" no-lock break by lonres.jdt desc:
       find last crchis where crchis.crc = lon.crc and crchis.regdt <= lonres.jdt no-lock no-error.
       if sum[1] + lonres.amt < comm_ved_sum then do:
           sum[1] = sum[1] + lonres.amt.
           sumkzt_before[1] = sumkzt_before[1] + lonres.amt * crchis.rate[1].
       end.
       else do: sumkzt_before[1] = sumkzt_before[1] + (comm_ved_sum - sum[1]) * crchis.rate[1]. sum[1] = comm_ved_sum. leave. end.
    end.
    for each lonres where lonres.lon = lon.lon and lonres.lev = 29 and lonres.dc = "D" no-lock break by lonres.jdt desc:
       find last crchis where crchis.crc = lon.crc and crchis.regdt <= lonres.jdt no-lock no-error.
       if sum[2] + lonres.amt < comm_prod_sum then do:
           sum[2] = sum[2] + lonres.amt.
           sumkzt_before[2] = sumkzt_before[2] + lonres.amt * crchis.rate[1].
       end.
       else do: sumkzt_before[2] = sumkzt_before[2] + (comm_prod_sum - sum[2]) * crchis.rate[1]. sum[2] = comm_prod_sum. leave. end.
    end.
    
    if sum[1] < comm_ved_sum or sum[2] < comm_prod_sum then do:
       message " Ошибка! Возвращаемая сумма больше начисленных комиссий " view-as alert-box buttons ok.
       return.
    end.
    else do:
       run lonbalcrc('lon',lon.lon,g-today,"28",yes,lon.crc,output sum[1]).
       run lonbalcrc('lon',lon.lon,g-today,"29",yes,lon.crc,output sum[2]).
       if sum[1] < comm_ved_sum or sum[2] < comm_prod_sum then do:
          message " Ошибка! Возвращаемая сумма больше начисленных комиссий " view-as alert-box buttons ok.
          return.
       end.
    end.
    
    if sumkzt_now[1] > sumkzt_before[1] then v-param = v-param + vdel +
                                                       string(sumkzt_before[1]) + vdel +
                                                       remx[3] + vdel +
                                                       string(sumkzt_now[1] - sumkzt_before[1]) + vdel +
                                                       string(comm_ved_sum) + vdel +
                                                       "0".
    else v-param = v-param + vdel +
                   string(sumkzt_now[1]) + vdel +
                   remx[3] + vdel +
                   "0" + vdel +
                   string(comm_ved_sum) + vdel +
                   string(sumkzt_before[1] - sumkzt_now[1]).
    
    if sumkzt_now[2] > sumkzt_before[2] then v-param = v-param + vdel +
                                                       string(sumkzt_before[2]) + vdel +
                                                       remx[4] + vdel +
                                                       string(sumkzt_now[2] - sumkzt_before[2]) + vdel +
                                                       string(comm_prod_sum) + vdel +
                                                       "0".
    else v-param = v-param + vdel +
                   string(sumkzt_now[2]) + vdel +
                   remx[4] + vdel +
                   "0" + vdel +
                   string(comm_prod_sum) + vdel +
                   string(sumkzt_before[2] - sumkzt_now[2]).
    
  end.
  
  s-jh = 0.
  run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode,
              output rdes, input-output s-jh).
  
  if rcode ne 0 then do:
        message rdes.
        pause no-message.
        return.
   end.
   run lonresadd(s-jh).
   
   /*message "Проводка " + string(s-jh) view-as alert-box buttons ok.*/
   run vou_bank(2).
  
end.

if comm_ved <> comm_ved1 or comm_prod <> comm_prod1 then do:
  find first lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-error.
  if avail lonhar then do:
    lonhar.rez-dec[3] = comm_ved.
    lonhar.rez-dec[4] = comm_prod.
    release lonhar.
  end.
  else message " Ошибка! Запись lonhar отсутствует " view-as alert-box buttons ok.
end.
