/* lndyndoh1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Показатели и динамика доходности кредитного портфеля
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
        30/06/2005 madiar
 * BASES
        bank, comm, txb
 * CHANGES
        05/07/2005 madiyar - 11 и 12 уровни - в тенге, исправил расчет сумм
        06/07/2005 madiyar - при выборе консолидированного отчета данные не накапливались, сохранялся только последний филиал - исправил
        08/07/2005 madiyar - отчет формируется на 7 дат, для расчета изменения на 6-ую дату
        02/08/2005 madiyar - на 7-ую дату не рассчитывался портфель, исправил
        15/08/2005 madiyar - сбор сумм не по lon-ам, а по ГК; добавились комиссии
        01/09/2005 madiyar - для физ.лиц были указаны счета юр.лиц; исправил
        02/02/2006 madiyar - расчет динамики начисленных процентов - по оборотам по счетам 174010 и 174020
        03/02/2006 madiyar - расчет динамики полученных процентов и динмики полученных комиссий - также по оборотам
        17/09/2006 Natalya D. - оптимизация: повторяющиеся запросы вывела в один, убрала жескую привязку к индексу
                                а период вывела в цикл по периоду, нужный индекс цепляется.
        06/04/2007 madiyar - no-undo
        17/11/2009 galina - изменения согласно ТЗ 579 от 09/11/2009
        11/01/2010 galina - убрала проверку на 1 января
        12/01/2010 galina - берем пеню из vals
        05/02/2010 galina - берем начисленный % из vals
        25/02/2010 galina - собираем полученные комиссии и %% из проводок
*/

function glsum returns decimal (input v-gl as integer, input v-dat as date, input v-crc as integer, input v-fact as integer, input v-cred as logical).
    def var v-sum as decimal init 0.
    find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = v-crc and txb.glday.gdt < v-dat no-lock no-error.
    if avail txb.glday then
       if v-cred then v-sum = txb.glday.cam.
       else v-sum = txb.glday.dam - txb.glday.cam.
    return (v-sum * v-fact).
end function.

function glsumallcrcd returns decimal (input v-gl as integer, input v-dat as date, input v-fact as integer).
    def var v-sum as decimal init 0.
    def var v-sum1 as decimal init 0.
    for each txb.crc no-lock:
      v-sum1 = 0.
      find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = crc.crc and txb.glday.gdt < v-dat no-lock no-error.
      if avail txb.glday then v-sum1 = txb.glday.dam. /* - txb.glday.cam.*/
      if v-sum1 > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < v-dat no-lock no-error.

        v-sum = v-sum + v-sum1 * txb.crchis.rate[1].
      end.
    end.
    return (v-sum * v-fact).
end function.

function glsumallcrc returns decimal (input v-gl as integer, input v-dat as date, input v-fact as integer).
    def var v-sum as decimal init 0.
    def var v-sum1 as decimal init 0.
    for each txb.crc no-lock:
      v-sum1 = 0.
      find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = crc.crc and txb.glday.gdt < v-dat no-lock no-error.
      if avail txb.glday then v-sum1 = txb.glday.dam - txb.glday.cam.
      if v-sum1 > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < v-dat no-lock no-error.

        v-sum = v-sum + v-sum1 * txb.crchis.rate[1].
      end.
    end.
    return (v-sum * v-fact).
end function.

function get_value returns deci (pbank as char, pdt as date, pcode as integer).
    find first vals where vals.bank = pbank and vals.code = pcode and vals.dt = pdt no-lock no-error.
    if avail vals then return (vals.deval).
    else return (0). 
end function.

def var v-bank as char no-undo.
v-bank = ''.
find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if avail txb.sysc then v-bank = txb.sysc.chval.  

def shared temp-table  wrk no-undo
    field idt      as   integer
    field idr      as   integer
    field rtitle   as   char
    field rval     as   deci extent 7
    index ind is primary idt idr.

def shared var dates as date extent 7.
def shared var port_ur as decimal extent 7.
def shared var port_fiz as decimal extent 7.
def var dat as date no-undo.
def var dat_prev as date no-undo.
def var i as integer no-undo.
def var k as integer no-undo.
def var rates as deci no-undo extent 20.

def var vvalues as deci no-undo extent 12.
def var vsum as deci no-undo extent 6.
def var v-5sum1 as deci no-undo.
def var v-5sum2 as deci no-undo.
def var d as date no-undo.
def var v-pen_pog as deci no-undo.
def var v-pen_nach as deci no-undo.
def var v-pen_pogur as deci no-undo.
def var v-pen_nachur as deci no-undo.
def var v-bal16 as deci no-undo.
def buffer b-jl for txb.jl.
find first txb.cmp no-lock no-error.

def var v-prcpayur as deci no-undo.
def var v-compayur  as deci no-undo.
def var v-prcpayfiz  as deci no-undo.
def var v-compayfiz  as deci no-undo.

hide message no-pause.
message ' Обработка ' + txb.cmp.name + ' '.

do i = 1 to 7:
  v-5sum1 = 0. v-5sum2 = 0.
  dat = dates[i].
  if i = 7 then dat_prev = date(month(dat - 1),1,year(dat - 1)).
  else dat_prev = dates[i + 1].  

  find first wrk where wrk.idt = 0 and wrk.idr = 0.
  wrk.rval[i] = wrk.rval[i] + glsumallcrc(141110,dat,1) + glsumallcrc(141710,dat,1) + glsumallcrc(142410,dat,1).
  port_ur[i] = wrk.rval[i].
  find first wrk where wrk.idt = 1 and wrk.idr = 0.
  wrk.rval[i] = wrk.rval[i] + glsumallcrc(141120,dat,1) + glsumallcrc(141720,dat,1) + glsumallcrc(142420,dat,1).
  port_fiz[i] =  wrk.rval[i].
  find first wrk where wrk.idt = 2 and wrk.idr = 0.
  wrk.rval[i] = port_ur[i] + port_fiz[i].

  vvalues = 0.
 /* do d = dat_prev to dat - 1 : 
  for each txb.jl where txb.jl.jdt = d /*< dat and txb.jl.jdt >= dat_prev*/ and txb.jl.dc = 'd' and txb.jl.crc = 2 no-lock /*use-index jdtdcgl*/ :
    
    find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
    if avail txb.crchis then do:
        if lookup(string(txb.jl.gl),"174010,174110,174091,174093") > 0 then v-5sum1 = v-5sum1 + txb.jl.dam * txb.crchis.rate[1].
       
        if lookup(string(txb.jl.gl),"174020,174120,174092,174094") > 0 then v-5sum2 = v-5sum2 + txb.jl.dam * txb.crchis.rate[1].         
    end.
    else message " Не найден курс! " view-as alert-box buttons ok.
  end.
  end.  
  find first wrk where wrk.idt = 0 and wrk.idr = 2.
       wrk.rval[i] = wrk.rval[i] + v-5sum1.
       vvalues[2] = vvalues[2] + wrk.rval[i].
  find first wrk where wrk.idt = 1 and wrk.idr = 2.
       wrk.rval[i] = wrk.rval[i] + v-5sum2.
       vvalues[2] = vvalues[2] + wrk.rval[i].*/

  /*find first wrk where wrk.idt = 0 and wrk.idr = 4.
  
  wrk.rval[i] = wrk.rval[i] + glsum(441160,dat,1,-1,no) - glsum(441160,dat_prev,1,-1,no) + glsum(441760,dat,1,-1,no) - glsum(441760,dat_prev,1,-1,no). /*полученные % за период*/
  vvalues[4] = vvalues[4] + wrk.rval[i].*/

  /*find first wrk where wrk.idt = 1 and wrk.idr = 4.
  
  wrk.rval[i] = wrk.rval[i] + glsum(441170,dat,1,-1,no) - glsum(441170,dat_prev,1,-1,no) + glsum(441770,dat,1,-1,no) - glsum(441770,dat_prev,1,-1,no). /*полученные % за период*/
  vvalues[4] = vvalues[4] + wrk.rval[i].

  find first wrk where wrk.idt = 0 and wrk.idr = 6.
 
  wrk.rval[i] = wrk.rval[i] + glsum(442910,dat,1,-1,no) - glsum(442910,dat_prev,1,-1,no).
  vvalues[6] = vvalues[6] + wrk.rval[i].

  find first wrk where wrk.idt = 1 and wrk.idr = 6.
 
  wrk.rval[i] = wrk.rval[i] + glsum(442920,dat,1,-1,no) - glsum(442920,dat_prev,1,-1,no) + glsum(442900,dat,1,-1,no) - glsum(442900,dat_prev,1,-1,no) .
  vvalues[6] = vvalues[6] + wrk.rval[i].*/

  /*if not(day(dat) = 1 and month(dat) = 1) then do:*/ /* не 1-ое января */
    
    find first wrk where wrk.idt = 0 and wrk.idr = 1.
    /*wrk.rval[i] = wrk.rval[i] + glsumallcrcd(174010,dat,1) + glsumallcrcd(174110,dat,1) + glsumallcrcd(174091,dat,1) + glsumallcrcd(174093,dat,1).  начисленные % */
    wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,101).
    vvalues[1] = vvalues[1] + wrk.rval[i].
/*    find first wrk where wrk.idt = 0 and wrk.idr = 3.
    wrk.rval[i] = wrk.rval[i] + glsum(441160,dat,1,-1,no) + glsum(441760,dat,1,-1,no). /* полученные % */
    vvalues[3] = vvalues[3] + wrk.rval[i].
    
    find first wrk where wrk.idt = 0 and wrk.idr = 5.
    wrk.rval[i] = wrk.rval[i] + glsum(442910,dat,1,-1,no). /*- vsum[1].  полученные комиссии */
    vvalues[5] = vvalues[5] + wrk.rval[i].*/

    find first wrk where wrk.idt = 1 and wrk.idr = 1.
    /*wrk.rval[i] = wrk.rval[i] + glsumallcrcd(174020,dat,1) + glsumallcrcd(174120,dat,1) + glsumallcrcd(174092,dat,1) + glsumallcrcd(174094,dat,1).  начисленные % */
    wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,102).
    vvalues[1] = vvalues[1] + wrk.rval[i].
/*    find first wrk where wrk.idt = 1 and wrk.idr = 3.
    wrk.rval[i] = wrk.rval[i] + glsum(441170,dat,1,-1,no) + glsum(441770,dat,1,-1,no).  /*полученные % */
    vvalues[3] = vvalues[3] + wrk.rval[i].
    
    find first wrk where wrk.idt = 1 and wrk.idr = 5.
    wrk.rval[i] = wrk.rval[i] + glsum(442920,dat,1,-1,no) + glsum(442900,dat,1,-1,no). /*- vsum[2].  полученные комиссии */
    vvalues[5] = vvalues[5] + wrk.rval[i].*/
    
    find first wrk where wrk.idt = 0 and wrk.idr = 2.
    /*wrk.rval[i] = wrk.rval[i] + (glsumallcrcd(174010,dat,1) + glsumallcrcd(174110,dat,1) + glsumallcrcd(174091,dat,1) + glsumallcrcd(174093,dat,1)) - (glsumallcrcd(174010,dat_prev,1) + glsumallcrcd(174110,dat_prev,1) + glsumallcrcd(174091,dat_prev,1) + glsumallcrcd(174093,dat_prev,1)).  начисленные % за период */.
    wrk.rval[i] = wrk.rval[i] + (get_value(v-bank, dat,101) - get_value(v-bank, dat_prev,101)).
    vvalues[2] = vvalues[2] + wrk.rval[i].
    find first wrk where wrk.idt = 1 and wrk.idr = 2.
    /*wrk.rval[i] = wrk.rval[i] + (glsumallcrcd(174020,dat,1) + glsumallcrcd(174120,dat,1) + glsumallcrcd(174092,dat,1) + glsumallcrcd(174094,dat,1)) - (glsumallcrcd(174020,dat_prev,1) + glsumallcrcd(174120,dat_prev,1) + glsumallcrcd(174092,dat_prev,1) + glsumallcrcd(174094,dat_prev,1)).  начисленные % за период*/.
    wrk.rval[i] = wrk.rval[i] + (get_value(v-bank, dat,102) - get_value(v-bank, dat_prev,102)).
    vvalues[2] = vvalues[2] + wrk.rval[i].

    /*if get_value(v-bank, dat,119) > 0 and get_value(v-bank, dat,120) > 0 and get_value(v-bank, dat,129) > 0 and get_value(v-bank, dat,128) > 0 then do:*/
       find first wrk where wrk.idt = 0 and wrk.idr = 7.
       wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,119).
       vvalues[7] = vvalues[7] + wrk.rval[i].
       
       find first wrk where wrk.idt = 1 and wrk.idr = 7.
       wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,120).
       vvalues[7] = vvalues[7] + wrk.rval[i].
       
       find first wrk where wrk.idt = 0 and wrk.idr = 9.
       wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,128).
       vvalues[9] = vvalues[9] + wrk.rval[i].
       

       find first wrk where wrk.idt = 1 and wrk.idr = 9.
       wrk.rval[i] = wrk.rval[i] + get_value(v-bank, dat,129).
       vvalues[9] = vvalues[9] + wrk.rval[i].

    /*end.*/
    /*else do:
       
       
       v-pen_pog = 0.
       v-pen_nach = 0.
       v-pen_pogur = 0.
       v-pen_nachur = 0.
       for each txb.lon no-lock break by txb.lon.cif:
    
        if txb.lon.opnamt <= 0 then next.
        if txb.lon.rdt >= dat then next. /* пропускаем все кредиты, выданные с v-dt и позже */
        run lonbalcrc_txb('lon',txb.lon.lon,dat,"16",no,1,output v-bal16).
        /*v-pen_pog = 0.*/
        for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' /*and txb.jl.jdt >= dat_prev*/ and txb.jl.jdt < dat and txb.jl.lev = 16 no-lock:
           find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
           if b-jl.sub = 'CIF' then do: /* погашение пени со счета */
             if (substring(string(txb.lon.gl),5,1) = '1') then v-pen_pogur = v-pen_pogur + txb.jl.cam.
             else v-pen_pog = v-pen_pog + txb.jl.cam.
           end.
           else do: /* учет списываемой пени (чтобы не было отрицательных сумм в динамике) */
             if (substring(string(txb.lon.gl),5,1) = '1') then v-pen_nachur = v-pen_nachur + txb.jl.cam.
             else v-pen_nach = v-pen_nach + txb.jl.cam.
           end.
        end.
        if (substring(string(txb.lon.gl),5,1) = '1') then v-pen_nachur = v-pen_nachur + v-bal16. 
        else v-pen_nach = v-pen_nach + v-bal16. 
      end.
      v-pen_nach = v-pen_nach + v-pen_pog.
      v-pen_nachur = v-pen_nachur + v-pen_pogur.
      
      find first wrk where wrk.idt = 0 and wrk.idr = 7.
      wrk.rval[i] = wrk.rval[i] + v-pen_nachur.
      vvalues[7] = vvalues[7] + wrk.rval[i].
       
      find first wrk where wrk.idt = 1 and wrk.idr = 7.
      wrk.rval[i] = wrk.rval[i] + v-pen_nach.
      vvalues[7] = vvalues[7] + wrk.rval[i].
       
      find first wrk where wrk.idt = 0 and wrk.idr = 9.
      wrk.rval[i] = wrk.rval[i] + v-pen_pogur.
      vvalues[9] = vvalues[9] + wrk.rval[i].

      find first wrk where wrk.idt = 1 and wrk.idr = 9.
      wrk.rval[i] = wrk.rval[i] + v-pen_pog.
      vvalues[9] = vvalues[9] + wrk.rval[i].
    end.*/
  /* end. */ /* не 1-ое января */

    v-prcpayur = 0.
    v-compayur = 0.
    v-prcpayfiz = 0.
    v-compayfiz = 0.

    for each txb.lon no-lock break by txb.lon.cif:
    
        if txb.lon.opnamt <= 0 then next.
        if txb.lon.rdt >= dat then next. /* пропускаем все кредиты, выданные с v-dt и позже */
        
        
        for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' and txb.jl.jdt < dat and (txb.jl.lev = 2 or txb.jl.lev = 9) no-lock:
           find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
           if not avail txb.jh then next.
           if txb.jh.party begins 'Storn' then next.
           find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
           if not avail b-jl then next.
           if b-jl.sub = 'CIF' then do: 
             if (substring(string(txb.lon.gl),5,1) = '1') then v-prcpayur = v-prcpayur + txb.jl.cam.
             else v-prcpayfiz = v-prcpayfiz + txb.jl.cam.
           end.
        end.
        
        for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' and txb.jl.jdt < dat no-lock:
            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if not avail txb.jh then next.
            if txb.jh.party begins 'Storn' then next.
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
            if not avail b-jl then next.
            if b-jl.gl = 460712 then do:
             if (substring(string(txb.lon.gl),5,1) = '1') then v-compayur = v-compayur + txb.jl.dam.
             else v-compayfiz = v-compayfiz + txb.jl.dam.        
            end.
            

        end.
        
    end.

    find first wrk where wrk.idt = 0 and wrk.idr = 3.
    wrk.rval[i] = wrk.rval[i] + v-prcpayur. /* полученные % */
    vvalues[3] = vvalues[3] + wrk.rval[i].
    
    find first wrk where wrk.idt = 0 and wrk.idr = 5.
    wrk.rval[i] = wrk.rval[i] + v-compayur. /*- vsum[1].  полученные комиссии */
    vvalues[5] = vvalues[5] + wrk.rval[i].
    
    find first wrk where wrk.idt = 1 and wrk.idr = 3.
    wrk.rval[i] = wrk.rval[i] + v-prcpayfiz.  /*полученные % */
    vvalues[3] = vvalues[3] + wrk.rval[i].
    
    find first wrk where wrk.idt = 1 and wrk.idr = 5.
    wrk.rval[i] = wrk.rval[i] + v-compayfiz. /*- vsum[2].  полученные комиссии */
    vvalues[5] = vvalues[5] + wrk.rval[i].
    

  do k = 1 to 12:
    find first wrk where wrk.idt = 2 and wrk.idr = k.
    wrk.rval[i] = vvalues[k].
  end.
  
end. /* do i = 1 to 7 */
