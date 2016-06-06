/* r-atlval.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Общий отчет по остаткам валюты по пунктам
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


{mainhead.i}



def var v-dat as date label "ДАТА    ".
def var comprt as cha initial "prit  " format "x(10)" .
def var v-new as log  format "создать/продожить"  initial "Создать".
def var m-crc like crc.crc.
def var m-sumd as dec decimals 2.
def var m-sumk as dec decimals 2.
def var m-amtd as dec decimals 2.
def var m-amtk as dec decimals 2.
def var m-diff as dec decimals 2.
def var m-beg like glbal.bal.
def var m-end like glbal.bal.
def var p-bal like pglbal.bal.
def var m-cashgl like jl.gl.
def var vprint as logical.
def var dest as char.
def var punum like point.point.
def var v-point like point.point.
def var prizn as logical init false.
def var my-ofc like ofc.ofc.
def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then  m-cashgl = inval.

for each crc where crc.sts ne 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

dest = "prit".
{btl.f}
v-dat = g-today.
if not g-batch then do :
  update v-dat skip
           comprt label  "Команда " skip
                    v-new label "Создать(с)/продожить(п)"
                      with side-label row 5 centered frame dat .
                      
                      end.
                      else v-dat = g-today.
                      

punum = 0.
update punum with  row 12 no-box overlay frame im1.
 display "......Ж Д И Т Е ......."  with row 12 frame ww centered .

if v-new then do :
output to rpt.img.

if punum = 0 then do:
    for each point break by point.point:
        put skip.
        {atl.f}
        view frame a.
        if first-of(point.point) then do:
            put  skip(2)
            "Валюта Входящий остаток         Дебет  "
            "          Кредит  Исходящий остаток" skip
"--------------------------------------------------------------------------"
         skip.
        end.
    

        find first jl where jl.jdt = g-today  no-lock no-error.
        if available jl then do:
            for each jl  where jl.jdt = g-today  no-lock
            break by jl.crc by jl.jh by jl.ln :
                if first-of(jl.crc) then do:
                    find crc where crc.crc = jl.crc no-lock no-error.
                    m-sumd = 0. m-sumk = 0.
                end.
                if jl.gl = m-cashgl then do :
                    find jh where jh.jh = jl.jh no-lock no-error.
                    if available jh then do:
                        v-point = jh.point.
                        m-amtd = 0. m-amtk = 0.
                        if jl.dc eq "D" then do:
                            if v-point eq point.point then do:
                                m-amtd = jl.dam.
                                m-sumd = m-sumd + m-amtd.
                            end.
                        end.    
                        else do:
                            if v-point eq point.point then do:
                                m-amtk = jl.cam.
                                m-sumk = m-sumk + m-amtk.
                            end.
                        end.
                    end. /*available jh*/
                end. /*if jl.gl*/

                if last-of(jl.crc) then do:
                    find first cashf where cashf.crc = jl.crc.
                    cashf.dam = cashf.dam + m-sumd .
                    cashf.cam = cashf.cam + m-sumk .
                    m-diff = m-sumd - m-sumk.
                end.
            end.  /*each jl*/
        end.
        if last-of(point.point) then do:
            for each crc where crc.sts ne 9 no-lock:
                for each pglbal where pglbal.point = point.point and 
                pglbal.gl =  m-cashgl and pglbal.crc = crc.crc:
                    p-bal = p-bal + pglbal.bal.
                end.
                find first cashf where cashf.crc = crc.crc no-lock no-error.
                if p-bal <> 0 or cashf.dam <> 0 or cashf.cam <> 0 then do:
                    display crc.code p-bal format "z,zzz,zzz,zz9.99-"
                    cashf.dam format "z,zzz,zzz,zz9.99-"
                    cashf.cam format "z,zzz,zzz,zz9.99-"
                    (p-bal + (cashf.dam - cashf.cam)) 
                    format "z,zzz,zzz,zz9.99-" skip(1)
                    with no-label no-box.
                end.
                p-bal = 0.
            end.
        end. /*if last-of(point.point)*/
    end. /*for each point*/
end.  /*punum = 0*/

if punum <> 0 then do:
    put skip.
        {ctl.f}
            view frame c.
    put skip(2)
        "Валюта Входящий остаток         Дебет  "
        "          Кредит  Исходящий остаток" skip
"--------------------------------------------------------------------------"
         skip.
    

    find first jl where jl.jdt = g-today  no-lock no-error.
    if available jl then do:
        for each jl  where jl.jdt = g-today  no-lock
        break by jl.crc by jl.jh by jl.ln :
            if first-of(jl.crc) then do:
                find crc where crc.crc = jl.crc no-lock no-error.
                m-sumd = 0. m-sumk = 0.
            end.
            if jl.gl = m-cashgl then do :
            find jh where jh.jh = jl.jh no-lock no-error.
                if available jh then do:
                    v-point = jh.point.
                    m-amtd = 0. m-amtk = 0.
                    if jl.dc eq "D" then do:
                        if v-point eq punum then do:
                            m-amtd = jl.dam.
                            m-sumd = m-sumd + m-amtd.
                        end.
                    end.
                    else do:
                        if v-point eq punum then do:
                            m-amtk = jl.cam.
                            m-sumk = m-sumk + m-amtk.
                        end.
                    end.
                end. /*available jh*/
            end. /*find jh*/

            if last-of(jl.crc) then do:
                find first cashf where cashf.crc = jl.crc.
                cashf.dam = cashf.dam + m-sumd .
                cashf.cam = cashf.cam + m-sumk .
                m-diff = m-sumd - m-sumk.
            end.
        end.  /*each jl*/
    end.
 
    for each crc where crc.sts ne 9 no-lock:
        for each pglbal where pglbal.point = punum and pglbal.gl = 
        m-cashgl and pglbal.crc = crc.crc:
            p-bal = p-bal + pglbal.bal.
        end.
        find first cashf where cashf.crc = crc.crc no-lock no-error.
        if p-bal <> 0 or cashf.dam <> 0 or cashf.cam <> 0 then do:
            display crc.code p-bal format "z,zzz,zzz,zz9.99-"
            cashf.dam format "z,zzz,zzz,zz9.99-"
            cashf.cam format "z,zzz,zzz,zz9.99-"
            (p-bal + (cashf.dam - cashf.cam)) format "z,zzz,zzz,zz9.99-" skip(1)
            with no-label no-box.
        end.
        p-bal = 0.
    end.

end.  
  
put skip(1) "***********       Конец  документа      ***********" skip(2).
output close.
end.
if not g-batch then do :
pause 0.
unix value(comprt) rpt.img.
pause 0.
end.

