/* lnnprov2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет по провизиям для налоговой
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
        24/02/2005 madiyar
 * CHANGES
        25/02/2005 madiyar - слово "Погашен" в примечании заменил на "Погашение"
        03/03/2005 madiyar - полностью переделал отчет
        04/03/2005 madiyar - сортировка записей lonres по дате
        05/03/2005 madiyar - забыл убрать отладочный код
        11/03/2005 madiyar - остаток долга - в тенге
        14/03/2005 madiyar - добавил "погашено списанного ОД"
        16/03/2005 madiyar - забыл убрать отладочный код
        18/03/2005 madiyar - добавил колонку по потерянным кредитам
                             исправил расчет погашенного списанного ОД
        19/03/2005 madiyar - исправил расчет сумм по погашению списанных кредитов и по потерянным кредитам
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        16/12/05   marinav - переделала for each под индех
        09/03/2006 madiyar - добавил группу кредита
        15/09/2006 Natalya D. - оптимизация: в выборку по lon & lonres добавила условие, так цепляется индекс.
        18/09/2006 Natalya D. - иправила один запрос, неправильно отрабатывал.
        22/12/2008 madyiar - подправил (if avail для проводок, удалил устаревшие куски кода)
        28/10/2010 madiyar - 763000 -> 813000
*/

def shared var g-today as date.

def shared temp-table wrk no-undo
  field bank as char
  field cif like txb.cif.cif
  field klname as char
  field urfiz as char
  field lon like txb.lon.lon
  field grp like txb.lon.grp
  field sum as deci extent 15
  field fact_prov as deci
  field comment as char
  index idx is primary bank cif lon.

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

/* группы кредитов юридических лиц */
def var lst_ur as char no-undo init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.
def shared var dt_old as date no-undo.

def shared var rates1 as deci no-undo extent 20.
def shared var rates2 as deci no-undo extent 20.

def var bb as deci no-undo.
def var mesa as integer no-undo.
def var cl_ch as logi no-undo.
def var cl_begin as integer no-undo.
def var cprov as deci no-undo extent 2.
def var pr_flag as logi no-undo.
def var v-process as integer no-undo.
def var vln as integer no-undo.
def var v-lev as char init '3,6'.
def var i as int.
mesa = 0.

for each txb.lon where txb.lon.rdt <= dt2 no-lock:
  
  if txb.lon.opnamt <= 0 then next.
  /*if txb.lon.rdt > dt2 then next.*/
  
  
  find first txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= dt1 and txb.lonres.jdt <= dt2 and (txb.lonres.lev = 3 or txb.lonres.lev = 6) no-lock no-error.
  if not avail txb.lonres then do:
    if txb.lon.rdt >= dt1 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,dt1,"3,6",no,1,output bb).
    if bb = 0 then next.
  end.
  
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  create wrk.
  wrk.bank = s-ourbank.
  wrk.cif = txb.lon.cif.
  wrk.klname = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
  wrk.lon = txb.lon.lon.
  wrk.grp = txb.lon.grp.
  if lookup(string(txb.lon.grp),lst_ur) > 0 then wrk.urfiz = 'юр'.
  else wrk.urfiz = 'физ'.
  
  /* начало */
  /* остаток долга */
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7",no,txb.lon.crc,output wrk.sum[1]).
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7",yes,txb.lon.crc,output wrk.sum[14]).
  
  wrk.sum[1] = wrk.sum[1] * rates1[txb.lon.crc].
  wrk.sum[14] = wrk.sum[14] * rates2[txb.lon.crc].
  
  /* норма провизий */
  
  if txb.lon.rdt < dt1 then do:
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dt1 no-lock no-error.
    if avail txb.lonhar then do:
      cl_begin = txb.lonhar.lonstat.
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
      if avail txb.lonstat then wrk.sum[2] = txb.lonstat.prc.
    end.
    else do: cl_begin = -1. wrk.sum[2] = -1. end. /* error! */
  end.
  else do: cl_begin = -2. wrk.sum[2] = -2. end. /* skip */
  
  find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= dt2 no-lock no-error.
  if avail txb.lonhar then do:
    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then wrk.sum[15] = txb.lonstat.prc.
  end.
  else wrk.sum[15] = -1. /* error! */
  
  /* провизии */
  
  pr_flag = no.
   for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= dt2                     
                        and (txb.lonres.lev = 3 or txb.lonres.lev = 6)
                        no-lock /*break by txb.lonres.jdt*/ :
    
    /*message " 1... " txb.lonres.jh " " txb.lonres.dc " " txb.lonres.amt " " vln " " v-process " " txb.lonres.jdt view-as alert-box buttons ok.*/
    
    /*if txb.lonres.jdt > dt2 then leave.*/
    
   /* message " 2... " txb.lonres.jh " " txb.lonres.dc " " txb.lonres.amt " " vln " " v-process " " txb.lonres.jdt view-as alert-box buttons ok.*/
    
    if pr_flag = no and txb.lonres.jdt >= dt1 then do:
      cprov[1] = wrk.sum[3] + wrk.sum[4].
      pr_flag = yes.
    end.
    
    /*message " 3... " txb.lonres.jh " " txb.lonres.dc " " txb.lonres.amt " " vln " " v-process " " txb.lonres.jdt view-as alert-box buttons ok.*/
    
    if txb.lonres.dc = 'c' then do:
         
         v-process = 1.
         vln = txb.lonres.ln.
         if vln mod 2 = 0 then vln = vln - 1.
                          else vln = vln + 1.
         find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.dam = txb.lonres.amt and txb.jl.ln = vln no-lock no-error.
         if avail txb.jl and txb.jl.sub = "lon" and ((txb.lonres.lev = 3 and txb.jl.lev = 6) or (txb.lonres.lev = 6 and txb.jl.lev = 3)) then v-process = 0. /* перенос провизий */
         
 /*        message "C--- " txb.lonres.jh " " txb.lonres.dc " " txb.lonres.amt " " vln " " v-process " " txb.lonres.jdt view-as alert-box buttons ok.*/
         
         if v-process = 0 then next.
         
         if txb.lonres.jdt < dt_old then do:
           wrk.sum[3] = wrk.sum[3] + txb.lonres.amt. /* на начало, в прошлые годы */
           wrk.sum[12] = wrk.sum[12] + txb.lonres.amt. /* на конец, в прошлые годы */
         end.
         
         if txb.lonres.jdt >= dt_old and txb.lonres.jdt < dt1 then do:
           wrk.sum[4] = wrk.sum[4] + txb.lonres.amt. /* на начало, в предш отч году */
           wrk.sum[12] = wrk.sum[12] + txb.lonres.amt. /* на конец, в прошлые годы */
         end.
         
         if txb.lonres.jdt >= dt1 and txb.lonres.jdt <= dt2 then do:
           wrk.sum[13] = wrk.sum[13] + txb.lonres.amt. /* на конец, в отч год */
           wrk.sum[5] = wrk.sum[5] + txb.lonres.amt. /* создано в отч году */
         end.
         
    end. /* dc = 'c' */
    else do:
         
         v-process = 1.
         /*if txb.lonres.jh = 448346 then message v-process view-as alert-box buttons ok.*/
         
         vln = txb.lonres.ln.
         if vln mod 2 = 0 then vln = vln - 1.
                          else vln = vln + 1.
         find first txb.jl where txb.jl.jh = txb.lonres.jh  and txb.jl.ln = vln and txb.jl.cam = txb.lonres.amt no-lock no-error.
         if avail txb.jl and txb.jl.sub = "lon" and ((txb.lonres.lev = 3 and txb.jl.lev = 6) or (txb.lonres.lev = 6 and txb.jl.lev = 3)) then v-process = 0. /* перенос провизий */
         else if avail txb.jl and ((txb.jl.sub = "lon" and (txb.jl.lev = 1 or txb.jl.lev = 7)) or (txb.jl.gl = 185800) or (txb.jl.gl = 763000) or (txb.jl.gl = 813000)) then v-process = 2. /* за баланс */
         /*if txb.lonres.jh = 448346 then message v-process view-as alert-box buttons ok.*/
         
/*         message "D--- " txb.lonres.jh " " txb.lonres.dc " " txb.lonres.amt " " vln " " v-process " " txb.lonres.jdt view-as alert-box buttons ok.*/
         
         if v-process = 0 then next.
         
         if txb.lonres.jdt < dt_old then do:
           wrk.sum[3] = wrk.sum[3] - txb.lonres.amt. /* списано провизий, созд в прошлых годах - на начало */
           wrk.sum[12] = wrk.sum[12] - txb.lonres.amt. /* списано провизий, созд в прошлых годах - на конец */
         end.
         
         if txb.lonres.jdt >= dt_old and txb.lonres.jdt < dt1 then do:
           if wrk.sum[3] > 0 then do: /* списано провизий, созд в прошлых и отч годах - на начало */
             if wrk.sum[3] > txb.lonres.amt then wrk.sum[3] = wrk.sum[3] - txb.lonres.amt.
             else do:
               wrk.sum[4] = wrk.sum[4] - (txb.lonres.amt - wrk.sum[3]).
               wrk.sum[3] = 0.
             end.
           end.
           else wrk.sum[4] = wrk.sum[4] - txb.lonres.amt.
           wrk.sum[12] = wrk.sum[12] - txb.lonres.amt. /* списано провизий, созд в прошлых годах - на конец */
         end.
         
         if txb.lonres.jdt >= dt1 and txb.lonres.jdt <= dt2 then do:
           cprov = 0.
           if wrk.sum[12] > 0 then do: /* списано провизий, созд в прошлых и отч годах - на конец */
             if wrk.sum[12] > txb.lonres.amt then do: wrk.sum[12] = wrk.sum[12] - txb.lonres.amt. cprov[1] = txb.lonres.amt. end.
             else do:
               cprov[1] = wrk.sum[12].
               cprov[2] = txb.lonres.amt - wrk.sum[12].
               wrk.sum[13] = wrk.sum[13] - (txb.lonres.amt - wrk.sum[12]).
               wrk.sum[12] = 0.
             end.
           end.
           else do:
             wrk.sum[13] = wrk.sum[13] - txb.lonres.amt.
             cprov[1] = 0.
             cprov[2] = txb.lonres.amt.
           end.
           
           /*if txb.lonres.jh = 448346 then do: displ wrk.sum format ">>>,>>>,>>>,>>9.99". pause. end.*/
           
           if v-process = 1 then do:
             wrk.sum[6] = wrk.sum[6] + cprov[1].
             wrk.sum[7] = wrk.sum[7] + cprov[2].
           end.
           else do:
             wrk.sum[8] = wrk.sum[8] + cprov[1].
             wrk.sum[9] = wrk.sum[9] + cprov[2].
           end.
           /*if txb.lonres.jh = 448346 then do: displ wrk.sum format ">>>,>>>,>>>,>>9.99". pause. end.*/
         end.
         
    end. /* dc = 'd' */
    
  end. /* for each txb.lonres */
  
  if wrk.sum[6] + wrk.sum[7] + wrk.sum[8] + wrk.sum[9] > 0 then do:
    run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13",yes,txb.lon.crc,output bb).
    if bb > 0 then wrk.comment = "Списан".
    else do:
      find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat >= dt1 and txb.lnsch.stdat <= dt2 no-lock no-error.
      if avail txb.lnsch then wrk.comment = "Погашение".
      cl_ch = no.
      for each txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt >= dt1 and txb.lonhar.fdt <= dt2 no-lock:
        if txb.lonhar.lonstat < cl_begin then do:
          cl_ch = yes. leave.
        end.
        else cl_begin = txb.lonhar.lonstat.
      end.
      if cl_ch then
         if wrk.comment <> '' then wrk.comment = wrk.comment + ",Переклассификация". else wrk.comment = "Переклассификация".
    end.
  end.
  
  if wrk.sum[8] + wrk.sum[9] > 0 then do:
    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 13 and txb.lonres.dc = "C" no-lock:
      if txb.lonres.jdt >= dt1 and txb.lonres.jdt <= dt2 then do:
        
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lonres.jdt no-lock no-error.
        
        find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.cam = txb.lonres.amt and txb.jl.gl = 494200 no-lock no-error.
        if avail txb.jl then wrk.sum[10] = wrk.sum[10] + txb.lonres.amt * txb.crchis.rate[1]. /* погашенные */
        else wrk.sum[11] = wrk.sum[11] + txb.lonres.amt * txb.crchis.rate[1]. /* потерянные */
        
      end.
    end.
  end.
  
  run lonbalcrc_txb('lon',txb.lon.lon,01/01/2005,"3,6",no,1,output wrk.fact_prov).
  wrk.fact_prov = - wrk.fact_prov.
  
  mesa = mesa + 1.
  if (mesa / 100) - integer (mesa / 100) = 0 then do:
     hide message no-pause.
     message " " + s-ourbank + " - " string(mesa) + ' кредитов '.
  end.
  
end. /* for each txb.lon */

hide message no-pause.
message " " + s-ourbank + " - " string(mesa) + ' кредитов '.

