/* lnanlz4.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Подготовка временной таблицы для анализа кредитного портфеля
 * RUN
       
 * CALLER
       lnanlz3
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-5-13 
 * AUTHOR
        09.12.2003 marinav,nataly
 * CHANGES
        08.12.2003 nataly  - заменен счет ГК 1439 -> 1428  в связи с переходом на новый ПС
        13.12.2003 marinav - добавилось - %%, остатки кредитного портфеля по датам 
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        01.01.2004 nadejda - изменен просчет предыдущих месяцев с учетом прошлого года
        03.01.2004 marinav - расчет просроченных кредитов по кол-ву дней просрочки   
        30.01.2004 marinav - учет выходных дней в кол-ве дней просрочки
                             в просрочку берется сумма > 100 тенге  
        04.02.2004 nadejda - добавлены штрафы и рентабельность
        04.03.04   marinav - расчет штрафов перенесен в lnanlz4
                             все остатки берутся по состоянию НА дату
        14/04/2004 madiyar - по кредитам чей срок прошел, но остаток не нулевой (на просрочке) - не находился график погашения
                             и выдавалось сообщение об ошибке
        21/06/2004 madiyar - подправил расчет начисленных процентов на дату
        05/07/2004 madiyar - закомментировал расчет провизий по реальной классификации (lonhar.lonstat) - устарела
        09/07/2004 madiyar - дописал расчет просроченных процентов для 4-ой схемы
        04/08/2004 madiyar - расчет просроченных процентов для 3-ей схемы: если дата позже 31 марта 2004 - то расчет по histrxbal, раньше -
                             по-старому (расчет от текущих остатков назад)
                             При классификации кредитов - убрал условие " полная просрочка <= 100 тенге "
        09/08/2004 madiyar - добавил временную таблицу wrkm для расчета начисл.%, получ.%, пени (по всем кредитам, не только по
                             попавшим в wrk)
        05/07/2004 madiyar - wrk.srez - фактически начисленные провизии
        01/11/2004 madiyar - теперь классификация берется из lonhar, а не вычисляется от просрочки
        09/11/2004 madiyar - полностью переделал отчет
        10/11/2004 madiyar - исправил расчет погашенных кредитов за период
        01/06/2005 madiyar - изменения в расчете комиссий
        02/06/2005 madiyar - изменения в расчете комиссий (continued)
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        10/10/2005 madiyar - добавилась комиссия за ведение тек. счета, расчет портфеля - по glday
        16/12/05   marinav - переделала for each под индех jl
        01/03/2006 madiyar - исправил расчет комиссий; no-undo; расчет дней просрочки - по проводкам
        04/04/2006 madiyar - попытался ускорить отчет
        02/10/2006 madiyar - исправил расчет удельных долей
        16/10/2006 madiyar - отбрасываем казпочтовые кредиты
        12/04/2007 madiyar - убрал лишние комиссии, подкорректировал расчет оставшихся
        02/10/2007 madiyar - поправил расчет полученных процентов
        04/01/2008 madiyar - если на дату портфель пустой, то создаем хотя бы одну пустую запись, чтобы не скривился отчет
        07/02/2008 madiyar - изменения в отчете
        11/02/2008 madiyar - поправка на сторно по штрафам
*/  


def shared var g-ofc as char.
def shared var g-today as date.

def var v-sumc as deci no-undo.

{pk0.i}

def shared var suma as decimal no-undo.

define var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

/*
define shared var s-credtype as char no-undo.
*/
define shared var krport as deci no-undo extent 4.
define shared var krportp as deci no-undo extent 4.
define shared var krprov as deci no-undo extent 4.
define shared var krprovp as deci no-undo extent 4.
define shared var dates as date no-undo extent 4.

function glsum returns decimal (input v-gl as integer, input v-dat as date, input v-crc as integer).
    def var v-sum as decimal no-undo init 0.
    find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = v-crc and txb.glday.gdt < v-dat no-lock no-error.
    if avail txb.glday then v-sum = txb.glday.dam - txb.glday.cam.
    return (v-sum).
end function.

function glsumallcrc returns decimal (input v-gl as integer, input v-dat as date).
    def var v-sum as decimal no-undo init 0.
    def var v-sum1 as decimal no-undo init 0.
    for each txb.crc no-lock:
      v-sum1 = 0.
      find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = crc.crc and txb.glday.gdt < v-dat no-lock no-error.
      if avail txb.glday then v-sum1 = txb.glday.dam - txb.glday.cam.
      if v-sum1 > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.regdt < v-dat no-lock no-error.
        v-sum = v-sum + v-sum1 * txb.crchis.rate[1].
      end.
    end.
    return (v-sum).
end function.

def buffer b-crchis for txb.crchis.
def var rat as decimal no-undo.
def var long as int no-undo init 0.
def new shared var bilance as decimal format "->,>>>,>>>,>>9.99".
def var bilance1 as decimal format "->,>>>,>>>,>>9.99".
def var prosr_od as deci no-undo.
def var dlong as date no-undo.
def var srok as deci no-undo.
def var v-sum as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-sumt as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-grp as inte no-undo.
def var i as inte no-undo.
def var dat as date no-undo.
def var dat_wrk as date no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var dayc1 as inte no-undo.
def var dayc2 as inte no-undo.
def var v-am2 as decimal no-undo init 0. 
def var tempgrp as int no-undo.
def var n as integer no-undo.

def var v-rate as decimal no-undo.
def var msumma as decimal no-undo extent 10.
def var mcount as integer no-undo extent 5.
def var komiss as deci no-undo.
def var mprov as deci no-undo.
def var dat2 as date no-undo.

def var mval1 as decimal no-undo.
def var mnum1 as integer no-undo.
def var pogdt as date.
def var mval2 as decimal no-undo extent 6.
def var mnum2 as integer no-undo extent 4.
def var mval3 as decimal no-undo extent 8.
def var mesa as integer.

def var vyear as inte no-undo.
def var vmonth as inte no-undo.
def var vday as inte no-undo.
def var mdays as inte no-undo.

def var scom as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal2 as deci no-undo.

def shared temp-table wrk no-undo
    field bank   as char
    field datot  like txb.lon.rdt
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field name   like txb.cif.name
    field plan   like txb.lon.plan
    field sts    as   char
    field grp    like txb.lon.grp
    field amoun  as decimal 
    field balans as decimal 
    field balans1 as decimal 
    field balans2 as decimal 
    field balans3 as decimal 
    field crc    as integer
    field prem   as decimal 
    field proc   as decimal 
    field duedt  as date
    field rez    as decimal 
    field rez1   as decimal 
    field rez2   as decimal 
    field srez   as decimal 
    field peni   as decimal 
    field penires  as decimal 
    field daymax as inte
    field zalog  as decimal 
    field srok   as deci
    index main is primary datot desc bank cif lon.

def shared temp-table wrkrep no-undo
    field m-table as integer
    field m-row as integer
    field m-values as deci extent 4
    index ind is primary m-table m-row.

def buffer b-jl for txb.jl.

do i = 1 to 4:
 
 dat = dates[i].
 
 find last txb.cls where txb.cls.whn < dat and txb.cls.del no-lock no-error. /* последний рабочий день перед dat */
 if avail txb.cls then dat_wrk = txb.cls.whn.
 else dat_wrk = dat - 1.
 
 krportp[i] = krportp[i] + glsumallcrc(141120,dat) + glsumallcrc(141720,dat) + glsumallcrc(142420,dat).
 krprovp[i] = krprovp[i] - glsum(146520,dat,1) - glsum(142820,dat,1).
 
 krport[i] = krport[i] + glsumallcrc(141120,dat) + glsumallcrc(141720,dat) + glsumallcrc(142420,dat) + glsumallcrc(141110,dat) + glsumallcrc(141710,dat) + glsumallcrc(142410,dat).
 krprov[i] = krprov[i] - glsum(146520,dat,1) - glsum(142820,dat,1) - glsum(146510,dat,1) - glsum(142810,dat,1).
 
 msumma = 0. mcount = 0.
 mval1 = 0. mnum1 = 0.
 mval2 = 0. mnum2 = 0.
 mval3 = 0.
 mesa = 0.
 
 /*
 vmonth = month(dat) - 1.
 vyear = year(dat).
 if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
 dat2 = date(vmonth,1,vyear).
 */
 if  i < 4 then dat2 = dates[i + 1]. else do:
     vmonth = month(dat) - 1.
     vyear = year(dat).
     if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
     dat2 = date(vmonth,1,vyear).
 end.
 
 for each txb.lon where txb.lon.grp = 90 or txb.lon.grp = 92 no-lock:
    
    if lon.opnamt <= 0 then next.
    if lon.rdt >= dat then next.
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
    if not avail pkanketa then next.
    
    find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
    if not avail txb.lnscg then next.
    
    if pkanketa.docdt < dat then do:
        
        /* выдано кредитов */
        if pkanketa.crc = 1 then v-rate = 1.
        else do:
          find last txb.crchis where txb.crchis.crc = pkanketa.crc and txb.crchis.regdt <= pkanketa.docdt no-lock no-error.
          v-rate = txb.crchis.rate[1].
        end.
        msumma[1] = msumma[1] + pkanketa.summa * v-rate.
        mcount[1] = mcount[1] + 1.
        if pkanketa.docdt >= dat2 then do:
           msumma[2] = msumma[2] + pkanketa.summa * v-rate.
           mcount[2] = mcount[2] + 1.
        end.
        
        /* комиссии */
        
        for each txb.jl where /*txb.jl.sub = 'cif' and*/ txb.jl.acc = pkanketa.aaa and txb.jl.dc = 'D' and txb.jl.jdt < dat no-lock:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
            if b-jl.gl = 460712 then do:
                msumma[9] = msumma[9] + txb.jl.dam. /* обслуживание счета */
                if txb.jl.jdt >= dat2 then msumma[10] = msumma[10] + txb.jl.dam.
            end.
        end.
        msumma[4] = msumma[4] + pkanketa.sumcom. /* фонд */
        if pkanketa.docdt >= dat2 then msumma[6] = msumma[6] + pkanketa.sumcom. /* фонд */
       
    end. /* if pkanketa.docdt < dat */
    
    /* Кредиты с законченным сроком действия договора */
    if pkanketa.duedt < dat then do:
        
        run lonbalcrc_txb('lon',txb.lon.lon,dat,"1,7",no,txb.lon.crc,output bilance). /* остаток ОД */
        if bilance > 0 then do:
          if pkanketa.crc = 1 then v-rate = 1.
          else do:
            find last txb.crchis where txb.crchis.crc = pkanketa.crc and txb.crchis.regdt <= pkanketa.docdt no-lock no-error.
            v-rate = txb.crchis.rate[1].
          end.
          mval1 = mval1 + bilance * v-rate.
          mnum1 = mnum1 + 1.
        end.
        
    end. /* if pkanketa.lon <> "" and pkanketa.duedt < dat */
    
    /* динамика роста погашенных кредитов */
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"14",no,txb.lon.crc,output mprov).
    if mprov > 0 then do:
      mval2[5] = mval2[5] + mprov.
      run lonbalcrc_txb('lon',txb.lon.lon,dat2,"14",no,txb.lon.crc,output komiss).
      if mprov - komiss > 0 then mval2[6] = mval2[6] + mprov - komiss.
    end.
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"1,7",no,txb.lon.crc,output bilance).
    if pkanketa.docdt < dat then do:
      mval2[1] = mval2[1] + pkanketa.summa - bilance.
      if bilance = 0 then  mnum2[1] = mnum2[1] + 1.
      bilance1 = bilance.
      run lonbalcrc_txb('lon',txb.lon.lon,dat,"13",no,txb.lon.crc,output mprov).
      if mprov > 0 then do: mnum2[2] = mnum2[2] + 1. mval2[2] = mval2[2] + mprov. end.

      run lonbalcrc_txb('lon',txb.lon.lon,dat2,"1,7",no,txb.lon.crc,output bilance).
      if bilance > 0 or pkanketa.docdt >= dat2 then do:
        if bilance1 = 0 then mnum2[3] = mnum2[3] + 1.
        if bilance > 0 then mval2[3] = mval2[3] + bilance - bilance1.
        if bilance = 0 and pkanketa.docdt >= dat2  then mval2[3] = mval2[3] + pkanketa.summa - bilance1. /*если на начало и конец периода bilance = 0 , то погшена вся сумма*/
/*        if bilance = 0 and bilance1 > 0 and pkanketa.docdt >= dat2  then mval2[3] = mval2[3] + pkanketa.summa - bilance1. */
        run lonbalcrc_txb('lon',txb.lon.lon,dat,"13",no,txb.lon.crc,output komiss).
        if mprov - komiss > 0 then do: mnum2[4] = mnum2[4] + 1. mval2[4] = mval2[4] + mprov - komiss. end.
      end.
      
    end.
    
    /* Портфель по БД */
    /* начисленные %% */
    /*
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                              and txb.histrxbal.level = 2
                              and txb.histrxbal.dt < dat and txb.histrxbal.crc = txb.lon.crc no-lock no-error.
    if avail txb.histrxbal then mval3[1] = mval3[1] + txb.histrxbal.dam.
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                              and txb.histrxbal.level = 2
                              and txb.histrxbal.dt < dat2 and txb.histrxbal.crc = txb.lon.crc no-lock no-error.
    if avail txb.histrxbal then mval3[2] = mval3[2] + txb.histrxbal.dam.
    */
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 11
                                  and txb.histrxbal.dt < dat and txb.histrxbal.crc = txb.lon.crc no-lock no-error.
    if avail txb.histrxbal then mval3[1] = mval3[1] + txb.histrxbal.cam.
    
    if not(day(dat2) = 1 and month(dat2) = 1) then do:
        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 11
                                      and txb.histrxbal.dt < dat2 and txb.histrxbal.crc = txb.lon.crc no-lock no-error.
        if avail txb.histrxbal then mval3[2] = mval3[2] + txb.histrxbal.cam.
    end.
    

    /* погашенные %% */
    /*
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < dat no-lock:
      if txb.lnsci.flp > 0 then do: 
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsci.idat no-lock no-error.
        mval3[3] = mval3[3] + txb.lnsci.paid-iv * txb.crchis.rate[1].
        if txb.lnsci.idat >= dat2 then mval3[4] = mval3[4] + txb.lnsci.paid-iv * txb.crchis.rate[1].
      end.
    end.
    */
    
    /* на дату */
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"12",no,1,output v-bal).
    v-bal = - v-bal.
    mval3[3] = mval3[3] + v-bal.
    /* за период */
    if not(day(dat2) = 1 and month(dat2) = 1) then do:
      run lonbalcrc_txb('lon',txb.lon.lon,dat2,"12",no,1,output v-bal2).
      v-bal2 = - v-bal2.
    end.
    else v-bal2 = 0.
    if v-bal - v-bal2 > 0 then mval3[4] = mval3[4] + v-bal - v-bal2.
    
    
    /* штрафы начисленные и полученные на дату */
    
    /* начисленные штрафы */
    
    /*
    if dat < 01/07/04 then find last txb.hislon where txb.hislon.lon = pkanketa.lon and txb.hislon.fdt < 01/07/04 no-lock no-error.
    else find last txb.hislon where txb.hislon.lon = pkanketa.lon and txb.hislon.fdt < dat no-lock no-error.
    if avail txb.hislon then mval3[5] = mval3[5] + txb.hislon.tdam[3].
    */
    
    /* полученные штрафы - обороты по 16 уровню по кредиту до заданной даты */
    
    /*
    for each txb.lonres where txb.lonres.lon = pkanketa.lon and txb.lonres.lev = 16 and txb.lonres.dc = "c" and txb.lonres.jdt < dat no-lock:
      mval3[6] = mval3[6] + txb.lonres.amt.
      if txb.lonres.jdt >= dat2 then mval3[7] = mval3[7] + txb.lonres.amt.
    end.
    */
    
    /*
    for each txb.lonres where txb.lonres.lon = pkanketa.lon and txb.lonres.lev = 16 and txb.lonres.jdt < dat no-lock:
        if txb.lonres.dc = "c" then do:
            mval3[6] = mval3[6] + txb.lonres.amt.
            if txb.lonres.jdt >= dat2 then mval3[7] = mval3[7] + txb.lonres.amt.
        end.
        else do:
            mval3[5] = mval3[5] + txb.lonres.amt. 
        end.
    end.
    */
    
    v-bal = 0. v-bal2 = 0.
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 16
                                  and txb.histrxbal.dt < dat and txb.histrxbal.crc = 1 no-lock no-error.
    if avail txb.histrxbal then do:
        mval3[5] = mval3[5] + txb.histrxbal.dam.
        mval3[7] = mval3[7] + txb.histrxbal.cam.
        v-bal = txb.histrxbal.dam.
        v-bal2 = txb.histrxbal.cam.
    end.
    
    mval3[6] = mval3[6] + v-bal.
    mval3[8] = mval3[8] + v-bal2.
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 16
                                  and txb.histrxbal.dt < dat2 and txb.histrxbal.crc = 1 no-lock no-error.
    if avail txb.histrxbal then do:
        mval3[6] = mval3[6] - txb.histrxbal.dam.
        mval3[8] = mval3[8] - txb.histrxbal.cam.
    end.
    
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"1,7",no,txb.lon.crc,output bilance). /* остаток  ОД*/
    
    if bilance > 0 then do:
      
      find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
      find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
      
      dlong = txb.lon.duedt.
      if txb.lon.ddt[5] <> ? and txb.lon.ddt[5] < dat then dlong = txb.lon.ddt[5].
      if txb.lon.cdt[5] <> ? and txb.lon.cdt[5] < dat then dlong = txb.lon.cdt[5].
      
      /**/
      find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
      
      create wrk.
      assign wrk.bank = s-ourbank
             wrk.datot = dat
             wrk.cif = txb.lon.cif
             wrk.lon = txb.lon.lon
             wrk.name = txb.cif.name
             wrk.plan = txb.lon.plan
             wrk.sts = txb.sub-cod.ccode
             wrk.grp = txb.lon.grp
             wrk.amoun = txb.lon.opnamt
             wrk.balans = bilance
             wrk.crc = txb.lon.crc
             wrk.duedt = dlong
             wrk.zalog = v-sum
             wrk.srok = dlong - dat
             wrk.rez = 0
             wrk.srez = 0.
      
      /* просрочка ОД */
      run lonbalcrc_txb('lon', txb.lon.lon, dat, "7", no, txb.lon.crc, output prosr_od).
      
      v-am2 = 0.
      
      /* расчет начисленной суммы на заданную дату */
      /* расчет просроченных процентов для 3 и 4 схем - разные */
      
      run lonbalcrc_txb('lon',txb.lon.lon,dat,"9",no,txb.lon.crc,output v-am2).
      
      /* дней просрочки */
      dayc1 = 0. dayc2 = 0.
      run lndayspr_txb(txb.lon.lon,dat,no,output dayc1,output dayc2).
      
      if dayc1 > dayc2 then wrk.daymax = dayc1.
                       else wrk.daymax = dayc2.
      
      find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dat no-lock no-error.
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
      if avail txb.lonstat then wrk.rez1 = txb.lonstat.prc.
      
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= dat no-lock no-error.
      if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
      
      run lonbalcrc_txb('lon',txb.lon.lon,dat,"3,6",no,1,output wrk.srez). /* фактически сформированные провизии */
      wrk.srez = - wrk.srez.
      
    end. /* bilance > 0 */
    
    mesa = mesa + 1.
    hide message no-pause.
    message " " s-ourbank " - " i " - " mesa " ".
    
 end. /* for each lon */
 
 /* если на дату портфель пустой, то создаем хотя бы одну пустую запись, чтобы не скривился отчет */
 find first wrk where wrk.datot = dat no-lock no-error.
 if not avail wrk then do:
     create wrk.
     assign wrk.bank = s-ourbank
            wrk.datot = dat
            wrk.cif = ''
            wrk.lon = ''.
 end.
 
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mcount[1].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mcount[2].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 3.
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[1].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 4.
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[2].
 /*
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 3. -- за выдачу на дату --
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[3].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 4. -- за выдачу за период --
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[5].
 */
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 1. /* фс */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[4].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 2. /* фс */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[6].
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 7. /* за обслуживание кредита */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[9].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 8. /* за обслуживание кредита */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[10].
 
 /*
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 9. -- обнал --
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[7].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 10. -- обнал --
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[8].
 */
 
 find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum1.
 find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval1.
 
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[1].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[2].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 3.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[3].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 4.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[4].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 5.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[1].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 6.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[2].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 7.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[3].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 8.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[4].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 15.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[5].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 16.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[6].
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 11.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[1].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 12.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[1] - mval3[2].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 13.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[3].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 14.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[4].
 
 
 v-sumc = 0.
 for each txb.jl where txb.jl.gl = 490000 and jl.jdt >= dat2 and jl.jdt < dat and jl.dc = 'd' no-lock:
     v-sumc = v-sumc + txb.jl.dam.
 end.
 
 mval3[5] = mval3[5] - v-sumc.
 mval3[6] = mval3[6] - v-sumc.
 mval3[7] = mval3[7] - v-sumc.
 mval3[8] = mval3[8] - v-sumc.
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 17.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[5].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 18.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[6].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 19.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[7].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 20.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[8].

end. /* do i = 1 to 4 */

