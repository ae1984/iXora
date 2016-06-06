/* s-lonsub.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Просмотр истории по выбранному кредиту
 * RUN
        верхнее меню История
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-1-1, 4-7-3, 4-8-3, 4-9-3, 4-13-3, 4-15-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
         10.07.2002         - возможность печати п 1 и 2
         01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
         11.02.2004 nadejda - увеличены форматы вывода чисел
         02.03.2004 marinav - добавлен отчет 3 - Комиссии по кредитной линии
         07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
         09.03.2004 sasco   - добавил find first w-lh после его create
         09.03.2004 marinav - добавлено  5) просроч ОД   6) просроч %%
         10.03.2004 marinav - добавлено  8) штрафы
         30.03.2004 marinav - исправления в отчете по штрафам
         21/06/2004 madiar  - вывод списанных сумм ( 10 - ОД, 11 - %%)
         22.06.2004 nadejda - сообщение "Сбор данных"
         03/09/2004 madiyar - в карточке % (vans = 9) не инициализировались нулями итоговые суммы (при повторных
                              запусках происходило накопление), исправил
         24/01/2005 madiyar - возможность задания дат "с" "по" в пунктах 1 и 2
         03/02/2005 madiyar - для ускорения вывода истории полностью закомментировал подготовку данных, все что необходимо - вынес наверх
         13/06/2005 madiyar - история погашения индексации
         09/12/2005 madiyar - карточка процентов - вывод ручных проводок начисления
         14/03/2007 madiyar - штрафы - отдельно вывод ручных проводок
         13/04/2007 madiyar - 14 - история по комиссии за обслуживание кредита
         25/07/2007 madiyar - убрал ссылку на удаленную таблицу jm
         26/02/09   marinav - vans = 9 перенос с просрочки не учитывать
         25/03/2009 galina  - не выводим проводки сторнирования для комиссии
         19.06.09   marinav - добавился 15 пункт Штрафы 5 ур
         22/06/2010 madiyar - история по комиссии выводится и по 9-значному счету
         24/07/2010 madiyar - добавил 16 пункт Списанные штрафы, update vans в фрейме
         27/07/2010 madiyar - hide frame
         23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
         26/01/2011 madiyar - история остатка КЛ
         04.07.2011 aigul - добавила корр счет и примечание для 1,2,5,6,7,8,10,11,15 уровней
         07/07/2011 madiyar - выписки по процентам
         22/07/2011 kapar  - ТЗ 1134
         25/06/2012 kapar - ТЗ ASTANA-BONUS
         11/10/2012 kapar - ТЗ ASTANA-BONUS(исправление)
         11.01.2013 evseev - тз-1530
*/

{global.i}
{lonlev.i}
def shared var s-lon like lon.lon.
/*def new shared var s-lon like lon.lon.
s-lon = "000144630".*/  /*для отладки */
define new shared temp-table w-amk
       field    nr   as integer
       field    dt   as date
       field    fdt  as date
       field    tdt  as date
       field    prn  as decimal
       field    rate as decimal
       field    amt1 as decimal
       field    amt2 as decimal
       field    amt3 as decimal
       field    amt4 as decimal
       field    dc   as char /* --date-- madiyar */
       field    trx  as char
       field    who  as char
       field    acc as int /*aigul - corr acc*/
       field    note as char. /*aigul - note*/


define temp-table t-lon
  field dt as date
  field dam as deci
  field cam as deci.

define var v-dam as deci init 0.
define var v-cam as deci init 0.
define var v-dbt as deci format '->>>,>>>,>>>,>>9.99'.
define var v-crt as deci format '->>>,>>>,>>>,>>9.99'.
define variable w-prn  as character.
define variable w-rate as character.
define variable w-amt1 as character.
define variable w-amt2 as character.
def buffer bgl for gl.
def var vans as int form "z9".
define variable vans1 as integer.
define variable v-stat as integer.
define variable v-stat0 as integer.
define variable finrez as decimal.
define variable f-dat as date.
def var vlon like lon.lon.
def var vacc as char format "x(10)".
def var vamt like jl.dam.
def var vinc as int.
def var vfactor as decimal extent 5.
def var vyrst like lon.opnamt extent 6 decimals 2.
def var vmost like vyrst.
def var vdb like vyrst.
def var vcr like vyrst.
def var vcu like vyrst.
def var vddt as date extent 5.
def var vcdt like vddt.
def var vint like jl.dam label "INT.DUE".
def var vmon like vint.
def var vacr like vint.
def var vtot like vint.
def var vfdt as date.
def var vtdt as date.
def var asof as date.
def var vtarget as date.
def var vinttgt like vint.
def var fv as char.
def var inc as int.
define variable f-dat1     as date.
define variable f-datc     as character.
define variable f-atlikums as decimal.
define variable f-deb      as decimal.
define variable f-kred     as decimal.
define variable f-jh       like jh.jh.
define variable f-who      like jh.who.
def var f-acc like jl.gl.
def var f-note as char.
define variable konts      like gl.gl.
define variable kurss      as decimal.
define variable rinda      as character.
define variable mon2       as date.
define variable mon1       as date.
define variable monc       as date.
define variable v-bil      as character.
define variable v-code     as character.
define variable v-code1    as character.
define variable i          as integer.
define variable j          as integer.
def var v-intod as dec.
def var v-bal as dec.
def var v-amtod as dec.
def var v-amtbl as dec.
def var v-lonbal as dec.
def var v-amt as dec.
def var v-d as date.
def var v-am1 as decimal init 0.
def var v-am2 as decimal init 0.

def var v-amt1 as decimal init 0.
def var v-amt2 as decimal init 0.
def var v-amt3 as decimal init 0.
def var v-amt4 as decimal init 0.

def var ssum1 as deci.
def var ssum2 as deci.
def var mlev as int.
def var s-title as char.

def var god as int.
def var v-crall like lonres.amt.
def var v-drall like lonres.amt.

def var v-lev  as int.
def var v-lev1 as int.
def var v-lev2 as int.
def var v-lev9 as int.

def var v-prem  as deci.
def var v-dprem as deci.

define new shared variable s-longl as integer extent 20.
define variable ok as logical.

define variable damu_v-cd1 as character.
def new shared var damu_ipay1 as dec.
def new shared var damu_v-intod as dec.
def var damu_v-iodcrc1 like crc.code.
def new shared var damu_v-payiod1 as dec.
def new shared var damu_v-4ur as dec.
def var damu_v-odcrc4 like crc.code.

define variable astana_v-cd1 as character.
def new shared var astana_ipay1 as dec.
def new shared var astana_v-intod as dec.
def var astana_v-iodcrc1 like crc.code.
def new shared var astana_v-payiod1 as dec.
def new shared var astana_v-4ur as dec.
def var astana_v-odcrc4 like crc.code.

def buffer b-jl for jl.

def var dt1 as date.
def var dt2 as date.
form skip(1)
     dt1 label ' С ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' ' ' skip(1)
     with side-label overlay row 5 centered frame dat.

find lon where lon.lon = s-lon no-lock.
find cif of lon no-lock.
find crc where crc.crc = lon.crc no-lock.
find last lonhar where lonhar.lon = s-lon no-lock.
v-stat = lonhar.lonstat.
v-code = crc.code.
v-code1 = 'KZT'. /* провизии всегда в тенге */

{x-eomint.f}

i = month(g-today).
i = i - 1.
if i = 0
then mon2 = date(12,1,year(g-today) - 1).
else mon2 = date(i,1,year(g-today)).
mon1 = date(month(g-today),1,year(g-today)).
run next-month(mon1,output monc).

{s-lonsub.f}.
{x-eomintl.i}
view frame lon.


define stream s3.


  inner:
  repeat:
    find gl where gl.gl eq lon.gl no-lock.
    display lon.lon
            lon.gl gl.sname
            lon.grp
            lon.cif trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name lon.loncat
            v-stat
            v-stat0
            finrez
            f-dat
            lon.rdt format "99/99/9999"
            lon.duedt format "99/99/9999"
            v-code v-code1
            lon.base lon.prem v-bil
            vint2mon mon2
            vint1mon mon1
            vintcmon monc
            vinttday g-today
            with frame lon.

    vyrst = 0.
    vmost = 0.
    vcu = 0.
    for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
    no-lock :
        if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then do:
            vyrst[1] = vyrst[1] + trxbal.ydam - trxbal.ycam.
            vmost[1] = vmost[1] + trxbal.mdam - trxbal.mcam.
            vcu[1] = vcu[1] + trxbal.dam - trxbal.cam.
        end.
    end.

    run atl-prcl(input lon.lon, input date(month(g-today),1,year(g-today)) - 1,
    output vmost[3], output vmost[4], output vmost[2]).

    run atl-prcl(input lon.lon, input date(1,1,year(g-today)) - 1,
    output vyrst[3], output vyrst[4], output vyrst[2]).


    run atl-prcl(input lon.lon, input g-today,
    output vcu[3], output vcu[4], output vcu[2]).


    run atl-prov(input lon.lon, input date(month(g-today),1,year(g-today)) - 1,
    output vmost[3]).

    run atl-prov(input lon.lon, input date(1,1,year(g-today)) - 1,
    output vyrst[3]).


    run atl-prov(input lon.lon, input g-today,
    output vcu[3]).

    {s-lonsub1.f}.

    /* mesg.i 3402 */
    /*
    message "1)ОД 2)Получ % 3)Комисс КЛ 4)Прогноз % 5)Проср ОД 6)Проср % 7)Провизии 8)Штрафы".
    message "9)Карточка % 10)СписОД 11)Спис% 12)ИндексОД 13)Индекс% "
          update vans.
    */

    /*
    message "1)ОД 2)Получ % 3)Комисс КЛ 4)Прогноз % 5)Проср ОД 6)Проср % 7)Провизии 8)Штрафы 9)Карточка %".
    message "10)СписОД 11)Спис% 12)ИндОД 13)Инд% 14) КомиссКр 15)Пеня 5ур 16)СписПеня" update vans.
    */

    vans = 0.
    displ vans with frame updvans.
    update vans go-on("PF4") with frame updvans.
    hide frame updvans.

    pause 0.

    if vans = 0 then leave.
    if vans > 32 then leave.

    else if vans = 1
    then do:
      dt1 = ?. dt2 = ?.
      displ dt1 dt2 with frame dat.
      update dt1 dt2 with frame dat.
      if dt1 = ? then dt1 = 01/01/1000.
      if dt2 = ? then dt2 = 01/01/3000.
      v-am1 = 0. v-am2 = 0.
         clear frame jl all.
                                         /*
                                      for each jl where jl.gl eq gl.gl and
                                          jl.acc eq vacc no-lock by jl.jdt:
                                          find gl of jl.
                                          display jl.jdt jl.dam jl.cam
                                          jl.jh jl.who with frame jl
                                          down centered row 2
                                          title string(gl.gl) + " " + gl.des.
                                          down with frame jl.
                                      end.
                                         */

         output stream s3 to drb.1.

      g1:
         for each lnscg where lnscg.lng = lon.lon and
             lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0
             no-lock by lnscg.stdat descending:

             if lnscg.stdat < dt1 or lnscg.stdat > dt2 then next.

             f-datc = string(lnscg.stdat,"99/99/9999").
             f-datc = substring(f-datc,7,4) +
                      substring(f-datc,3,4) + substring(f-datc,1,2).
            f-acc = 0.
            f-note = "".
            find first jl where jl.jh = lnscg.jh and jl.dam = lnscg.paid  no-lock no-error.
            if avail jl and jl.lev = 1 then do:
                find first b-jl where b-jl.jh = lnscg.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                if avail b-jl and b-jl.rem[2] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                if avail b-jl and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                if avail b-jl and b-jl.rem[4] = "" and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
            end.
            if avail jl and jl.lev = 7 then do:
                find first b-jl where b-jl.jh = lnscg.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                if avail b-jl and b-jl.rem[2] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                if avail b-jl and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                if avail b-jl and b-jl.rem[4] = "" and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
            end.
             export  stream s3
                     f-datc
                     lnscg.stdat
                     lnscg.jh
                     lnscg.paid
                     0
                     lnscg.who
                     f-acc
                     f-note.
         end.
         if lon.gua = "OD"
         then do:
              f-atlikums = ?.
              f-deb = 0.
              f-kred = 0.

              for each aab where aab.aaa = lon.lcr no-lock
                  by aab.fdt descending:
                  if f-atlikums <> ?
                  then do:
                       f-deb  = 0.
                       f-kred = 0.
                       if f-atlikums < - aab.bal
                       then f-kred = - aab.bal - f-atlikums.
                       else f-deb  = f-atlikums - ( - aab.bal ) .
                       export  stream s3
                               f-datc
                               f-dat1
                               0
                               f-deb
                               f-kred
                               ""
                               f-acc
                               f-note.
                  end.
                  f-dat1 = aab.fdt.
                  f-datc = string(f-dat1,"99/99/9999").
                  f-datc = substring(f-datc,7,4) + substring(f-datc,3,4) +
                           substring(f-datc,1,2).
                  f-atlikums = - aab.bal.
              end.
              if f-atlikums <> ?
              then do:
                   f-deb = f-atlikums.
                   export  stream s3
                           f-datc
                           f-dat1
                           0
                           f-deb
                           0
                           ""
                           f-acc
                           f-note.
              end.
         end.
         else
         for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0
             no-lock by lnsch.flp descending:
             f-deb = 0.
             do:
                  if lnsch.flp <= 0
                  then leave.

                  if lnsch.stdat < dt1 or lnsch.stdat > dt2 then next.

                  f-dat1 = lnsch.stdat.
                  f-datc = string(f-dat1,"99/99/9999").
                  f-datc = substring(f-datc,7,4) +
                           substring(f-datc,3,4) + substring(f-datc,1,2).
                  f-kred = lnsch.paid.
                  f-acc = 0.
                  f-note = "".
                    find first jl where jl.jh = lnsch.jh and jl.cam = lnsch.paid and jl.sub = "LON"  no-lock no-error.
                    if avail jl and jl.lev = 1 then do:
                        find first b-jl where b-jl.jh = lnsch.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[2] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                        if avail b-jl and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                        if avail b-jl and b-jl.rem[4] = "" and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    end.
                    if avail jl and jl.lev = 7 then do:
                        find first b-jl where b-jl.jh = lnsch.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[2] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                        if avail b-jl and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                        if avail b-jl and b-jl.rem[4] = "" and b-jl.rem[2] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    end.
                  export  stream s3
                          f-datc
                          f-dat1
                          lnsch.jh
                          0
                          f-kred
                          lnsch.who
                          f-acc
                          f-note.
             end.
         end.

         output stream s3 close.
         unix silent sort drb.1 > drb.2.

          def stream m-out.
          output stream m-out to rpt.img.
          put stream m-out
          "                          "
          "Основная сумма "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + v-code format "x(100)" skip.

          if dt1 > 01/01/1000 or dt2 < 01/01/3000 then do:
            put stream m-out "Период: ".
            if dt1 > 01/01/1000 then put stream m-out 'c ' dt1 format "99/99/9999" ' '.
            if dt2 < 01/01/3000 then put stream m-out 'по ' dt2 format "99/99/9999".
            put stream m-out skip.
          end.

          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "                Дебет"
          "                Кредит"
          "  Транзакция "
          " Исполнитель  "
          " Корр счет  "
          " Примечание  "skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

         input stream s3 from drb.2 no-echo.
         repeat on endkey undo,leave:
            import stream s3
                   f-datc
                   f-dat1
                   f-jh
                   f-deb
                   f-kred
                   f-who
                   f-acc
                   f-note.
/************************/
              put stream m-out
     f-dat1 format "99/99/9999"
     f-deb  format "->>,>>>,>>>,>>>,>>9.99"
     f-kred format "->>,>>>,>>>,>>>,>>9.99"
     f-jh   format "zzzzzzzzzz" "      "
     f-who
     f-acc  format "zzzzzzzzzz" "      "
     f-note format "x(50)" skip.
/***********************/
    v-am1 = v-am1 + f-deb.
    v-am2 = v-am2 + f-kred.

/*            display f-dat1
                    f-deb
                    f-kred
                    f-jh
                    f-who
                    with frame jl
                        down centered row 2 title string(gl.gl) + " " + gl.des.
            down with frame jl.*/
         end.
         input stream s3 close.
         put stream m-out  fill( "-", 150 ) format "x(150)" skip.
         put stream m-out "  ИТОГО   " v-am1 format "->>,>>>,>>>,>>>,>>9.99" v-am2 format "->>,>>>,>>>,>>>,>>9.99" skip.
         output stream m-out close.
         if  not g-batch then do:
             pause 0 before-hide .
             run menu-prt( "rpt.img" ).
             pause before-hide.
         end.
    end.
    else if vans = 4
    then do:
         update vtarget with frame lon.
         if vtarget <= lon.rdt then vinttgt = 0.
         else do:
             if vtarget le g-today then run atl-prcl(s-lon,vtarget - 1, output vinttgt, output v-amt, output v-amt).
             else do:
                run atl-dat(s-lon,g-today,output v-lonbal).
                run atl-prcl(s-lon,g-today,output vinttgt, output v-amt, output v-amt).
                find last rate where rate.base eq lon.base and rate.cdt le g-today no-lock no-error.
                if g-today lt lon.rdt then v-d = lon.rdt. else v-d = g-today.
                run day-360(v-d,vtarget - 1,lon.basedy,output dn1,output dn2).
                vinttgt = vinttgt + round((dn1 * v-lonbal * (rate.rate + lon.prem) / 100 / lon.basedy),2).
             end.
         end.
         display vinttgt with frame lon.
    end. /* if vans = 4 */
    else if vans = 2 or vans = 24 or vans = 29
    then do:

         if vans = 24 then next.
         if vans = 29 and lon.grp <> 95 then next.

         if vans = 2 then do: v-lev1 = 1. v-lev2 = 2.  v-lev9 = 9. end.
         if vans = 24 then do: v-lev1 = 1. v-lev2 = 44.  v-lev9 = 45. end.
         if vans = 29 then do: v-lev1 = 1. v-lev2 = 49.  v-lev9 = 50. end.

         if lon.grp = 95 then do:
           if lon.prem = 0 then v-prem = lon.prem1. else v-prem = lon.prem.
           if v-prem = 0 then v-prem = 1.
           if lon.dprem = 0 then v-dprem = lon.dprem1. else v-dprem = lon.dprem.
         end.
         else do:
           v-prem = 1.
           v-dprem = 0.
         end.

         dt1 = ?. dt2 = ?.
         displ dt1 dt2 with frame dat.
         update dt1 dt2 with frame dat.
         if dt1 = ? then dt1 = 01/01/1000.
         if dt2 = ? then dt2 = 01/01/3000.

         v-am1 = 0. v-am2 = 0.
         clear frame jl all.
         output stream s3 to drb.1.
         if lon.gua = "OD"
         then do:
              find aaa where aaa.aaa = lon.lcr no-lock.
              rinda = aaa.craccnt.
              find aaa where aaa.aaa = rinda no-lock.
              find aax where aax.lgr = aaa.lgr and aax.ln = 17 no-lock.
              konts = aax.cgl.
              find aaa where aaa.aaa = lon.lcr no-lock.

              for each jl where jl.gl = konts no-lock:

/*
                  find aah where aah.aah = jl.aah no-lock no-error.
                  if available aah and aah.aaa = aaa.craccnt
                  then do:
                       f-dat1 = jl.jdt.
                       f-datc = string(f-dat1,"99/99/9999").
                       f-datc = substring(f-datc,7,4) +
                            substring(f-datc,3,4) + substring(f-datc,1,2).
                       export  stream s3
                               f-datc
                               f-dat1
                               jl.jh
                               jl.dam
                               jl.cam
                               jl.who.
                  end.
*/
              end.
         end.
         else do:
              for each lnsci where lnsci.lni = lon.lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:

                  if vans = 24 then next.
                  if lnsci.idat < dt1 or lnsci.idat > dt2 then next.
                  f-acc = 0.
                  f-note = "".
                    find first jl where jl.jh = lnsci.jh and jl.dam = lnsci.paid-iv  no-lock no-error.
                    if avail jl and jl.lev = v-lev2 and jl.sub = "LON"  then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                    if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[5].
                    end.
                    if avail jl and jl.lev = v-lev9 and jl.sub = "LON"  then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                        if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[5].
                    end.
                    if avail jl and jl.lev = v-lev1 then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                        if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                    end.
                    find first jl where jl.jh = lnsci.jh and jl.cam = lnsci.paid-iv no-lock no-error.
                    if avail jl and jl.lev = v-lev2 and jl.sub = "LON"  then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                    if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[5].
                    end.
                    if avail jl and jl.lev = v-lev9 and jl.sub = "LON"  then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                        if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[5].
                    end.
                    if avail jl and jl.lev = v-lev1 then do:
                        find first b-jl where b-jl.jh = lnsci.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl and b-jl.rem[3] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[3].
                        if avail b-jl and b-jl.rem[3] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                    end.
                  f-dat1 = lnsci.idat.
                  f-datc = string(f-dat1,"99/99/9999").
                  f-datc = substring(f-datc,7,4) + substring(f-datc,3,4) + substring(f-datc,1,2).
                  if vans = 2 then
                    f-kred = (lnsci.paid-iv / v-prem) * (v-prem - v-dprem).
                  else
                    f-kred = (lnsci.paid-iv / v-prem) * v-dprem.
                  export  stream s3
                          f-datc
                          f-dat1
                          lnsci.jh
                          0
                          f-kred
                          lnsci.who
                          f-acc
                          f-note.
              end.
         end.
         output stream s3 close.
         unix silent sort drb.1 > drb.2.
          def stream m-out.
          output stream m-out to rpt.img.
          put stream m-out
          "                       "
          "ПОГАШЕНИЕ ПРОЦЕНТОВ "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + v-code format "x(100)" skip.

          if dt1 > 01/01/1000 or dt2 < 01/01/3000 then do:
            put stream m-out "Период: ".
            if dt1 > 01/01/1000 then put stream m-out 'c ' dt1 format "99/99/9999" ' '.
            if dt2 < 01/01/3000 then put stream m-out 'по ' dt2 format "99/99/9999".
            put stream m-out skip.
          end.

          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "             Дебет"
          "             Кредит"
          "  Транзакция "
          " Исполнитель  "
          " Корр счет  "
          " Примечание  "skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

         input stream s3 from drb.2 no-echo.
         repeat on endkey undo,leave:
            import stream s3
                   f-datc
                   f-dat1
                   f-jh
                   f-deb
                   f-kred
                   f-who
                   f-acc
                   f-note.
/************************/
              put stream m-out
     f-dat1 format "99/99/9999"
     f-deb  format "->>>,>>>,>>>,>>9.99"
     f-kred format "->>>,>>>,>>>,>>9.99"
     f-jh   format "zzzzzzzzzz" "      "
     f-who
     f-acc format "zzzzzzzzzz" "      "
     f-note format "x(50)" skip.
/***********************/
    v-am1 = v-am1 + f-deb.
    v-am2 = v-am2 + f-kred.

/*            display f-dat1
                    f-deb
                    f-kred
                    f-jh
                    f-who
                    with frame jl
                    down centered row 2 title
                     string(gl.gl) + " " + gl.des.
                    " Погашение процентов " .
            down with frame jl. */
         end.
         input stream s3 close.
         put stream m-out  fill( "-", 150 ) format "x(150)" skip.
         put stream m-out "  ИТОГО   " v-am1 format "->>>,>>>,>>>,>>9.99" v-am2 format "->>>,>>>,>>>,>>9.99" skip.
         put stream m-out skip.
         output stream m-out close.
         if  not g-batch then do:
             pause 0 before-hide .
             run menu-prt( "rpt.img" ).
             pause before-hide.
         end.
                                           /*
                                for each bgl where bgl.subled eq "lon" and
                                bgl.level eq vans no-lock:
                                for each jl where jl.gl eq bgl.gl and jl.acc eq
                                vacc no-lock by jl.jdt:
                                find gl of jl.
                                display jl.jdt  jl.dam jl.cam jl.jh jl.who with
                                2 title string(gl.gl) +
                                " " + gl.des. down with frame jl.
                                end.
                                 end.
                                            */
    end.
    else if vans = 3
    then do:
         v-dbt = 0.
         v-crt = 0.
         output stream m-out to rpt.img.
          put stream m-out
          "    "
          "Комиссия за неиспользование кредитной линии "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 100 ) format "x(80)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  " skip.
          put stream m-out  fill( "-", 100 ) format "x(80)" skip.

         for each lonres use-index lon where lonres.lon = s-lon and
             lonres.lev = 25 no-lock break by jh:
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  v-dbt = v-dbt + lonres.amt.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  v-crt = v-crt + lonres.amt.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.
             put stream m-out
             v-dt  v-db  v-cr '  ' v-jh '  ' lonres.who skip.

         end.
         put stream m-out skip(1) '  Итого    ' v-dbt '  ' v-crt skip.

       output stream m-out close.
       run menu-prt( "rpt.img" ).
    end.

    else if vans = 5
    then do:
         v-dbt = 0.
         v-crt = 0.
         output stream m-out to rpt.img.
          put stream m-out
          "    "
          "Просроченная основная сумма "  skip
          "      (счет 1424)" skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
            " Корр счет  "
          " Примечание  "skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

         for each lonres use-index lon where lonres.lon = s-lon and
             lonres.lev = 7 no-lock break by jh:
             if lonres.dc = "D"
             then do:
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = lonres.amt and jl.sub = "LON" and jl.lev = 7 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                  end.
                  v-db = lonres.amt.
                  v-cr = 0.
                  v-dbt = v-dbt + lonres.amt.
             end.
             else do:
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = lonres.amt and jl.sub = "LON" and jl.lev = 7 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl  then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
                  v-db = 0.
                  v-cr = lonres.amt.
                  v-crt = v-crt + lonres.amt.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

             put stream m-out
             v-dt  v-db  v-cr '  ' v-jh '  ' lonres.who f-acc format "zzzzzzzzzz" "      " f-note format "x(50)" skip.

         end.
         put stream m-out skip(1) '  Итого    ' v-dbt '  ' v-crt skip.

       output stream m-out close.
       run menu-prt( "rpt.img" ).
    end.

    else if vans = 6 or vans = 25 or vans = 30
    then do:
         if vans = 25 then next.
         if vans = 30 and lon.grp <> 95 then next.

         v-dbt = 0.
         v-crt = 0.
         output stream m-out to rpt.img.
          put stream m-out
          "    "
          "Просроченные проценты "  skip
          "      (счет 1741)" skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
            " Корр счет  "
          " Примечание  "skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

         if vans = 6 then do: v-lev9 = 9. end.
         if vans = 25 then do: v-lev9 = 45. end.
         if vans = 30 then do: v-lev9 = 50. end.

         for each lonres use-index lon where lonres.lon = s-lon and
             lonres.lev = 9 no-lock break by jh:
             if lonres.dc = "D"
             then do:
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = lonres.amt and jl.sub = "LON" and lonres.lev = v-lev9 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl then assign f-acc = b-jl.gl f-note =  b-jl.rem[2].
                  end.
                  v-db = lonres.amt.
                  v-cr = 0.
                  v-dbt = v-dbt + lonres.amt.
             end.
             else do:
                  f-acc = 0.
                  f-note = "".

                  find first jl where jl.jh = lonres.jh and jl.cam = lonres.amt and jl.sub = "LON" and lonres.lev = v-lev9 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl  then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
                  v-db = 0.
                  v-cr = lonres.amt.
                  v-crt = v-crt + lonres.amt.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.
             put stream m-out
             v-dt  v-db  v-cr '  ' v-jh '  ' lonres.who f-acc format "zzzzzzzzzz" "      " f-note format "x(50)" skip.

         end.
         put stream m-out skip(1) '  Итого    ' v-dbt '  ' v-crt skip.

       output stream m-out close.
       run menu-prt( "rpt.img" ).
    end.

    else if vans = 7
    then do:
         clear frame rs all.
         def stream m-out.
         output stream m-out to rpt.img.
          put stream m-out
          "                          "
          "Провизия "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  " " skip.
          put stream m-out  "6 - Резервы(провизии)по займам и финансовому лизингу юр" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 6 or lonres.lev eq 3)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 6) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 6) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-crall = 0.
            v-drall = 0.
         end.
       end.


          put stream m-out  " " skip.
          put stream m-out  "36 - Резервы(провизии)по начисленному вознаграждению" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 36)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 36) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 36) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-crall = 0.
            v-drall = 0.
         end.
       end.

          put stream m-out  " " skip.
          put stream m-out  "37 - Резервы(провизии)по штрафам(пени)" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 37)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 37) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 37) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-crall = 0.
            v-drall = 0.
         end.
       end.

         output stream m-out close.
         if  not g-batch then do:
             pause 0 before-hide .
             run menu-prt( "rpt.img" ).
             pause before-hide.
         end.


        /*     display v-dt v-db v-cr crc.code v-jh lonres.gl lonres.who
                     with frame rs down centered
                     row 2 title " Провизии ".
                     /*
                     string(konts) + " " +
                     gl.des + ", валюта " + string(lonres.crc1,"z9"). */
              down with frame rs.
         */

     end.

    else if vans = 21
    then do:
         clear frame rs all.
         def stream m-out.
         output stream m-out to rpt.img.
          put stream m-out
          "                          "
          "Корректировки провизий "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  " " skip.
          put stream m-out  "38 - Счет корректировки провизий ОД ЮЛ" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 38)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 38) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 38) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-drall = 0.
            v-crall = 0.
         end.
       end.

          put stream m-out  " " skip.
          put stream m-out  "39 - Счет корректировки провизий % ЮЛ" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 39)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 39) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 39) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-drall = 0.
            v-crall = 0.
         end.
       end.

          put stream m-out  " " skip.
          put stream m-out  "40 - Счет корректировки провизий штрафы ФЛ" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 40)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and (jl.lev = 40) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and (jl.lev = 40) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-drall = 0.
            v-crall = 0.
         end.
       end.

         output stream m-out close.
         if  not g-batch then do:
             pause 0 before-hide .
             run menu-prt( "rpt.img" ).
             pause before-hide.
         end.


        /*     display v-dt v-db v-cr crc.code v-jh lonres.gl lonres.who
                     with frame rs down centered
                     row 2 title " Провизии ".
                     /*
                     string(konts) + " " +
                     gl.des + ", валюта " + string(lonres.crc1,"z9"). */
              down with frame rs.
         */

     end.

    else if vans = 22
    then do:
         clear frame rs all.
         def stream m-out.
         output stream m-out to rpt.img.
          put stream m-out
          "                          "
          "Провизия АФН "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "              Кредит"
          " Транзакция "
          " Исполнитель  "
          " Корр счет"
          " Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.

       repeat god = 1999 to year(g-today) by 1:

         for each lonres use-index jdt where (lonres.lon = s-lon and (lonres.lev eq 41)) and year(lonres.jdt) = god no-lock:
             find crc where crc.crc = lonres.crc no-lock.
             if lonres.dc = "D"
             then do:
                  v-db = lonres.amt.
                  v-cr = 0.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = v-db and jl.sub = "LON" and jl.lev = 41 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             else do:
                  v-db = 0.
                  v-cr = lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = v-cr and jl.sub = "LON" and jl.lev = 41 no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    if avail b-jl and b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                  end.
             end.
             v-dt = string(lonres.whn,"99/99/9999").
             v-jh = lonres.jh.

          put stream m-out  v-dt
                    v-db format ">,>>>,>>>,>>>,>>9.99"
                    v-cr format ">,>>>,>>>,>>>,>>9.99"
                    v-jh format ">>>>>>>>>>9" " "
                    lonres.who
                    f-acc format "zzzzzzzzzz" "      "
                    f-note format "x(50)" skip.
          v-crall = v-crall + v-cr.
          v-drall = v-drall + v-db.
         end.
         if v-crall > 0 then do:
            put stream m-out fill( "-", 150 ) format "x(150)" skip
                             "     ИТОГО" v-drall format ">,>>>,>>>,>>>,>>9.99"
                                          v-crall format ">,>>>,>>>,>>>,>>9.99".
            put stream m-out skip.
            v-drall = 0.
            v-crall = 0.
         end.
       end.
         output stream m-out close.
         if  not g-batch then do:
             pause 0 before-hide .
             run menu-prt( "rpt.img" ).
             pause before-hide.
         end.


        /*     display v-dt v-db v-cr crc.code v-jh lonres.gl lonres.who
                     with frame rs down centered
                     row 2 title " Провизии ".
                     /*
                     string(konts) + " " +
                     gl.des + ", валюта " + string(lonres.crc1,"z9"). */
              down with frame rs.
         */

     end.

    else if vans = 8
    then do:
         for each t-lon. delete t-lon. end.
         v-dbt = 0.
         v-crt = 0.
         output stream m-out to rpt.img.
          put stream m-out
          "    "
          "Штрафы "  skip
          "    (счет 1860)" skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 100 ) format "x(80)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "                Кредит"
          skip.
          put stream m-out  fill( "-", 100 ) format "x(80)" skip.

          v-dam = 0. v-cam = 0.
          for each histrxbal where histrxbal.sub = 'lon' and histrxbal.acc = lon.lon and histrxbal.lev = 16 no-lock.
              if histrxbal.dam > 0 or histrxbal.cam > 0 then do:
                 create t-lon.
                 assign t-lon.dt = histrxbal.dt  t-lon.dam = histrxbal.dam - v-dam t-lon.cam = histrxbal.cam - v-cam.
                 v-dbt = v-dbt + histrxbal.dam - v-dam.  v-crt = v-crt + histrxbal.cam - v-cam.
                 assign v-dam = histrxbal.dam v-cam = histrxbal.cam.
              end.
          end.

/*
          for each hislon where hislon.lon = lon.lon and hislon.fdt > 01/07/04 no-lock.
              if hislon.tdam[3] - v-dam > 0 or hislon.tcam[3] - v-cam > 0 then do:
                create t-lon.
                assign t-lon.dt = hislon.fdt  t-lon.dam = hislon.tdam[3] - v-dam t-lon.cam = hislon.tcam[3] - v-cam.
                v-dbt = v-dbt + hislon.tdam[3] - v-dam.  v-crt = v-crt + hislon.tcam[3] - v-cam.
                assign v-dam = hislon.tdam[3] v-cam = hislon.tcam[3].
              end.
          end.
*/
          for each t-lon.
            put stream m-out
               t-lon.dt  t-lon.dam format '->>,>>>,>>>,>>>,>>9.99' t-lon.cam format '->>,>>>,>>>,>>>,>>9.99'  skip.
          end.

          put stream m-out skip(1) '  Итого    ' v-dbt '   ' v-crt skip.

          v-dbt = 0.
          v-crt = 0.
          put stream m-out unformatted skip(2) fill( "-", 150 ) format "x(150)" skip.
          put stream m-out unformatted " Дата       Тип              Дебет           Кредит    Транзакция Логин    Корр счет  Примечание" skip.
          put stream m-out unformatted fill( "-", 150 ) format "x(150)" skip.

          for each lonres where lonres.lon = lon.lon and (lonres.lev = 16 or lonres.lev = 5) no-lock:
               if lonres.dc = "d" then DO:
                  v-dbt = v-dbt + lonres.amt.
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.dam = lonres.amt and (lonres.lev = 16 or lonres.lev = 5) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                    if avail b-jl  then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                  end.
               END.
               else DO:
                  f-acc = 0.
                  f-note = "".
                  find first jl where jl.jh = lonres.jh and jl.cam = lonres.amt and (lonres.lev = 16 or lonres.lev = 5) no-lock no-error.
                  if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                    if avail b-jl  and  b-jl.rem[4] <> "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[4].
                    if avail b-jl  and  b-jl.rem[4] = "" then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                  end.
                  v-crt = v-crt + lonres.amt.
                END.
               put stream m-out unformatted
                   " " lonres.jdt format "99/99/9999" " "
                   if lonres.lev = 5 then "Внеc." else "     " " "
                   if lonres.dc = "d" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   if lonres.dc = "c" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   lonres.jh format 'z,zzz,zzz,zz9' " "
                   lonres.who format "x(7)"
                   f-acc format "zzzzzzzzzz" "      "
                   f-note format "x(50)" skip.

          end.

          put stream m-out unformatted skip(1) '  Итого           ' v-dbt format 'z,zzz,zzz,zz9.99' " " v-crt format 'z,zzz,zzz,zz9.99' skip.


      output stream m-out close.
      run menu-prt( "rpt.img" ).
      end.

      else if vans = 9  or vans = 23 or vans = 28
      then do:

         /*(lon.grp <> 13 or lon.grp <> 23 or lon.grp <> 53 or lon.grp <> 63)*/
         if vans = 23 then next.
         if vans = 28 and lon.grp <> 95 then next.

         if vans = 9 then do: v-lev = 2. end.
         if vans = 23 then do: v-lev = 44. end.
         if vans = 28 then do: v-lev = 49. end.

           clear frame colhead all.
           v-amt1 = 0. v-amt2 = 0. v-amt3 = 0. v-amt4 = 0.
           run prc-sad(s-lon, vans, v-lev).
           j = 0.
           {functions-def.i}
          def stream m-out.
          output stream m-out to rpt.img.
          put stream m-out
          FirstLine( 1, 1 ) format "x(100)"skip(1)
          "                          "
          "КАРТОЧКА ПРОЦЕНТОВ "  skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + v-code format "x(100)" skip
          FirstLine( 2, 1 ) format "x(100)" skip.
          put stream m-out  fill( "-", 100 ) format "x(100)" skip.
          put stream m-out
          "С...     "
          "По...           "
          "Сумма      "
          "%став.  "
          "Начисл.%%  "
          "Транзакция "
          "Испол-ль  "
          "Дата        "
          "Оплачен.%% "
          "Транзакция "
          "Испол-ль "
          "Просроч.%% "
          "Списано    "
          skip.
          put stream m-out  fill( "-", 137 ) format "x(137)" skip.
          for each w-amk by w-amk.nr:
              put stream m-out
                w-amk.fdt " "
                w-amk.tdt " "
                w-amk.prn format (">,>>>,>>>,>>9.99") " "
                w-amk.rate format (">>9.99")
                w-amk.amt1 format("->,>>>,>>9.99") " "
                "           "
                "          "
                w-amk.dt " "
                w-amk.amt2 format ("->,>>>,>>9.99") " "
                w-amk.trx "   "
                w-amk.who format "x(8)" " ".
                if w-amk.amt3 <> 0 then put stream m-out w-amk.amt3 format ("->,>>>,>>9.99").
                else put stream m-out space(10).
                if w-amk.amt4 <> 0 then put stream m-out w-amk.amt4 format ("->,>>>,>>9.99") skip.
                else put stream m-out skip.
                v-amt1 = v-amt1 + w-amk.amt1.
                v-amt2 = v-amt2 + w-amk.amt2.
                v-amt3 = v-amt3 + w-amk.amt3.
                v-amt4 = v-amt4 + w-amk.amt4.
              delete w-amk.
          end.
          put stream m-out unformatted skip(1).

          for each lonres where lonres.lon = lon.lon and lonres.lev = v-lev no-lock:
            if lonres.dc = "d" and lonres.trx ne 'LON0066' then do:
              put stream m-out unformatted
                "         "
                lonres.jdt format "99/99/99" " "
                "                "
                "       "
                lonres.amt format("->,>>>,>>9.99") " "
                lonres.jh "   "
                lonres.who format "x(8)"
                skip.
              v-amt1 = v-amt1 + lonres.amt.
            end.
          end.

          find gl where gl.gl = lon.gl no-lock.
          put stream m-out  fill( "-", 137 ) format "x(137)"   skip.
          put stream m-out "      И Т О Г О :" .
          put stream m-out  v-amt1 format("->>>,>>>,>>9.99") at 40
                            v-amt2 format("->>>,>>>,>>9.99") at 84.
          if v-amt3 <> 0 then
             put stream m-out  v-amt3 format("->>,>>9.99").
          else put stream m-out space(10).
          if v-amt4 <> 0 then
             put stream m-out  v-amt4 format("->>,>>9.99").
          put stream m-out skip.
          output stream m-out close.
          if  not g-batch then do:
              pause 0 before-hide .
              run menu-prt( "rpt.img" ).
              pause before-hide.
          end.
          {functions-end.i}

     end.


     else if vans = 10 or vans = 11  or vans = 16
     then do:

          ssum1 = 0.
          ssum2 = 0.
          mlev = 0.
          s-title = ''.

          for each w-amk: delete w-amk. end.

          if vans = 10 then do:
             mlev = 13. s-title = "ОСНОВНОГО ДОЛГА".
          end.
          else do:
             mlev = 14. s-title = "ПРОЦЕНТОВ".
          end.
          if vans = 16 then do:
             mlev = 30. s-title = "ШТРАФОВ".
          end.

          for each lonres where lonres.lon = s-lon and lonres.lev = mlev no-lock:
            create w-amk.
            w-amk.nr = lonres.jh.
            w-amk.dt = lonres.jdt.
            w-amk.dc = lonres.dc.
            if lonres.dc = 'D' then do:
                f-acc = 0.
                f-note = "".
                find first jl where jl.jh = lonres.jh and jl.dam = lonres.amt no-lock no-error.
                if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.lev = 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] <> ""  then assign w-amk.acc = b-jl.gl w-amk.note =  b-jl.rem[4].
                    if avail b-jl and b-jl.rem[4] = ""  then assign w-amk.acc = b-jl.gl w-amk.note =  b-jl.rem[1].
                end.
                w-amk.amt1 = lonres.amt.
            end.
            if lonres.dc = 'C' then do:
                find first jl where jl.jh = lonres.jh and jl.cam = lonres.amt no-lock no-error.
                if avail jl then do:
                    find first b-jl where b-jl.jh = lonres.jh and b-jl.lev = 1 no-lock no-error.
                    if avail b-jl and b-jl.rem[4] <> ""  then assign w-amk.acc = b-jl.gl w-amk.note =  b-jl.rem[4].
                    if avail b-jl and b-jl.rem[4] = ""  then assign w-amk.acc = b-jl.gl w-amk.note =  b-jl.rem[1].
                end.
                w-amk.amt2 = lonres.amt.
            end.
          end.

          output stream m-out to rptm.img.
          find first cmp no-lock no-error.
          find first ofc where ofc.ofc = g-ofc no-lock no-error.
          put stream m-out string( today, "99/99/9999" ) ", " string( time, "HH:MM:SS" ) ", " cmp.name format "X(40)" skip
                     "Исполнитель: " ofc.name format "X(40)" skip(1)
                     "                 СПИСАНИЕ ЗА БАЛАНС " s-title format "X(20)" skip(1)
                     "Кредит: " + lon.lon format "x(100)" skip
                     "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
                     "Валюта: " + v-code format "x(100)" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          put stream m-out "Дата         Транзакция              Дебет             Кредит    Корр счет       Примечание" skip.
          put stream m-out  fill( "-", 150 ) format "x(150)" skip.
          v-amt1 = 0. v-amt2 = 0.
          for each w-amk by w-amk.dt:
              put stream m-out
                w-amk.dt format "99/99/9999" "   "
                w-amk.nr format ">>>>>>>>>9" "   "
                w-amk.amt1 format (">,>>>,>>>,>>9.99") "   "
                w-amk.amt2 format(">,>>>,>>>,>>9.99")
                w-amk.acc format "zzzzzzzzzz" "      "
                w-amk.note format "x(50)"
                skip.
              v-amt1 = v-amt1 + w-amk.amt1.
              v-amt2 = v-amt2 + w-amk.amt2.

              delete w-amk.
          end.
          put stream m-out fill( "-", 150 ) format "x(150)"   skip.
          put stream m-out "    И Т О Г О :" .
          put stream m-out v-amt1 format(">,>>>,>>>,>>9.99") at 27 "   "
                           v-amt2 format(">,>>>,>>>,>>9.99") skip.
          output stream m-out close.
          if  not g-batch then do:
              pause 0 before-hide.
              run menu-prt( "rptm.img" ).
              pause before-hide.
          end.
     end.


     else if vans = 12 or vans = 13
     then do:

          ssum1 = 0.
          ssum2 = 0.
          mlev = 0.
          s-title = ''.

          for each w-amk: delete w-amk. end.

          if vans = 12 then do:
             mlev = 20. s-title = "ОСНОВНОГО ДОЛГА".
          end.
          else do:
             mlev = 22. s-title = "ПРОЦЕНТОВ".
          end.
          for each lonres where lonres.lon = s-lon and lonres.lev = mlev no-lock:
            create w-amk.
            w-amk.nr = lonres.jh.
            w-amk.dt = lonres.jdt.
            w-amk.dc = lonres.who.
            if lonres.dc = 'D' then w-amk.amt1 = lonres.amt.
            if lonres.dc = 'C' then w-amk.amt2 = lonres.amt.
          end.

          output stream m-out to rptm.img.
          find first cmp no-lock no-error.
          find first ofc where ofc.ofc = g-ofc no-lock no-error.
          put stream m-out string( today, "99/99/9999" ) ", " string( time, "HH:MM:SS" ) ", " cmp.name format "X(40)" skip
                     "Исполнитель: " ofc.name format "X(40)" skip(1)
                     "                  ПОГАШЕНИЕ ИНДЕКС. " s-title format "X(20)" skip(1)
                     "Кредит: " + lon.lon format "x(20)" skip
                     "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(60)" skip
                     "Валюта: " + v-code format "x(20)" skip.
          put stream m-out  fill( "-", 100 ) format "x(80)" skip.
          put stream m-out "Дата                    Дебет             Кредит   Транзакция  Исполнитель" skip.
          put stream m-out  fill( "-", 100 ) format "x(80)" skip.
          v-amt1 = 0. v-amt2 = 0.
          for each w-amk by w-amk.dt:
              put stream m-out
                w-amk.dt format "99/99/9999" "   "
                w-amk.amt1 format (">,>>>,>>>,>>9.99") "   "
                w-amk.amt2 format(">,>>>,>>>,>>9.99") "   "
                w-amk.nr format ">>>>>>>>>9" "    "
                w-amk.dc format "x(9)" skip.
              v-amt1 = v-amt1 + w-amk.amt1.
              v-amt2 = v-amt2 + w-amk.amt2.
              delete w-amk.
          end.
          put stream m-out fill( "-", 100 ) format "x(80)"   skip.
          put stream m-out "И Т О Г О :" .
          put stream m-out v-amt1 format(">,>>>,>>>,>>9.99") at 14 "   "
                           v-amt2 format(">,>>>,>>>,>>9.99") skip.
          output stream m-out close.
          if  not g-batch then do:
              pause 0 before-hide.
              run menu-prt( "rptm.img" ).
              pause before-hide.
          end.
     end.


     else if vans = 14
     then do:
         v-dbt = 0.
         /* v-crt = 0. */
         output stream m-out to rpt.img.
         put stream m-out unformatted
             "    "
             "Полученная комиссия за обслуживание кредита"  skip(1)
             "Кредит: " + lon.lon format "x(100)" skip
             "Т.счет: " + lon.aaa format "x(100)" skip
             "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
             "Валюта: " + crc.code format "x(100)" skip.

         put stream m-out unformatted fill( "-", 150 ) format "x(150)" skip.
         put stream m-out unformatted
             "   Дата    "
             "             Сумма"
             "  Транзакция"
             " Исполнитель" skip.
         put stream m-out unformatted fill( "-", 100 ) format "x(150)" skip.

         for each jl where jl.acc = lon.aaa and jl.dc = 'D' no-lock:
            find first jh where jh.jh = jl.jh no-lock no-error.
            if not avail jh then next.
            if jh.party begins 'Storn' then next.
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
            if b-jl.gl = 460712 then do:
                v-dbt = v-dbt + jl.dam.
                put stream m-out unformatted
                    jl.jdt format "99/99/9999" " "
                    jl.dam format "zzz,zzz,zzz,zz9.99" " "
                    jl.jh format "zzzzzzzzzz9" " "
                    jl.who skip.
            end.
         end.

         find first aaa where aaa.aaa20 = lon.aaa no-lock no-error.
         if avail aaa then do:
             for each jl where jl.acc = aaa.aaa and jl.dc = 'D' no-lock:
                find first jh where jh.jh = jl.jh no-lock no-error.
                if not avail jh then next.
                if jh.party begins 'Storn' then next.
                find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                if b-jl.gl = 460712 then do:
                    v-dbt = v-dbt + jl.dam.
                    put stream m-out unformatted
                        jl.jdt format "99/99/9999" " "
                        jl.dam format "zzz,zzz,zzz,zz9.99" " "
                        jl.jh format "zzzzzzzzzz9" " "
                        jl.who + "'" skip.
                end.
             end.
         end.

         put stream m-out unformatted skip(1) "   Итого   " v-dbt format "zzz,zzz,zzz,zz9.99" skip.

       output stream m-out close.
       run menu-prt( "rpt.img" ).
     end.


    else if vans = 15
    then do:
         v-dbt = 0.
         v-crt = 0.
         for each t-lon. delete t-lon. end.
         output stream m-out to rpt.img.
          put stream m-out
          "    "
          "Штрафы "  skip
          "    (5 ур.)" skip(1)
          "Кредит: " + lon.lon format "x(100)" skip
          "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
          "Валюта: " + crc.code format "x(100)" skip.

          put stream m-out  fill( "-", 100 ) format "x(80)" skip.
          put stream m-out
          "   Дата    "
          "              Дебет"
          "                Кредит"
          skip.
          put stream m-out  fill( "-", 100 ) format "x(80)" skip.

          v-dam = 0. v-cam = 0.
          for each histrxbal where histrxbal.sub = 'lon' and histrxbal.acc = lon.lon and histrxbal.lev = 5 no-lock.
              if histrxbal.dam > 0 or histrxbal.cam > 0 then do:
                 create t-lon.
                 assign t-lon.dt = histrxbal.dt  t-lon.dam = histrxbal.dam - v-dam t-lon.cam = histrxbal.cam - v-cam.
                 v-dbt = v-dbt + histrxbal.dam - v-dam.  v-crt = v-crt + histrxbal.cam - v-cam.
                 assign v-dam = histrxbal.dam v-cam = histrxbal.cam.
              end.
          end.

          for each t-lon.
            put stream m-out
               t-lon.dt  t-lon.dam format '->>,>>>,>>>,>>>,>>9.99' t-lon.cam format '->>,>>>,>>>,>>>,>>9.99'  skip.
          end.

          put stream m-out skip(1) '  Итого    ' v-dbt '   ' v-crt skip.

          v-dbt = 0.
          v-crt = 0.
          put stream m-out unformatted skip(2) fill( "-", 150 ) format "x(150)" skip.
          put stream m-out unformatted " Дата       Тип              Дебет           Кредит    Транзакция Логин  Корр счет   Примечание " skip.
          put stream m-out unformatted fill( "-", 150 ) format "x(150)" skip.

          for each lonres where lonres.lon = lon.lon and lonres.lev = 5 no-lock:
              if lonres.dc = "d" then do:
                      f-acc = 0.
                      f-note = "".
                      find first jl where jl.jh = lonres.jh and jl.dam = lonres.amt and jl.lev = 5 no-lock no-error.
                      if avail jl then do:
                        find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
                        if avail b-jl  then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                      end.
                      v-dbt = v-dbt + lonres.amt.
               end.
               else do:
                    v-crt = v-crt + lonres.amt.
                    f-acc = 0.
                    f-note = "".
                    find first jl where jl.jh = lonres.jh and jl.cam = lonres.amt and jl.lev = 5 no-lock no-error.
                    if avail jl then do:
                        find first b-jl where b-jl.jh = lonres.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
                        if avail b-jl  then assign f-acc = b-jl.gl f-note =  b-jl.rem[1].
                    end.
                end.
               put stream m-out unformatted
                   " " lonres.jdt format "99/99/9999" " "
                   if lonres.lev = 5 then "Внеc." else "     " " "
                   if lonres.dc = "d" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   if lonres.dc = "c" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   lonres.jh format 'z,zzz,zzz,zz9' " "
                   lonres.who format "x(7)"
                   f-acc format "zzzzzzzzzz" "      "
                   f-note format "x(50)" skip.

          end.

          put stream m-out unformatted skip(1) '  Итого           ' v-dbt format 'z,zzz,zzz,zz9.99' " " v-crt format 'z,zzz,zzz,zz9.99' skip.

          output stream m-out close.
          run menu-prt( "rpt.img" ).
    end.
    else if vans = 17
    then do:
        output stream m-out to rpt.img.
        put stream m-out unformatted
              "    "
              "Комиссия по годовой ставке"  skip(1)
              "Кредит: " + lon.lon format "x(100)" skip
              "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
              "Валюта: " + crc.code format "x(100)" skip(1).

        put stream m-out unformatted "Автоматическое начисление" skip.
        put stream m-out unformatted fill( "-", 100 ) format "x(80)" skip.
        put stream m-out unformatted "С...     По...           СуммаОД Ставка  Начислено Испол-ль" skip.
        put stream m-out unformatted fill( "-", 100 ) format "x(80)" skip.
        for each lonsres where lonsres.lon = lon.lon and lonsres.restype = "a" no-lock:
             put stream m-out unformatted
                lonsres.fdt format "99/99/99" " "
                lonsres.tdt format "99/99/99" " "
                lonsres.od format "zzz,zzz,zz9.99" " "
                lonsres.prem format "zz9.99" " "
                lonsres.amt format "zzz,zz9.99" " "
                lonsres.who format "x(8)" skip.
        end.

        put stream m-out unformatted skip(1) "Прочие операции (m-доначисление s-списание p-погашение)" skip.
        put stream m-out unformatted fill( "-", 100 ) format "x(80)" skip.
        put stream m-out unformatted "Дата     Т        СуммаОД Ставка      Сумма Испол-ль" skip.
        put stream m-out unformatted fill( "-", 100 ) format "x(80)" skip.
        for each lonsres where lonsres.lon = lon.lon and lonsres.restype <> "a" no-lock:
            put stream m-out unformatted
                lonsres.fdt format "99/99/99" " "
                lonsres.restype format "x" " "
                lonsres.od format "zzz,zzz,zz9.99" " "
                lonsres.prem format "zz9.99" " "
                lonsres.amt format "zzz,zz9.99" " "
                lonsres.who format "x(8)" skip.
        end.

        output stream m-out close.
        run menu-prt( "rpt.img").
    end.
    else if vans = 18
    then do:
        output stream m-out to rpt.img.
        put stream m-out
            "    "
            "Кредит: " + lon.lon format "x(100)" skip
            "Клиент: " + lon.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(100)" skip
            "Валюта: " + crc.code format "x(100)" skip.

        do i = 1 to 2:
            if i = 1 then mlev = 15.
            else mlev = 35.

            put stream m-out unformatted skip(1)
                if i = 1 then "Остаток возобн. КЛ (15 ур.)" else "Остаток невозобн. КЛ (35 ур.) " skip
                fill( "-", 100 ) format "x(80)" skip.

            put stream m-out
                "   Дата    "
                "            Дебет"
                "           Кредит"
                "  Сс.счет "
                "    Транзакция"
                " Исполнитель"
            skip.
            put stream m-out  fill( "-", 100 ) format "x(80)" skip.

            v-dbt = 0.
            v-crt = 0.
            for each lonres where lonres.lon = lon.lon and lonres.lev = mlev no-lock:
               find first jh where jh.jh = lonres.jh no-lock no-error.
               put stream m-out unformatted
                   " " lonres.jdt format "99/99/9999" " "
                   if lonres.dc = "d" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   if lonres.dc = "c" then string(lonres.amt,'z,zzz,zzz,zz9.99') else fill(" ",16) " "
                   if avail jh then string(jh.ref,"x(9)") else fill(" ",9) " "
                   lonres.jh format 'z,zzz,zzz,zz9' " "
                   lonres.who format "x(7)"  skip.
               if lonres.dc = "d" then v-dbt = v-dbt + lonres.amt.
               else v-crt = v-crt + lonres.amt.
            end.

            put stream m-out unformatted skip(1) '  Итого     ' v-dbt format 'z,zzz,zzz,zz9.99' " " v-crt format 'z,zzz,zzz,zz9.99' skip.
        end.

        output stream m-out close.
        run menu-prt( "rpt.img" ).
    end.
    else
    if vans = 19 or vans = 26 or vans = 31 then do:
      if vans = 26 then next.
      if vans = 31 and lon.grp <> 95 then next.

      run lnrptprc.
    end.
    else do:
    if vans = 20 or vans = 27 or vans = 32 then
      if vans = 27 then next.
      if vans = 32 and lon.grp <> 95 then next.

      run lnrptprc9.
    end.


 end. /* inner */

