/* prod-lon.p
 * MODULE
        Доходы-расходы в разрезе продуктов (кредиты)
 * DESCRIPTION
        Доходы-расходы в разрезе продуктов (кредиты)
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
        06/10/2006 madiyar
 * CHANGES
        13/10/2006 madiyar - добавил данные за период с начала года, убрал промежуточные итоги
        18/10/2006 madiyar - добавил данные по процентным доходам за период с начала года
        27/10/2006 madiyar - промежуточный вывод в файл для дебага
                             закомментил расчет комиссий за рассмотрение заявки
                             переделал расчет комиссий - фонд покрытия кредитных рисков
        30/10/2006 madiyar - исправил ошибки
        02/11/2006 madiyar - в заголовок отчета по конкретному департаменту добавил название департамента
*/

def shared var v-mon as integer no-undo.
def shared var v-god as integer no-undo.
def shared var v-report-type as integer. /* 1 - по срокам (ГК), 2 - сводный, 3 - по департаменту */
def shared var v-dep-code as char no-undo. /* если тип отчета 3, то в v-dep-code код департамента для отчета */

def var dd as integer no-undo.
def var p-dt1 as date no-undo. /* начало периода */
def var p-dt2 as date no-undo. /* конец периода */

def var ost-mon as decimal extent 12. /*массив средних значений по  месяцам*/
def var ost-mon7 as decimal extent 12. /*массив средних значений по  месяцам*/
def var v-bal_aver as decimal.
def var v-bal_aver7 as decimal.

run  mondays(v-mon,v-god,output dd).
p-dt1 = date(v-mon, 1, v-god).
p-dt2 = date(v-mon, dd, v-god).

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-bal as decimal no-undo.
def var v-baly as decimal no-undo.
def var v-balend as decimal no-undo.
def var v-bal7 as decimal no-undo.
def var v-bal7y as decimal no-undo.
def var v-balend7 as decimal no-undo.
def var v-accr1 as decimal no-undo.
def var v-accr2 as decimal no-undo.
def var v-pen as decimal no-undo.
def var vdt as date no-undo.
def var v-procn1 as decimal no-undo.
def var v-procn2 as decimal no-undo.
def var v-procp1 as decimal no-undo.
def var v-procp2 as decimal no-undo.
def var v-komiss as decimal no-undo.
def var months as char extent 12 init ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь","октябрь", "ноябрь", "декабрь"] no-undo.
def var v-urfiz as integer no-undo.
def var v-krdolg as integer no-undo.
def var v-prog as integer no-undo.
def var i as integer no-undo.
def var v-sum as deci no-undo extent 11.
def var v-sum1 as deci no-undo extent 11.
def var v-sum2 as deci no-undo extent 11.
def var v-sum3 as deci no-undo extent 11.

def var v-proglist as char extent 8.
v-proglist[1] = "Бизнес-кредиты".
v-proglist[2] = "Ипотека".
v-proglist[3] = "Ипотека сотрудникам".
v-proglist[4] = "Автокредиты".
v-proglist[5] = "Автокредиты сотрудникам".
v-proglist[6] = "Прочие кредиты".
v-proglist[7] = "Прочие кредиты сотрудникам".
v-proglist[8] = "Экспресс-кредиты".
def buffer bjl for jl.
def stream vcrpt.
def var v-dep as char no-undo.
def var v-bank as char no-undo.
def var dt_st as date no-undo.
def var dt_end as date no-undo.
def var v-segm as char no-undo.

def temp-table templon no-undo
    field urfiz   as integer
    field krdolg  as integer
    field dt as date /*1111*/
    field crc     like bank.crc.crc
    field gl      like gl.gl
    field prog    as integer
    field grp     as integer
    field segm    as char
    field dep     as char
    field bal     as decimal
    field baly    as decimal
    field balend  as decimal
    field bal7    as decimal
    field bal7y   as decimal
    field balend7 as decimal
    field accr    as decimal
    field proc    as decimal
    field procy   as decimal
    field pen     as decimal
    field komiss  as decimal
index idx is primary grp segm crc dep
index idx2 urfiz krdolg crc prog gl dt.

def var sumbal as decimal no-undo.
def var sumbaly as decimal no-undo.
def var sumaccr as decimal no-undo.
def var sumbal7 as decimal no-undo.
def var sumbal7y as decimal no-undo.
def var sumbalend as decimal no-undo.
def var sumbalend7 as decimal no-undo.
def var sumproc as decimal no-undo.
def var sumprocy as decimal no-undo.
def var sumpen as decimal no-undo.
def var sumcom as decimal no-undo.

def var v-day as integer.
def var v-dayy as integer.
v-day = p-dt2 - p-dt1 + 1.
v-dayy = p-dt2 - date(1,1,year(p-dt2)) + 1.

{getdep.i}

def var lst_ur as char no-undo init ''. /* группы кредитов юридических лиц */
def var lst_kr as char no-undo init ''. /* группы краткосрочных кредитов */
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
  if substr(string(longrp.stn),2,1) = '1' then do:
    if lst_kr <> '' then lst_kr = lst_kr + ','.
    lst_kr = lst_kr + string(longrp.longrp).
  end.
end.

find cmp no-lock no-error.
if avail cmp then v-bank = cmp.name.

for each trxbal no-lock where trxbal.sub = 'lon' and /* trxbal.acc = "004151279" and */
    (trxbal.lev = 1 or trxbal.lev = 7 or trxbal.lev = 11 or trxbal.lev = 12 or trxbal.lev = 16 or trxbal.lev = 6).
    v-bal = 0. v-baly = 0. v-balend = 0. v-procn1 = 0. v-procn2 = 0. v-pen = 0. v-dep = "".
    v-bal7 = 0. v-bal7y = 0. v-balend7 = 0. v-procp1 = 0. v-procp2 = 0.
    v-accr1 = 0. v-accr2 = 0 .
    /*
    v-bb = 0.
    */
    find first lon where lon.lon = trxbal.acc no-lock no-error.
    if not avail lon then next.
    /* if lon.gl <> 141120 and lon.gl <> 141720 then next.*/
    
    find last cif where cif.cif = lon.cif no-lock no-error.
    
    if lookup(string(lon.grp),lst_ur) > 0 then assign v-urfiz = 0 v-dep = '205'.
    else do:
      v-urfiz = 1.
      v-dep = getdep(lon.cif).
      if v-dep = '208' then v-dep = '207'. /* если кредит падает на операционку, то запихиваем его в ДПК */
    end.
    
    if v-report-type = 3 and v-dep <> v-dep-code then next. /* отчет по конкретному департаменту */
    
    if lookup(string(lon.grp),lst_kr) > 0 then v-krdolg = 0. else v-krdolg = 1.
    
    /*
    1 - бизнес кредиты
    2 - ипотека
    3 - ипотека сотрудникам
    4 - автокредиты
    5 - автокредиты сотрудникам
    6 - прочие кредиты
    7 - прочие кредиты сотрудникам
    8 - экспресс-кредитование
    */
    if v-report-type <> 1 then do:
      if lookup(string(lon.grp),"90,92") > 0 then v-prog = 8.
      else
      if lookup(string(lon.grp),"16,26,56,66") > 0 then v-prog = 1.
      else
      if lookup(string(lon.grp),"27,67") > 0 then v-prog = 2.
      else
      if lookup(string(lon.grp),"15,25,35,45,55,65") > 0 then v-prog = 4.
      else v-prog = 6.
      find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnsegm' no-lock no-error.
      if avail sub-cod and sub-cod.ccode = "02" then do:
        if v-prog = 2 then v-prog = 3.
        else if v-prog = 4 then v-prog = 5.
        else if v-prog = 6 then v-prog = 7.
      end.
    end.
    
    if trxbal.lev = 16 then assign dt_st = p-dt2 dt_end = p-dt2.
    else
    if trxbal.lev = 1 or trxbal.lev = 7 then assign dt_st = date(1,1,year(p-dt2)) dt_end = p-dt2.
    else assign dt_st = p-dt1 dt_end = p-dt2.
    
    /* комиссии */
    v-komiss = 0.
    if trxbal.lev = 1 then do:
       if lon.grp = 90 or lon.grp = 92 then do:
           find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
           if not avail pkanketa or pkanketa.credtype <> '6' then next.
           /* рассмотрение заявки */
           /*
           if pkanketa.rdt >= dt_st and pkanketa.rdt <= dt_end then do:
             find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'numpas' no-lock no-error.
             if avail pkanketh then do:
               if pkanketh.rescha[3] = '' then v-komiss = v-komiss + 300.
             end.
           end.
           */
           /* покрытие кредитных рисков */
           if lon.opnamt >= 0 and lon.rdt >= dt_st and lon.rdt <= dt_end then do:
             /*
             v-komiss = v-komiss + lon.opnamt * 0.05.
             */
             for each jl where jl.acc = lon.aaa and jl.dc = "D" and jl.jdt = lon.rdt and jl.lev = 1 no-lock:
               find first bjl where bjl.jh = jl.jh and bjl.ln = jl.ln + 1 no-lock no-error.
               if avail bjl and bjl.gl = 442900 then v-komiss = v-komiss + jl.dam.
             end.
           end.
           /* ведение текущего счета */
           for each jl where jl.acc = lon.aaa and jl.dc = 'D' and jl.jdt >= dt_st and jl.jdt <= dt_end and jl.lev = 1 use-index accdcjdt no-lock:
             find first bjl where bjl.jh = jl.jh and bjl.ln = jl.ln + 1 no-lock no-error.
             if avail bjl and bjl.gl = 460712 then v-komiss = v-komiss + jl.dam.
           end. 
       end.
       else do:
           for each lonres where lonres.lon = trxbal.acc and lonres.jdt >= dt_st and lonres.jdt <= dt_end and lonres.dc = 'C' no-lock:
             if lonres.lev = 27 then v-komiss = v-komiss + lonres.amt.
             else
             if lonres.lev = 25 or lonres.lev = 28 or lonres.lev = 29 then do:
               find last crchis where crchis.crc = lon.crc and crchis.regdt <= lonres.jdt no-lock no-error.
               v-komiss = v-komiss + lonres.amt * crchis.rate[1].
             end.
           end.
       end.
    end.

    do vdt = dt_st - 1 to dt_end: 
        v-bal = 0. v-balend = 0. v-procn1 = 0. v-procn2 = 0. v-pen = 0.
        v-bal7 = 0. v-balend7 = 0. v-procp1 = 0. v-procp2 = 0. v-accr1 = 0. v-accr2 = 0.

        find last histrxbal where histrxbal.acc = trxbal.acc and histrxbal.lev = trxbal.lev
                  and histrxbal.subled = trxbal.subled and histrxbal.crc = trxbal.crc and histrxbal.dt <= vdt no-lock no-error.
        if avail histrxbal then do:
            if histrxbal.lev = 1 then do:
              if vdt = dt_st - 1 then next.
              v-baly = histrxbal.dam - histrxbal.cam.
              if vdt >= p-dt1 then v-bal = histrxbal.dam - histrxbal.cam.
              if vdt = dt_end then v-balend = histrxbal.dam - histrxbal.cam.
            end.
            else
            if histrxbal.lev = 7 then do:
              if vdt = dt_st - 1 then next.
              v-bal7y = histrxbal.dam - histrxbal.cam.
              if vdt >= p-dt1 then v-bal7 = histrxbal.dam - histrxbal.cam.
              if vdt = dt_end then v-balend7 = histrxbal.dam - histrxbal.cam.
            end.
            else
            if histrxbal.lev = 6 then do:
              if vdt = dt_st - 1 then v-accr1 = histrxbal.cam - histrxbal.dam.
              if vdt = dt_end then v-accr2 = histrxbal.cam - histrxbal.dam.
            end.
            else
            if histrxbal.lev = 11 then do:
              if vdt = dt_st - 1 then v-procn1 = histrxbal.cam - histrxbal.dam.
              if vdt = dt_end then v-procn2 = histrxbal.cam - histrxbal.dam.
            end.
            else
            if histrxbal.lev = 12 then do:
              if vdt = dt_st - 1 then v-procp1 = histrxbal.cam - histrxbal.dam.
              if vdt = dt_end then v-procp2 = histrxbal.cam - histrxbal.dam.
            end.
            else
            if histrxbal.lev = 16 and vdt = dt_end then v-pen = histrxbal.dam - histrxbal.cam.
        end.
        if v-bal + v-baly + v-bal7 + v-bal7y + v-procn1 + v-procn2 + v-procp1 + v-procp2 + v-pen + v-accr1 + v-accr2 + v-komiss = 0 then next.
        if lon.crc <> 1 then do:
            find last crchis where crchis.crc = lon.crc and crchis.rdt <= vdt use-index crcrdt no-lock no-error.
              if not available crchis then do:  
              message 'Не задан курс для Счета ' lon.lon.
              next.
            end.
            v-bal = v-bal * crchis.rate[1]. /*остатки осн долга в тенге за каждый день*/
            v-baly = v-baly * crchis.rate[1].
            v-bal7 = v-bal7 * crchis.rate[1].
            v-bal7y = v-bal7y * crchis.rate[1].
            if vdt = dt_end then 
               assign v-balend = v-balend * crchis.rate[1]
                      v-balend7 = v-balend7 * crchis.rate[1].
        end.
/*         if  histrxbal.lev  =  7 then  message vdt  histrxbal.lev v-baly v-bal7y histrxbal.acc.*/
          ost-mon[month(vdt)] = ost-mon[month(vdt)]  + v-baly.
          ost-mon7[month(vdt)] = ost-mon7[month(vdt)]  + v-bal7y.

        /* сегментация */
        v-segm = '00'.
        find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnsegm' no-lock no-error.
        if avail sub-cod then do:
          if sub-cod.ccode = '01' or sub-cod.ccode = '02' or sub-cod.ccode = '08' then v-segm = sub-cod.ccode.
        end.
        find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = 'lon' and sub-cod.d-cod = "kdkik" no-lock no-error.
        if avail sub-cod and sub-cod.ccode = '01' then v-segm = 'kik'.
        
        if v-report-type = 1 then do:
            find last templon where templon.grp = lon.grp and templon.segm = v-segm and templon.crc = lon.crc and templon.dep = v-dep no-error.
            if not avail templon then do:
                create templon.
                assign templon.grp = lon.grp
                       templon.segm = v-segm
                       templon.crc = lon.crc
                       templon.dep = v-dep
                       templon.dt = vdt
                       templon.gl = lon.gl.
            end.
        end.
        else do:
            find last templon where templon.urfiz = v-urfiz and templon.krdolg = v-krdolg and templon.crc = lon.crc and templon.prog = v-prog
                     and templon.gl = lon.gl and templon.dt = vdt no-error.
            if not avail templon then do:
                create templon.
                assign templon.urfiz = v-urfiz
                       templon.krdolg = v-krdolg
                       templon.crc = lon.crc
                       templon.prog = v-prog
                       templon.gl = lon.gl
                       templon.dt = vdt.
            end.
        end.
        templon.bal = templon.bal + v-bal.
        templon.baly = templon.baly + v-baly.
        templon.bal7 = templon.bal7 + v-bal7.
        templon.bal7y = templon.bal7y + v-bal7y.
        templon.balend = templon.balend + v-balend.
        templon.balend7 = templon.balend7 + v-balend7.
        templon.proc = templon.proc + v-procn2 - v-procn1 + v-procp2 - v-procp1. /* %% за месяц*/
        templon.procy = templon.procy + v-procn2 + v-procp2.                    /*%% с  начала года */
        templon.accr = templon.accr + v-accr2 - v-accr1.
        templon.pen = templon.pen + v-pen.
        if v-komiss > 0 then do:
           templon.komiss = templon.komiss + v-komiss.
           sumcom = sumcom + v-komiss.
           v-komiss = 0.
        end.
        sumbal = sumbal + v-bal.
        sumbaly = sumbaly + v-baly.
        sumbal7 = sumbal + v-bal7.
        sumbal7y = sumbaly  + v-bal7y.
        sumbalend = sumbalend + v-balend.
        sumbalend7 = sumbalend7 + v-balend7.
        sumproc = sumproc + v-procn2 - v-procn1 + v-procp2 - v-procp1.
        sumprocy = sumprocy + v-procn2 + v-procp2.
        sumaccr = sumaccr + v-accr2 - v-accr1.
        sumpen = sumpen + v-pen.
    end. /*по датам*/
end.

/*Расчитываем средние остатки за каждый месяц*/
do i = 1 to 12 .
   run  mondays(i,v-god,output dd).
   ost-mon[i] = ost-mon[i] / dd.
   ost-mon7[i] = ost-mon7[i] / dd.
   v-bal_aver = v-bal_aver + ost-mon[i].
   v-bal_aver7 = v-bal_aver7 + ost-mon7[i].
end.

    v-bal_aver = v-bal_aver / v-mon. /*средние остатки за весь период как средние арифметичесике по месяцам*/
    v-bal_aver7 = v-bal_aver7 / v-mon.

def stream rpt2.
output stream rpt2 to 'sredn-lon.txt'.
for each templon break by templon.gl by templon.dt.
        accum templon.baly (total by templon.gl by templon.dt ).
        accum templon.bal7y (total by templon.gl  by templon.dt).
        accum templon.proc (total by templon.gl  by templon.dt).
        accum templon.accr (total by templon.gl by templon.dt).
        accum templon.pen (total by templon.gl  by templon.dt).
        accum templon.balend (total by templon.gl  by templon.dt).
        accum templon.balend7 (total by templon.gl by templon.dt).
        accum templon.komiss (total by templon.gl by templon.dt).

if last-of(templon.dt) then  put stream rpt2 skip  templon.gl   ' ' templon.dt
   (accum total by templon.dt templon.baly) format "zzzzz,zzz,zzz,zz9.99" 
   (accum total by templon.dt templon.bal7y) format "zzzzz,zzz,zzz,zz9.99" 
   (accum total by templon.dt templon.balend) format "zzzzz,zzz,zzz,zz9.99" .

if last-of(templon.gl) then  put stream rpt2 skip  templon.gl 
   (accum total by templon.gl templon.baly) format "zzzzz,zzz,zzz,zz9.99" 
   (accum total by templon.gl templon.bal7y) format "zzzzz,zzz,zzz,zz9.99" 
   (accum total by templon.gl templon.balend) format "zzzzz,zzz,zzz,zz9.99" .
  
 
end.
put stream rpt2 v-bal_aver format  'zz,zzz,zzz,zz9.99'  '   '  v-bal_aver7 format  'zz,zzz,zzz,zz9.99'.
output stream rpt2 close.

output stream vcrpt to 'product_lon.htm'.
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted 
   "<p><B>" v-bank ".<br>Отчет о средних остатках за " months[month(p-dt2)] " " string(year(p-dt2),"9999") " года</B></p>" skip.

if v-report-type = 1 then do:

    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
       "<TR align=""center"">" 
         "<TD><FONT size=""1""><B>Счет ГК</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Группа</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Наименование группы</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Департамент</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Средние остатки за месяц</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Остатки на конец месяца</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Ср.остатки за месяц - проср.ОД</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Остатки на конец месяца - проср.ОД</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Процентные доходы</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Ассигнования</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>%</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Штрафы</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Комиссии</B></FONT></TD>" skip
       "</TR>" skip.
    
    for each templon no-lock break by templon.grp by templon.segm by templon.crc by templon.dep:
    
        accum templon.bal (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.bal7 (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.proc (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.accr (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.pen (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.balend (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.balend7 (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        accum templon.komiss (total /*by templon.grp*/ by templon.segm by templon.crc by templon.dep).
        
        if last-of(templon.dep) then do:
            find first longrp where longrp.longrp = templon.grp no-lock no-error.
            find crc where crc.crc = templon.crc no-lock no-error.
            v-segm = ''.
            if templon.segm <> '00' then do:
              if templon.segm = 'kik' then v-segm = ' - Продан в КИК'.
              else do:
                find first codfr where codfr.codfr = "lnsegm" and codfr.code = templon.segm no-lock no-error.
                if avail codfr then v-segm = ' - ' + codfr.name[1]. else v-segm = ' - ' + templon.segm.
              end.
            end.
            put stream vcrpt unformatted
                "<TR valign=""top""><TD>" templon.gl  "</TD>" skip
                  "<TD>"  templon.grp  "</TD>" skip
                  "<TD>"  longrp.des + v-segm "</TD>" skip
                  "<TD>"  crc.code  "</TD>" skip
                  "<TD>"  templon.dep "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.bal) / v-day,"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.balend),"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.bal7) / v-day,"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.balend7),"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.proc),"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.accr),"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" if (accum total by templon.dep templon.bal) > 0 then replace(string((accum total by templon.dep templon.proc) * v-day / (accum total by templon.dep templon.bal) * 1200,"zzzzzzzzzzzzz9.99"),".",",") else '' "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.pen),"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                  "<TD>" replace(string((accum total by templon.dep templon.komiss),"zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                "</TR>" skip.
        end. /* last dep */
        
        if last-of(templon.segm) then do:
            find first longrp where longrp.longrp = templon.grp no-lock no-error.
            v-segm = ''.
            if templon.segm <> '00' then do:
              if templon.segm = 'kik' then v-segm = ' - Продан в КИК'.
              else do:
                find first codfr where codfr.codfr = "lnsegm" and codfr.code = templon.segm no-lock no-error.
                if avail codfr then v-segm = ' - ' + codfr.name[1]. else v-segm = ' - ' + templon.segm.
              end.
            end.
            put stream vcrpt unformatted
                "<TR valign=""top""><TD><b>  ИТОГО по группе  </b></TD>" skip
                  "<TD><b>" templon.grp "</b></TD>" skip
                  "<TD><b>" longrp.des + v-segm "</b></TD>" skip
                  "<TD> &nbsp </TD>" skip
                  "<TD> &nbsp </TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.bal) / v-day,"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.balend),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.bal7) / v-day,"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.balend7),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.proc),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.accr),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD> &nbsp </TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.pen),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                  "<TD><b>" replace(string((accum total by templon.segm templon.komiss),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
                "</TR>" skip.
        end. /* last segm */
    end. /* for each templon */
    
    put stream vcrpt unformatted
        "<TR valign=""top""><TD><b> &nbsp </b></TD>" skip
          "<TD><b> &nbsp </b></TD>" skip
          "<TD><b> &nbsp </b></TD>" skip
          "<TD> &nbsp </TD>" skip
          "<TD> ИТОГО </TD>" skip
          "<TD><b>" replace(string((sumbal) / v-day,"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumbalend),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumbal7) / v-day,"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumbalend7),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumproc),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumaccr),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD> &nbsp </TD>" skip
          "<TD><b>" replace(string((sumpen),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
          "<TD><b>" replace(string((sumcom),"-zzzzzzzzzzzzz9.99"),".",",") "</b></TD>" skip
        "</TR>" skip.
    
    put stream vcrpt unformatted "</TABLE>" skip.
end. /* if v-report-type = 1 */
else do:
    
    if v-report-type = 3 then do:
       put stream vcrpt unformatted "По департаменту " v-dep-code.
       find codfr where codfr.codfr = 'sdep' and codfr.code = v-dep-code no-lock no-error.
       if avail codfr then put stream vcrpt unformatted " (" trim(codfr.name[1]) ")<br><br>".
    end.
    
    put stream vcrpt unformatted
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
       "<TR align=""center"">"
         "<TD><FONT size=""1""><B>Наименование группы</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Средние остатки за месяц</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Средние остатки за период с начала года</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Остатки на конец месяца</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Ср.остатки за месяц - проср.ОД</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Ср.остатки за период с начала года - проср.ОД</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Остатки на конец месяца - проср.ОД</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Процентные доходы</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Процентные доходы за период с начала года</B></FONT></TD>" skip
         
         "<TD><FONT size=""1""><B>Ассигнования</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>%</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Штрафы</B></FONT></TD>" skip
         "<TD><FONT size=""1""><B>Комиссии</B></FONT></TD>" skip
       "</TR>" skip.
    
    for each templon no-lock break by templon.urfiz by templon.krdolg by templon.crc by templon.prog:
        
        if first-of(templon.urfiz) then do:
          v-sum = 0.
          put stream vcrpt unformatted
                "<TR><TD colspan=""14""><b>" if templon.urfiz = 0 then "Корпоративные клиенты" else "Физические лица" "</b></TD></TR>" skip.
        end.
        if first-of(templon.krdolg) then do:
          v-sum1 = 0.
          put stream vcrpt unformatted
                "<TR><TD colspan=""14""><b><i>" if templon.krdolg = 0 then "Краткосрочные кредиты" else "Долгосрочные кредиты" "</i></b></TD></TR>" skip.
        end.
        if first-of(templon.crc) then do:
          v-sum2 = 0.
          find first crc where crc.crc = templon.crc no-lock no-error.
        end.
        if first-of(templon.prog) then v-sum3 = 0.
        
        v-sum3[1] = v-sum3[1] + templon.bal.
        v-sum3[2] = v-sum3[2] + templon.baly.
        v-sum3[3] = v-sum3[3] + templon.balend.
        v-sum3[4] = v-sum3[4] + templon.bal7.
        v-sum3[5] = v-sum3[5] + templon.bal7y.
        v-sum3[6] = v-sum3[6] + templon.balend7.
        v-sum3[7] = v-sum3[7] + templon.proc.
        v-sum3[8] = v-sum3[8] + templon.procy.
        v-sum3[9] = v-sum3[9] + templon.accr.
        v-sum3[10] = v-sum3[10] + templon.pen.
        v-sum3[11] = v-sum3[11] + templon.komiss.
        
        if last-of(templon.prog) then do:
            put stream vcrpt unformatted
                "<TR valign=""top""><TD>" v-proglist[templon.prog] "</TD>" skip
                  "<TD>" crc.code "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[1] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[2] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[3],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[4] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[5] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[6],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[7],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[8],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[9],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" if v-sum3[1] > 0 then replace(trim(string(v-sum3[7] * v-day / v-sum3[1] * 1200,"-zzzzzzzzzzzzz9.99")),".",",") else '' "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[10],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                  "<TD>" replace(trim(string(v-sum3[11],"-zzzzzzzzzzzzz9.99")),".",",") "</TD>" skip
                "</TR>" skip.
            
            do i = 1 to 11: v-sum2[i] = v-sum2[i] + v-sum3[i]. end.
        end.
        
        if last-of(templon.crc) then do:
            do i = 1 to 11: v-sum1[i] = v-sum1[i] + v-sum2[i]. end.
            /*
            put stream vcrpt unformatted
                "<TR valign=""top""><TD><b>  ИТОГО по " crc.code "</b></TD>" skip
                  "<TD><b>" crc.code "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[1] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[2] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[3],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[4] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[5] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[6],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[7],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[8],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" if v-sum2[1] > 0 then replace(trim(string(v-sum2[7] * v-day / v-sum2[1] * 1200,"-zzzzzzzzzzzzz9.99")),".",",") else '' "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[9],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum2[10],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                "</TR>" skip.
            */
        end.
        
        if last-of(templon.krdolg) then do:
            do i = 1 to 11: v-sum[i] = v-sum[i] + v-sum1[i]. end.
            /*
            put stream vcrpt unformatted
                "<TR valign=""top""><TD colspan=""2""><b>  ИТОГО по " if templon.krdolg = 0 then "краткосрочным кредитам" else "долгосрочным кредитам" "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[1] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[2] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[3],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[4] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[5] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[6],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[7],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[8],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" if v-sum1[1] > 0 then replace(trim(string(v-sum1[7] * v-day / v-sum1[1] * 1200,"-zzzzzzzzzzzzz9.99")),".",",") else '' "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[9],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum1[10],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                "</TR>" skip.
            */
        end.
        
        if last-of(templon.urfiz) then do:
            put stream vcrpt unformatted
                "<TR valign=""top""><TD colspan=""2""><b>  ИТОГО по " if templon.urfiz = 0 then "корпоративным клиентам" else "физическим лицам" "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[1] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[2] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[3],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[4] / v-day,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[5] / v-dayy,"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[6],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[7],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[8],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[9],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" if v-sum[1] > 0 then replace(trim(string(v-sum[7] * v-day / v-sum[1] * 1200,"-zzzzzzzzzzzzz9.99")),".",",") else '' "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[10],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                  "<TD><b>" replace(trim(string(v-sum[11],"-zzzzzzzzzzzzz9.99")),".",",") "</b></TD>" skip
                "</TR>" skip.
        end.
        
    end. 
    
    put stream vcrpt unformatted "</TABLE>" skip.
    
end. /* else do (v-report-type <> 1) */

{html-end.i " stream vcrpt "}

output stream vcrpt close.
unix silent value("cptwin product_lon.htm excel").
  
pause 0.

