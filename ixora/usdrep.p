/* usdrep.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*usdrep.p - usd*/
{mainhead.i}

define variable iffirst as logical.
define variable i as integer.
def var valuta as int.
def var j as int.
def var k as int.
def var n as int.
define variable vmonth as character.
define variable vyear as character.
define variable ddate as date.
define variable adate as date.
def var bdate as int.
def var kdate as date.
define new shared variable ndate as date extent 31.
define variable iday as integer initial 1.
define variable lastday as integer.
def var repmon as int.
def var repday as int.
define buffer baab for aab.
def var onerate as deci format "zzz,zzz.9999".
def var ninrate as deci format "zzz,zzz.9999".
def var ost like aab.bal.
def var tso like aab.bal.
def var sto like aab.bal.
def var wtal like aab.bal extent 31.
def var wbal like aab.bal extent 31.
def new shared var nbal like aab.bal extent 31.
def new shared var wsum like aab.bal extent 31.
def var fsum like aab.bal.
def new shared var nsum like aab.bal extent 31.
def var rkbatl like aab.bal.
def var filatl like aab.bal.
def new shared var citatl like aab.bal.
def var asatl like aab.bal.
def var atlik like aab.bal.
def var c-sped as int.
def var pper as char.
def var ppor as char.
def var ppa as int.
def var ppb as int.
def var ppc as int.
def var ppd as int.
def var ppe as int.
def var ppf as int.
def var ppg as int.
def var pph as int.
def var sych as char.
def var syct as char.
def var pi as int init 0.
def var po as int init 0.
def var nnn like aab.bal.
def new shared var cit11 like aab.bal.
def new shared var cit12 like aab.bal.
def new shared var cit13 like aab.bal .
def new shared var nsum11 like aab.bal extent 31.
def new shared var nsum12 like aab.bal extent 31.
def new shared var nsum13 like aab.bal extent 31.

define new shared temp-table wfil
    field wcif like cif.cif
    field wloro like aab.bal label "LORO" extent 31
    field watl like aab.bal
    field wcrc like crc.crc.

define new shared temp-table nfil
    field ncif like cif.cif
    field ncitl like aab.bal extent 31
    field ngeo like cif.geo
    field natl like aab.bal
    field ncrc like crc.crc.

def new shared temp-table ffil
    field fcif like cif.cif
    field fatlik like aab.bal
    field fdaysum like aab.bal extent 31.

def new shared temp-table sfil
    field scif like cif.cif
    field sgeo like cif.geo
    field satl like aab.bal
    field satlik like aab.bal
    field sdaysum like aab.bal extent 31.

{image1.i rpt.img}


find sysc where sysc.sysc = "SPEDAR" no-lock no-error.
    if not available sysc then do:
        message 'Ievadiet citu banku FOREX darЁjumus konta numuru'.
    end.
    else do:
        c-sped = sysc.inval.
    end.


find sysc where sysc.sysc EQ "RMDFBG" no-lock no-error.
if not available sysc then do:
   message "Ievadiet nostro konta numuru.".
   return.
end.
else do:
    /*ppa = sysc.inval.*/
    sych = sysc.chval.
end.
repeat:
    pi = pi + 1.
    pper = substring(sych,1,index(sych,",") - 1).
    if pi = 1 then ppa = integer(pper).
    if pi = 2 then ppb = integer(pper).
    if pi = 3 then ppc = integer(pper).
    if pi = 4 then ppd = integer(pper).
    sych = substring(sych,index(sych,",") + 1,length(sysc.chval)).
    if sych = "" then leave.
end.


find sysc where sysc.sysc EQ "SAUZPI" no-lock no-error.
if not available sysc then do:
   message "Ievadiet saist. konta numuru.".
   return.
end.
else do:
    syct = sysc.chval.
end.
repeat:
    po = po + 1.
    ppor = substring(syct,1,index(syct,",") - 1).
    if po = 1 then ppe = integer(ppor).
    if po = 2 then ppf = integer(ppor).
    if po = 3 then ppg = integer(ppor).
    if po = 4 then pph = integer(ppor).
    syct = substring(syct,index(syct,",") + 1,length(sysc.chval)).
    if syct = "" then leave.
end.

vmonth = string (month(today) ).
vyear  = string (year (today) ).

update vmonth label "MЁNESIS" vyear label "GADS"
    with row 10 side-labels no-box overlay centered.

ddate = date ( integer(vmonth), iday, integer(vyear) ).
lastday = day ( {monthend.i "(ddate)"} ) - 1 .

repmon = month(g-today).
repday = day(g-today).

if repmon eq integer(vmonth) and repday lt lastday then do:
    lastday = repday.
end.

hide all.
adate = ddate.

{image2.i}
{report1.i 180}
vtitle = "LORO RЁґINU IZEJO№IE ATLIKUMI - USD".
{report2.i 180}
put skip.
for each cif where cif.cgr eq 410 no-lock:
    
    /* один филиал */
    for each aaa where aaa.cif eq cif.cif and aaa.crc eq 2 /*use-index cif*/
        and substring(aaa.aaa,1,3) < "200" no-lock:
        adate = ddate.

        DO i = 1 to lastday:
            ndate[i] = adate.

            find first wfil where wfil.wcif eq aaa.cif and wfil.wcrc eq aaa.crc
            no-error.
            if not available wfil then do:
                create wfil.
                wfil.wcif = aaa.cif.
                wfil.wcrc = aaa.crc.
            end.
            find last aab where aab.aaa eq aaa.aaa and aab.fdt le
            ndate[i] no-lock no-error.
            if available aab then do:
                wfil.wloro[i] = aab.bal.
                wfil.watl = wfil.watl + wfil.wloro[i].
            end.
            if repmon eq integer(vmonth) and ndate[i] ge g-today then
            wfil.wloro[i] = 0.
            adate = adate + 1.

        END.
    end.       /*aaa*/
end.    /*cif*/


adate = ddate.

DO i = 1 to lastday:
ndate[i] = adate.

    for each crc where crc.crc eq 2:
    find last  glday where glday.gdt le ndate[i]
        and glday.gl eq ppa and glday.crc = crc.crc /*132100*/ no-lock no-error.
                if available glday then do:
                        wbal[i] = wbal[i] + glday.bal.
                        ost = wbal[i].
                        kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wbal[i] = ost.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wbal[i] = 0.
    adate = adate + 1.
END.

/*в связи с переходом на нов.гл.книгу: sysc.sysc = "RMDFBG"*/
if ppb <> ppa then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
        and glday.gl eq ppb  and glday.crc = crc.crc 
        /*132050*/ no-lock no-error.
                if available glday then do:
                        wbal[i] = wbal[i] + glday.bal.
                        ost = wbal[i].
                        kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wbal[i] = ost.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wbal[i] = 0.
    adate = adate + 1.
END.
end.

if ppc <> ppa then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
        and glday.gl eq ppc  and glday.crc = crc.crc 
        /*132150*/ no-lock no-error.
                if available glday then do:
                        wbal[i] = wbal[i] + glday.bal.
                        ost = wbal[i].
                        kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wbal[i] = ost.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wbal[i] = 0.
    adate = adate + 1.
END.
end.

if ppd <> ppa then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
        and glday.gl eq ppd  and glday.crc = crc.crc 
        /*137250*/ no-lock no-error.
                if available glday then do:
                        wbal[i] = wbal[i] + glday.bal.
                        ost = wbal[i].
                        kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wbal[i] = ost.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wbal[i] = 0.
    adate = adate + 1.
END.
end.
/************************************************************************/
/*sysc.sysc = "SAUZPI"*/
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
        and glday.gl eq ppe /*412400*/ and glday.crc = crc.crc no-lock no-error.
                if available glday then do:
                    wtal[i] = wtal[i] + glday.bal.
                    tso = wtal[i].
                    kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wtal[i] = tso.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wtal[i] = 0.
    adate = adate + 1.
END.

if ppf <> ppe then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
    and glday.gl eq ppf /*413050*/ and glday.crc eq crc.crc no-lock no-error.
                if available glday then do:
                    wtal[i] = wtal[i] + glday.bal.
                    tso = wtal[i].
                    kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wtal[i] = tso.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wtal[i] = 0.
    adate = adate + 1.
END.
end.

if ppg <> ppe then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
    and glday.gl eq ppg /*413100*/ and glday.crc eq crc.crc no-lock no-error.

                if available glday then do:
                    wtal[i] = wtal[i] + glday.bal.
                    tso = wtal[i].
                    kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wtal[i] = tso.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wtal[i] = 0.
    adate = adate + 1.
END.
end.

if pph <> ppe then do:
adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:

    find last glday where glday.gdt le ndate[i] and glday.gl eq pph
    /*413150*/ and glday.crc eq crc.crc  no-lock no-error.

                if available glday then do:
                    wtal[i] = wtal[i] + glday.bal.
                    tso = wtal[i].
                    kdate = ndate[i].
                end.
    end.
    if adate ne kdate then wtal[i] = tso.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        wtal[i] = 0.
    adate = adate + 1.
END.
end.

adate = ddate.
DO i = 1 to lastday:
ndate[i] = adate.
    for each crc where crc.crc eq 2:
    find last glday where glday.gdt le ndate[i]
        and glday.gl eq c-sped /*412410->417150*/  and glday.crc = crc.crc
        no-lock no-error.

                if available glday then do:
                    nbal[i] = nbal[i] + glday.bal.
                    sto = nbal[i].
                    kdate = ndate[i].
                end.
    end.
    if adate ne kdate then nbal[i] = sto.
    if repmon eq integer(vmonth) and ndate[i] ge g-today then
        nbal[i] = 0.
    adate = adate + 1.
END.

/*******************************************************/
for each wfil break by wfil.wcif:
    DO i = 1 to lastday:
        find first ffil where ffil.fcif eq wfil.wcif no-error.
        if not available ffil then do:
            create ffil.
            ffil.fcif = wfil.wcif.
        end.
        wsum[i] =  wsum[i] + wfil.wloro[i].
        ffil.fdaysum[i] = ffil.fdaysum[i] + wfil.wloro[i].
        ffil.fatlik = ffil.fatlik + wfil.wloro[i].
    END.
end.

/*citas bankas*/
for each cif where cif.cgr eq 407 no-lock:
    /*viena banka*/
    for each aaa where aaa.cif eq cif.cif and aaa.crc eq 2
        and substring(aaa.aaa,1,3) < "200" no-lock:
            adate = ddate.
            DO i = 1 to lastday:
                ndate[i] = adate.

                find first nfil where nfil.ncif eq aaa.cif and nfil.ngeo eq
                    cif.geo and nfil.ncrc eq aaa.crc no-error.

                if not available nfil then do:
                    create nfil.
                    nfil.ncif = aaa.cif.
                    nfil.ngeo = cif.geo.
                    nfil.ncrc = aaa.crc.
                end.

                find last aab where aab.aaa eq aaa.aaa and aab.fdt le
                    ndate[i] no-lock no-error.
                if available aab then do:
                    nfil.ncitl[i] = nfil.ncitl[i] + aab.bal.
                    nfil.natl = nfil.natl + nfil.ncitl[i].
                end.

                if repmon eq integer(vmonth) and ndate[i] ge g-today then
                    nfil.ncitl[i] = 0.
                adate = adate + 1.

            END.
    end. /*for each aaa*/
end. /*for each cif*/

for each nfil break by nfil.ncif:
    DO i = 1 to lastday:
        find first sfil where sfil.scif eq nfil.ncif no-error.
        if not available sfil then do:
            create sfil.
            sfil.scif = nfil.ncif.
            sfil.sgeo = nfil.ngeo.
            sfil.satl = nfil.natl.
        end.
        
        if 
        /*sfil.sgeo eq "11" */
        substring(string(integer(sfil.sgeo),"999"),2) eq "11" then do:
            nsum11[i] = nsum11[i] + nfil.ncitl[i].
            cit11 = cit11 + nfil.ncitl[i].
        end.
        if 
        /*sfil.sgeo eq "12" */
         substring(string(integer(sfil.sgeo),"999"),2) eq "12" then do:
            nsum12[i] = nsum12[i] + nfil.ncitl[i].
            cit12 = cit12 + nfil.ncitl[i].
        end.
        if 
        /*sfil.sgeo eq "13" */
         substring(string(integer(sfil.sgeo),"999"),2) eq "13" then do:
            nsum13[i] = nsum13[i] + nfil.ncitl[i].
            cit13 = cit13 + nfil.ncitl[i].
        end.
        /*wsum[i] =  wsum[i] + wfil.wloro[i].  */
        sfil.sdaysum[i] = sfil.sdaysum[i] + nfil.ncitl[i].
       /* sfil.satlik = sfil.satlik + nfil.ncit[i].*/
        sfil.satlik = sfil.satlik + nsum11[i] + nsum12[i] + nsum13[i].
    END.
end.

iffirst = false.
adate = ddate.

put skip.
put "                              ".
   do k = 1 to 10:
       put ndate[k] "             ".
   end.
put skip.
/*put "RKB                 ".*/
  put "Nostro - loro       ".

    do n = 1 to 10:
        put  wbal[n] - wtal[n] format "z,zzz,zzz,zzz,zz9.99-".
        rkbatl = rkbatl + wbal[n] - wtal[n].
    end.
put skip(1).

  put "Kop– fili–les(loro) ".
do n = 1 to 10:
    put wsum[n].
    filatl = filatl + wsum[n].
end.
put skip(1).

run cie(input 1, input 10).
put skip.
/*put "A/S RKB             ".*/
  put "132050+132100+132150".
do n = 1 to 10:
    put (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n])
        format "z,zzz,zzz,zzz,zz9.99-".
    asatl = asatl + (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n]).
    nnn = nnn + nbal[n].
end.
put skip.
put "      (Nostro)" skip.
put skip(2).

put "                              ".
do k = 11 to 20:
    put ndate[k] "             ".
end.
put skip.
/*put "RKB                 ".*/
  put "Nostro - loro       ".

do n = 11 to 20:
    put wbal[n] - wtal[n] format "z,zzz,zzz,zzz,zz9.99-".
    rkbatl = rkbatl + wbal[n] - wtal[n].
end.
put skip(1).

put "Kop– fili–les(loro) ".
do n = 11 to 20:
    put wsum[n].
    filatl = filatl + wsum[n].
end.
put skip(1).

run cie(input 11, input 20).
put skip.
/*put "A/S RKB             ".*/
  put "132050+132100+132150".

do n = 11 to 20:
    put (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n])
        format "z,zzz,zzz,zzz,zz9.99-".
    asatl = asatl + (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n]).
    nnn = nnn + nbal[n].
end.
put skip.
put "      (Nostro)" skip.
put skip(2).

put "                              ".
do k = 21 to 30:
    put ndate[k] "             ".
end.
put skip.

/*put "RKB                 ".*/
  put "Nostro - loro       ".

do n = 21 to 30:
    put wbal[n] - wtal[n] format "z,zzz,zzz,zzz,zz9.99-".
    rkbatl = rkbatl + wbal[n] - wtal[n].
end.
put skip(1).

put "Kop– fili–les(loro) ".
do n = 21 to 30:
    put wsum[n].
    filatl = filatl + wsum[n].
end.
put skip(1).

run cie(input 21, input 30).
put skip.
/*put "A/S RKB             ".*/
  put "132050+132100+132150".

do n = 21 to 30:
    put (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n])
        format "z,zzz,zzz,zzz,zz9.99-".
    asatl = asatl + (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n]).
    nnn = nnn + nbal[n].
end.
put skip.
  put "      (Nostro)" skip.
put skip(2).

IF lastday gt 30 then do:
put "                              ".
do k = 31 to lastday:
    put ndate[k] "             ".
    put "vidёjais atlik.".
end.
put skip(1).
/*put "RKB                 ".*/
  put "Nostro - loro       ".

    do n = 31 to lastday:
        put wbal[n] - wtal[n] format "z,zzz,zzz,zzz,zz9.99-".
        rkbatl = rkbatl + wbal[n] - wtal[n].
        put rkbatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
    end.
put skip(1).

put "Kop– fili–les(loro) ".
do n = 31 to lastday:
    put wsum[n].
    filatl = filatl + wsum[n].
end.
put skip(1).

for each ffil break by ffil.fcif:
    if first-of (ffil.fcif) then do:
        put skip.
        find cif where cif.cif eq ffil.fcif no-lock no-error.
        put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
        iffirst = true.
    end.
    do j = 31 to lastday:
        put ffil.fdaysum[j].
        put ffil.fatlik / lastday format "z,zzz,zzz,zzz,zz9.99-".
    end.
end.
put skip(2).
put "Citas bankas(loro)  ".
do n = 31 to lastday:
    put nsum11[n] + nsum12[n] + nsum13[n] - nbal[n]
        format "z,zzz,zzz,zzz,zz9.99-".
    citatl = citatl + nsum11[n] + nsum12[n] + nsum13[n] - nbal[n].
    put citatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
    /*nnn = nnn + nbal[n].*/
end.
put skip(1).
run cie(input 31, input lastday).
/*****************/
/*сюда вставить перечень всех др.банков:11-Латв.,12-др.банки,13-банки ОЕСД*/

put "Latv.banku loro k.  ".
do n = 31 to lastday:
    put nsum11[n].
    put cit11 / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).
for each sfil where 
/*sfil.sgeo eq "11"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "11" 
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
    do j = 31 to lastday:
        put sfil.sdaysum[j].
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
    end.
end.
put skip(1).

put "OECD v.banku loro k.".
do n = 31 to lastday:
    put nsum13[n].
    put cit13 / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).
for each sfil where 
/*sfil.sgeo eq "13"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "13" 
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
    do j = 31 to lastday:
        put sfil.sdaysum[j].
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
    end.
end.
put skip(1).

put "Citu v.banku loro k.".
do n = 31 to lastday:
    put nsum12[n] /*- nbal[n]*/.
    put (cit12 /*- nnn*/) / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).
for each sfil where 
/*sfil.sgeo eq "12"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "12" 
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
    do j = 31 to lastday:
        put sfil.sdaysum[j].
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
    end.
end.
put skip(1).
/********************/
/*put "A/S RKB             ".*/
  put "132050+132100+132150".

do n = 31 to lastday:
    put (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n])
        format "z,zzz,zzz,zzz,zz9.99-".
    asatl = asatl + (wbal[n] - wtal[n]) + wsum[n] +
        (nsum11[n] + nsum12[n] + nsum13[n] - nbal[n]).
    put asatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).
END.  /*больше 30 дней в месяце*/
ELSE DO:
put "                              ".
put "vidёjais atlik.".
put skip(1).
/*put "RKB                 ".*/
  put "Nostro - loro       ".

put rkbatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).

put "Kop– fili–les(loro) ".
put filatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).
for each ffil break by ffil.fcif:
    if first-of (ffil.fcif) then do:
        put skip.
        find cif where cif.cif eq ffil.fcif no-lock no-error.
        put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
        iffirst = true.
    end.
    put ffil.fatlik / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip.
put skip(2).
put "Citas bankas(loro)  ".
put citatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).
/**********************************************************************/
/*сюда вставить перечень всех др.банков:11-Латв.,12-др.банки,13-банки ОЕСД*/

put "Latv.banku loro k.  ".
    put cit11 / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).
for each sfil where 
/*sfil.sgeo eq "11"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "11" 
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).

put "OECD v.banku loro k.".
    put cit13 / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).
for each sfil where 
/*sfil.sgeo eq "13"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "13" 
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).

put "Citu v.banku loro k.".
    put (cit12 - nnn) / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip(1).
for each sfil where 
/*sfil.sgeo eq "12"*/
    substring(string(integer(sfil.sgeo),"999"),2) eq "12"
    break by sfil.scif:

        if first-of (sfil.scif) then do:
            put skip.
            find cif where cif.cif eq sfil.scif no-lock no-error.
            put trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)".
            iffirst = true.
        end.
        put sfil.satl / lastday format "z,zzz,zzz,zzz,zz9.99-".
end.
put skip(1).


/**********************************************************************/
put skip(1).
/*put "A/S RKB             ".*/
  put "132050+132100+132150".

put asatl / lastday format "z,zzz,zzz,zzz,zz9.99-".
put skip.
  put "      (Nostro)" skip.
put skip. 
END.

{report3.i}
{image3.i}
