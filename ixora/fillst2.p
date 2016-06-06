/* fillst.p
 * MODULE
        Общий
 * DESCRIPTION
        Заполнение хранилища данных для управленческих отчетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        04/05/2008 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        06/08/2008 madiyar - комиссии собираем по ГК
        05/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
        10.12.2008 galina - возможность расчитывать выбранные параметры
        11.12.2008 galina - перекомпеляция
        15/12/2008 galina  - берем все провизии, а не только в тенге
        12/01/2010 galina - учитываем списанную пеню в начисленной
*/

def input parameter v-dt as date no-undo.
def input parameter p-code as char no-undo.

def shared temp-table wrk like vals.
def var j as integer no-undo.
/*
def shared temp-table wrk no-undo
  field bank as char
  field sp as char
  field code as char
  field dt as date
  field deval as deci
  field chval as char
  index idx is primary bank sp code.
*/

def shared var rate as deci extent 3.
/*
def shared var lst_ur as char.
*/

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-begday as date no-undo init ?.
find txb.sysc where txb.sysc.sysc = 'BEGDAY' no-lock no-error.
if available txb.sysc and txb.sysc.daval <> ? then v-begday = txb.sysc.daval.

find first txb.cmp no-lock no-error.
if v-begday = ? then do:
    message "Не настроен справочник BEGDAY!" skip txb.cmp.name view-as alert-box error.
    return.
end.

if v-begday >= v-dt then return.

/*
message s-ourbank string(v-begday, "99/99/9999") string(v-dt, "99/99/9999") view-as alert-box.
*/
message s-ourbank.

def buffer b-jl for txb.jl.
def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal16 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal5 as deci no-undo.
def var v-bal13 as deci no-undo.
def var v-bal14 as deci no-undo.
def var v-bal30 as deci no-undo.
def var v-bal6 as deci no-undo.

def var v-prc_nach as deci no-undo.
def var v-prc_pog as deci no-undo.
def var v-pen_nach as deci no-undo.
def var v-pen_del as deci no-undo.
def var v-pen_pog as deci no-undo.

def var v-express as logi no-undo.
def var v-ur as logi no-undo.
def var v-kr as logi no-undo.
def var v-deval as deci no-undo.
def var v-cif as char no-undo.
def var v-cif_expr as char no-undo.
def var dayc1 as integer no-undo.
def var dayc2 as integer no-undo.
def var v-daymax as integer no-undo.

def var v-lonstat as integer no-undo.

def var v-duedt as date no-undo.

def var coun as integer no-undo.
def var startTime as integer no-undo.
def var endTime as integer no-undo.

startTime = time.

{val_functions.i}


coun = 0.
for each txb.lon no-lock break by txb.lon.cif:
    
    if txb.lon.opnamt <= 0 then next.
    if txb.lon.rdt >= v-dt then next. /* пропускаем все кредиты, выданные с v-dt и позже */
    
    if txb.lon.crc < 1 or txb.lon.crc > 3 then do:
        message "Некорректный код валюты, crc=" + string(txb.lon.crc) + ", lon=" + txb.lon.lon view-as alert-box error.
        next.
    end.
    
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1",no,txb.lon.crc,output v-bal1).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"7",no,txb.lon.crc,output v-bal7).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"2",no,txb.lon.crc,output v-bal2).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"9",no,txb.lon.crc,output v-bal9).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"16",no,1,output v-bal16).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"4",no,txb.lon.crc,output v-bal4).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"5",no,1,output v-bal5).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"13",no,txb.lon.crc,output v-bal13).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"14",no,txb.lon.crc,output v-bal14).
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"30",no,1,output v-bal30).
    
    
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"6",no,txb.lon.crc,output v-bal6).
    v-bal6 = - v-bal6.
    
    v-prc_pog = 0.
    
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat >= v-begday and txb.lnsci.idat < v-dt and txb.lnsci.flp > 0 no-lock:
        v-prc_pog = v-prc_pog + txb.lnsci.paid.
    end.
    v-prc_nach = v-bal2 + v-bal9 + v-prc_pog.
    
    v-pen_pog = 0.
    v-pen_del = 0.
    for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' and txb.jl.jdt >= v-begday and txb.jl.jdt < v-dt and txb.jl.lev = 16 no-lock:
        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
        if b-jl.sub = 'CIF' then v-pen_pog = v-pen_pog + txb.jl.cam.
        else v-pen_del = v-pen_del + txb.jl.cam. 
    end.
    v-pen_nach = v-pen_del + v-bal16 + v-pen_pog.
    
    v-lonstat = 1.
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < v-dt use-index lonhar-idx1 no-lock no-error.
    if avail txb.lonhar then v-lonstat = txb.lonhar.lonstat.
    
    v-express = (txb.lon.grp = 90 or txb.lon.grp = 92).
    v-ur = (substring(string(txb.lon.gl),5,1) = '1').
    v-kr = (substring(string(txb.lon.gl),4,1) = '1').
    
    v-daymax = 0. dayc1 = 0. dayc2 = 0.
    if v-bal7 + v-bal9 > 0 then do:
        run lndayspr_txb(txb.lon.lon,v-dt,no,output dayc1,output dayc2).
        if dayc1 > dayc2 then v-daymax = dayc1.
                         else v-daymax = dayc2.
    end.
    
    v-duedt = txb.lon.duedt.
    if txb.lon.ddt[5] <> ? then v-duedt = txb.lon.ddt[5].
    if txb.lon.cdt[5] <> ? then v-duedt = txb.lon.cdt[5].
    
    if p-code <> "" then do j = 1 to num-entries(p-code):
      find valspr where valspr.code = int(entry(j,p-code)) and valspr.active no-lock no-error.
      if avail valspr then do:
        v-deval = 0.
        if trim(valspr.proc) <> "" then run value(trim(valspr.proc)) (output v-deval).
        find first wrk where wrk.bank = s-ourbank and wrk.code = valspr.code and wrk.sp = 0 and wrk.dt = v-dt no-error.
        if not avail wrk then do:
          create wrk.
          assign wrk.bank = s-ourbank
                 wrk.code = valspr.code
                 wrk.sp = 0
                 wrk.dt = v-dt.
        end.
        wrk.deval = wrk.deval + v-deval.  
      end.
    end.
    else do:
      for each valspr where valspr.sub = 'lon' and valspr.active no-lock:
        v-deval = 0.
        if trim(valspr.proc) <> "" then run value(trim(valspr.proc)) (output v-deval).
        find first wrk where wrk.bank = s-ourbank and wrk.code = valspr.code and wrk.sp = 0 and wrk.dt = v-dt no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.bank = s-ourbank
                   wrk.code = valspr.code
                   wrk.sp = 0
                   wrk.dt = v-dt.
        end.
        wrk.deval = wrk.deval + v-deval.
        /*
        if v-bal1 + v-bal7 > 0 then message "2..." s-ourbank " " string(v-deval,">>>,>>>,>>>,>>9.99") view-as alert-box.
        */
      end.
    end.
    
    coun = coun + 1.
    
end.

for each valspr where valspr.sub = 'gl' and valspr.active no-lock:
    v-deval = 0.
    if trim(valspr.proc) <> "" then run value(trim(valspr.proc)) (output v-deval).
    find first wrk where wrk.bank = s-ourbank and wrk.code = valspr.code and wrk.sp = 0 and wrk.dt = v-dt no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.bank = s-ourbank
               wrk.code = valspr.code
               wrk.sp = 0
               wrk.dt = v-dt.
    end.
    wrk.deval = wrk.deval + v-deval.
end.


endTime = time.

output to fillst.txt append.
put unformatted skip(2) s-ourbank " " txb.cmp.name skip
                string(startTime,"hh:mm:ss") " start" skip
                string(endTime,"hh:mm:ss") " finish" skip
                "elapsed " string(endTime - startTime,"hh:mm:ss") ", processed " coun " loans" skip.
output close.

hide message no-pause.

