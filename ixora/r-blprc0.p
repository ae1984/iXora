/* r-blprc0.p
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
        31/12/99 pragma
 * CHANGES
*/

/*---------------------------------------------------------------------------
   Procenty na datu - Juris Omuls
----------------------------------------------------------------------------*/
/* изменения от 12.05.2000 */
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{mainhead.i}
{r-blprc.f}.
define variable cifi      as character format "x(6)".
define variable ligumi    as character format "x(10)".
define variable krediti   as character format "x(10)".
define variable debetsp   as decimal format '->,>>>,>>9.99'.
define variable kreditsp  as decimal format '->,>>>,>>9.99'.
define variable kopa-lig  as decimal format '->,>>>,>>9.99'.
define variable kopa-ligs as decimal format '->,>>>,>>9.99'.
define variable kopa-ligp as decimal format '->,>>>,>>9.99'.
define variable kopa-ligps as decimal format '->,>>>,>>9.99'.
define variable npk       as integer.
define variable ligums    as character.
define variable v-ligums  as character.
define variable vprem like lon.prem.
define variable bilance   as decimal format '->,>>>,>>9.99'.
define variable bilancep  as decimal format '->,>>>,>>9.99'.
define variable i         as integer.
define variable n         as integer.
define variable dn1       as integer.
define variable dn2       as decimal.
define variable v-name    as character.
define variable v-name1   as character.
def var v-rate            like crchis.rate[1].
def var pred              as decimal.
def var pr                as character init ' '.
define stream s1.
define stream s2.
grupa = 10.
valuta = 1.
datums = g-today.

update datums label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .
       if datums = g-today then run tb('Внимание!','День не закрыт.','Данные на текущий момент',string(datums)).

unix silent rm -f rpt.img.

repeat:
    display grupa valuta with down centered frame grupa.
    update grupa validate(can-find(longrp where longrp.longrp = grupa),'Нет такой группы кредитов. Загляните в справочник.')  
         valuta validate(can-find(crc where crc.crc = valuta),'Нет такого кода валюты. Загляните в справочник.')
         with frame grupa.
    display gaidiet no-label with frame grupa.
    if keyfunction(lastkey) eq "end-error" then leave.
    output stream s1 to rpt.img append.
    npk = 1.
    find longrp where longrp.longrp = grupa no-lock.
    put stream s1 skip.
    put stream s1
        skip
        head0 at 25
        datums
        '.'
        longrp.des ' '
        gr-nos grupa format 'zz9' '  '
        val-nos valuta format 'z9'.
        if valuta = 1
           then put stream s1 ' (тыс.тенге)' skip.
        else do:
          put stream s1 ' Курс:'.
          find last crchis where crchis.crc = valuta and crchis.rdt le datums
               no-lock .
          v-rate = crchis.rate[1].
          put stream s1 v-rate  format "zzz.99" skip.
        end.
    put stream s1 unformatted
        skip
        head[1].
    put stream s1 unformatted skip
        head[2].
    put stream s1 unformatted
        skip
        head[3]
        skip.
    output stream s2 to drb.1.
    n = 0.
    kopa-lig = 0.
    kopa-ligp = 0.
    kopa-ligs = 0.
    kopa-ligps = 0.
    for each lon where lon.grp = grupa and lon.crc = valuta no-lock:
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat le datums
             no-lock no-error.
        if not available ln%his
        then next.
        if ln%his.rdt > datums 
        then next.
        if lon.dam[1] = 0 and lon.gua <> "OD"
        then next.
        n = n + 1.
        cifi = lon.cif.                   /* клиент */
        ligumi = '?         '.
        krediti = lon.lon.                /* счет   */
        ligumi = ln%his.lcnt.             /* договор*/
        export stream s2
            cifi 
            ligumi
            krediti.
    end.
    output stream s2 close.
    unix silent sort -f drb.1 > drb.2.
    input stream s2 from drb.2 no-echo.
    v-ligums = ' '.
    npk = 1.
    cifs = ' '.
    repeat on endkey undo,leave:
        import stream s2 cifi ligumi krediti.
        find lon where lon.lon = krediti no-lock.
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat le datums
             no-lock.
        find cif where cif.cif = lon.cif no-lock.
        find gl where gl.gl = lon.gl no-lock.
        ligums = substring(ligumi,1,16).
        if ligums <> v-ligums or ligums = '?'  /* в рамках одного договора */
        then do:
             if i > 1 and ( kopa-lig <> 0 or kopa-ligp <> 0) then 
                put stream s1 skip
                if valuta = 1
                   then kopa-lig / 1000
                   else kopa-lig  format '->,>>>,>>9.99' at 70
                if valuta = 1
                   then kopa-ligp / 1000
                   else kopa-ligp format '->,>>>,>>9.99' at 117
                '***'.
             if valuta = 1 then do:
                kopa-ligs = kopa-ligs + round(kopa-lig / 1000,2).
                kopa-ligps = kopa-ligps + round(kopa-ligp / 1000,2).
             end.
             else do:
                kopa-ligs = kopa-ligs + kopa-lig .
                kopa-ligps = kopa-ligps + kopa-ligp. 
             end.
             kopa-lig = 0.
             kopa-ligp = 0.
             v-ligums = ligums.
             i = 0.
        end.
        i = i + 1.
        run atl-dat(lon.lon,datums,output bilance). /* остаток */                        
        if lon.gua = "OD"
        then do:
             find aaa where aaa.aaa = lon.lcr no-lock.
             vprem = aaa.rate.
             run pro-od(lon.lcr,date(month(datums),1,year(datums)),datums,
                        output debetsp).
             kreditsp = 0.
        end.
        else do:
             vprem = lon.prem.   /* %% ставка */
             debetsp =  0.
             kreditsp =  0.
             for each lnsci where lnsci.lni = lon.lon and lnsci.idat le datums
                 and lnsci.f0 > - 1 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
                 kreditsp = kreditsp + lnsci.paid-iv. /* погашенные %% */
                 /*kreditsp = round(kreditsp,2). */
             end.
             for each acr where acr.lon = lon.lon and acr.fdt le datums no-lock:
                 if acr.tdt < datums
                 then do:
                      run day-360(acr.fdt,acr.tdt,lon.basedy,
                                  output dn1,output dn2).
                 end.
                 else run day-360(acr.fdt,datums,lon.basedy,
                                  output dn1,output dn2).
                 debetsp = debetsp + acr.rate * dn1 *
                           acr.prn / 100 / lon.basedy. /* начисленные %% */
               /*     debetsp  = round(debetsp,2).*/
             end.
        end.
        vprem = ln%his.intrate.
        kopa-lig = kopa-lig + bilance.
        bilancep = debetsp - kreditsp.
        pr = ' '.
        if round(bilancep,2) = 0.01 then bilancep = 0.
        if bilancep < 0  then do:
           pred = 0.
           for each lonres where lonres.lon = lon.lon and lonres.jdt le datums                     and lonres.jdt ge 12/19/99 and lonres.lev eq 10 no-lock:
               if lonres.dc eq 'D ' then
                  pred = pred + lonres.amt.
               else 
                  pred = pred - lonres.amt.
           end.          
           if pred = 0 then do:
              bilancep = 0.
              pr = '*'.
           end.
              
        end.
        kopa-ligp = kopa-ligp + bilancep.
        if bilance <> 0 or round(bilancep,2) <> 0
        then do:
             if lon.cif <> cifs
             then do:
                  repeat while v-name1 <> "":
                     run rin-dal(input-output v-name1,output v-name,30).
                     put stream s1 skip v-name format "x(30)" at 29.
                  end.
                  v-name1 = trim(trim(cif.prefix) + " " + trim(cif.name)).
                  cifs = lon.cif.
             end.
             run rin-dal(input-output v-name1,output v-name,30).
             put stream s1
                 skip
                 npk format 'zz9' ' '
                 ligumi format 'x(16)' ' '
                 lon.cif ' '
                 v-name format 'x(30)' ' '
                 lon.lon .
             npk = npk + 1.
             put stream s1
                if valuta = 1
                then bilance / 1000
                else bilance
                format '->,>>>,>>9.99'
                vprem format 'zzzz9.99'
                if valuta = 1
                then debetsp / 1000  
                else debetsp
                format '->,>>>,>>9.99'
                if valuta = 1
                then kreditsp / 1000
                else kreditsp format '->,>>>,>>9.99'
                if valuta = 1
                then bilancep / 1000
                else bilancep format '->,>>>,>>9.99'
                pr .
        end.
    end.
    if valuta = 1 then do:
       kopa-ligs = kopa-ligs + round(kopa-lig / 1000,2).
       kopa-ligps = kopa-ligps + round(kopa-ligp / 1000,2).
    end.
    else do:
       kopa-ligs = kopa-ligs + kopa-lig.
       kopa-ligps = kopa-ligps + kopa-ligp.
    end.
    repeat while v-name1 <> "":
       run rin-dal(input-output v-name1,output v-name,30).
       put stream s1 skip v-name format "x(30)" at 29.
    end.
    put stream s1 unformatted skip
        head[1].
    put stream s1
        skip
        npk - 1   format 'zz9' 
        kopa-ligs 
        format '->>>,>>>,>>>,>>9.99' at 64
        kopa-ligps
        format '->>>,>>>,>>>,>>9.99' at 111.
    
    if valuta <> 1 then
        put stream s1 skip
            space (40)
            'в тенге '
            kopa-ligs * v-rate
            format '->>>,>>>,>>>,>>9.99' at 64
            kopa-ligps * v-rate
            format '->>>,>>>,>>>,>>9.99' at 111.
    put stream s1 skip(5).
    input stream s2 close.
    output stream s1 close.
end.
if  not g-batch then do:                                
    pause 0.
    run menu-prt( 'rpt.img' ).
end.
